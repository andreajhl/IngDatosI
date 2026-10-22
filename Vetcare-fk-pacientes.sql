alter table Raza
	add constraint FK_Raza_Especie
	foreign key (id_especie) references Especie (id_especie);

alter table Mascota
	add constraint FK_Mascota_Dueno
	foreign key (id_dueno) references Dueno (id_dueno);

alter table Mascota
	add constraint FK_Mascota_Raza
	foreign key (id_raza) references Raza (id_raza);

alter table Alergia
	add constraint FK_Alergia_Medicamento
	foreign key (id_medicamento) references Medicamento (id_medicamento);

alter table MascotaAlergia
	add constraint FK_MascotaAlergia_Mascota
	foreign key (id_mascota) references Mascota (id_mascota);

alter table MascotaAlergia
	add constraint FK_MascotaAlergia_Alergia
	foreign key (id_alergia) references Alergia (id_alergia);

alter table Atencion
	add constraint FK_Atencion_Mascota
	foreign key (id_mascota) references Mascota (id_mascota);

alter table Atencion
	add constraint FK_Atencion_Veterinario
	foreign key (id_veterinario) references Veterinario (id_empleado);

alter table Atencion
	add constraint FK_Atencion_Turno
	foreign key (id_turno) references Turno (id_turno);

alter table Atencion
	add constraint FK_Atencion_TurnoGuardia
	foreign key (id_turno_guardia) references TurnoGuardia (id_turno_guardia);

alter table Estudio
	add constraint FK_Estudio_Atencion
	foreign key (id_atencion) references Atencion (id_atencion);

alter table Estudio
	add constraint FK_Estudio_TipoEstudio
	foreign key (id_tipo_estudio) references TipoEstudio (id_tipo_estudio);

alter table Estudio
	add constraint FK_Estudio_Turno
	foreign key (id_turno) references Turno (id_turno);

alter table Receta
	add constraint FK_Receta_Atencion
	foreign key (id_atencion) references Atencion (id_atencion);

alter table DetalleReceta
	add constraint FK_DetalleReceta_Receta
	foreign key (id_receta) references Receta (id_receta);

alter table DetalleReceta
	add constraint FK_DetalleReceta_Medicamento
	foreign key (id_medicamento) references Medicamento (id_medicamento);