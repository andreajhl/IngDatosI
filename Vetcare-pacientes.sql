create table Dueno (
	id_dueno  int           identity (1, 1) not null,
	dni       varchar (20)  not null unique,
	nombre    varchar (50)  not null,
	apellido  varchar (50)  not null,
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
	nombre           varchar (50) not null,
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

create table TipoEstudio (
	id_tipo_estudio int identity (1, 1) not null,
	nombre          varchar (50) not null unique,
	requiere_turno  bit default 0 not null,
	es_externo      bit default 0 not null,
	primary key (id_tipo_estudio)
);

create table Atencion (
	id_atencion      int identity (1, 1) not null,
	id_mascota       int not null,
	id_veterinario   int not null,
	tipo             varchar (20) not null,
	fecha_hora       datetime2 default sysdatetime() not null,
	orden_llegada    int null,
	id_turno         int null,
	id_turno_guardia int null,
	nivel_urgencia   varchar (20) null,
	motivo           varchar (200) not null,
	peso             decimal (10, 2) not null,
	temperatura      decimal (4, 1) null,
	diagnostico      varchar (500) not null,
	observaciones    varchar (max) null,
	ref_pago_externo varchar (50) null,
	estado_pago      varchar (20) null,
	primary key (id_atencion),
	constraint CK_Atencion_tipo check (tipo in ('GENERAL', 'ESPECIALIDAD', 'GUARDIA')),
	constraint CK_Atencion_peso check (peso > 0),
	constraint CK_Atencion_especialidad_turno check (
		not (tipo = 'ESPECIALIDAD' and id_turno is null)
	),
	constraint CK_Atencion_guardia_turno check (
		not (tipo = 'GUARDIA' and id_turno_guardia is null)
	)
);

go

create trigger TR_Atencion_turno_unico
on Atencion
after insert, update
as
begin
	if exists (
		select 1
		from Atencion
		where id_turno is not null
		group by id_turno
		having count(*) > 1
	)
	begin
		raiserror('el turno ya esta asignado a otra atencion', 16, 1);
		rollback transaction;
	end
end;

go

create table Estudio (
	id_estudio        int identity (1, 1) not null,
	id_atencion       int not null,
	id_tipo_estudio   int not null,
	id_turno          int null,
	fecha_solicitud   datetime2 constraint DF_Estudio_fecha_solicitud default sysdatetime() not null,
	fecha_realizacion datetime2 null,
	fecha_resultado   datetime2 null,
	resultado         varchar (500) null,
	primary key (id_estudio),
	constraint CK_Estudio_fecha_resultado check (fecha_resultado > fecha_solicitud)
);

create table Receta (
	id_receta              int identity (1, 1) not null,
	id_atencion            int not null,
	fecha                  date default getdate() not null,
	indicaciones_generales varchar (500) null,
	primary key (id_receta)
);

create table DetalleReceta (
	id_receta      int not null,
	id_medicamento int not null,
	dosis          varchar (50) not null,
	frecuencia     varchar (50) not null,
	duracion_dias  int not null,
	primary key (id_receta, id_medicamento),
	constraint CK_DetalleReceta_duracion_dias check (duracion_dias > 0)
);