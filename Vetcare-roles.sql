use VetCare;
go

create role rol_administrativo;
create role rol_veterinario;
create role rol_ayudante;
go

grant select, insert, update on Dueno           to rol_administrativo;
grant select, insert, update on Mascota         to rol_administrativo;
grant select, insert, update on MascotaAlergia  to rol_administrativo;
grant select, insert, update on Turno           to rol_administrativo;
grant select, insert, update on TurnoGuardia    to rol_administrativo;
grant select, insert         on MovimientoStock to rol_administrativo;
grant select                 on Especie         to rol_administrativo;
grant select                 on Raza            to rol_administrativo;
grant select                 on Alergia         to rol_administrativo;
grant select                 on Veterinario     to rol_administrativo;
grant select                 on Medicamento     to rol_administrativo;
grant select                 on Atencion        to rol_administrativo;

deny select on Atencion (diagnostico) to rol_administrativo;
go

grant select, insert, update on Atencion             to rol_veterinario;
grant select, insert, update on Estudio              to rol_veterinario;
grant select, insert, update on Receta               to rol_veterinario;
grant select, insert, update on DetalleReceta        to rol_veterinario;
grant select, insert, update on Internacion          to rol_veterinario;
grant select, insert, update on EvolucionInternacion to rol_veterinario;
grant select                 on TipoEstudio          to rol_veterinario;
grant select                 on Medicamento          to rol_veterinario;
grant select                 on Dueno                to rol_veterinario;
grant select                 on Mascota              to rol_veterinario;
grant select                 on MascotaAlergia       to rol_veterinario;
grant select                 on Alergia              to rol_veterinario;
grant select                 on Especie              to rol_veterinario;
grant select                 on Raza                 to rol_veterinario;

deny select on Dueno (dni, telefono, direccion)         to rol_veterinario;
deny select on Atencion (ref_pago_externo, estado_pago) to rol_veterinario;
go

grant select         on Mascota              to rol_ayudante;
grant select         on Internacion          to rol_ayudante;
grant select, insert on EvolucionInternacion to rol_ayudante;

deny select on Dueno (dni, telefono, email, direccion)                to rol_ayudante;
deny select on Atencion (diagnostico, ref_pago_externo, estado_pago) to rol_ayudante;
go