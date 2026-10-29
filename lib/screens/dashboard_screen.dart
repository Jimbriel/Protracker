import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/catalog.dart';
import '../data/demo_store.dart';
import '../data/stats.dart';
import '../models/cleaning_models.dart';
import '../widgets/app_bar_actions.dart';
import '../widgets/app_drawer.dart';
import '../widgets/kpi_card.dart';

const _typeColors = {
  CleaningType.daily: AppColors.primary,
  CleaningType.weekly: AppColors.secondary,
  CleaningType.deep: AppColors.accent,
  CleaningType.emergency: AppColors.error,
};

/// Informes estadísticos de las limpiezas, semanales y mensuales.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StatsPeriod _period = StatsPeriod.week;

  @override
  Widget build(BuildContext context) {
    final store = DemoStore.instance;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          'Estadísticas',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: const [AppBarActions()],
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final stats = DashboardStats.compute(
            store.activities,
            _period,
            DateTime.now(),
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<StatsPeriod>(
                key: const ValueKey('period'),
                segments: [
                  for (final p in StatsPeriod.values)
                    ButtonSegment(value: p, label: Text(p.label)),
                ],
                selected: {_period},
                onSelectionChanged: (s) => setState(() => _period = s.first),
              ),
              const SizedBox(height: 16),
              _kpis(stats),
              const SizedBox(height: 16),
              _card(
                'Completadas y pendientes',
                _periodSubtitle(),
                SizedBox(height: 190, child: _barChart(stats)),
              ),
              const SizedBox(height: 16),
              _card(
                'Frecuencia de limpieza',
                'Completadas por tipo',
                _frequency(stats),
              ),
              const SizedBox(height: 16),
              _card(
                'Cumplimiento por área',
                'Actividades completadas / programadas',
                _byArea(stats),
              ),
              const SizedBox(height: 16),
              _card(
                'Cumplimiento y tiempo por equipo',
                'Limpiezas realizadas y minutos promedio',
                _byEquipment(stats),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  String _periodSubtitle() => _period == StatsPeriod.week
      ? 'Últimos 7 días'
      : 'Últimas 4 semanas (S4 = la actual)';

  Widget _kpis(DashboardStats s) {
    final kpis = [
      (s.done, 'Limpiezas realizadas'),
      (s.compliancePercent, 'Cumplimiento (%)'),
      (s.pending, 'Pendientes'),
      (s.avgMinutes?.round() ?? 0, 'Tiempo promedio (min)'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kpis.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (_, i) => KpiCard(value: kpis[i].$1, label: kpis[i].$2),
    );
  }

  Widget _card(String title, String subtitle, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _barChart(DashboardStats s) {
    final maxY = s.buckets
        .map((b) => b.done + b.pending)
        .fold<int>(1, (m, v) => v > m ? v : m)
        .toDouble();
    return BarChart(
      BarChartData(
        maxY: maxY + 2,
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  s.buckets[v.toInt()].label,
                  style: GoogleFonts.inter(fontSize: 11),
                ),
              ),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < s.buckets.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (s.buckets[i].done + s.buckets[i].pending).toDouble(),
                  width: _period == StatsPeriod.week ? 16 : 30,
                  borderRadius: BorderRadius.circular(4),
                  rodStackItems: [
                    BarChartRodStackItem(
                      0,
                      s.buckets[i].done.toDouble(),
                      AppColors.secondary,
                    ),
                    BarChartRodStackItem(
                      s.buckets[i].done.toDouble(),
                      (s.buckets[i].done + s.buckets[i].pending).toDouble(),
                      AppColors.accent,
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _frequency(DashboardStats s) {
    if (s.done == 0) return const Text('Sin datos');
    return Row(
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 28,
              sections: [
                for (final e in s.doneByType.entries)
                  PieChartSectionData(
                    value: e.value.toDouble(),
                    color: _typeColors[e.key],
                    radius: 34,
                    title: '${e.value}',
                    titleStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final t in CleaningType.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _typeColors[t],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${t.label}: ${s.doneByType[t] ?? 0}',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _byArea(DashboardStats s) {
    return _progressRow(kArea, s.done, s.total, trailing: '${s.compliancePercent}%');
  }

  Widget _byEquipment(DashboardStats s) {
    final rows = s.byEquipment.entries.toList()
      ..sort((a, b) => b.value.total.compareTo(a.value.total));
    return Column(
      children: [
        for (final e in rows)
          _progressRow(
            DemoStore.instance.equipmentById(e.key).name,
            e.value.done,
            e.value.total,
            trailing: s.avgMinutesByEquipment[e.key] == null
                ? '—'
                : '${s.avgMinutesByEquipment[e.key]!.round()} min',
          ),
      ],
    );
  }

  Widget _progressRow(String label, int done, int total, {String? trailing}) {
    final value = total == 0 ? 0.0 : done / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: GoogleFonts.inter(fontSize: 13)),
              ),
              Text(
                '$done/$total',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                SizedBox(
                  width: 52,
                  child: Text(
                    trailing,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              color: value >= 0.85 ? AppColors.secondary : AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
