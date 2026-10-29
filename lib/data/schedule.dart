import '../data/catalog.dart';
import '../models/cleaning_models.dart';

/// Letra de turno de un operario en una fecha, o 'L' si es su día libre.
///
/// Horario de ejemplo: cada operario tiene un día libre a la semana, distinto
/// según su posición en la lista de usuarios.
String scheduledShift(AppUser user, DateTime date) {
  final operators = kUsers.where((u) => u.role == UserRole.operario).toList();
  final index = operators.indexOf(user);
  final off = (date.weekday + index) % 7 == 0;
  return off ? 'L' : (user.shift ?? '');
}
