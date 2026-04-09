import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../domain/entities/pomodoro_session.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/datasources/hive_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../providers/task_provider.dart';

final weekSessionsProvider = FutureProvider<Map<int, int>>((ref) async {
  final TaskRepository repo = TaskRepositoryImpl(HiveDataSource());
  final now = DateTime.now();
  final Map<int, int> counts = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
  for (int i = 0; i < 7; i++) {
    final day = now.subtract(Duration(days: 6 - i));
    final sessions = await repo.getSessionsByDate(day);
    counts[i] = sessions.where((s) => s.type == SessionType.work).length;
  }
  return counts;
});

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);
    final sessionsAsync = ref.watch(weekSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tasksAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (tasks) => _SummaryCards(tasks: tasks),
            ),
            const SizedBox(height: 28),
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pomodoros — últimos 7 dias',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  sessionsAsync.when(
                    loading: () => const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('Erro: $e'),
                    data: (data) => _WeekBarChart(data: data),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tarefas com mais foco',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  tasksAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (tasks) => _TopTasksList(tasks: tasks),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.gray2.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.purple1.withOpacity(0.15),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final List<Task> tasks;
  const _SummaryCards({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final total = tasks.length;
    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final totalPomodoros = tasks.fold(
      0,
      (sum, t) => sum + t.pomodorosCompleted,
    );

    return Row(
      children: [
        _StatCard(
          label: 'Criadas',
          value: '$total',
          icon: Icons.list_alt,
          color: AppTheme.purple1,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Concluídas',
          value: '$done',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF00BCD4),
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Pomodoros',
          value: '$totalPomodoros',
          icon: Icons.local_fire_department,
          color: const Color(0xFFFFAB40),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(color: AppTheme.gray4, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekBarChart extends StatelessWidget {
  final Map<int, int> data;
  const _WeekBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'][d.weekday % 7];
    });

    final maxY =
        (data.values.isEmpty ? 1 : data.values.reduce((a, b) => a > b ? a : b))
            .toDouble();

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY < 4 ? 4 : maxY + 1,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${rod.toY.toInt()} 🍅',
                const TextStyle(color: AppTheme.white, fontSize: 12),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    days[value.toInt()],
                    style: const TextStyle(color: AppTheme.gray4, fontSize: 11),
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}',
                  style: const TextStyle(color: AppTheme.gray4, fontSize: 10),
                ),
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppTheme.gray3, strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            7,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (data[i] ?? 0).toDouble(),
                  gradient: LinearGradient(
                    colors: [AppTheme.purple2, AppTheme.purple1],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY < 4 ? 4 : maxY + 1,
                    color: AppTheme.gray3.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopTasksList extends StatelessWidget {
  final List<Task> tasks;
  const _TopTasksList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final sorted = [...tasks]
      ..sort((a, b) => b.pomodorosCompleted.compareTo(a.pomodorosCompleted));
    final top = sorted.where((t) => t.pomodorosCompleted > 0).take(5).toList();

    if (top.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Nenhum pomodoro registrado ainda.\nInicie um timer vinculado a uma tarefa!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.gray4),
          ),
        ),
      );
    }

    return Column(
      children: top.map((task) {
        final maxP = sorted.first.pomodorosCompleted;
        final progress = task.pomodorosCompleted / maxP;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: AppTheme.gray3,
                        valueColor: const AlwaysStoppedAnimation(
                          AppTheme.purple1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: AppTheme.purple1,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.pomodorosCompleted}',
                    style: const TextStyle(
                      color: AppTheme.purple1,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
