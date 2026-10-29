import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../widgets/app_bar_actions.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _viewMode = 1; // 0=kanban, 1=calendar, 2=list, 3=clipboard
  DateTime _selectedDate = DateTime.now();
  String _category = 'Diaria';

  final _categories = ['Diaria', 'Semanal', 'Profunda', 'Emergencia'];

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
              'Tareas',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Vista Calendario',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: Column(
        children: [
          _buildViewModeBar(),
          const SizedBox(height: 8),
          _buildCalendarFilters(),
          const SizedBox(height: 8),
          const Expanded(child: EmptyState()),
        ],
      ),
    );
  }

  Widget _buildViewModeBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.iconBg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewModeBtn(
            icon: Icons.view_week_outlined,
            active: _viewMode == 0,
            onTap: () => setState(() => _viewMode = 0),
          ),
          _ViewModeBtn(
            icon: Icons.calendar_month_rounded,
            active: _viewMode == 1,
            onTap: () => setState(() => _viewMode = 1),
          ),
          _ViewModeBtn(
            icon: Icons.format_list_bulleted_rounded,
            active: _viewMode == 2,
            onTap: () => setState(() => _viewMode = 2),
          ),
          _ViewModeBtn(
            icon: Icons.assignment_outlined,
            active: _viewMode == 3,
            onTap: () => setState(() => _viewMode = 3),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded, size: 20),
            color: AppColors.textSecondary,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_alt_outlined, size: 20),
                color: AppColors.primary,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '2',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DropdownField<String>(
                value: _category,
                items: _categories,
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
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

class _DropdownField<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(
                    e.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ))
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
        isDense: true,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
