-- database_schema.sql

-- 1. Crear bd si no existe y usarlo
CREATE SCHEMA IF NOT EXISTS tienda_online;
USE tienda_online;

-- 2. Tablas Transaccionales

-- Tabla Clientes: Informacion de los usuarios
CREATE TABLE IF NOT EXISTS Clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    ciudad VARCHAR(100),
    pais VARCHAR(100),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Categorias: Clasificacion de productos
CREATE TABLE IF NOT EXISTS Categorias (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre_categoria VARCHAR(100) UNIQUE NOT NULL
);

-- Tabla Proveedores: Informacion de los proveedores de productos
CREATE TABLE IF NOT EXISTS Proveedores (
    id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
    nombre_proveedor VARCHAR(255) NOT NULL,
    contacto_proveedor VARCHAR(255),
    telefono_proveedor VARCHAR(20),
    email_proveedor VARCHAR(255) UNIQUE
);

-- Tabla Productos: Detalle de los productos disponibles
CREATE TABLE IF NOT EXISTS Productos (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    nombre_producto VARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    id_categoria INT,
    id_proveedor INT,
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria),
    FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor)
);

-- Tabla Metodos_Pago: Diferentes formas de pago aceptadas
CREATE TABLE IF NOT EXISTS Metodos_Pago (
    id_metodo_pago INT PRIMARY KEY AUTO_INCREMENT,
    nombre_metodo VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla Pedidos: Informacion gral de cada orden de compra
CREATE TABLE IF NOT EXISTS Pedidos (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    fecha_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_pedido DECIMAL(10, 2) NOT NULL,
    estado_pedido VARCHAR(50) NOT NULL DEFAULT 'Pendiente', -- Ej: Pendiente, Enviado, Completado, Cancelado
    id_metodo_pago INT,
    direccion_envio VARCHAR(255),
    ciudad_envio VARCHAR(100),
    pais_envio VARCHAR(100),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    FOREIGN KEY (id_metodo_pago) REFERENCES Metodos_Pago(id_metodo_pago)
);

-- Tabla Detalle_Pedido: Productos especificos dentro de cada pedido
CREATE TABLE IF NOT EXISTS Detalle_Pedido (
    id_detalle_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_al_comprar DECIMAL(10, 2) NOT NULL, -- Precio del producto al momento de la compra
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

-- Tabla Reviews_Productos: Calificaciones y comentarios de los clientes sobre productos
CREATE TABLE IF NOT EXISTS Reviews_Productos (
    id_review INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    id_cliente INT NOT NULL,
    calificacion INT NOT NULL, -- Valor entre 1 y 5
    comentario TEXT,
    fecha_review DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_calificacion CHECK (calificacion >= 1 AND calificacion <= 5),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

-- Tabla Carritos_Compras: Carritos de compra actales de los clientes
CREATE TABLE IF NOT EXISTS Carritos_Compras (
    id_carrito INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT UNIQUE NOT NULL, -- Un cliente solo puede tener un carrito activo
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_ultima_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

-- Tabla Detalle_Carrito: Productos dentro de cada carrito de compra
CREATE TABLE IF NOT EXISTS Detalle_Carrito (
    id_detalle_carrito INT PRIMARY KEY AUTO_INCREMENT,
    id_carrito INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    FOREIGN KEY (id_carrito) REFERENCES Carritos_Compras(id_carrito),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
    UNIQUE (id_carrito, id_producto) -- Un producto solo puede estar una vez en un mismo carrito
);

-- Tabla Log_Errores: Para registrar errores o eventos importantes del sistema.
CREATE TABLE IF NOT EXISTS Log_Errores (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    mensaje_error TEXT NOT NULL,
    fecha_hora_error DATETIME DEFAULT CURRENT_TIMESTAMP,
    origen VARCHAR(255) -- Ej: 'TRIGGER_STOCK_UPDATE', 'PROCEDURE_PEDIDO'
);

-- Tabla Promociones: Información sobre las ofertas y descuentos
CREATE TABLE IF NOT EXISTS Promociones (
    id_promocion INT PRIMARY KEY AUTO_INCREMENT,
    nombre_promocion VARCHAR(255) NOT NULL,
    tipo_descuento VARCHAR(50) NOT NULL, -- Ej: 'Porcentaje', 'MontoFijo'
    valor_descuento DECIMAL(5, 2) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,
    CONSTRAINT chk_fechas_promocion CHECK (fecha_fin >= fecha_inicio)
);

-- 3. Tablas Dimensionales (para Análisis
-- Dim_Tiempo: Para el analisis temporal de ventas
CREATE TABLE IF NOT EXISTS Dim_Tiempo (
    id_tiempo INT PRIMARY KEY, -- Clave generada basada en la fecha (YYYYMMDD)
    fecha DATE UNIQUE NOT NULL,
    dia INT NOT NULL,
    mes INT NOT NULL,
    anio INT NOT NULL,
    trimestre INT NOT NULL,
    nombre_dia VARCHAR(20) NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL,
    semana_del_anio INT NOT NULL
);

-- Dim_Producto: Atributos de producto para el analisis, desnormalizados
CREATE TABLE IF NOT EXISTS Dim_Producto (
    id_dim_producto INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    nombre_producto VARCHAR(255) NOT NULL,
    nombre_categoria VARCHAR(100),
    nombre_proveedor VARCHAR(255),
    precio_actual DECIMAL(10, 2),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

-- Dim_Cliente: Atributos de cliente para el analisis, desnormalizados
CREATE TABLE IF NOT EXISTS Dim_Cliente (
    id_dim_cliente INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    nombre_completo VARCHAR(200) NOT NULL,
    email_cliente VARCHAR(255),
    ciudad_cliente VARCHAR(100),
    pais_cliente VARCHAR(100),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

-- 4. Tabla de Hechos (OLAP)

-- Fact_Ventas: Almacena las metricas de ventas y las claves a las dimensiones
CREATE TABLE IF NOT EXISTS Fact_Ventas (
    id_fact_venta INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_tiempo INT NOT NULL,
    id_dim_producto INT NOT NULL,
    id_dim_cliente INT NOT NULL,
    cantidad_vendida INT NOT NULL,
    precio_venta_unitario DECIMAL(10, 2) NOT NULL,
    monto_total_venta DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido),
    FOREIGN KEY (id_tiempo) REFERENCES Dim_Tiempo(id_tiempo),
    FOREIGN KEY (id_dim_producto) REFERENCES Dim_Producto(id_dim_producto),
    FOREIGN KEY (id_dim_cliente) REFERENCES Dim_Cliente(id_cliente)
);