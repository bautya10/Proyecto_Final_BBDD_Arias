-- queries_for_analysis.sql (Puedes crear un archivo separado para vistas o incluirlas aquí)

USE tienda_online;

-- Vista 1: Productos con stock bajo (menos de 50 unidades)
CREATE OR REPLACE VIEW Vista_Productos_Stock_Bajo AS
SELECT
    id_producto,
    nombre_producto,
    stock,
    precio_unitario,
    nombre_categoria
FROM
    Productos p
JOIN
    Categorias c ON p.id_categoria = c.id_categoria
WHERE
    stock < 50
ORDER BY
    stock ASC;

-- Vista 2: Clientes VIP (aquellos que han gastado más de un cierto monto, ej. 500)
CREATE OR REPLACE VIEW Vista_Clientes_VIP AS
SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    c.email,
    SUM(p.total_pedido) AS gasto_total
FROM
    Clientes c
JOIN
    Pedidos p ON c.id_cliente = p.id_cliente
GROUP BY
    c.id_cliente, c.nombre, c.apellido, c.email
HAVING
    gasto_total > 500
ORDER BY
    gasto_total DESC;

-- Vista 3: Ventas detalladas por producto y cliente
CREATE OR REPLACE VIEW Vista_Ventas_Detalladas AS
SELECT
    pe.id_pedido,
    pe.fecha_pedido,
    cl.nombre AS nombre_cliente,
    cl.apellido AS apellido_cliente,
    pr.nombre_producto,
    dp.cantidad,
    dp.precio_al_comprar AS precio_unitario_venta,
    (dp.cantidad * dp.precio_al_comprar) AS subtotal_linea
FROM
    Pedidos pe
JOIN
    Clientes cl ON pe.id_cliente = cl.id_cliente
JOIN
    Detalle_Pedido dp ON pe.id_pedido = dp.id_pedido
JOIN
    Productos pr ON dp.id_producto = pr.id_producto;

-- Vista 4: Resumen de ventas diarias
CREATE OR REPLACE VIEW Vista_Resumen_Ventas_Diarias AS
SELECT
    DATE(fecha_pedido) AS fecha,
    COUNT(id_pedido) AS total_pedidos,
    SUM(total_pedido) AS ingresos_diarios
FROM
    Pedidos
WHERE
    estado_pedido = 'Completado'
GROUP BY
    DATE(fecha_pedido)
ORDER BY
    fecha ASC;

-- Vista 5: Productos más vendidos (por cantidad total)
CREATE OR REPLACE VIEW Vista_Productos_Mas_Vendidos AS
SELECT
    p.nombre_producto,
    c.nombre_categoria,
    SUM(dp.cantidad) AS cantidad_total_vendida
FROM
    Detalle_Pedido dp
JOIN
    Productos p ON dp.id_producto = p.id_producto
JOIN
    Categorias c ON p.id_categoria = c.id_categoria
GROUP BY
    p.nombre_producto, c.nombre_categoria
ORDER BY
    cantidad_total_vendida DESC
LIMIT 10; -- Top 10 productos

-- stored_procedures.sql

USE tienda_online;

-- Stored Procedure 1: SP_RegistrarNuevoPedido
DELIMITER $$
CREATE PROCEDURE SP_RegistrarNuevoPedido(
    IN p_id_cliente INT,
    IN p_id_metodo_pago INT,
    IN p_direccion_envio VARCHAR(255),
    IN p_ciudad_envio VARCHAR(100),
    IN p_pais_envio VARCHAR(100),
    IN p_productos_json JSON -- Se espera un JSON como '[{"id_producto": 1, "cantidad": 2}, {"id_producto": 3, "cantidad": 1}]'
)
BEGIN
    DECLARE v_id_pedido INT;
    DECLARE v_total_pedido DECIMAL(10, 2) DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    DECLARE v_json_length INT;
    DECLARE v_id_producto INT;
    DECLARE v_cantidad INT;
    DECLARE v_precio_unitario DECIMAL(10, 2);
    DECLARE v_stock_actual INT;

    -- Iniciar transacción para asegurar atomicidad
    START TRANSACTION;

    -- 1. Insertar el pedido principal
    INSERT INTO Pedidos (id_cliente, fecha_pedido, total_pedido, estado_pedido, id_metodo_pago, direccion_envio, ciudad_envio, pais_envio)
    VALUES (p_id_cliente, NOW(), 0, 'Pendiente', p_id_metodo_pago, p_direccion_envio, p_ciudad_envio, p_pais_envio);

    SET v_id_pedido = LAST_INSERT_ID(); -- Obtener el ID del pedido recién insertado

    -- 2. Procesar cada producto en el JSON
    SET v_json_length = JSON_LENGTH(p_productos_json);
    WHILE i < v_json_length DO
        SET v_id_producto = JSON_UNQUOTE(JSON_EXTRACT(p_productos_json, CONCAT('$[', i, '].id_producto')));
        SET v_cantidad = JSON_UNQUOTE(JSON_EXTRACT(p_productos_json, CONCAT('$[', i, '].cantidad')));

        -- Obtener precio y stock actual del producto
        SELECT precio_unitario, stock INTO v_precio_unitario, v_stock_actual
        FROM Productos WHERE id_producto = v_id_producto;

        -- Verificar si hay stock suficiente
        IF v_stock_actual < v_cantidad THEN
            ROLLBACK; -- Deshacer la transacción si no hay stock
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para uno o más productos.';
        END IF;

        -- Insertar en Detalle_Pedido
        INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad, precio_al_comprar)
        VALUES (v_id_pedido, v_id_producto, v_cantidad, v_precio_unitario);

        -- Actualizar el stock del producto
        UPDATE Productos SET stock = stock - v_cantidad WHERE id_producto = v_id_producto;

        -- Calcular el total del pedido
        SET v_total_pedido = v_total_pedido + (v_cantidad * v_precio_unitario);

        SET i = i + 1;
    END WHILE;

    -- 3. Actualizar el total_pedido en la tabla Pedidos
    UPDATE Pedidos SET total_pedido = v_total_pedido WHERE id_pedido = v_id_pedido;

    COMMIT; -- Confirmar la transacción
    SELECT v_id_pedido AS Nuevo_Pedido_ID, 'Pedido registrado exitosamente.' AS Mensaje;

END $$
DELIMITER ;


-- Stored Procedure 2: SP_ObtenerReporteVentasPorFecha
-- Obtiene un resumen de ventas para un rango de fechas dado.
DELIMITER $$
CREATE PROCEDURE SP_ObtenerReporteVentasPorFecha(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT
        DATE(p.fecha_pedido) AS Fecha,
        COUNT(DISTINCT p.id_pedido) AS Total_Pedidos,
        SUM(dp.cantidad) AS Total_Productos_Vendidos,
        SUM(dp.cantidad * dp.precio_al_comprar) AS Ingresos_Totales
    FROM
        Pedidos p
    JOIN
        Detalle_Pedido dp ON p.id_pedido = dp.id_pedido
    WHERE
        p.fecha_pedido BETWEEN p_fecha_inicio AND p_fecha_fin
        AND p.estado_pedido = 'Completado'
    GROUP BY
        DATE(p.fecha_pedido)
    ORDER BY
        Fecha;
END $$
DELIMITER ;

-- triggers.sql

USE tienda_online;

-- Trigger 1: TR_ActualizarStockDespuesDePedido
DELIMITER $$
CREATE TRIGGER TR_ActualizarStockDespuesDePedido
AFTER INSERT ON Detalle_Pedido
FOR EACH ROW
BEGIN
    UPDATE Productos
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;

    -- Opcional: Registrar si el stock llega a cero o negativo (aunque el SP ya lo valida)
    IF (SELECT stock FROM Productos WHERE id_producto = NEW.id_producto) <= 0 THEN
        INSERT INTO Log_Errores (mensaje_error, origen)
        VALUES (CONCAT('Alerta: Stock de producto ', NEW.id_producto, ' agotado o negativo después de pedido.'), 'TRIGGER_STOCK_UPDATE');
    END IF;
END $$
DELIMITER ;


-- Trigger 2: TR_LogCambioEstadoPedido
DELIMITER $$
CREATE TRIGGER TR_LogCambioEstadoPedido
AFTER UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    IF OLD.estado_pedido <> NEW.estado_pedido THEN
        INSERT INTO Log_Errores (mensaje_error, origen)
        VALUES (CONCAT('Cambio de estado para Pedido ID: ', NEW.id_pedido, ' de ', OLD.estado_pedido, ' a ', NEW.estado_pedido), 'TRIGGER_ESTADO_PEDIDO');
    END IF;
END $$
DELIMITER ;

-- functions.sql

USE tienda_online;

-- Funcion 1: FN_CalcularIngresoTotalCliente
-- Retorna el total de dinero gastado por un cliente específico.
DELIMITER $$
CREATE FUNCTION FN_CalcularIngresoTotalCliente(p_id_cliente INT)
RETURNS DECIMAL(10, 2)
READS SQL DATA
BEGIN
    DECLARE total_gastado DECIMAL(10, 2);
    SELECT SUM(total_pedido) INTO total_gastado
    FROM Pedidos
    WHERE id_cliente = p_id_cliente AND estado_pedido = 'Completado'; -- Solo pedidos completados
    RETURN IFNULL(total_gastado, 0); -- Si no hay pedidos, devuelve 0
END $$
DELIMITER ;


-- Funcion 2: FN_ObtenerNombreProducto
-- Retorna el nombre de un producto dado su ID.
DELIMITER $$
CREATE FUNCTION FN_ObtenerNombreProducto(p_id_producto INT)
RETURNS VARCHAR(255)
READS SQL DATA
BEGIN
    DECLARE nombre_prod VARCHAR(255);
    SELECT nombre_producto INTO nombre_prod
    FROM Productos
    WHERE id_producto = p_id_producto;
    RETURN IFNULL(nombre_prod, 'Producto No Encontrado');
END $$
DELIMITER ;