create table Dueno (
	id_dueno  int           identity (1, 1) not null,
	dni       varchar (20)  not null unique,
	telefono  varchar (30)  not null,
	email     varchar (100) null,
	direccion varchar (200) null,
	primary key (id_dueno)
);

create table Especie (
	id_especie int identity (1, 1) not null,
	nombre     varchar (50) not null unique,
	primary key (id_especie),
	constraint CK_Especie_nombre check (nombre in ('Perro', 'Gato'))
);

create table Raza (
	id_raza    int identity (1, 1) not null,
	id_especie int not null,
	nombre     varchar (50) not null,
	primary key (id_raza),
	constraint UQ_Raza_especie_nombre unique (id_especie, nombre)
);

create table Mascota (
	id_mascota       int identity (1, 1) not null,
	id_dueno         int not null,
	id_raza          int not null,
	sexo             char (1) not null,
	fecha_nacimiento date not null,
	castrado         bit default 0 not null,
	fecha_baja       date null,
	primary key (id_mascota),
	constraint CK_Mascota_sexo check (sexo in ('M', 'H')),
	constraint CK_Mascota_fecha_nacimiento check (fecha_nacimiento <= cast(getdate() as date)),
	constraint CK_Mascota_fecha_baja check (
		fecha_baja is null or fecha_baja > fecha_nacimiento
	)
);

create table Alergia (
	id_alergia     int identity (1, 1) not null,
	nombre         varchar (50) not null unique,
	tipo           varchar (20) not null,
	id_medicamento int null,
	primary key (id_alergia),
	constraint CK_Alergia_tipo check (
		tipo in ('MEDICAMENTO', 'ALIMENTO', 'AMBIENTAL', 'OTRO')
	)
);

create table MascotaAlergia (
	id_mascota int not null,
	id_alergia int not null,
	primary key (id_mascota, id_alergia)
);