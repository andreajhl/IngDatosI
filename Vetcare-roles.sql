USE VetCare;
GO

-- =========================
-- ROLES
-- =========================
CREATE ROLE rol_administrativo;
CREATE ROLE rol_veterinario;
CREATE ROLE rol_ayudante;
GO

-- =========================
-- rol_administrativo
-- Registra duenos y mascotas, da turnos, carga guardias y stock.
-- Ve contacto del dueno. NO ve diagnosticos.
-- =========================
GRANT SELECT, INSERT, UPDATE ON Dueno          TO rol_administrativo;
GRANT SELECT, INSERT, UPDATE ON Mascota        TO rol_administrativo;
GRANT SELECT, INSERT, UPDATE ON MascotaAlergia TO rol_administrativo;
GRANT SELECT                 ON Especie        TO rol_administrativo;
GRANT SELECT                 ON Raza           TO rol_administrativo;
GRANT SELECT                 ON Alergia        TO rol_administrativo;
GRANT SELECT                 ON Atencion       TO rol_administrativo;

-- Descomentar y ajustar nombres segun el resto del esquema:
-- GRANT SELECT, INSERT, UPDATE ON Turno           TO rol_administrativo;
-- GRANT SELECT, INSERT, UPDATE ON TurnoGuardia    TO rol_administrativo;
-- GRANT SELECT, INSERT         ON MovimientoStock TO rol_administrativo;

DENY SELECT ON Atencion (diagnostico) TO rol_administrativo;
GO

-- =========================
-- rol_veterinario
-- Registra atenciones, estudios, recetas e internaciones. Ve historia clinica.
-- NO ve DNI, telefono, direccion ni pagos.
-- =========================
GRANT SELECT, INSERT, UPDATE ON Atencion       TO rol_veterinario;
GRANT SELECT, INSERT, UPDATE ON Estudio        TO rol_veterinario;
GRANT SELECT, INSERT, UPDATE ON Receta         TO rol_veterinario;
GRANT SELECT, INSERT, UPDATE ON DetalleReceta  TO rol_veterinario;
GRANT SELECT                 ON TipoEstudio    TO rol_veterinario;
GRANT SELECT                 ON Dueno          TO rol_veterinario;
GRANT SELECT                 ON Mascota        TO rol_veterinario;
GRANT SELECT                 ON MascotaAlergia TO rol_veterinario;
GRANT SELECT                 ON Alergia        TO rol_veterinario;
GRANT SELECT                 ON Especie        TO rol_veterinario;
GRANT SELECT                 ON Raza           TO rol_veterinario;

-- Descomentar y ajustar nombres:
-- GRANT SELECT, INSERT, UPDATE ON Internacion TO rol_veterinario;
-- GRANT SELECT                 ON Medicamento TO rol_veterinario;

 DENY SELECT ON Dueno (dni, telefono, direccion)        TO rol_veterinario;
 DENY SELECT ON Atencion (ref_pago_externo, estado_pago) TO rol_veterinario;
GO

-- =========================
-- rol_ayudante
-- Carga la evolucion de los internados y ve las internaciones activas.
-- NO ve datos sensibles, diagnosticos ni pagos.
-- =========================
GRANT SELECT ON Mascota TO rol_ayudante;

-- Descomentar y ajustar nombres:
-- GRANT SELECT         ON Internacion          TO rol_ayudante;
-- GRANT SELECT, INSERT ON EvolucionInternacion TO rol_ayudante;

DENY SELECT ON Dueno (dni, telefono, email, direccion)                 TO rol_ayudante;
DENY SELECT ON Atencion (diagnostico, ref_pago_externo, estado_pago)  TO rol_ayudante;
GO

-- =========================
-- Ejemplo de asignacion de rol a un usuario (opcional)
-- =========================
-- CREATE USER usuario_vet WITHOUT LOGIN;
-- ALTER ROLE rol_veterinario ADD MEMBER usuario_vet;