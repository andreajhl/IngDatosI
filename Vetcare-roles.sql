use VetCare;
go

create role rol_administrativo;
create role rol_veterinario;
create role rol_ayudante;
go

grant select, insert on Dueno           to rol_administrativo;
grant select, insert on Mascota         to rol_administrativo;
grant select, insert on Turno           to rol_administrativo;
grant select, insert on TurnoGuardia    to rol_administrativo;
grant select, insert on MovimientoStock to rol_administrativo;

deny select on Atencion (diagnostico) to rol_administrativo;
go

grant select, insert on Atencion      to rol_veterinario;
grant select, insert on Estudio       to rol_veterinario;
grant select, insert on Receta        to rol_veterinario;
grant select, insert on DetalleReceta to rol_veterinario;
grant select, insert on Internacion   to rol_veterinario;

deny select on Dueno (dni, telefono, direccion)         to rol_veterinario;
deny select on Atencion (ref_pago_externo, estado_pago) to rol_veterinario;
go

grant select         on Internacion          to rol_ayudante;
grant select, insert on EvolucionInternacion to rol_ayudante;

deny select on Dueno (dni, telefono, email, direccion)                to rol_ayudante;
deny select on Atencion (diagnostico, ref_pago_externo, estado_pago) to rol_ayudante;
go