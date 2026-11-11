------------------------------------------------------------------------------------
---------------------- Creacion de tablas y relaciones -----------------------------
------------------------------------------------------------------------------------
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
  nombre    VARCHAR (50)  NOT NULL,
  apellido  VARCHAR (50)  NOT NULL,
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
  id_mascota       INT           IDENTITY (1, 1) NOT NULL,
  id_dueno         INT           NOT NULL,
  id_raza          INT           NOT NULL,
  nombre           VARCHAR (50)  NOT NULL,
  sexo             CHAR (1)      NOT NULL,
  fecha_nacimiento DATE          NOT NULL,
  castrado         BIT           DEFAULT 0 NOT NULL,
  fecha_baja       DATE          NULL,
  causa_baja       VARCHAR (200) NULL,
  eutanasia        BIT           DEFAULT 0 NOT NULL,
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
  id_mascota      INT           NOT NULL,
  id_alergia      INT           NOT NULL,
  observaciones   VARCHAR (200) NULL,
  fecha_deteccion DATE          NULL,
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
-- esquema para separar el manejo de jaulas
CREATE SCHEMA internacion;


GO
CREATE TABLE internacion.Jaula (
  id_jaula INT          IDENTITY (1, 1) PRIMARY KEY,
  numero   INT          NOT NULL,
  tamano   VARCHAR (10) NOT NULL,
  activa   BIT          DEFAULT 1 NOT NULL,
  CONSTRAINT UQ_jaula_numero UNIQUE (numero),
  CONSTRAINT CK_jaula_tamano CHECK (tamano IN ('chica', 'mediana', 'grande'))
);

--
CREATE TABLE Internacion (
  id_internacion     INT           IDENTITY (1, 1) PRIMARY KEY,
  id_atencion        INT           NOT NULL,
  id_veterinario     INT           NOT NULL,
  id_jaula           INT           NOT NULL,
  motivo             VARCHAR (500) NULL,
  fecha_hora_ingreso DATETIME      NOT NULL,
  fecha_hora_egreso  DATETIME      NULL,
  tipo_egreso        VARCHAR (10)  NULL,
  CONSTRAINT CK_internacion_fechas CHECK (fecha_hora_egreso IS NULL
                                          OR fecha_hora_egreso > fecha_hora_ingreso),
  CONSTRAINT CK_internacion_tipo_egreso CHECK (tipo_egreso IN ('alta', 'derivada', 'fallecida'))
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
  CONSTRAINT CK_medicamento_stock_minimo CHECK (stock_minimo >= 0)
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
  CONSTRAINT CK_uso_medicamento_cantidad CHECK (cantidad > 0),
  CONSTRAINT CK_uso_medicamento_destino CHECK ((id_atencion IS NOT NULL
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
  CONSTRAINT CK_movimiento_stock_tipo CHECK (tipo IN ('ingreso', 'ajuste')),
  CONSTRAINT CK_movimiento_stock_ingreso CHECK (tipo <> 'ingreso'
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
-- 9. FK Internacion y Stock
-- Internacion
ALTER TABLE Internacion
  ADD CONSTRAINT FK_internacion_atencion FOREIGN KEY (id_atencion) REFERENCES Atencion (id_atencion);

ALTER TABLE Internacion
  ADD CONSTRAINT FK_internacion_veterinario FOREIGN KEY (id_veterinario) REFERENCES Veterinario (id_veterinario);

ALTER TABLE Internacion
  ADD CONSTRAINT FK_internacion_jaula FOREIGN KEY (id_jaula) REFERENCES internacion.Jaula (id_jaula);

-- Evolucion Internacion
ALTER TABLE EvolucionInternacion
  ADD CONSTRAINT FK_evolucion_internacion FOREIGN KEY (id_internacion) REFERENCES Internacion (id_internacion);

ALTER TABLE EvolucionInternacion
  ADD CONSTRAINT FK_evolucion_empleado FOREIGN KEY (id_empleado) REFERENCES Empleado (id_empleado);

-- Uso Medicamento
ALTER TABLE UsoMedicamento
  ADD CONSTRAINT FK_uso_medicamento FOREIGN KEY (id_medicamento) REFERENCES Medicamento (id_medicamento);

ALTER TABLE UsoMedicamento
  ADD CONSTRAINT FK_uso_atencion FOREIGN KEY (id_atencion) REFERENCES Atencion (id_atencion);

ALTER TABLE UsoMedicamento
  ADD CONSTRAINT FK_uso_evolucion FOREIGN KEY (id_evolucion) REFERENCES EvolucionInternacion (id_evolucion);

-- Movimiento Stock
ALTER TABLE MovimientoStock
  ADD CONSTRAINT FK_movimiento_medicamento FOREIGN KEY (id_medicamento) REFERENCES Medicamento (id_medicamento);

ALTER TABLE MovimientoStock
  ADD CONSTRAINT FK_movimiento_empleado FOREIGN KEY (id_empleado) REFERENCES Empleado (id_empleado);


GO
-- 10. Roles y permisos
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


GO
------------------------------------------------------------------------------------
-------------------------------- Carga de datos ------------------------------------
------------------------------------------------------------------------------------
-- 1. Medicamentos
INSERT  INTO Medicamento (
  nombre_comercial,
  droga,
  presentacion,
  unidad_medida,
  stock_minimo
)
VALUES                   ('Amoxidal', 'Amoxicilina', 'Comprimidos 500 mg', 'comprimido', 20),
                         ('Metacam', 'Meloxicam', 'Suspension oral 1.5 mg/ml', 'ml', 50),
                         ('Ivomec', 'Ivermectina', 'Inyectable 1%', 'ml', 10);

-- 2. Pacientes
INSERT  INTO Dueno (
  nombre,
  apellido,
  dni,
  telefono,
  email,
  direccion
)
VALUES             ('Laura', 'Gomez', '30111222', '1155550001', 'laura.gomez@mail.com', 'Av. Corrientes 1234'),
                   ('Martin', 'Perez', '28333444', '1155550002', NULL, 'Av. Santa Fe 123'),
                   ('Sofia', 'Lopez', '32555666', '1155550003', 'sofia.lopez@mail.com', NULL);

INSERT  INTO Especie (
  nombre
)
VALUES               ('Perro'),
                     ('Gato');

INSERT  INTO Raza (
  id_especie,
  nombre
)
VALUES            (1, 'Labrador'),
                  (1, 'Caniche'),
                  (2, 'Salchicha'),
                  (2, 'Chihuhua');

INSERT  INTO Mascota (
  id_dueno,
  id_raza,
  nombre,
  sexo,
  fecha_nacimiento,
  castrado
)
VALUES               (1, 1, 'Toby', 'M', '2019-03-10', 1),
                     (1, 3, 'Mishi', 'H', '2021-07-22', 1),
                     (2, 2, 'Luna', 'H', '2018-11-05', 0),
                     (3, 4, 'Simba', 'M', '2022-01-15', 0);

INSERT  INTO Alergia (
  nombre,
  tipo,
  id_medicamento
)
VALUES               ('Penicilina', 'MEDICAMENTO', 1),
                     ('Pollo', 'ALIMENTO', NULL),
                     ('Polen', 'AMBIENTAL', NULL);

INSERT  INTO MascotaAlergia (
  id_mascota,
  id_alergia,
  observaciones,
  fecha_deteccion
)
VALUES                      (1, 1, 'Reaccion cutanea tras tratamiento', '2023-05-12'),
                            (3, 2, NULL, '2022-09-01');

-- 3. Personal y Agenda
INSERT  INTO Empleado (
  dni,
  nombre,
  apellido,
  telefono,
  direccion,
  tipo
)
VALUES                (25111000, 'Carlos', 'Ruiz', '1144440001', 'Av. Rivadavia 500', 'veterinario'),
                      (27222000, 'Ana', 'Fernandez', '1144440002', 'Av. Cabildo 2100', 'veterinario'),
                      (32333000, 'Julia', 'Martinez', '1144440003', 'Av. Santa Fe 800', 'administrativo'),
                      (38444000, 'Diego', 'Hernandez', '1144440004', 'Callao 45', 'ayudante');

INSERT  INTO Veterinario (
  id_veterinario,
  matricula
)
VALUES                   (1, 10001),
                         (2, 10002);

INSERT  INTO Administrativo (
  id_administrativo,
  sector
)
VALUES                      (3, 'recepcion');

INSERT  INTO Ayudante (
  id_ayudante,
  area
)
VALUES                (4, 'internacion');

INSERT  INTO Especialidad (
  nombre
)
VALUES                    ('Cardiologia'),
                          ('Dermatologia');

INSERT  INTO VeterinarioEspecialidad (
  id_veterinario,
  id_especialidad
)
VALUES                               (2, 1),
                                     (2, 2);

INSERT  INTO Turno (
  fecha_hora,
  estado,
  id_mascota,
  id_veterinario,
  id_especialidad
)
VALUES             ('2026-10-01 10:00', 'atendido', 1, 2, 1),
                   ('2026-11-05 16:30', 'pendiente', 4, 2, 2);

INSERT  INTO TurnoGuardia (
  fecha_inicio,
  fecha_fin
)
VALUES                    ('2026-10-10 20:00', '2026-10-11 08:00');

INSERT  INTO TurnoGuardiaVeterinario (
  id_turno_guardia,
  id_veterinario
)
VALUES                               (1, 1);

-- 4. Clinica
INSERT  INTO TipoEstudio (
  nombre,
  requiere_turno,
  es_externo
)
VALUES                   ('Radiografia', 1, 0),
                         ('Analisis de sangre', 0, 1);

INSERT  INTO Atencion (
  id_mascota,
  id_veterinario,
  tipo,
  fecha_hora,
  orden_llegada,
  id_turno,
  id_turno_guardia,
  nivel_urgencia,
  motivo,
  peso,
  temperatura,
  diagnostico
)
VALUES                (2, 1, 'GENERAL', '2026-09-20 11:00', 1, NULL, NULL, NULL, 'Control anual', 4.20, 38.5, 'Sana'),
                      (1, 2, 'ESPECIALIDAD', '2026-10-01 10:00', NULL, 1, NULL, NULL, 'Soplo cardiaco', 30.50, 38.7, 'Soplo leve, control en 6 meses'),
                      (3, 1, 'GUARDIA', '2026-10-10 23:15', NULL, NULL, 1, 'ALTA', 'Vomitos y decaimiento', 6.80, 39.8, 'Gastroenteritis aguda');

INSERT  INTO Estudio (
  id_atencion,
  id_tipo_estudio,
  fecha_solicitud,
  fecha_realizacion,
  fecha_resultado,
  resultado
)
VALUES               (2, 1, '2026-10-01 10:30', '2026-10-03 09:00', '2026-10-03 12:00', 'Silueta cardiaca levemente aumentada'),
                     (3, 2, '2026-10-10 23:40', NULL, NULL, NULL);

INSERT  INTO Receta (
  id_atencion,
  fecha,
  indicaciones_generales
)
VALUES              (2, '2026-10-01', 'Reposo y control en 6 meses'),
                    (3, '2026-10-11', 'Dieta blanda por 5 dias');

INSERT  INTO DetalleReceta (
  id_receta,
  id_medicamento,
  dosis,
  frecuencia,
  duracion_dias
)
VALUES                     (1, 2, '0.5 ml', 'Cada 24 hs', 10),
                           (2, 1, '1 comprimido', 'Cada 12 hs', 7);

-- 5. Internacion y Stock
INSERT  INTO internacion.Jaula (
  numero,
  tamano
)
VALUES                         (1, 'chica'),
                               (2, 'grande');

INSERT  INTO Internacion (
  id_atencion,
  id_veterinario,
  id_jaula,
  motivo,
  fecha_hora_ingreso,
  fecha_hora_egreso,
  tipo_egreso
)
VALUES                   (3, 1, 1, 'Deshidratacion por gastroenteritis', '2026-10-10 23:50', '2026-10-12 10:00', 'alta');

INSERT  INTO EvolucionInternacion (
  id_internacion,
  id_empleado,
  fecha_hora,
  temperatura,
  peso,
  observaciones
)
VALUES                            (1, 4, '2026-10-11 08:00', 39.1, 6.70, 'Sin vomitos durante la noche'),
                                  (1, 1, '2026-10-11 18:00', 38.6, 6.75, 'Mejora notable, comienza a comer');

INSERT  INTO UsoMedicamento (
  id_medicamento,
  id_atencion,
  id_evolucion,
  dosis,
  via_aplicacion,
  cantidad
)
VALUES                      (2, 2, NULL, '0.5 ml', 'oral', 1),
                            (1, NULL, 1, '1 comprimido', 'oral', 1);

INSERT  INTO MovimientoStock (
  id_medicamento,
  id_empleado,
  tipo,
  cantidad,
  motivo
)
VALUES                       (1, 3, 'ingreso', 100, 'Compra a proveedor'),
                             (2, 3, 'ingreso', 200, 'Compra a proveedor'),
                             (3, 3, 'ingreso', 30, 'Compra a proveedor'),
                             (1, 3, 'ajuste', -2, 'Vencimiento');


GO
------------------------------------------------------------------------------------
----------------------------------- Funciones --------------------------------------
------------------------------------------------------------------------------------
-- 1 si la mascota existe y no estaba de baja en @fecha, si no 0.
CREATE OR ALTER FUNCTION fn_mascota_activa (
  @id_mascota INT,
  @fecha DATE
)
RETURNS BIT
AS
BEGIN
  IF EXISTS (SELECT 1
             FROM   Mascota
             WHERE  id_mascota = @id_mascota
                    AND (fecha_baja IS NULL
                         OR fecha_baja > @fecha))
    RETURN 1;
  RETURN 0;
END


GO
------------------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_historia_clinica (
  @id_mascota INT
)
RETURNS TABLE 
AS
RETURN 
  (SELECT a.fecha_hora AS fecha,
          'Atencion' AS tipo_evento,
          a.diagnostico AS detalle,
          e.apellido + ', ' + e.nombre AS veterinario
   FROM   Atencion AS a
          INNER JOIN
          Empleado AS e
          ON e.id_empleado = a.id_veterinario
   WHERE  a.id_mascota = @id_mascota
   UNION ALL
   SELECT es.fecha_solicitud,
          'Estudio',
          te.nombre + ': ' + ISNULL(es.resultado, 'sin resultado'),
          e.apellido + ', ' + e.nombre
   FROM   Estudio AS es
          INNER JOIN
          Atencion AS a
          ON a.id_atencion = es.id_atencion
          INNER JOIN
          TipoEstudio AS te
          ON te.id_tipo_estudio = es.id_tipo_estudio
          INNER JOIN
          Empleado AS e
          ON e.id_empleado = a.id_veterinario
   WHERE  a.id_mascota = @id_mascota
   UNION ALL
   SELECT i.fecha_hora_ingreso,
          'Internacion',
          ISNULL(i.motivo, 'sin motivo') + ' - ' + ISNULL(i.tipo_egreso, 'en curso'),
          e.apellido + ', ' + e.nombre
   FROM   Internacion AS i
          INNER JOIN
          Atencion AS a
          ON a.id_atencion = i.id_atencion
          INNER JOIN
          Empleado AS e
          ON e.id_empleado = i.id_veterinario
   WHERE  a.id_mascota = @id_mascota)



GO
------------------------------------------------------------------------------------
-- 1 si el veterinario esta libre, 0 si tiene otro turno o esta de guardia
CREATE OR ALTER FUNCTION fn_veterinario_libre (
  @id_veterinario INT,
  @fecha_hora DATETIME
)
RETURNS BIT
AS
BEGIN
  -- chequeamos si tiene algun turno pendiente que se pise (duran 30 min)
  IF EXISTS (SELECT 1
             FROM   Turno
             WHERE  id_veterinario = @id_veterinario
                    AND estado = 'pendiente'
                    AND abs(datediff(minute, fecha_hora, @fecha_hora)) < 30)
    RETURN 0;
  -- chequeamos que no este de guardia en ese horario (ni que el turno de 30 min se meta en una guardia)
  IF EXISTS (SELECT 1
             FROM   TurnoGuardiaVeterinario AS tgv
                    INNER JOIN
                    TurnoGuardia AS tg
                    ON tg.id_turno_guardia = tgv.id_turno_guardia
             WHERE  tgv.id_veterinario = @id_veterinario
                    AND @fecha_hora < tg.fecha_fin
                    AND dateadd(minute, 30, @fecha_hora) > tg.fecha_inicio)
    RETURN 0;
  RETURN 1;
END


GO
------------------------------------------------------------------------------------
-- asigna un turno pendiente validando mascota, veterinario activo, especialidad y disponibilidad
CREATE OR ALTER PROCEDURE sp_asignar_turno
  @id_mascota INT,
  @id_veterinario INT,
  @fecha_hora DATETIME,
  @id_especialidad INT=NULL -- null si es para estudio
AS
BEGIN
  -- validaciones previas
  IF dbo.fn_mascota_activa(@id_mascota, CAST (@fecha_hora AS DATE)) = 0
    THROW 50000, 'La mascota no esta activa o fue dada de baja', 1;
  IF NOT EXISTS (SELECT 1
                 FROM   Veterinario AS v
                        INNER JOIN
                        Empleado AS e
                        ON e.id_empleado = v.id_veterinario
                 WHERE  v.id_veterinario = @id_veterinario
                        AND e.activo = 1)
    THROW 50000, 'El veterinario no existe o no se encuentra activo', 1;
  IF @fecha_hora < getdate()
    THROW 50000, 'No se puede asignar un turno en una fecha pasada', 1;
  -- si no es estudio, verificamos que el veterinario tenga esa especialidad
  IF @id_especialidad IS NOT NULL
     AND NOT EXISTS (SELECT 1
                     FROM   VeterinarioEspecialidad
                     WHERE  id_veterinario = @id_veterinario
                            AND id_especialidad = @id_especialidad)
    THROW 50000, 'El veterinario no cuenta con esa especialidad', 1;
  IF dbo.fn_veterinario_libre(@id_veterinario, @fecha_hora) = 0
    THROW 50000, 'El veterinario ya esta ocupado o de guardia en ese horario', 1;
  INSERT  INTO Turno (
    fecha_hora,
    estado,
    id_mascota,
    id_veterinario,
    id_especialidad
  )
  VALUES             (@fecha_hora, 'pendiente', @id_mascota, @id_veterinario, @id_especialidad);
END


GO
------------------------------------------------------------------------------------
-- registra la atencion clinica y marca el turno como atendido si corresponde
CREATE OR ALTER PROCEDURE sp_registrar_atencion
  @id_mascota INT,
  @id_veterinario INT,
  @tipo VARCHAR (20),
  @motivo VARCHAR (200),
  @peso DECIMAL (10, 2),
  @temperatura DECIMAL (4, 1)=NULL,
  @diagnostico VARCHAR (500),
  @id_turno INT=NULL,
  @id_turno_guardia INT=NULL,
  @orden_llegada INT=NULL,
  @nivel_urgencia VARCHAR (20)=NULL
AS
BEGIN
  SET XACT_ABORT ON;
  BEGIN TRY
    IF dbo.fn_mascota_activa(@id_mascota, CAST (getdate() AS DATE)) = 0
      THROW 50000, 'La mascota esta dada de baja o no existe', 1;
    -- si es por especialidad, validamos que el turno sea de esa mascota y este pendiente
    -- (que no sea null ya lo controla el check de la tabla)
    IF @tipo = 'ESPECIALIDAD'
      BEGIN
        IF NOT EXISTS (SELECT 1
                       FROM   Turno
                       WHERE  id_turno = @id_turno
                              AND id_mascota = @id_mascota
                              AND estado = 'pendiente')
          THROW 50000, 'El turno no corresponde a la mascota o no esta pendiente', 1;
      END
    BEGIN TRANSACTION;
    INSERT  INTO Atencion (
      id_mascota,
      id_veterinario,
      tipo,
      orden_llegada,
      id_turno,
      id_turno_guardia,
      nivel_urgencia,
      motivo,
      peso,
      temperatura,
      diagnostico
    )
    VALUES                (@id_mascota, @id_veterinario, @tipo, @orden_llegada, @id_turno, @id_turno_guardia, @nivel_urgencia, @motivo, @peso, @temperatura, @diagnostico);
    -- si vino con turno, lo pasamos a atendido
    IF @id_turno IS NOT NULL
      BEGIN
        UPDATE Turno
        SET    estado = 'atendido'
        WHERE  id_turno = @id_turno;
      END
    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@trancount > 0
      ROLLBACK;
    THROW;
  END CATCH
END


GO
------------------------------------------------------------------------------------
-- reasigna turnos pendientes de un veterinario ausente a otro disponible, o los cancela
CREATE OR ALTER PROCEDURE sp_reasignar_turnos
  @id_veterinario INT,
  @desde DATETIME
AS
BEGIN
  SET XACT_ABORT ON;
  DECLARE @id_turno AS INT;
  DECLARE @fecha_hora AS DATETIME;
  DECLARE @id_especialidad AS INT;
  DECLARE @nuevo_vet AS INT;
  DECLARE @reasignados AS INT = 0;
  DECLARE @cancelados AS INT = 0;
  -- usamos cursor fast_forward porque solo avanzamos hacia adelante fila por fila
  DECLARE cur_turnos CURSOR LOCAL FAST_FORWARD
    FOR SELECT   id_turno,
                 fecha_hora,
                 id_especialidad
        FROM     Turno
        WHERE    id_veterinario = @id_veterinario
                 AND estado = 'pendiente'
                 AND fecha_hora >= @desde
        ORDER BY fecha_hora ASC;
  BEGIN TRY
    -- envolvemos todo el recorrido en una transaccion para que sea todo o nada
    BEGIN TRANSACTION;
    OPEN cur_turnos;
    FETCH NEXT FROM cur_turnos INTO @id_turno, @fecha_hora, @id_especialidad;
    WHILE @@fetch_status = 0
      BEGIN
        SET @nuevo_vet = NULL;
        -- buscamos otro veterinario activo, con la misma especialidad (si aplica) y libre
        SELECT TOP 1 @nuevo_vet = v.id_veterinario
        FROM   Veterinario AS v
               INNER JOIN
               Empleado AS e
               ON e.id_empleado = v.id_veterinario
        WHERE  e.activo = 1
               AND v.id_veterinario <> @id_veterinario
               AND (@id_especialidad IS NULL
                    OR EXISTS (SELECT 1
                               FROM   VeterinarioEspecialidad AS ve
                               WHERE  ve.id_veterinario = v.id_veterinario
                                      AND ve.id_especialidad = @id_especialidad))
               AND dbo.fn_veterinario_libre(v.id_veterinario, @fecha_hora) = 1;
        IF @nuevo_vet IS NOT NULL
          BEGIN
            UPDATE Turno
            SET    id_veterinario = @nuevo_vet
            WHERE  id_turno = @id_turno;
            SET @reasignados = @reasignados + 1;
          END
        ELSE
          BEGIN
            -- si no hay nadie libre se cancela
            UPDATE Turno
            SET    estado = 'cancelado'
            WHERE  id_turno = @id_turno;
            SET @cancelados = @cancelados + 1;
          END
        FETCH NEXT FROM cur_turnos INTO @id_turno, @fecha_hora, @id_especialidad;
      END
    CLOSE cur_turnos;
    DEALLOCATE cur_turnos;
    COMMIT TRANSACTION;
    SELECT @reasignados AS turnos_reasignados,
           @cancelados AS turnos_cancelados;
  END TRY
  BEGIN CATCH
    -- si fallo a mitad de camino, revertimos todos los turnos que se hayan llegado a tocar
    IF @@trancount > 0
      ROLLBACK;
    THROW;
  END CATCH
END


GO
CREATE OR ALTER FUNCTION dbo.fn_stock_actual (
  @id_medicamento INT
)
RETURNS INT
AS
BEGIN
  DECLARE @movimientos AS INT = 0;
  DECLARE @usos AS INT = 0;
  DECLARE @stock AS INT = 0;
  SELECT @movimientos = ISNULL(SUM(cantidad), 0)
  FROM   MovimientoStock
  WHERE  id_medicamento = @id_medicamento;
  SELECT @usos = ISNULL(SUM(cantidad), 0)
  FROM   UsoMedicamento
  WHERE  id_medicamento = @id_medicamento;
  SET @stock = @movimientos - @usos;
  RETURN @stock;
END


GO
------------------------------------------------------------------------
----------------------------------- Vistas --------------------------------------
------------------------------------------------------------------------------------
-- Mascota con su dueño, sin dni, telefono ni direccion
CREATE OR ALTER VIEW vw_mascota_dueno
AS
SELECT m.nombre AS Mascota,
       e.nombre AS Especie,
       r.nombre AS Raza,
       m.sexo AS Sexo,
       CASE WHEN m.castrado = 1 THEN 'Si' ELSE 'No' END AS Castrado,
       CASE WHEN dbo.fn_mascota_activa(m.id_mascota, CAST (GETDATE() AS DATE)) = 1 THEN 'Activa' ELSE 'Baja' END AS Estado,
       CONCAT(d.nombre, ' ', d.apellido) AS 'Dueño',
       d.email AS Email
FROM   Mascota AS m
       INNER JOIN
       Raza AS r
       ON r.id_raza = m.id_raza
       INNER JOIN
       Especie AS e
       ON e.id_especie = r.id_especie
       INNER JOIN
       Dueno AS d
       ON d.id_dueno = m.id_dueno;


GO
CREATE OR ALTER VIEW dbo.vw_internaciones_activas
AS
SELECT m.nombre AS mascota,
       es.nombre AS especie,
       j.numero AS numero_jaula,
       e.apellido + ', ' + e.nombre AS veterinario,
       i.fecha_hora_ingreso AS ingreso,
       DATEDIFF(DAY, i.fecha_hora_ingreso, GETDATE()) AS dias_internado,
       i.motivo
FROM   Internacion AS i
       INNER JOIN
       Atencion AS a
       ON a.id_atencion = i.id_atencion
       INNER JOIN
       Mascota AS m
       ON m.id_mascota = a.id_mascota
       INNER JOIN
       Raza AS r
       ON r.id_raza = m.id_raza
       INNER JOIN
       Especie AS es
       ON es.id_especie = r.id_especie
       INNER JOIN
       internacion.Jaula AS j
       ON j.id_jaula = i.id_jaula
       INNER JOIN
       Empleado AS e
       ON e.id_empleado = i.id_veterinario
WHERE  i.fecha_hora_egreso IS NULL;


GO
CREATE OR ALTER VIEW dbo.vw_stock_medicamento
AS
SELECT nombre_comercial AS medicamento,
       droga,
       dbo.fn_stock_actual(id_medicamento) AS stock_actual,
       stock_minimo,
       CASE WHEN dbo.fn_stock_actual(id_medicamento) < stock_minimo THEN N'SÍ' ELSE N'NO' END AS en_falta
FROM   Medicamento
WHERE  activo = 1;


GO
------------------------------------------------------------------------------------
------------------------------- Stored Procedure -----------------------------------
------------------------------------------------------------------------------------
-- Alta de mascota en un paso: si el dueño no existe lo crea.
CREATE OR ALTER PROCEDURE sp_registrar_mascota
  @dni VARCHAR (20),
  @nombre VARCHAR (50),
  @apellido VARCHAR (50),
  @telefono VARCHAR (30),
  @email VARCHAR (100)=NULL,
  @direccion VARCHAR (200)=NULL,
  @nombre_mascota VARCHAR (50),
  @id_raza INT,
  @sexo CHAR (1),
  @fecha_nacimiento DATE,
  @castrado BIT=0
AS
BEGIN
  SET XACT_ABORT ON;
  BEGIN TRY
    DECLARE @id_dueno AS INT;
    BEGIN TRANSACTION;
    SELECT @id_dueno = id_dueno
    FROM   Dueno
    WHERE  dni = @dni;
    IF @id_dueno IS NULL
      BEGIN
        INSERT  INTO Dueno (
          dni,
          nombre,
          apellido,
          telefono,
          email,
          direccion
        )
        VALUES             (@dni, @nombre, @apellido, @telefono, @email, @direccion);
        SET @id_dueno = SCOPE_IDENTITY();
      END
    INSERT  INTO Mascota (
      id_dueno,
      id_raza,
      nombre,
      sexo,
      fecha_nacimiento,
      castrado
    )
    VALUES               (@id_dueno, @id_raza, @nombre_mascota, @sexo, @fecha_nacimiento, @castrado);
    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK;
    THROW;
  END CATCH
END


GO
-- Registra la baja (fallecimiento) de una mascota registrada.
CREATE OR ALTER PROCEDURE sp_baja_mascota
  @id_mascota INT,
  @fecha_baja DATE=NULL
AS
BEGIN
  SET XACT_ABORT ON;
  BEGIN TRY
    IF @fecha_baja IS NULL
      BEGIN
        SET @fecha_baja = CAST (GETDATE() AS DATE);
      END
    IF NOT EXISTS (SELECT 1
                   FROM   Mascota
                   WHERE  id_mascota = @id_mascota)
      THROW 50000, 'La mascota no existe', 1;
    IF EXISTS (SELECT 1
               FROM   Mascota
               WHERE  id_mascota = @id_mascota
                      AND fecha_baja IS NOT NULL)
      THROW 50000, 'La mascota ya está dada de baja', 1;
    BEGIN TRANSACTION;
    UPDATE Mascota
    SET    fecha_baja = @fecha_baja
    WHERE  id_mascota = @id_mascota;
    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK;
    THROW;
  END CATCH
END


GO
CREATE UNIQUE INDEX ux_internacion_jaula_abierta
  ON Internacion(id_jaula) WHERE fecha_hora_egreso IS NULL;


GO
CREATE OR ALTER PROCEDURE dbo.sp_internar_mascota
  @id_atencion INT,
  @id_veterinario INT,
  @id_jaula INT,
  @motivo VARCHAR (500)
AS
BEGIN
  SET XACT_ABORT ON;
  DECLARE @id_mascota AS INT = (SELECT id_mascota
                                FROM   Atencion
                                WHERE  id_atencion = @id_atencion);
  IF @id_mascota IS NULL
    THROW 50000, 'La atencion no existe.', 1;
  IF NOT EXISTS (SELECT 1
                 FROM   internacion.Jaula
                 WHERE  id_jaula = @id_jaula
                        AND activa = 1)
    THROW 50000, 'La jaula no existe o esta dada de baja.', 1;
  IF EXISTS (SELECT 1
             FROM   Internacion
             WHERE  id_jaula = @id_jaula
                    AND fecha_hora_egreso IS NULL)
    THROW 50000, 'La jaula esta ocupada.', 1;
  IF EXISTS (SELECT 1
             FROM   Internacion AS i
                    INNER JOIN
                    Atencion AS a
                    ON a.id_atencion = i.id_atencion
             WHERE  a.id_mascota = @id_mascota
                    AND i.fecha_hora_egreso IS NULL)
    THROW 50000, 'La mascota ya esta internada.', 1;
  IF dbo.fn_mascota_activa(@id_mascota, CAST (GETDATE() AS DATE)) = 0
    THROW 50000, 'La mascota esta de baja.', 1;
  INSERT  INTO Internacion (
    id_atencion,
    id_veterinario,
    id_jaula,
    motivo,
    fecha_hora_ingreso
  )
  VALUES                   (@id_atencion, @id_veterinario, @id_jaula, @motivo, GETDATE());
END


GO
CREATE OR ALTER PROCEDURE dbo.sp_egresar_internacion
  @id_internacion INT,
  @tipo_egreso VARCHAR (10)
AS
BEGIN
  SET XACT_ABORT ON;
  BEGIN TRY
    IF NOT EXISTS (SELECT 1
                   FROM   Internacion
                   WHERE  id_internacion = @id_internacion)
      THROW 50000, 'La internacion no existe.', 1;
    IF EXISTS (SELECT 1
               FROM   Internacion
               WHERE  id_internacion = @id_internacion
                      AND fecha_hora_egreso IS NOT NULL)
      THROW 50000, 'La internacion ya esta cerrada.', 1;
    BEGIN TRANSACTION;
    UPDATE Internacion
    SET    fecha_hora_egreso = GETDATE(),
           tipo_egreso       = @tipo_egreso
    WHERE  id_internacion = @id_internacion;
    IF @tipo_egreso = 'fallecida'
      UPDATE Mascota
      SET    fecha_baja = CAST (GETDATE() AS DATE)
      WHERE  id_mascota = (SELECT a.id_mascota
                           FROM   Internacion AS i
                                  INNER JOIN
                                  Atencion AS a
                                  ON a.id_atencion = i.id_atencion
                           WHERE  i.id_internacion = @id_internacion);
    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK;
    THROW;
  END CATCH
END


GO
CREATE OR ALTER PROCEDURE dbo.sp_aplicar_medicamento
  @id_medicamento INT,
  @cantidad INT,
  @id_atencion INT=NULL,
  @id_evolucion INT=NULL,
  @dosis VARCHAR (100)=NULL,
  @via_aplicacion VARCHAR (50)=NULL
AS
BEGIN
  SET XACT_ABORT ON;
  BEGIN TRY
    IF NOT EXISTS (SELECT 1
                   FROM   Medicamento
                   WHERE  id_medicamento = @id_medicamento
                          AND activo = 1)
      THROW 50000, 'El medicamento no existe o esta inactivo', 1;
    BEGIN TRANSACTION;
    IF dbo.fn_stock_actual(@id_medicamento) < @cantidad
      THROW 50000, 'Stock insuficiente', 1;
    INSERT  INTO UsoMedicamento (
      id_medicamento,
      cantidad,
      id_atencion,
      id_evolucion,
      dosis,
      via_aplicacion
    )
    VALUES                      (@id_medicamento, @cantidad, @id_atencion, @id_evolucion, @dosis, @via_aplicacion);
    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK;
    THROW;
  END CATCH
END


GO
------------------------------------------------------------------------------------
------------------------------------- Trigger --------------------------------------
------------------------------------------------------------------------------------
-- Al dar de baja una mascota: cancela sus turnos pendientes y cierra su internación como fallecida
CREATE OR ALTER TRIGGER tr_mascota_baja
  ON Mascota
  AFTER UPDATE
  AS BEGIN
       UPDATE t
       SET    t.estado = 'cancelado'
       FROM   Turno AS t
              INNER JOIN
              inserted AS n
              ON n.id_mascota = t.id_mascota
       WHERE  t.estado = 'pendiente'
              AND n.fecha_baja IS NOT NULL;
       UPDATE i
       SET    i.fecha_hora_egreso = GETDATE(),
              i.tipo_egreso       = 'fallecida'
       FROM   Internacion AS i
              INNER JOIN
              Atencion AS a
              ON a.id_atencion = i.id_atencion
              INNER JOIN
              inserted AS n
              ON n.id_mascota = a.id_mascota
       WHERE  i.fecha_hora_egreso IS NULL
              AND n.fecha_baja IS NOT NULL;
     END


GO
CREATE OR ALTER TRIGGER dbo.tr_uso_medicamento_stock
  ON UsoMedicamento
  AFTER INSERT
  AS BEGIN
       IF EXISTS (SELECT 1
                  FROM   inserted
                  WHERE  dbo.fn_stock_actual(id_medicamento) < 0)
         THROW 50000, 'Stock insuficiente', 1;
     END


GO
------------------------------------------------------------------------------------
------------------------------------- Subconsultas --------------------------------------
------------------------------------------------------------------------------------
-- S1: Mascotas activas sin atencion en el ultimo año
SELECT m.id_mascota,
       m.nombre
FROM   Mascota AS m
WHERE  dbo.fn_mascota_activa(m.id_mascota, CAST (GETDATE() AS DATE)) = 1
       AND NOT EXISTS (SELECT 1
                       FROM   Atencion AS a
                       WHERE  a.id_mascota = m.id_mascota
                              AND a.fecha_hora >= DATEADD(YEAR, -1, GETDATE())
                              AND a.fecha_hora <= GETDATE());

-- S2: Medicamentos bajo el stock minimo
SELECT m.id_medicamento,
       m.nombre_comercial,
       m.stock_minimo
FROM   Medicamento AS m
WHERE  m.activo = 1
       AND dbo.fn_stock_actual(m.id_medicamento) < m.stock_minimo;

-- S3: Jaulas libres
SELECT j.id_jaula,
       j.numero,
       j.tamano
FROM   internacion.Jaula AS j
WHERE  j.activa = 1
       AND j.id_jaula NOT IN (SELECT i.id_jaula
                              FROM   Internacion AS i
                              WHERE  i.fecha_hora_egreso IS NULL);