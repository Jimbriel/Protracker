import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../data/catalog.dart';
import '../data/demo_store.dart';
import '../data/schedule.dart';
import '../models/cleaning_models.dart';
import '../widgets/activity_tile.dart';
import '../widgets/app_bar_actions.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';
import 'activity_screen.dart';
import 'report_screen.dart';

enum _View { kanban, calendar, list, schedule }

const _viewTitles = {
  _View.kanban: 'Vista por estado',
  _View.calendar: 'Vista Calendario',
  _View.list: 'Vista Lista',
  _View.schedule: 'Horario mensual',
};

/// Plan de tareas: calendario, lista, estados y horario mensual.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  _View _view = _View.calendar;
  DateTime _selectedDate = DateTime.now();
  CleaningType? _type; // null = todas

  List<CleaningActivity> _activitiesOn(DateTime day) {
    final store = DemoStore.instance;
    final user = store.currentUser;
    final base = (user == null || user.role != UserRole.operario)
        ? store.activitiesOn(day)
        : store.tasksFor(user, day);
    return [
      for (final a in base)
        if (_type == null || a.type == _type) a,
    ];
  }

  void _open(CleaningActivity a) {
    final user = DemoStore.instance.currentUser;
    final runnable = user?.role == UserRole.operario &&
        user!.id == a.assignedToId &&
        !a.isDone;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => runnable
            ? ActivityScreen(activityId: a.id)
            : ReportScreen(activityId: a.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan de Tareas',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              _viewTitles[_view]!,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: const [AppBarActions()],
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: ListenableBuilder(
        listenable: DemoStore.instance,
        builder: (context, _) => Column(
          children: [
            _buildViewModeBar(),
            if (_view != _View.schedule) _buildFilters(),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_view) {
      case _View.schedule:
        return _ScheduleGrid(month: _selectedDate);
      case _View.kanban:
        final items = _activitiesOn(_selectedDate);
        if (items.isEmpty) return const EmptyState();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            for (final s in ActivityStatus.values) ...[
              SectionTitle(s.label.toUpperCase()),
              for (final a in items.where((a) => a.status == s))
                ActivityTile(
                  activity: a,
                  showAssignee: true,
                  onTap: () => _open(a),
                ),
            ],
          ],
        );
      case _View.list:
        return _list();
      case _View.calendar:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: CalendarDatePicker(
                key: ValueKey(_selectedDate),
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(
                  const Duration(days: 60),
                ),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                onDateChanged: (d) => setState(() => _selectedDate = d),
              ),
            ),
            ..._listChildren(),
          ],
        );
    }
  }

  Widget _list() {
    final children = _listChildren();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: children,
    );
  }

  List<Widget> _listChildren() {
    final items = _activitiesOn(_selectedDate);
    return [
      SectionTitle(
        '${DateFormat('dd/MM/yyyy').format(_selectedDate)} · '
        '${items.length} actividades',
      ),
      if (items.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 24),
          child: EmptyState(label: 'Sin actividades este día'),
        ),
      for (final a in items)
        ActivityTile(activity: a, showAssignee: true, onTap: () => _open(a)),
    ];
  }

  Widget _buildViewModeBar() {
    Widget btn(_View v, IconData icon) => _ViewModeBtn(
          icon: icon,
          active: _view == v,
          onTap: () => setState(() => _view = v),
        );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.iconBg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          btn(_View.kanban, Icons.view_week_outlined),
          btn(_View.calendar, Icons.calendar_month_rounded),
          btn(_View.list, Icons.format_list_bulleted_rounded),
          btn(_View.schedule, Icons.grid_on_rounded),
          const Spacer(),
          IconButton(
            tooltip: 'Hoy',
            onPressed: () => setState(() => _selectedDate = DateTime.now()),
            icon: const Icon(Icons.today_rounded, size: 20),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final t in [null, ...CleaningType.values])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(t?.label ?? 'Todas'),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ViewModeBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ViewModeBtn({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(
          icon,
          size: 20,
          color: active ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Horario del mes: una fila por operario y una columna por día.
class _ScheduleGrid extends StatelessWidget {
  final DateTime month;
  const _ScheduleGrid({required this.month});

  static const _shiftColors = {
    'A': Color(0xFF3B82F6),
    'B': Color(0xFF8B5CF6),
    'H': AppColors.secondary,
    'L': AppColors.textHint,
  };

  @override
  Widget build(BuildContext context) {
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final today = DateTime.now();
    final operators = kUsers.where((u) => u.role == UserRole.operario).toList();

    Widget cell(String text,
        {Color? color, bool bold = false, bool mark = false}) {
      return Container(
        width: 30,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: mark ? AppColors.iconBg : null,
          border: const Border(
            bottom: BorderSide(color: AppColors.divider),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('MM/yyyy').format(month),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            OutlinedButton.icon(
              key: const ValueKey('load-schedule'),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Demo: el horario de este mes ya viene cargado de ejemplo',
                  ),
                ),
              ),
              icon: const Icon(Icons.upload_file_outlined, size: 18),
              label: const Text('Cargar horario'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 84,
                    height: 34,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Persona',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  for (final u in operators)
                    Container(
                      width: 84,
                      height: 34,
                      alignment: Alignment.centerLeft,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.divider),
                        ),
                      ),
                      child: Text(
                        u.name.split(' ').first,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          for (var d = 1; d <= days; d++)
                            cell(
                              '$d',
                              bold: true,
                              color: AppColors.textSecondary,
                              mark: DateUtils.isSameDay(
                                DateTime(month.year, month.month, d),
                                today,
                              ),
                            ),
                        ],
                      ),
                      for (final u in operators)
                        Row(
                          children: [
                            for (var d = 1; d <= days; d++)
                              () {
                                final date =
                                    DateTime(month.year, month.month, d);
                                final letter = scheduledShift(u, date);
                                return cell(
                                  letter,
                                  bold: true,
                                  color: _shiftColors[letter],
                                  mark: DateUtils.isSameDay(date, today),
                                );
                              }(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            for (final s in kShifts)
              Text(
                '${s.letter} = ${s.name}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _shiftColors[s.letter],
                  fontWeight: FontWeight.w600,
                ),
              ),
            Text(
              'L = Libre',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
