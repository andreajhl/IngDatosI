CREATE TABLE Dueno (
	id_dueno  int           IDENTITY (1, 1) NOT NULL,
	dni       varchar (20)  NOT NULL UNIQUE,
	telefono  varchar (30)  NOT NULL,
	email     varchar (100) NULL,
	direccion varchar (200) NULL,
	PRIMARY KEY (id_dueno)
);

CREATE TABLE Especie (
	id_especie int IDENTITY (1, 1) NOT NULL,
	nombre     varchar (50) NOT NULL UNIQUE,
	PRIMARY KEY (id_especie),
	CONSTRAINT CK_Especie_nombre CHECK (nombre IN ('Perro', 'Gato'))
);

CREATE TABLE Raza (
	id_raza    int IDENTITY (1, 1) NOT NULL,
	id_especie int NOT NULL,
	nombre     varchar (50) NOT NULL,
	PRIMARY KEY (id_raza),
	CONSTRAINT UQ_Raza_especie_nombre UNIQUE (id_especie, nombre)
);

CREATE TABLE Mascota (
	id_mascota       int IDENTITY (1, 1) NOT NULL,
	id_dueno         int NOT NULL,
	id_raza          int NOT NULL,
	sexo             char (1) NOT NULL,
	fecha_nacimiento date NOT NULL,
	castrado         bit DEFAULT 0 NOT NULL,
	fecha_baja       date NULL,
	PRIMARY KEY (id_mascota),
	CONSTRAINT CK_Mascota_sexo CHECK (sexo IN ('M', 'H')),
	CONSTRAINT CK_Mascota_fecha_nacimiento CHECK (fecha_nacimiento <= CAST(getdate() AS date)),
	CONSTRAINT CK_Mascota_fecha_baja CHECK (
		fecha_baja IS null OR fecha_baja > fecha_nacimiento
	)
);

CREATE TABLE Alergia (
	id_alergia     int IDENTITY (1, 1) NOT NULL,
	nombre         varchar (50) NOT NULL UNIQUE,
	tipo           varchar (20) NOT NULL,
	id_medicamento int NULL,
	PRIMARY KEY (id_alergia),
	CONSTRAINT CK_Alergia_tipo CHECK (
		tipo IN ('MEDICAMENTO', 'ALIMENTO', 'AMBIENTAL', 'OTRO')
	)
);

CREATE TABLE MascotaAlergia (
	id_mascota int NOT NULL,
	id_alergia int NOT NULL,
	PRIMARY KEY (id_mascota, id_alergia)
);