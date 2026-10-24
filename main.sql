-- 1. Creacion de la base de datos
USE master;

IF DB_ID('VetCare') IS NOT NULL
  ALTER DATABASE VetCare
    SET SINGLE_USER 
    WITH ROLLBACK IMMEDIATE;

DROP DATABASE IF EXISTS VetCare;


GO
CREATE DATABASE VetCare;


GO
USE VetCare;


GO
-- 2. Tablas de Pacientes
CREATE TABLE Dueno (
  id_dueno  INT           IDENTITY (1, 1) NOT NULL,
  dni       VARCHAR (20)  NOT NULL UNIQUE,
  telefono  VARCHAR (30)  NOT NULL,
  email     VARCHAR (100) NULL,
  direccion VARCHAR (200) NULL,
  PRIMARY KEY (id_dueno)
);

CREATE TABLE Especie (
  id_especie INT          IDENTITY (1, 1) NOT NULL,
  nombre     VARCHAR (50) NOT NULL UNIQUE,
  PRIMARY KEY (id_especie),
  CONSTRAINT CK_Especie_nombre CHECK (nombre IN ('Perro', 'Gato'))
);

CREATE TABLE Raza (
  id_raza    INT          IDENTITY (1, 1) NOT NULL,
  id_especie INT          NOT NULL,
  nombre     VARCHAR (50) NOT NULL,
  PRIMARY KEY (id_raza),
  CONSTRAINT UQ_Raza_especie_nombre UNIQUE (id_especie, nombre)
);

CREATE TABLE Mascota (
  id_mascota       INT      IDENTITY (1, 1) NOT NULL,
  id_dueno         INT      NOT NULL,
  id_raza          INT      NOT NULL,
  sexo             CHAR (1) NOT NULL,
  fecha_nacimiento DATE     NOT NULL,
  castrado         BIT      DEFAULT 0 NOT NULL,
  fecha_baja       DATE     NULL,
  PRIMARY KEY (id_mascota),
  CONSTRAINT CK_Mascota_sexo CHECK (sexo IN ('M', 'H')),
  CONSTRAINT CK_Mascota_fecha_nacimiento CHECK (fecha_nacimiento <= CAST (getdate() AS DATE)),
  CONSTRAINT CK_Mascota_fecha_baja CHECK (fecha_baja IS NULL
                                          OR fecha_baja > fecha_nacimiento)
);

CREATE TABLE Alergia (
  id_alergia     INT          IDENTITY (1, 1) NOT NULL,
  nombre         VARCHAR (50) NOT NULL UNIQUE,
  tipo           VARCHAR (20) NOT NULL,
  id_medicamento INT          NULL,
  PRIMARY KEY (id_alergia),
  CONSTRAINT CK_Alergia_tipo CHECK (tipo IN ('MEDICAMENTO', 'ALIMENTO', 'AMBIENTAL', 'OTRO'))
);

CREATE TABLE MascotaAlergia (
  id_mascota INT NOT NULL,
  id_alergia INT NOT NULL,
  PRIMARY KEY (id_mascota, id_alergia)
);


GO
-- 3. Tablas de Personal y Agenda
CREATE TABLE Empleado (
  id_empleado INT           IDENTITY (1, 1) PRIMARY KEY,
  dni         INT           NOT NULL UNIQUE, -- dato sensible
  nombre      VARCHAR (50)  NOT NULL,
  apellido    VARCHAR (50)  NOT NULL,
  telefono    VARCHAR (20)  NOT NULL, -- dato sensible
  direccion   VARCHAR (100) NOT NULL, -- dato sensible
  tipo        VARCHAR (20)  NOT NULL CHECK (tipo IN ('veterinario', 'administrativo', 'ayudante')),
  activo      BIT           DEFAULT 1 NOT NULL -- baja logica
);

CREATE TABLE Veterinario (
  id_veterinario INT NOT NULL PRIMARY KEY,
  matricula      INT NOT NULL UNIQUE
);

CREATE TABLE Administrativo (
  id_administrativo INT          NOT NULL PRIMARY KEY,
  sector            VARCHAR (30) NOT NULL CHECK (sector IN ('recepcion', 'facturacion', 'administracion'))
);

CREATE TABLE Ayudante (
  id_ayudante INT          NOT NULL PRIMARY KEY,
  area        VARCHAR (20) NOT NULL CHECK (area IN ('consultorio', 'internacion', 'internación'))
);

CREATE TABLE Especialidad (
  id_especialidad INT          IDENTITY (1, 1) PRIMARY KEY,
  nombre          VARCHAR (50) NOT NULL UNIQUE
);

CREATE TABLE VeterinarioEspecialidad (
  id_veterinario  INT NOT NULL,
  id_especialidad INT NOT NULL,
  PRIMARY KEY (id_veterinario, id_especialidad)
);

-- turnos y guardias
CREATE TABLE Turno (
  id_turno        INT          IDENTITY (1, 1) PRIMARY KEY,
  fecha_hora      DATETIME     NOT NULL,
  estado          VARCHAR (15) DEFAULT 'pendiente' NOT NULL CHECK (estado IN ('pendiente', 'atendido', 'cancelado', 'ausente')),
  id_mascota      INT          NOT NULL,
  id_veterinario  INT          NOT NULL,
  id_especialidad INT          NULL
);

CREATE TABLE TurnoGuardia (
  id_turno_guardia INT      IDENTITY (1, 1) PRIMARY KEY,
  fecha_inicio     DATETIME NOT NULL,
  fecha_fin        DATETIME NOT NULL,
  CHECK (fecha_fin > fecha_inicio)
);

CREATE TABLE TurnoGuardiaVeterinario (
  id_turno_guardia INT NOT NULL,
  id_veterinario   INT NOT NULL,
  PRIMARY KEY (id_turno_guardia, id_veterinario)
);


GO
-- 4. Tablas Clinicas
CREATE TABLE TipoEstudio (
  id_tipo_estudio INT          IDENTITY (1, 1) NOT NULL,
  nombre          VARCHAR (50) NOT NULL UNIQUE,
  requiere_turno  BIT          DEFAULT 0 NOT NULL,
  es_externo      BIT          DEFAULT 0 NOT NULL,
  PRIMARY KEY (id_tipo_estudio)
);

CREATE TABLE Atencion (
  id_atencion      INT             IDENTITY (1, 1) NOT NULL,
  id_mascota       INT             NOT NULL,
  id_veterinario   INT             NOT NULL,
  tipo             VARCHAR (20)    NOT NULL,
  fecha_hora       DATETIME        DEFAULT GETDATE() NOT NULL,
  orden_llegada    INT             NULL,
  id_turno         INT             NULL,
  id_turno_guardia INT             NULL,
  nivel_urgencia   VARCHAR (20)    NULL,
  motivo           VARCHAR (200)   NOT NULL,
  peso             DECIMAL (10, 2) NOT NULL,
  temperatura      DECIMAL (4, 1)  NULL,
  diagnostico      VARCHAR (500)   NOT NULL,
  observaciones    VARCHAR (MAX)   NULL,
  ref_pago_externo VARCHAR (50)    NULL,
  estado_pago      VARCHAR (20)    NULL,
  PRIMARY KEY (id_atencion),
  CONSTRAINT CK_Atencion_tipo CHECK (tipo IN ('GENERAL', 'ESPECIALIDAD', 'GUARDIA')),
  CONSTRAINT CK_Atencion_peso CHECK (peso > 0),
  -- no puede haber una atencion de especialidad sin turno
  CONSTRAINT CK_Atencion_especialidad_turno CHECK (NOT (tipo = 'ESPECIALIDAD'
                                                        AND id_turno IS NULL)),
  -- no puede haber una atencion de guardia sin turno de guardia
  CONSTRAINT CK_Atencion_guardia_turno CHECK (NOT (tipo = 'GUARDIA'
                                                   AND id_turno_guardia IS NULL))
);

CREATE TABLE Estudio (
  id_estudio        INT           IDENTITY (1, 1) NOT NULL,
  id_atencion       INT           NOT NULL,
  id_tipo_estudio   INT           NOT NULL,
  id_turno          INT           NULL,
  fecha_solicitud   DATETIME      CONSTRAINT DF_Estudio_fecha_solicitud DEFAULT GETDATE() NOT NULL,
  fecha_realizacion DATETIME      NULL,
  fecha_resultado   DATETIME      NULL,
  resultado         VARCHAR (500) NULL,
  PRIMARY KEY (id_estudio),
  CONSTRAINT CK_Estudio_fecha_resultado CHECK (fecha_resultado >= fecha_solicitud)
);

CREATE TABLE Receta (
  id_receta              INT           IDENTITY (1, 1) NOT NULL,
  id_atencion            INT           NOT NULL,
  fecha                  DATE          DEFAULT GETDATE() NOT NULL,
  indicaciones_generales VARCHAR (500) NULL,
  PRIMARY KEY (id_receta)
);

CREATE TABLE DetalleReceta (
  id_receta      INT          NOT NULL,
  id_medicamento INT          NOT NULL,
  dosis          VARCHAR (50) NOT NULL,
  frecuencia     VARCHAR (50) NOT NULL,
  duracion_dias  INT          NOT NULL,
  PRIMARY KEY (id_receta, id_medicamento),
  CONSTRAINT CK_DetalleReceta_duracion_dias CHECK (duracion_dias > 0)
);


GO
-- 5. Tablas de Internacion y Stock
CREATE TABLE Jaula (
  id_jaula INT          IDENTITY (1, 1) PRIMARY KEY,
  numero   INT          NOT NULL,
  tamano   VARCHAR (10) NOT NULL,
  activa   BIT          DEFAULT 1 NOT NULL,
  CONSTRAINT Jaula_Numero UNIQUE (numero),
  CONSTRAINT Jaula_Tamano CHECK (tamano IN ('chica', 'mediana', 'grande'))
);

CREATE TABLE Internacion (
  id_internacion     INT           IDENTITY (1, 1) PRIMARY KEY,
  id_atencion        INT           NOT NULL,
  id_veterinario     INT           NOT NULL,
  id_jaula           INT           NOT NULL,
  motivo             VARCHAR (500) NULL,
  fecha_hora_ingreso DATETIME      NOT NULL,
  fecha_hora_egreso  DATETIME      NULL,
  tipo_egreso        VARCHAR (10)  NULL,
  CONSTRAINT Internacion_Fechas CHECK (fecha_hora_egreso IS NULL
                                       OR fecha_hora_egreso > fecha_hora_ingreso),
  CONSTRAINT Internacion_TipoEgreso CHECK (tipo_egreso IN ('alta', 'derivada', 'fallecida'))
);

CREATE TABLE EvolucionInternacion (
  id_evolucion   INT            IDENTITY (1, 1) PRIMARY KEY,
  id_internacion INT            NOT NULL,
  id_empleado    INT            NOT NULL,
  fecha_hora     DATETIME       DEFAULT GETDATE() NOT NULL,
  temperatura    DECIMAL (4, 1) NULL,
  peso           DECIMAL (7, 2) NULL,
  observaciones  VARCHAR (1000) NULL
);

CREATE TABLE Medicamento (
  id_medicamento   INT           IDENTITY (1, 1) PRIMARY KEY,
  nombre_comercial VARCHAR (100) NOT NULL,
  droga            VARCHAR (100) NOT NULL,
  presentacion     VARCHAR (100) NULL,
  unidad_medida    VARCHAR (30)  NOT NULL,
  stock_minimo     INT           NOT NULL,
  activo           BIT           DEFAULT 1 NOT NULL,
  CONSTRAINT Medicamento_StockMinimo CHECK (stock_minimo >= 0)
);

CREATE TABLE UsoMedicamento (
  id_uso         INT           IDENTITY (1, 1) PRIMARY KEY,
  id_medicamento INT           NOT NULL,
  id_atencion    INT           NULL,
  id_evolucion   INT           NULL,
  dosis          VARCHAR (100) NULL,
  via_aplicacion VARCHAR (50)  NULL,
  cantidad       INT           NOT NULL,
  fecha_hora     DATETIME      DEFAULT GETDATE() NOT NULL,
  CONSTRAINT UsoMedicamento_Cantidad CHECK (cantidad > 0),
  CONSTRAINT UsoMedicamento_Destino CHECK ((id_atencion IS NOT NULL
                                            AND id_evolucion IS NULL)
                                           OR (id_atencion IS NULL
                                               AND id_evolucion IS NOT NULL))
);

CREATE TABLE MovimientoStock (
  id_movimiento  INT           IDENTITY (1, 1) PRIMARY KEY,
  id_medicamento INT           NOT NULL,
  id_empleado    INT           NOT NULL,
  tipo           VARCHAR (10)  NOT NULL,
  cantidad       INT           NOT NULL,
  fecha_hora     DATETIME      DEFAULT GETDATE() NOT NULL,
  motivo         VARCHAR (500) NULL,
  CONSTRAINT MovimientoStock_Tipo CHECK (tipo IN ('ingreso', 'ajuste')),
  CONSTRAINT MovimientoStock_Ingreso CHECK (tipo <> 'ingreso'
                                            OR cantidad > 0)
);


GO
-- 6. FK Pacientes
ALTER TABLE Raza
  ADD CONSTRAINT FK_Raza_Especie FOREIGN KEY (id_especie) REFERENCES Especie (id_especie);

ALTER TABLE Mascota
  ADD CONSTRAINT FK_Mascota_Dueno FOREIGN KEY (id_dueno) REFERENCES Dueno (id_dueno);

ALTER TABLE Mascota
  ADD CONSTRAINT FK_Mascota_Raza FOREIGN KEY (id_raza) REFERENCES Raza (id_raza);

ALTER TABLE Alergia
  ADD CONSTRAINT FK_Alergia_Medicamento FOREIGN KEY (id_medicamento) REFERENCES Medicamento (id_medicamento);

ALTER TABLE MascotaAlergia
  ADD CONSTRAINT FK_MascotaAlergia_Mascota FOREIGN KEY (id_mascota) REFERENCES Mascota (id_mascota);

ALTER TABLE MascotaAlergia
  ADD CONSTRAINT FK_MascotaAlergia_Alergia FOREIGN KEY (id_alergia) REFERENCES Alergia (id_alergia);


GO
-- 7. FK Personal y Agenda
-- fk subtipos a empleado
ALTER TABLE Veterinario
  ADD FOREIGN KEY (id_veterinario) REFERENCES Empleado (id_empleado);

ALTER TABLE Administrativo
  ADD FOREIGN KEY (id_administrativo) REFERENCES Empleado (id_empleado);

ALTER TABLE Ayudante
  ADD FOREIGN KEY (id_ayudante) REFERENCES Empleado (id_empleado);

-- veterinario especialidad
ALTER TABLE VeterinarioEspecialidad
  ADD FOREIGN KEY (id_veterinario) REFERENCES Veterinario (id_veterinario);

ALTER TABLE VeterinarioEspecialidad
  ADD FOREIGN KEY (id_especialidad) REFERENCES Especialidad (id_especialidad);

-- turnos
ALTER TABLE Turno
  ADD FOREIGN KEY (id_veterinario) REFERENCES Veterinario (id_veterinario);

ALTER TABLE Turno
  ADD FOREIGN KEY (id_especialidad) REFERENCES Especialidad (id_especialidad);

ALTER TABLE Turno
  ADD FOREIGN KEY (id_mascota) REFERENCES Mascota (id_mascota); -- tabla de opcion 1

-- guardias
ALTER TABLE TurnoGuardiaVeterinario
  ADD FOREIGN KEY (id_turno_guardia) REFERENCES TurnoGuardia (id_turno_guardia);

ALTER TABLE TurnoGuardiaVeterinario
  ADD FOREIGN KEY (id_veterinario) REFERENCES Veterinario (id_veterinario);


GO
-- 8. FK Clinicas
-- Atencion
ALTER TABLE Atencion
  ADD CONSTRAINT FK_Atencion_Mascota FOREIGN KEY (id_mascota) REFERENCES Mascota (id_mascota);

ALTER TABLE Atencion
  ADD CONSTRAINT FK_Atencion_Veterinario FOREIGN KEY (id_veterinario) REFERENCES Veterinario (id_veterinario);

ALTER TABLE Atencion
  ADD CONSTRAINT FK_Atencion_Turno FOREIGN KEY (id_turno) REFERENCES Turno (id_turno);

ALTER TABLE Atencion
  ADD CONSTRAINT FK_Atencion_TurnoGuardia FOREIGN KEY (id_turno_guardia) REFERENCES TurnoGuardia (id_turno_guardia);


GO
-- Estudio
ALTER TABLE Estudio
  ADD CONSTRAINT FK_Estudio_Atencion FOREIGN KEY (id_atencion) REFERENCES Atencion (id_atencion);

ALTER TABLE Estudio
  ADD CONSTRAINT FK_Estudio_TipoEstudio FOREIGN KEY (id_tipo_estudio) REFERENCES TipoEstudio (id_tipo_estudio);

ALTER TABLE Estudio
  ADD CONSTRAINT FK_Estudio_Turno FOREIGN KEY (id_turno) REFERENCES Turno (id_turno);


GO
-- Receta
ALTER TABLE Receta
  ADD CONSTRAINT FK_Receta_Atencion FOREIGN KEY (id_atencion) REFERENCES Atencion (id_atencion);


GO
-- DetalleReceta
ALTER TABLE DetalleReceta
  ADD CONSTRAINT FK_DetalleReceta_Receta FOREIGN KEY (id_receta) REFERENCES Receta (id_receta);

ALTER TABLE DetalleReceta
  ADD CONSTRAINT FK_DetalleReceta_Medicamento FOREIGN KEY (id_medicamento) REFERENCES Medicamento (id_medicamento);


GO
-- 9. Roles y permisos
USE VetCare;


GO
CREATE ROLE rol_administrativo;

CREATE ROLE rol_veterinario;

CREATE ROLE rol_ayudante;


GO
GRANT select, insert
  ON Dueno TO rol_administrativo;

GRANT select, insert
  ON Mascota TO rol_administrativo;

GRANT select, insert
  ON Turno TO rol_administrativo;

GRANT select, insert
  ON TurnoGuardia TO rol_administrativo;

GRANT select, insert
  ON MovimientoStock TO rol_administrativo;

DENY select
  ON Atencion (diagnostico) TO rol_administrativo;


GO
GRANT select, insert
  ON Atencion TO rol_veterinario;

GRANT select, insert
  ON Estudio TO rol_veterinario;

GRANT select, insert
  ON Receta TO rol_veterinario;

GRANT select, insert
  ON DetalleReceta TO rol_veterinario;

GRANT select, insert
  ON Internacion TO rol_veterinario;

DENY select
  ON Dueno (dni, telefono, direccion) TO rol_veterinario;

DENY select
  ON Atencion (ref_pago_externo, estado_pago) TO rol_veterinario;


GO
GRANT select
  ON Internacion TO rol_ayudante;

GRANT select, insert
  ON EvolucionInternacion TO rol_ayudante;

DENY select
  ON Dueno (dni, telefono, email, direccion) TO rol_ayudante;

DENY select
  ON Atencion (diagnostico, ref_pago_externo, estado_pago) TO rol_ayudante;