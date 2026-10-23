create database ClinicaVeterinaria
go
use ClinicaVeterinaria
go

create table Empleado (
    idEmpleado int identity(1,1) primary key,
    dni int not null unique, -- dato sensible
    nombre varchar(50) not null,
    apellido varchar(50) not null,
    telefono varchar(20) not null, -- dato sensible
    direccion varchar(100) not null, -- dato sensible
    tipo varchar(20) not null check (tipo in ('veterinario', 'administrativo', 'ayudante')),
    activo bit not null default 1 -- baja logica
)

create table Veterinario (
    idVeterinario int not null primary key,
    matricula int not null unique
);

create table Administrativo (
    idAdministrativo int not null primary key,
    sector varchar(30) not null check (sector in ('recepcion', 'facturacion', 'administracion'))
)

create table Ayudante (
    idAyudante int not null primary key,
    area varchar(20) not null check (area in ('consultorio', 'internacion', 'internación'))
);

create table Especialidad (
    idEspecialidad int identity(1,1) primary key,
    nombre varchar(50) not null unique
)

create table VeterinarioEspecialidad (
    idVeterinario int not null,
    idEspecialidad int not null,
    primary key (idVeterinario, idEspecialidad)
)

-- turnos y guardias
create table Turno (
    idTurno int identity(1,1) primary key,
    fechaHora datetime not null,
    estado varchar(15) not null default 'pendiente' check (estado in ('pendiente', 'atendido', 'cancelado', 'ausente')),
    idMascota int not null,
    idVeterinario int not null,
    idEspecialidad int null
);

create table TurnoGuardia (
    idTurnoGuardia int identity(1,1) primary key,
    fechaInicio datetime not null,
    fechaFin datetime not null,
    check (fechaFin > fechaInicio)
)

create table TurnoGuardiaVeterinario (
    idTurnoGuardia int not null,
    idVeterinario int not null,
    primary key (idTurnoGuardia, idVeterinario)
)