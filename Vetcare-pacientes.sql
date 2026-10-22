create table dueño (
	id_dueno  int           identity (1, 1) not null,
	dni       varchar (20)  not null unique,
	nombre    varchar (50)  not null,
	apellido  varchar (50)  not null,
	telefono  varchar (30)  not null,
	email     varchar (100) null,
	direccion varchar (200) null,
	primary key (id_dueno)
);

create table especie (
	id_especie int identity (1, 1) not null,
	nombre     varchar (50) not null unique,
	primary key (id_especie),
	constraint ck_especie_nombre check (nombre in ('Perro', 'Gato'))
);

create table raza (
	id_raza    int identity (1, 1) not null,
	id_especie int not null,
	nombre     varchar (50) not null,
	primary key (id_raza),
	constraint uq_raza_especie_nombre unique (id_especie, nombre)
);

create table mascota (
	id_mascota       int identity (1, 1) not null,
	id_dueno         int not null,
	id_raza          int not null,
	nombre           varchar (50) not null,
	sexo             char (1) not null,
	fecha_nacimiento date not null,
	castrado         bit default 0 not null,
	fecha_baja       date null,
	primary key (id_mascota),
	constraint ck_mascota_sexo check (sexo in ('M', 'H')),
	constraint ck_mascota_fecha_nacimiento check (fecha_nacimiento <= cast(getdate() as date)),
	constraint ck_mascota_fecha_baja check (
		fecha_baja is null or fecha_baja > fecha_nacimiento
	)
);

create table alergia (
	id_alergia     int identity (1, 1) not null,
	nombre         varchar (50) not null unique,
	tipo           varchar (20) not null,
	id_medicamento int null,
	primary key (id_alergia),
	constraint ck_alergia_tipo check (
		tipo in ('MEDICAMENTO', 'ALIMENTO', 'AMBIENTAL', 'OTRO')
	)
);

create table mascotaalergia (
	id_mascota int not null,
	id_alergia int not null,
	primary key (id_mascota, id_alergia)
);

create table tipoestudio (
	id_tipo_estudio int identity (1, 1) not null,
	nombre          varchar (50) not null unique,
	requiere_turno  bit default 0 not null,
	es_externo      bit default 0 not null,
	primary key (id_tipo_estudio)
);

create table atencion (
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
	constraint ck_atencion_tipo check (tipo in ('GENERAL', 'ESPECIALIDAD', 'GUARDIA')),
	constraint ck_atencion_peso check (peso > 0),
	constraint ck_atencion_especialidad_turno check (
		not (tipo = 'ESPECIALIDAD' and id_turno is null)
	),
	constraint ck_atencion_guardia_turno check (
		not (tipo = 'GUARDIA' and id_turno_guardia is null)
	)
);

create unique index uq_atencion_id_turno
	on atencion (id_turno)
	where id_turno is not null;

create table estudio (
	id_estudio        int identity (1, 1) not null,
	id_atencion       int not null,
	id_tipo_estudio   int not null,
	id_turno          int null,
	fecha_solicitud   datetime2 constraint df_estudio_fecha_solicitud default sysdatetime() not null,
	fecha_realizacion datetime2 null,
	fecha_resultado   datetime2 null,
	resultado         varchar (500) null,
	primary key (id_estudio),
	constraint ck_estudio_fecha_resultado check (fecha_resultado > fecha_solicitud)
);

create table receta (
	id_receta              int identity (1, 1) not null,
	id_atencion            int not null,
	fecha                  date default getdate() not null,
	indicaciones_generales varchar (500) null,
	primary key (id_receta)
);

create table detallereceta (
	id_receta      int not null,
	id_medicamento int not null,
	dosis          varchar (50) not null,
	frecuencia     varchar (50) not null,
	duracion_dias  int not null,
	primary key (id_receta, id_medicamento),
	constraint ck_detallereceta_duracion_dias check (duracion_dias > 0)
);

go

alter table raza
	add constraint fk_raza_especie
	foreign key (id_especie) references especie (id_especie);

alter table mascota
	add constraint fk_mascota_dueno
	foreign key (id_dueno) references dueño (id_dueno);

alter table mascota
	add constraint fk_mascota_raza
	foreign key (id_raza) references raza (id_raza);

alter table alergia
	add constraint fk_alergia_medicamento
	foreign key (id_medicamento) references medicamento (id_medicamento);

alter table mascotaalergia
	add constraint fk_mascotaalergia_mascota
	foreign key (id_mascota) references mascota (id_mascota);

alter table mascotaalergia
	add constraint fk_mascotaalergia_alergia
	foreign key (id_alergia) references alergia (id_alergia);

alter table atencion
	add constraint fk_atencion_mascota
	foreign key (id_mascota) references mascota (id_mascota);

alter table atencion
	add constraint fk_atencion_veterinario
	foreign key (id_veterinario) references veterinario (id_empleado);

alter table atencion
	add constraint fk_atencion_turno
	foreign key (id_turno) references turno (id_turno);

alter table atencion
	add constraint fk_atencion_turnoguardia
	foreign key (id_turno_guardia) references turnoguardia (id_turno_guardia);

alter table estudio
	add constraint fk_estudio_atencion
	foreign key (id_atencion) references atencion (id_atencion);

alter table estudio
	add constraint fk_estudio_tipoestudio
	foreign key (id_tipo_estudio) references tipoestudio (id_tipo_estudio);

alter table estudio
	add constraint fk_estudio_turno
	foreign key (id_turno) references turno (id_turno);

alter table receta
	add constraint fk_receta_atencion
	foreign key (id_atencion) references atencion (id_atencion);

alter table detallereceta
	add constraint fk_detallereceta_receta
	foreign key (id_receta) references receta (id_receta);

alter table detallereceta
	add constraint fk_detallereceta_medicamento
	foreign key (id_medicamento) references medicamento (id_medicamento);