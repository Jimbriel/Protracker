import '../models/cleaning_models.dart';

// Catálogo del área de Dieta, transcrito de docs/referencia_area_dieta.md.
//
// SUPUESTOS pendientes de confirmar con el socio:
// - Códigos de frecuencia: DT y DX = diaria, S1 = semanal, ML = profunda.
// - Qué equipos corresponden a cada turno (los turnos A, B y H son de ejemplo).

const kArea = 'Dieta';

const kSumaUlc = Chemical(
  id: 'suma-ulc',
  name: 'Suma ULC',
  concentration: '15 ml/litro',
);
const kBreakUpChlor = Chemical(
  id: 'break-up-chlor',
  name: 'Break Up Chlor',
  concentration: '15 ml/litro',
);
const kGlanceHd = Chemical(
  id: 'glance-hd',
  name: 'Glance HD',
  concentration: '20 ml/litro',
);
const kSanitizante = Chemical(
  id: 'ac-10-diquat',
  name: 'Sanitizante AC 10 DIQUAT',
);

const kChemicals = [kSumaUlc, kBreakUpChlor, kGlanceHd, kSanitizante];

const _epiAltura = 'Equipo de protección contra caídas de altura';
const _internaExterna = 'Limpiar tanto la parte interna como la externa';
const _alrededor = 'Realizar la limpieza alrededor del equipo';
const _rincones = 'Prestar especial atención a rincones y juntas';

const kEquipment = [
  Equipment(
    id: 'refrigeradora',
    name: 'Refrigeradora',
    area: kArea,
    steps: [
      'Retirar la reja',
      'Quitar los residuos de productos',
      'Limpiar con vileda empapado en agua caliente y Suma ULC',
      'Pasar vileda por la superficie interna y externa',
      'Enjuagar con agua y secar con paño limpio',
    ],
    utensils: ['Vileda', 'Balde de agua / manguera', 'Papel desechable'],
    ppe: ['Gafas', 'Guantes', 'Protector facial', 'Protector frontal de plástico'],
    chemicalId: 'suma-ulc',
    attentionPoints: [_internaExterna, _alrededor],
    frequencyCodes: ['DT'],
    frequencies: [CleaningType.daily],
    typicalMinutes: 25,
  ),
  Equipment(
    id: 'purificador',
    name: 'Purificador de agua',
    area: kArea,
    steps: [
      'Rociar la superficie con el atomizador de Suma ULC',
      'Limpiar con toalla desechable',
      'Enjuagar con paño humedecido en agua',
    ],
    utensils: ['Atomizador', 'Papel desechable'],
    ppe: [],
    chemicalId: 'suma-ulc',
    attentionPoints: [_internaExterna, _alrededor],
    frequencyCodes: ['S1'],
    frequencies: [CleaningType.weekly],
    typicalMinutes: 10,
  ),
  Equipment(
    id: 'mesas',
    name: 'Mesas de trabajo',
    area: kArea,
    steps: [
      'Desocupar la mesa',
      'Retirar la suciedad gruesa y limpiar con vileda empapado en agua caliente y Suma ULC',
      'Cepillar la superficie de la estantería',
      'Enjuagar con paño empapado en agua caliente',
      'Secar con paño desechable limpio',
      'Sanitizar',
    ],
    utensils: [
      'Atomizador con Suma ULC',
      'Vileda',
      'Paño desechable',
      'Cepillo de mano',
      'Sanitizante AC 10 DIQUAT',
      'Balde con agua caliente',
    ],
    ppe: ['Guantes'],
    chemicalId: 'suma-ulc',
    attentionPoints: [_rincones],
    frequencyCodes: ['DX'],
    frequencies: [CleaningType.daily],
    typicalMinutes: 30,
  ),
  Equipment(
    id: 'bachas',
    name: 'Bachas de 2 pozos',
    area: kArea,
    steps: [
      'Limpiar con agua caliente y Suma ULC',
      'Pasar vileda por todo el lavamanos',
      'Enjuagar bien con agua caliente, eliminando todos los residuos de limpieza',
      'Secar con paño desechable',
    ],
    utensils: ['Vileda', 'Balde de agua / manguera', 'Papel desechable', 'Guantes'],
    ppe: ['Guantes'],
    chemicalId: 'suma-ulc',
    attentionPoints: [_internaExterna, _alrededor],
    frequencyCodes: ['DX'],
    frequencies: [CleaningType.daily],
    typicalMinutes: 15,
  ),
  Equipment(
    id: 'rejillas',
    name: 'Rejillas',
    area: kArea,
    steps: [
      'Retirar la reja protectora',
      'Retirar la basura con escoba y pala',
      'Verter la solución y cepillar para eliminar la suciedad',
    ],
    utensils: [
      'Solución de Break Up y agua caliente',
      'Escoba',
      'Cepillo de piso',
      'Pala recogedora',
    ],
    ppe: ['Guantes', 'Botas'],
    chemicalId: 'break-up-chlor',
    attentionPoints: ['Esquinas', 'Revisar el estado en que se encuentra la baldosa'],
    frequencyCodes: ['DT'],
    frequencies: [CleaningType.daily],
    typicalMinutes: 15,
  ),
  Equipment(
    id: 'tumbados',
    name: 'Tumbados',
    area: kArea,
    steps: [
      'Rociar Suma ULC',
      'Eliminar la suciedad con paño; si es necesario usar cepillo',
      'Limpiar con paño desechable',
    ],
    utensils: ['Atomizador con Suma ULC', 'Paño desechable', 'Cepillo de mano', 'Escalera'],
    ppe: ['Gafas', 'Guantes', _epiAltura],
    chemicalId: 'suma-ulc',
    attentionPoints: [_rincones, 'No olvidar usar EPI'],
    frequencyCodes: ['S1'],
    frequencies: [CleaningType.weekly],
    typicalMinutes: 35,
  ),
  Equipment(
    id: 'iluminarias',
    name: 'Iluminarias',
    area: kArea,
    steps: [
      'Retirar la reja',
      'Quitar los residuos de productos',
      'Limpiar con vileda empapado en agua caliente y Suma ULC',
      'Pasar vileda por la superficie interna y externa',
      'Enjuagar con agua y secar con paño limpio',
    ],
    utensils: ['Vileda', 'Balde de agua / manguera', 'Papel desechable'],
    ppe: ['Gafas', 'Guantes', 'Protector facial', 'Protector frontal de plástico'],
    chemicalId: 'suma-ulc',
    attentionPoints: [_internaExterna, _alrededor],
    frequencyCodes: ['S1'],
    frequencies: [CleaningType.weekly],
    typicalMinutes: 30,
  ),
  Equipment(
    id: 'pisos',
    name: 'Pisos',
    area: kArea,
    steps: [
      'Colocar advertencia de seguridad',
      'Retirar materiales y equipos móviles',
      'Barrer con escoba',
      'Recoger polvo y suciedad con pala',
      'Si es necesario, usar espátula para retirar suciedad adherida',
      'Esparcir Break Up Chlor con atomizador',
      'Esparcir solución y cepillar de forma uniforme todo el piso',
      'Botar el agua y usar scullí para eliminar la solución y el Break Up Chlor',
      'Retirar la advertencia de seguridad',
    ],
    utensils: [
      'Escoba y pala',
      'Balde',
      'Solución preparada con agua y detergente',
      'Atomizador con Break Up Chlor',
      'Scullí',
      'Cepillo de piso',
    ],
    ppe: ['Guantes', 'Botas'],
    chemicalId: 'break-up-chlor',
    attentionPoints: [
      'Suciedad pegada en el piso',
      'Rincones, juntas y esquinas',
      'Áreas debajo de equipos y mesas',
    ],
    frequencyCodes: ['ML', 'DT-1', 'LD-1'],
    frequencies: [CleaningType.daily, CleaningType.deep],
    typicalMinutes: 45,
  ),
  Equipment(
    id: 'paredes',
    name: 'Paredes',
    area: kArea,
    steps: [
      'Rociar Suma ULC sobre la superficie',
      'Con cepillo retirar la suciedad adherida; usar espátula o vileda si es necesario',
      'Enjuagar con agua caliente',
      'Secar con paño limpio',
    ],
    utensils: [
      'Agua caliente',
      'Atomizador con Break Up Chlor',
      'Vileda y paño',
      'Cepillo de mano / espátula',
      'Escalera',
    ],
    ppe: ['Guantes', 'Botas', _epiAltura],
    chemicalId: 'break-up-chlor',
    attentionPoints: [
      'Separar los elementos apoyados en las paredes para limpiar detrás',
      'Pasar el cepillo por las hendiduras',
    ],
    frequencyCodes: ['S1'],
    frequencies: [CleaningType.weekly],
    typicalMinutes: 40,
  ),
  Equipment(
    id: 'vidrios',
    name: 'Vidrios',
    area: kArea,
    steps: [
      'Retirar con paño el polvo adherido',
      'Rociar con Glance HD',
      'Pasar vileda por toda la superficie',
      'Secar con toallas de papel o paño limpio',
    ],
    utensils: ['Atomizador con Glance HD', 'Vileda', 'Escalera', 'Toallas de papel / paño'],
    ppe: ['Guantes', _epiAltura],
    chemicalId: 'glance-hd',
    attentionPoints: ['Bordes y orilla', 'Manchas en vidrios, especialmente las de grasa'],
    frequencyCodes: ['S1'],
    frequencies: [CleaningType.weekly],
    typicalMinutes: 20,
  ),
];

const kShifts = [
  Shift(
    letter: 'A',
    name: 'Turno A (mañana)',
    startHour: 6,
    equipmentIds: ['mesas', 'bachas', 'rejillas'],
  ),
  Shift(
    letter: 'B',
    name: 'Turno B (tarde)',
    startHour: 14,
    equipmentIds: ['purificador', 'tumbados', 'iluminarias', 'vidrios'],
  ),
  Shift(
    letter: 'H',
    name: 'Turno H (intermedio)',
    startHour: 10,
    equipmentIds: ['pisos', 'paredes', 'refrigeradora'],
  ),
];

// Nombres ficticios.
const kUsers = [
  AppUser(id: 'u-carlos', name: 'Carlos Méndez', role: UserRole.operario, shift: 'H'),
  AppUser(id: 'u-marta', name: 'Marta Salazar', role: UserRole.operario, shift: 'H'),
  AppUser(id: 'u-ana', name: 'Ana Rivera', role: UserRole.operario, shift: 'A'),
  AppUser(id: 'u-diego', name: 'Diego Paz', role: UserRole.operario, shift: 'A'),
  AppUser(id: 'u-luis', name: 'Luis Ortega', role: UserRole.operario, shift: 'B'),
  AppUser(id: 'u-patricia', name: 'Patricia Gómez', role: UserRole.jefatura),
  AppUser(id: 'u-roberto', name: 'Roberto Vega', role: UserRole.supervisor),
];

const kJefaturaId = 'u-patricia';
