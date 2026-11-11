ALTER TABLE Raza
	ADD CONSTRAINT FK_Raza_Especie
	FOREIGN KEY (id_especie) REFERENCES Especie (id_especie);

ALTER TABLE Mascota
	ADD CONSTRAINT FK_Mascota_Dueno
	FOREIGN KEY (id_dueno) REFERENCES Dueno (id_dueno);

ALTER TABLE Mascota
	ADD CONSTRAINT FK_Mascota_Raza
	FOREIGN KEY (id_raza) REFERENCES Raza (id_raza);

ALTER TABLE Alergia
	ADD CONSTRAINT FK_Alergia_Medicamento
	FOREIGN KEY (id_medicamento) REFERENCES Medicamento (id_medicamento);

ALTER TABLE MascotaAlergia
	ADD CONSTRAINT FK_MascotaAlergia_Mascota
	FOREIGN KEY (id_mascota) REFERENCES Mascota (id_mascota);

ALTER TABLE MascotaAlergia
	ADD CONSTRAINT FK_MascotaAlergia_Alergia
	FOREIGN KEY (id_alergia) REFERENCES Alergia (id_alergia);