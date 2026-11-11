# VetCare

Base de datos (SQL Server) para la administración de una veterinaria. TP integrador de Ingeniería de Datos I.

### Integrantes
* Miyasato, Ryu
* Ortega, Joaquin
* Hernandez, Andrea
* Vega, Nicolas

## Contenido

**`main.sql`** es el script completo. Se ejecuta de punta a punta y está dividido en bloques:

1. **Creación de tablas y relaciones**: base de datos, tablas por módulo, FKs, roles y permisos sobre tablas
2. **Carga de datos**: datos de prueba
3. **Índices**
4. **Funciones**: `fn_mascota_activa`, `fn_veterinario_libre`, `fn_stock_actual`, `fn_historia_clinica`
5. **Vistas**: `vw_mascota_dueno`, `vw_internaciones_activas`, `vw_stock_medicamento`
6. **Stored procedures**: alta y baja de mascotas, turnos, atenciones, internaciones y medicamentos
7. **Triggers**: `tr_mascota_baja`, `tr_uso_medicamento_stock`
8. **Subconsultas** (S1–S3)
9. **Permisos sobre vistas, funciones y SP**
10. **Pruebas**

Los demás `.sql` son los scripts parciales de cada módulo, ya integrados en `main.sql`:

| Módulo | Tablas | FKs |
|---|---|---|
| Pacientes (dueños, mascotas, especies, alergias) | `Vetcare-pacientes.sql` | `Vetcare-fk-pacientes.sql` |
| Personal y agenda (empleados, especialidades, turnos, guardias) | `vetcare-tablas-PersonalAgenda.sql` | `vetcare-FK-PersonalAgenda.sql` |
| Clínica (atenciones, estudios, recetas) | `vetcare-tablas_clinical.sql` | `vetcare-fk-clinical.sql` |
| Internación y stock (jaulas, internaciones, medicamentos) | `Vetcare-Tablas-Internacion-Stock.sql` | — |
| Roles (`rol_administrativo`, `rol_veterinario`, `rol_ayudante`) | `Vetcare-roles.sql` | — |
