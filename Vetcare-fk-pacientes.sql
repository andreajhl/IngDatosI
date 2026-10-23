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