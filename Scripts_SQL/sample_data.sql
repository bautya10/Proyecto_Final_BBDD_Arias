-- sample_data.sql

USE tienda_online;

-- Insertar datos en Clientes
INSERT INTO Clientes (nombre, apellido, email, telefono, direccion, ciudad, pais, fecha_registro) VALUES
('Juan', 'Pérez', 'juan.perez@example.com', '1122334455', 'Av. Siempre Viva 123', 'Buenos Aires', 'Argentina', '2024-01-10 10:00:00'),
('Ana', 'García', 'ana.garcia@example.com', '1133445566', 'Alicia Garzon 456', 'Cordoba', 'Argentina', '2024-01-15 11:30:00'),
('Carlos', 'Ruiz', 'carlos.ruiz@example.com', '1144556677', 'Av. Cabildo 625', 'Mendoza', 'Argentina', '2024-02-01 09:00:00'),
('María', 'López', 'maria.lopez@example.com', '1155667788', 'Av. Reforma 101', 'Neuquén', 'Argentina', '2024-02-05 14:00:00'),
('Pedro', 'Sánchez', 'pedro.sanchez@example.com', '1166778899', 'Gran Vía 202', 'Entre Rios', 'Argentina', '2024-03-01 16:00:00');

-- Insertar datos en Categorias
INSERT INTO Categorias (nombre_categoria) VALUES
('Electrónica'),
('Ropa'),
('Libros'),
('Hogar'),
('Alimentos'),
('Deportes'),
('Belleza');

-- Insertar datos en Proveedores
INSERT INTO Proveedores (nombre_proveedor, contacto_proveedor, telefono_proveedor, email_proveedor) VALUES
('TechGlobal S.A.', 'Laura Gómez', '987654321', 'contacto@techglobal.com'),
('FashionTrends Ltd.', 'Marco Rossi', '123456789', 'info@fashiontrends.com'),
('BookWorm Inc.', 'Sofía Castro', '555123456', 'sales@bookworm.com'),
('HomeEssentials Co.', 'David Lee', '777888999', 'support@homeessentials.com');

-- Insertar datos en Metodos_Pago
INSERT INTO Metodos_Pago (nombre_metodo) VALUES
('Tarjeta de Crédito'),
('Tarjeta de Débito'),
('Transferencia Bancaria'),
('PayPal'),
('Efectivo (contra entrega)');

-- Insertar datos en Productos
INSERT INTO Productos (nombre_producto, descripcion, precio_unitario, stock, id_categoria, id_proveedor) VALUES
('Smartphone X', 'Último modelo de smartphone con cámara de alta resolución.', 799.99, 50, 1, 1),
('Laptop Gamer Pro', 'Laptop de alto rendimiento para juegos y diseño gráfico.', 1200.00, 20, 1, 1),
('Camiseta Algodón Básica', 'Camiseta unisex de algodón orgánico, varios colores.', 15.50, 200, 2, 2),
('Jeans Slim Fit Hombre', 'Jeans ajustados de mezclilla premium.', 45.00, 100, 2, 2),
('El Principito', 'Clásico de la literatura infantil.', 25.00, 80, 3, 3),
('Cafetera Express Deluxe', 'Cafetera automática para espressos y capuccinos.', 99.99, 30, 4, 4),
('Set de Sartenes Antiadherentes', 'Set de 3 sartenes de diferentes tamaños.', 60.00, 40, 4, 4),
('Manzanas Rojas Orgánicas (1kg)', 'Manzanas frescas y orgánicas.', 3.50, 150, 5, NULL), -- Asumimos que algunos alimentos pueden no tener proveedor en este set de datos
('Pelota de Fútbol Profesional', 'Balón oficial de fútbol de alta calidad.', 30.00, 75, 6, NULL),
('Crema Hidratante Facial', 'Crema de día con protección solar.', 20.00, 120, 7, NULL);

-- Insertar datos en Pedidos (asumiendo IDs generados)
INSERT INTO Pedidos (id_cliente, fecha_pedido, total_pedido, estado_pedido, id_metodo_pago, direccion_envio, ciudad_envio, pais_envio) VALUES
(1, '2024-03-10 10:00:00', 799.99, 'Completado', 1, 'Av. Siempre Viva 123', 'Buenos Aires', 'Argentina'), -- Juan: Smartphone
(2, '2024-03-11 11:00:00', 60.00, 'Completado', 2, 'Alicia Garzon 456', 'Cordoba', 'Argentina'),             -- Ana: Sartenes
(1, '2024-03-12 12:00:00', 1215.50, 'Pendiente', 3, 'Av. Siempre Viva 123', 'Buenos Aires', 'Argentina'), -- Juan: Laptop + Camiseta
(3, '2024-03-15 09:30:00', 25.00, 'Enviado', 4, 'Av. Cabildo 625', 'Mendoza', 'Argentina'),              -- Carlos: El Principito
(4, '2024-03-16 14:00:00', 3.50, 'Completado', 5, 'Av. Reforma 101', 'Neuquén', 'México'),      		-- María: Manzanas
(2, '2024-03-17 10:00:00', 45.00, 'Cancelado', 1, 'Alicia Garzon 456', 'Cordoba', 'Argentina'),             -- Ana: Jeans
(5, '2024-04-01 08:00:00', 30.00, 'Completado', 2, 'Gran Vía 202', 'Entre Rios', 'Argentina'),              -- Pedro: Pelota
(1, '2024-04-05 13:00:00', 20.00, 'Enviado', 3, 'Av. Siempre Viva 123', 'Buenos Aires', 'Argentina'); -- Juan: Crema Hidratante

-- Insertar datos en Detalle_Pedido
-- Pedido 1 (Juan): Smartphone X
INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad, precio_al_comprar) VALUES (1, 1, 1, 799.99);
-- Pedido 2 (Ana): Set de Sartenes
INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad, precio_al_comprar) VALUES (2, 7, 1, 60.00);
-- Pedido 3 (Juan): Laptop Gamer Pro, Camiseta Algodón Básica
INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad, precio_al_comprar) VALUES (3, 2, 1, 1200.00), (3, 3, 1, 15.50);
-- Pedido 4 (Carlos): El Principito
INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad, precio_al_comprar) VALUES (4, 5, 1, 25.00);
-- Pedido 5 (María): Manzanas Rojas Orgánicas
INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad, precio_al_comprar) VALUES (5, 8, 1, 3.50);
-- Pedido 6 (Ana): Jeans Slim Fit Hombre
INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad, precio_al_comprar) VALUES (6, 4, 1, 45.00);
-- Pedido 7 (Pedro): Pelota de Fútbol Profesional
INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad, precio_al_comprar) VALUES (7, 9, 1, 30.00);
-- Pedido 8 (Juan): Crema Hidratante Facial
INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad, precio_al_comprar) VALUES (8, 10, 1, 20.00);

-- Insertar datos en Reviews_Productos
INSERT INTO Reviews_Productos (id_producto, id_cliente, calificacion, comentario, fecha_review) VALUES
(1, 1, 5, 'Excelente smartphone, muy rápido y buena cámara.', '2024-03-11 15:00:00'),
(7, 2, 4, 'Sartenes de buena calidad, aunque un poco pequeñas.', '2024-03-12 10:00:00'),
(5, 3, 5, 'Un clásico imperdible. Lo recomiendo para todas las edades.', '2024-03-16 11:00:00'),
(8, 4, 3, 'Manzanas frescas, pero algunas venían golpeadas.', '2024-03-17 18:00:00'),
(1, 2, 4, 'El teléfono es bueno, pero la batería podría durar más.', '2024-03-20 09:00:00');

-- Insertar datos en Carritos_Compras
INSERT INTO Carritos_Compras (id_cliente, fecha_creacion, fecha_ultima_actualizacion) VALUES
(1, '2024-05-20 09:00:00', '2024-05-20 10:30:00'),
(3, '2024-05-21 14:00:00', '2024-05-21 14:00:00');

-- Insertar datos en Detalle_Carrito
INSERT INTO Detalle_Carrito (id_carrito, id_producto, cantidad) VALUES
(1, 4, 1), -- Cliente 1 (Juan) tiene Jeans en el carrito
(1, 6, 1), -- Cliente 1 (Juan) también tiene Cafetera
(2, 10, 2); -- Cliente 3 (Carlos) tiene 2 Cremas hidratantes

-- Insertar datos en Promociones
INSERT INTO Promociones (nombre_promocion, tipo_descuento, valor_descuento, fecha_inicio, fecha_fin) VALUES
('Verano 2024', 'Porcentaje', 10.00, '2024-06-01 00:00:00', '2024-08-31 23:59:59'),
('Black Friday', 'MontoFijo', 50.00, '2024-11-29 00:00:00', '2024-12-01 23:59:59');

-- Llenado de Dim_Tiempo
-- Necesitamos IDs de tiempo con formato YYYYMMDD
INSERT INTO Dim_Tiempo (id_tiempo, fecha, dia, mes, anio, trimestre, nombre_dia, nombre_mes, semana_del_anio) VALUES
(20240301, '2024-03-01', 1, 3, 2024, 1, 'Viernes', 'Marzo', 9),
(20240310, '2024-03-10', 10, 3, 2024, 1, 'Domingo', 'Marzo', 10),
(20240311, '2024-03-11', 11, 3, 2024, 1, 'Lunes', 'Marzo', 11),
(20240312, '2024-03-12', 12, 3, 2024, 1, 'Martes', 'Marzo', 11),
(20240315, '2024-03-15', 15, 3, 2024, 1, 'Viernes', 'Marzo', 11),
(20240316, '2024-03-16', 16, 3, 2024, 1, 'Sábado', 'Marzo', 11),
(20240317, '2024-03-17', 17, 3, 2024, 1, 'Domingo', 'Marzo', 12),
(20240401, '2024-04-01', 1, 4, 2024, 2, 'Lunes', 'Abril', 14),
(20240405, '2024-04-05', 5, 4, 2024, 2, 'Viernes', 'Abril', 14);

-- Insertar datos en Dim_Producto
INSERT INTO Dim_Producto (id_producto, nombre_producto, nombre_categoria, nombre_proveedor, precio_actual)
SELECT
    p.id_producto,
    p.nombre_producto,
    c.nombre_categoria,
    pr.nombre_proveedor,
    p.precio_unitario
FROM Productos p
LEFT JOIN Categorias c ON p.id_categoria = c.id_categoria
LEFT JOIN Proveedores pr ON p.id_proveedor = pr.id_proveedor;

-- Insertar datos en Dim_Cliente (Similar a Dim_Producto)
INSERT INTO Dim_Cliente (id_cliente, nombre_completo, email_cliente, ciudad_cliente, pais_cliente)
SELECT
    id_cliente,
    CONCAT(nombre, ' ', apellido),
    email,
    ciudad,
    pais
FROM Clientes;

INSERT INTO Fact_Ventas (id_pedido, id_tiempo, id_dim_producto, id_dim_cliente, cantidad_vendida, precio_venta_unitario, monto_total_venta)
SELECT
    dp.id_pedido,
    REPLACE(DATE_FORMAT(p.fecha_pedido, '%Y%m%d'), '-', '') AS id_tiempo_key, -- Esto debe coincidir con Dim_Tiempo.id_tiempo
    dp.id_producto AS id_dim_producto_key, -- id_producto es la clave para Dim_Producto
    p.id_cliente AS id_dim_cliente_key, --  id_cliente es la clave para Dim_Cliente
    dp.cantidad,
    dp.precio_al_comprar,
    (dp.cantidad * dp.precio_al_comprar) AS monto_total
FROM Detalle_Pedido dp
JOIN Pedidos p ON dp.id_pedido = p.id_pedido;
