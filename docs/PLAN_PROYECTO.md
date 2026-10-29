# PRO tracker: plan y estado del proyecto

Aplicación móvil (demo) para el **control y registro de limpieza en las áreas de cocina**: limpiezas diarias, semanales (profundas) y de emergencia, con historial, evidencia fotográfica y firmas de validación.

> **Naturaleza del proyecto:** demo para presentar a clientes potenciales. No tiene backend: los datos son simulados y se guardan en el dispositivo. El objetivo es que se vea y se sienta como una app real.

## Objetivo

Mostrar, de punta a punta, cómo el personal de cocina ejecuta sus tareas de limpieza y cómo la jefatura y la supervisión las asignan, validan y analizan.

Requerimientos funcionales (según el documento "Proyecto para el área de limpieza"):

1. **Gestión de usuarios** y asignación de tareas por área o turno.
2. **Firmas digitales** al terminar cada actividad: quien la realizó, la jefatura que la asignó y el supervisor que la valida.
3. **Calendario** de actividades por persona o turno.
4. **Cronómetro** con hora de inicio y fin de cada actividad.
5. **Carga del horario mensual** del personal (persona × día = turno).
6. **Turnos identificados por letra**, cada uno con actividades específicas (pisos, paredes, cortinas, refrigeradores, etc.). Cada actividad se registra por separado.
7. **Tareas del día** visibles al ingresar, según el turno; al terminar cada una se solicitan **fotos de evidencia**.
8. **Reportes** con: fecha, hora de inicio y fin, tipo de actividad, área, frecuencia, utensilios, productos químicos y concentración, checklist de pasos (hecho / no hecho), observaciones, fotos y firmas.
9. **Informes estadísticos** semanales y mensuales, en gráficos o tablas: limpiezas por área, cumplimiento, frecuencia (diaria / semanal / profunda), completadas vs. pendientes y tiempo promedio por actividad.

## Estado actual

El código base viene de un clon visual de Fracttal ONE (sistema de mantenimiento) y **todavía no implementa ninguna función de limpieza**.

| Requerimiento | Estado |
|---|---|
| 1. Usuarios | Pendiente (el login es solo visual) |
| 2. Firmas digitales | Pendiente |
| 3. Calendario | Pendiente (la pantalla muestra un estado vacío) |
| 4. Cronómetro | Pendiente |
| 5. Horario mensual | Pendiente |
| 6. Turnos y actividades | Pendiente |
| 7. Tareas del día y fotos | Pendiente |
| 8. Reportes | Pendiente |
| 9. Estadísticas | Pendiente (hay gráficas de ejemplo con `fl_chart` para reutilizar) |

Reutilizable: tema visual, drawer, tarjetas de KPI, gráficas y estructura de navegación.

Fases 0, 1 y 2 completadas; Fases 3 y 4 hechas en versión reducida: calendario con las actividades de cada día (filtros por tipo, vistas por estado y lista), horario mensual de ejemplo (persona × día) y dashboard con estadísticas reales semanales y mensuales (realizadas, cumplimiento, pendientes, tiempo promedio, frecuencia, por área y por equipo). Falta la exportación a PDF y cargar un horario desde archivo. Para usar la demo ver el [README](../README.md). Fase 2: login por usuario con vistas por rol (operario, jefatura, supervisor), ejecución de actividades con cronómetro, checklist, fotos (cámara, galería o foto de muestra) y firma dibujada, reporte completo, validación del supervisor, reasignación y limpiezas de emergencia. Fase 1: modelos, catálogo de Dieta (10 equipos, 3 turnos A/B/H, 7 usuarios ficticios), historial de 28 días generado, `DemoStore` con persistencia y botón "Restablecer demo"; los indicadores del dashboard ya leen esos datos. Los códigos de frecuencia y la asignación de equipos a turnos son **supuestos** (ver `lib/data/catalog.dart`). Fase 0 (plataformas web y Android, renombrado, limpieza de Fracttal, `flutter analyze` y `flutter test` sin errores).

Deuda técnica conocida:

- El dashboard y el login siguen con datos y textos de ejemplo (gráfica `OtChartCard`); se reemplazan en las Fases 2 y 4.

## Plataforma de presentación

- **Principal:** PWA publicada en GitHub Pages. Se abre con un enlace y en el celular se agrega a la pantalla de inicio para verse como app.
- **Respaldo:** APK de Android, por si falla el internet durante la reunión.

## Plan de actividades

### Fase 0: base
- [x] Habilitar plataformas web y Android (`flutter create .`).
- [x] Renombrar el paquete y las clases a protracker.
- [x] Reemplazar este README por defecto (hecho) y arreglar la prueba rota.
- [x] Quitar los elementos de Fracttal que no aplican.

### Fase 1: datos simulados
- [x] Modelos: usuario (con rol), turno, área, equipo, actividad, checklist, químico y registro de limpieza.
- [x] Datos de ejemplo del área de Dietas, 3 o 4 turnos y unos 5 usuarios.
- [x] Servicio en memoria con persistencia en `shared_preferences`.
- [x] Botón "Restablecer demo".

### Fase 2: flujo central
- [x] Login por usuario, con acceso como operario, jefatura o supervisor.
- [x] "Mis tareas de hoy", filtradas por turno.
- [x] Detalle de actividad: cronómetro, utensilios y químicos, checklist con observaciones, fotos y firma del operario.
- [x] Vista de jefatura: asignar tareas.
- [x] Vista de supervisor: validar y firmar.
- [x] Reporte final de la actividad con todos los campos.

### Fase 3: calendario y horarios
- [x] Calendario con las actividades de cada día (operario ve las suyas; jefatura y supervisor ven todas).
- [x] Horario mensual de ejemplo (persona × día = turno). *El botón "Cargar horario" es simulado; falta importar un archivo.*

### Fase 4: estadísticas
- [x] Gráficas semanales y mensuales (por área, cumplimiento, frecuencia, pendientes, tiempo promedio).
- [ ] Exportar reportes a PDF.

### Fase 5: publicación
- [ ] Manifiesto PWA (nombre, ícono, colores).
- [ ] Publicar en GitHub Pages y generar el APK.
- [ ] Ensayo completo de la demo en un celular real.

## Forma de trabajo

- **Por fases, en orden.** Cada fase termina con la app corriendo y sin errores antes de pasar a la siguiente.
- **Prioridad:** lo que se ve en la presentación. El flujo de la Fase 2 es lo más importante; las Fases 3 y 4 pueden usar datos precargados.
- **Git:** rama `main` estable; cada fase o función en una rama propia (`feat/...`) y commits pequeños en español, con mensaje claro. Se integra a `main` solo cuando funciona.
- **Antes de cada commit:** `flutter analyze` y `flutter test` deben pasar.
- **Claude Code** implementa; **Jimmy** revisa en pantalla, aporta el contenido real (equipos, checklists, químicos) y decide prioridades. Los cambios se muestran corriendo, no solo descritos.
- **Contenido real vs. de ejemplo:** mientras no lleguen los datos reales del socio, se usan datos genéricos y ficticios, fáciles de reemplazar desde un solo archivo de datos.
- **Cambios de alcance:** se anotan en este README para que el socio y el equipo vean lo mismo.

## Ejecutar el proyecto

```bash
flutter pub get
flutter run -d chrome
```

## Contenido de referencia

La tabla del área de Dieta (10 equipos con pasos, utensilios, químicos, puntos de atención y frecuencia) está transcrita en [referencia_area_dieta.md](referencia_area_dieta.md). Es la base de los datos de ejemplo.

## Material pendiente del socio

- Significado de los códigos de frecuencia (DT, DX, S1, ML, DT-1, LD-1).
- Qué equipos corresponden a cada turno (por ejemplo, el turno H).
- Concentración del sanitizante AC 10 DIQUAT.
- Otras áreas de la cocina además de Dieta.
- Ejemplo de un formato de reporte o bitácora actual, si existe.
