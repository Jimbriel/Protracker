# PRO tracker

Demo de una aplicación móvil para el **control y registro de limpieza en las áreas de cocina** (limpiezas diarias, semanales, profundas y de emergencia), con cronómetro, checklist, fotos de evidencia, firmas digitales, reportes y estadísticas.

> **Es una demo.** No tiene servidor: los datos son de ejemplo (área de Dieta, nombres ficticios) y se guardan solo en el navegador o dispositivo de quien la usa.

- **Abrir la demo:** https://jimbriel.github.io/Protracker/ (en el celular, usar "Agregar a pantalla de inicio" para verla como app).
- **Plan, estado y pendientes del proyecto:** [docs/PLAN_PROYECTO.md](docs/PLAN_PROYECTO.md)
- **Datos reales del área de Dieta usados como base:** [docs/referencia_area_dieta.md](docs/referencia_area_dieta.md)

## Guía de uso de la demo

### 1. Entrar
1. En la pantalla de login escribe cualquier texto en **Email** y toca **Siguiente** (no se valida).
2. Elige con qué usuario entrar. Cada rol ve una parte distinta del flujo:

| Usuario | Rol | Qué hace |
|---|---|---|
| Carlos Méndez, Marta Salazar | Operario, turno H | Limpia pisos, paredes y refrigeradora |
| Ana Rivera, Diego Paz | Operario, turno A | Limpia mesas, bachas y rejillas |
| Luis Ortega | Operario, turno B | Limpia purificador, tumbados, iluminarias y vidrios |
| Patricia Gómez | Jefatura | Asigna tareas y crea emergencias |
| Roberto Vega | Supervisor | Valida y firma las limpiezas |

Para cambiar de usuario: menú (☰) → **Cerrar sesión**.

### 2. Recorrido sugerido (unos 5 minutos)

**A. Operario (entra como Carlos Méndez)**
1. En **Mis tareas** aparecen las tareas del día según su turno, una barra de avance y las tareas atrasadas.
2. Abre **Pisos** y toca **Iniciar**: el cronómetro empieza a correr.
3. Revisa los productos con su concentración, los utensilios, el EPI y los puntos de atención.
4. Marca los pasos del checklist. Deja alguno sin marcar para ver que pide una **observación** obligatoria.
5. En **Evidencia fotográfica** toca **Agregar foto**: *Tomar foto* (cámara del celular), *Elegir de la galería* o **Usar foto de muestra** (para equipos sin cámara).
6. En **Firma del operario** toca **Firmar** y dibuja la firma con el dedo o el mouse.
7. Toca **Finalizar actividad**. Si falta algo, la app lista exactamente qué. Al terminar se abre el **reporte** completo.

**B. Supervisor (cierra sesión y entra como Roberto Vega)**
1. En **Validación → Por validar** aparece la limpieza de Carlos.
2. Ábrela: el reporte muestra fecha, horas, duración, tipo, área, frecuencia, utensilios, químicos, checklist (✔ / ✘), observaciones, fotos y firmas.
3. Toca **Validar y firmar** y dibuja la firma. La limpieza pasa a **Validadas** con las tres firmas (operario, jefatura y supervisor).

**C. Jefatura (entra como Patricia Gómez)**
1. En **Asignación** ve las tareas de hoy agrupadas por turno.
2. Toca el ícono de flechas (⇄) de una tarea pendiente para **reasignarla** a otra persona del turno.
3. Toca el botón rojo **Emergencia** para crear una limpieza de emergencia: elige equipo y persona. Aparece en las tareas de esa persona.

**D. Estadísticas y calendario (Jefatura o Supervisor)**
1. Menú (☰) → **Dashboard**: cambia entre **Semana** y **Mes** para ver limpiezas realizadas, cumplimiento, pendientes, tiempo promedio, frecuencia de limpieza y cumplimiento por área y por equipo.
2. Menú (☰) → **Plan de Tareas**, con cuatro vistas (botones de arriba):
   - por estado, calendario, lista y **horario mensual** (persona × día con la letra del turno; `L` = libre).
   - Toca un día en el calendario para ver sus actividades; los filtros separan diaria, semanal, profunda y emergencia.

### 3. Antes de cada presentación
- Menú (☰) → **Restablecer demo** deja todo como al inicio (tareas de hoy pendientes y la sesión cerrada).
- La demo funciona mejor en el celular o con la ventana angosta del navegador.
- Si algo se ve raro, recarga la página; los datos se conservan.

## Limitaciones de la demo (decirlo al presentar)
- Los datos y las personas son de ejemplo; no hay base de datos ni usuarios reales.
- **Códigos de frecuencia y turnos son supuestos** pendientes de confirmar (DT/DX = diaria, S1 = semanal, ML = profunda; la asignación de equipos a los turnos A, B y H es de ejemplo).
- **Cargar horario** no importa un archivo: el horario del mes ya viene de ejemplo.
- Aún no se exportan reportes a PDF.

## Para desarrolladores

```bash
flutter pub get
flutter run -d chrome
```

```bash
flutter analyze
flutter test
```

Publicación en GitHub Pages: compilar con `flutter build web --release --base-href /Protracker/` y publicar el contenido de `build/web` en la rama `gh-pages`.
