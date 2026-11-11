use ClinicaVeterinaria
go

-- fk subtipos a empleado
alter table Veterinario add foreign key (idVeterinario) references Empleado(idEmpleado)
alter table Administrativo add foreign key (idAdministrativo) references Empleado(idEmpleado)
alter table Ayudante add foreign key (idAyudante) references Empleado(idEmpleado)

-- veterinario especialidad
alter table VeterinarioEspecialidad
    add foreign key (idVeterinario) references Veterinario(idVeterinario)

alter table VeterinarioEspecialidad
    add foreign key (idEspecialidad) references Especialidad(idEspecialidad)

-- turnos
alter table Turno add foreign key (idVeterinario) references Veterinario(idVeterinario)
alter table Turno add foreign key (idEspecialidad) references Especialidad(idEspecialidad)
alter table Turno add foreign key (idMascota) references Mascota(idMascota) -- tabla de opcion 1

-- guardias
alter table TurnoGuardiaVeterinario
    add foreign key (idTurnoGuardia) references TurnoGuardia(idTurnoGuardia)

alter table TurnoGuardiaVeterinario
    add foreign key (idVeterinario) references Veterinario(idVeterinario)
