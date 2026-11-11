Create database ClinicaVeterinaria
Go

Use ClinicaVeterinaria
Go

CREATE TABLE Jaula (
    id_jaula INT IDENTITY(1,1) PRIMARY KEY,
    numero INT NOT NULL,
    tamano VARCHAR(10) NOT NULL,
    activa BIT NOT NULL DEFAULT 1,

    CONSTRAINT Jaula_Numero
        UNIQUE (numero),

    CONSTRAINT Jaula_Tamano
        CHECK (tamano IN ('chica', 'mediana', 'grande')));

CREATE TABLE Internacion (
    id_internacion INT IDENTITY(1,1) PRIMARY KEY,
    id_atencion INT NOT NULL,
    id_veterinario INT NOT NULL,
    id_jaula INT NOT NULL,
    motivo VARCHAR(500) NULL,
    fecha_hora_ingreso DATETIME NOT NULL,
    fecha_hora_egreso DATETIME NULL,
    tipo_egreso VARCHAR(10) NULL,

    CONSTRAINT Internacion_Fechas
        CHECK (fecha_hora_egreso IS NULL OR fecha_hora_egreso > fecha_hora_ingreso),

    CONSTRAINT Internacion_TipoEgreso
        CHECK (tipo_egreso IN ('alta', 'derivada', 'fallecida')));

CREATE TABLE EvolucionInternacion (
    id_evolucion INT IDENTITY(1,1) PRIMARY KEY,
    id_internacion INT NOT NULL,
    id_empleado INT NOT NULL,
    fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),
    temperatura DECIMAL(4,1) NULL,
    peso DECIMAL(7,2) NULL,
    observaciones VARCHAR(1000) NULL);

CREATE TABLE Medicamento (
    id_medicamento INT IDENTITY(1,1) PRIMARY KEY,
    nombre_comercial VARCHAR(100) NOT NULL,
    droga VARCHAR(100) NOT NULL,
    presentacion VARCHAR(100) NULL,
    unidad_medida VARCHAR(30) NOT NULL,
    stock_minimo INT NOT NULL,
    activo BIT NOT NULL DEFAULT 1,

    CONSTRAINT Medicamento_StockMinimo
        CHECK (stock_minimo >= 0));

CREATE TABLE UsoMedicamento (
    id_uso INT IDENTITY(1,1) PRIMARY KEY,
    id_medicamento INT NOT NULL,
    id_atencion INT NULL,
    id_evolucion INT NULL,
    dosis VARCHAR(100) NULL,
    via_aplicacion VARCHAR(50) NULL,
    cantidad INT NOT NULL,
    fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UsoMedicamento_Cantidad
        CHECK (cantidad > 0),

    CONSTRAINT UsoMedicamento_Destino
        CHECK ((id_atencion IS NOT NULL AND id_evolucion IS NULL) OR (id_atencion IS NULL AND id_evolucion IS NOT NULL)));

CREATE TABLE MovimientoStock (
    id_movimiento INT IDENTITY(1,1) PRIMARY KEY,
    id_medicamento INT NOT NULL,
    id_empleado INT NOT NULL,
    tipo VARCHAR(10) NOT NULL,
    cantidad INT NOT NULL,
    fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),
    motivo VARCHAR(500) NULL,

    CONSTRAINT MovimientoStock_Tipo
        CHECK (tipo IN ('ingreso', 'ajuste')),

    CONSTRAINT MovimientoStock_Ingreso
        CHECK (tipo <> 'ingreso'OR cantidad > 0));