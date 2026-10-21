-- Atencion
ALTER TABLE Atencion
  ADD CONSTRAINT FK_Atencion_Mascota FOREIGN KEY (id_mascota) REFERENCES Mascota (id_mascota);

ALTER TABLE Atencion
  ADD CONSTRAINT FK_Atencion_Veterinario FOREIGN KEY (id_veterinario) REFERENCES Veterinario (id_empleado);

ALTER TABLE Atencion
  ADD CONSTRAINT FK_Atencion_Turno FOREIGN KEY (id_turno) REFERENCES Turno (id_turno);

ALTER TABLE Atencion
  ADD CONSTRAINT FK_Atencion_TurnoGuardia FOREIGN KEY (id_turno_guardia) REFERENCES TurnoGuardia (id_turno_guardia);


GO
-- Estudio
ALTER TABLE Estudio
  ADD CONSTRAINT FK_Estudio_Atencion FOREIGN KEY (id_atencion) REFERENCES Atencion (id_atencion);

ALTER TABLE Estudio
  ADD CONSTRAINT FK_Estudio_TipoEstudio FOREIGN KEY (id_tipo_estudio) REFERENCES TipoEstudio (id_tipo_estudio);

ALTER TABLE Estudio
  ADD CONSTRAINT FK_Estudio_Turno FOREIGN KEY (id_turno) REFERENCES Turno (id_turno);


GO
-- Receta
ALTER TABLE Receta
  ADD CONSTRAINT FK_Receta_Atencion FOREIGN KEY (id_atencion) REFERENCES Atencion (id_atencion);


GO
-- DetalleReceta
ALTER TABLE DetalleReceta
  ADD CONSTRAINT FK_DetalleReceta_Receta FOREIGN KEY (id_receta) REFERENCES Receta (id_receta);

ALTER TABLE DetalleReceta
  ADD CONSTRAINT FK_DetalleReceta_Medicamento FOREIGN KEY (id_medicamento) REFERENCES Medicamento (id_medicamento);
  