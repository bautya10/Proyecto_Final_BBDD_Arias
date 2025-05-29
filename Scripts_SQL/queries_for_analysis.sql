-- queries_for_analysis.sql

USE tienda_online;

-- 1. Informe de Ventas Totales por Mes (Completados)
-- Objetivo: Ver la tendencia de ingresos mensuales de pedidos completados
SELECT
    DATE_FORMAT(fecha_pedido, '%Y-%m') AS Mes,
    COUNT(id_pedido) AS Total_Pedidos_Completados,
    SUM(total_pedido) AS Ingresos_Totales_Completados
FROM
    Pedidos
WHERE
    estado_pedido = 'Completado'
GROUP BY
    Mes
ORDER BY
    Mes;

-- 2. Top 5 Clientes por Gasto Total
-- Objetivo: Identificar a los clientes mas valiosos para la tienda
SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    c.email,
    SUM(p.total_pedido) AS Gasto_Total
FROM
    Clientes c
JOIN
    Pedidos p ON c.id_cliente = p.id_cliente
WHERE
    p.estado_pedido = 'Completado'
GROUP BY
    c.id_cliente, c.nombre, c.apellido, c.email
ORDER BY
    Gasto_Total DESC
LIMIT 5;

-- 3. Productos mas vendidos (por cantidad)
-- Objetivo: Conocer que productos tienen mayor demanda
SELECT
    pr.nombre_producto,
    ca.nombre_categoria,
    SUM(dp.cantidad) AS Cantidad_Total_Vendida
FROM
    Detalle_Pedido dp
JOIN
    Productos pr ON dp.id_producto = pr.id_producto
JOIN
    Categorias ca ON pr.id_categoria = ca.id_categoria
GROUP BY
    pr.nombre_producto, ca.nombre_categoria
ORDER BY
    Cantidad_Total_Vendida DESC
LIMIT 10;

-- 4. Ingresos por Categoria de Producto
-- Objetivo: Entender que categorías de productos son las mas rentable
SELECT
    ca.nombre_categoria,
    SUM(dp.cantidad * dp.precio_al_comprar) AS Ingresos_Por_Categoria
FROM
    Detalle_Pedido dp
JOIN
    Productos pr ON dp.id_producto = pr.id_producto
JOIN
    Categorias ca ON pr.id_categoria = ca.id_categoria
JOIN
    Pedidos pe ON dp.id_pedido = pe.id_pedido
WHERE
    pe.estado_pedido = 'Completado'
GROUP BY
    ca.nombre_categoria
ORDER BY
    Ingresos_Por_Categoria DESC;

-- 5. Estado Actual del Inventario por Producto y Proveedor
-- Objetivo: Monitorear el stock y quien provee cada producto.
SELECT
    p.nombre_producto,
    c.nombre_categoria,
    pv.nombre_proveedor,
    p.stock,
    p.precio_unitario
FROM
    Productos p
LEFT JOIN
    Categorias c ON p.id_categoria = c.id_categoria
LEFT JOIN
    Proveedores pv ON p.id_proveedor = pv.id_proveedor
ORDER BY
    p.stock ASC;

-- 6. Promedio de Calificación de Productos
-- Objetivo: Evaluar la satisfaccion del cliente con los productos.
SELECT
    p.nombre_producto,
    AVG(rp.calificacion) AS Calificacion_Promedio,
    COUNT(rp.id_review) AS Total_Reviews
FROM
    Productos p
JOIN
    Reviews_Productos rp ON p.id_producto = rp.id_producto
GROUP BY
    p.nombre_producto
ORDER BY
    Calificacion_Promedio DESC;

-- 7. Clientes con Carritos de Compra Activos (no convertidos en pedido)
-- Objetivo: Identificar oportunidades de recuperacion de carrito.
SELECT
    c.nombre,
    c.apellido,
    c.email,
    cc.fecha_ultima_actualizacion,
    GROUP_CONCAT(p.nombre_producto SEPARATOR ', ') AS Productos_En_Carrito
FROM
    Clientes c
JOIN
    Carritos_Compras cc ON c.id_cliente = cc.id_cliente
JOIN
    Detalle_Carrito dc ON cc.id_carrito = dc.id_carrito
JOIN
    Productos p ON dc.id_producto = p.id_producto
WHERE
    c.id_cliente NOT IN (SELECT id_cliente FROM Pedidos WHERE estado_pedido IN ('Pendiente', 'Enviado', 'Completado')) -- Excluye clientes que ya hicieron un pedido
GROUP BY
    c.id_cliente, c.nombre, c.apellido, c.email, cc.fecha_ultima_actualizacion
ORDER BY
    cc.fecha_ultima_actualizacion DESC;

-- 8. Pedidos con Productos de MltiplesCategorías
-- Objetivo: Entender patrones de compra diversificados.
SELECT
    p.id_pedido,
    cl.nombre AS Nombre_Cliente,
    cl.apellido AS Apellido_Cliente,
    p.fecha_pedido,
    COUNT(DISTINCT c.nombre_categoria) AS Cantidad_Categorias_Diferentes,
    GROUP_CONCAT(DISTINCT c.nombre_categoria SEPARATOR ', ') AS Categorias_En_Pedido
FROM
    Pedidos p
JOIN
    Clientes cl ON p.id_cliente = cl.id_cliente
JOIN
    Detalle_Pedido dp ON p.id_pedido = dp.id_pedido
JOIN
    Productos pr ON dp.id_producto = pr.id_producto
JOIN
    Categorias c ON pr.id_categoria = c.id_categoria
GROUP BY
    p.id_pedido, cl.nombre, cl.apellido, p.fecha_pedido
HAVING
    Cantidad_Categorias_Diferentes > 1
ORDER BY
    Cantidad_Categorias_Diferentes DESC;

-- 9. Uso de la tabla de hechos Fact_Ventas: Ventas Totales por Cliente y Mes (desde la tabla de Hechos)
-- Objetivo: Anaisis de ventas por cliente y tiempo, usando el modelo dimensional.
SELECT
    dc.nombre_completo AS Cliente,
    dt.nombre_mes AS Mes,
    dt.anio AS Anio,
    SUM(fv.monto_total_venta) AS Total_Venta_Fact
FROM
    Fact_Ventas fv
JOIN
    Dim_Cliente dc ON fv.id_dim_cliente = dc.id_cliente -- se relaciona c id_cliente trsccn
JOIN
    Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
GROUP BY
    dc.nombre_completo, dt.nombre_mes, dt.anio
ORDER BY
    Cliente, Anio, dt.mes;

-- 10. Uso de la tabla de hechos Fact_Ventas: Ventas por Producto y Trimestre
-- Objetivo: Analisisde rendimiento de productos en el tiempo.
SELECT
    dp.nombre_producto AS Producto,
    dt.trimestre AS Trimestre,
    dt.anio AS Anio,
    SUM(fv.monto_total_venta) AS Total_Venta_Fact
FROM
    Fact_Ventas fv
JOIN
    Dim_Producto dp ON fv.id_dim_producto = dp.id_producto -- se relaciona con id_producto tsccnl
JOIN
    Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
GROUP BY
    dp.nombre_producto, dt.trimestre, dt.anio
ORDER BY
    Producto, Anio, Trimestre;