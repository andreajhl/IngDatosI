USE master;

DROP DATABASE IF EXISTS VetCare;

GO

CREATE DATABASE VetCare;
GO

USE VetCare;

GO

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
  fecha_hora       DATETIME2       DEFAULT SYSDATETIME() NOT NULL,
  orden_llegada    INT             NULL,
  id_turno         INT             NULL,
  id_turno_guardia INT             NULL,
  nivel_urgencia   VARCHAR (20)    NULL,
  motivo           VARCHAR (200)   NOT NULL,
  peso             DECIMAL (10, 2) NOT NULL,
  temperatura      DECIMAL (4, 1)  NULL,
  diagnostico      VARCHAR (500)   NOT NULL,
  observaciones    TEXT            NULL,
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
  fecha_solicitud   DATETIME2     CONSTRAINT DF_Estudio_fecha_solicitud DEFAULT SYSDATETIME() NOT NULL,
  fecha_realizacion DATETIME2     NULL,
  fecha_resultado   DATETIME2     NULL,
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