import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../domain/entities/pomodoro_session.dart';
import '../../domain/entities/task.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/task_provider.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroProvider);
    final tasksAsync = ref.watch(taskListProvider);
    final color = _sessionColor(pomodoro.sessionType);
    final progress = _calcProgress(pomodoro);

    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Badge sessão
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    _sessionLabel(pomodoro.sessionType),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Timer circular com glassmorphism
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Anel externo decorativo
                  CustomPaint(
                    size: const Size(260, 260),
                    painter: _RingPainter(progress: progress, color: color),
                  ),
                  // Card glassmorphism central
                  ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.gray2.withOpacity(0.7),
                          border: Border.all(
                            color: color.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(pomodoro.remaining),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.white,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _stateLabel(pomodoro.state),
                              style: const TextStyle(
                                color: AppTheme.gray4,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Indicadores de ciclo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < (pomodoro.completedPomodoros % 4);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: filled ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: filled ? AppTheme.purple1 : AppTheme.gray3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Text(
              '${pomodoro.completedPomodoros} pomodoros hoje',
              style: const TextStyle(color: AppTheme.gray4, fontSize: 12),
            ),
            const SizedBox(height: 32),

            // Seletor de tarefa
            tasksAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (tasks) {
                final pending = tasks
                    .where((t) => t.status != TaskStatus.done)
                    .toList();
                if (pending.isEmpty) return const SizedBox.shrink();
                return _TaskSelector(
                  tasks: pending,
                  activeTaskId: pomodoro.activeTaskId,
                );
              },
            ),
            const SizedBox(height: 32),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GlassButton(
                  icon: Icons.replay,
                  onTap: () => ref.read(pomodoroProvider.notifier).reset(),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _handleMainButton(ref, pomodoro),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 160,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.purple1, AppTheme.purple2],
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.purple1.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _mainIcon(pomodoro.state),
                          color: AppTheme.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _mainLabel(pomodoro.state),
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  double _calcProgress(PomodoroStatus p) {
    final total = switch (p.sessionType) {
      SessionType.work => kWorkDuration,
      SessionType.shortBreak => kShortBreak,
      SessionType.longBreak => kLongBreak,
    };
    return 1 - (p.remaining.inSeconds / total.inSeconds);
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _sessionColor(SessionType t) => switch (t) {
    SessionType.work => AppTheme.purple1,
    SessionType.shortBreak => const Color(0xFF00BCD4),
    SessionType.longBreak => const Color(0xFF4CAF50),
  };

  String _sessionLabel(SessionType t) => switch (t) {
    SessionType.work => '🍅  Foco',
    SessionType.shortBreak => '☕  Pausa curta',
    SessionType.longBreak => '🌿  Pausa longa',
  };

  String _stateLabel(PomodoroState s) => switch (s) {
    PomodoroState.idle => 'pronto',
    PomodoroState.running => 'em andamento',
    PomodoroState.paused => 'pausado',
    PomodoroState.finished => 'concluído!',
  };

  IconData _mainIcon(PomodoroState s) => switch (s) {
    PomodoroState.running => Icons.pause_rounded,
    PomodoroState.paused => Icons.play_arrow_rounded,
    _ => Icons.play_arrow_rounded,
  };

  String _mainLabel(PomodoroState s) => switch (s) {
    PomodoroState.running => 'Pausar',
    PomodoroState.paused => 'Retomar',
    _ => 'Iniciar',
  };

  void _handleMainButton(WidgetRef ref, PomodoroStatus p) {
    final notifier = ref.read(pomodoroProvider.notifier);
    switch (p.state) {
      case PomodoroState.running:
        notifier.pause();
      case PomodoroState.paused:
        notifier.resume();
      default:
        notifier.start(taskId: p.activeTaskId);
    }
  }
}

// Botão glassmorphism circular
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.gray3.withOpacity(0.6),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppTheme.gray4.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Icon(icon, color: AppTheme.white, size: 22),
          ),
        ),
      ),
    );
  }
}

// Pintor do anel de progresso
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Trilha
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Progresso
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// Seletor de tarefa
class _TaskSelector extends ConsumerStatefulWidget {
  final List<Task> tasks;
  final String? activeTaskId;
  const _TaskSelector({required this.tasks, this.activeTaskId});

  @override
  ConsumerState<_TaskSelector> createState() => _TaskSelectorState();
}

class _TaskSelectorState extends ConsumerState<_TaskSelector> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.activeTaskId;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.gray2.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.purple1.withOpacity(0.15),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tarefa vinculada',
                style: TextStyle(
                  color: AppTheme.gray4,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selected,
                dropdownColor: AppTheme.gray2,
                style: const TextStyle(color: AppTheme.white),
                decoration: const InputDecoration(
                  hintText: 'Selecione uma tarefa',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text(
                      'Nenhuma',
                      style: TextStyle(color: AppTheme.gray4),
                    ),
                  ),
                  ...widget.tasks.map(
                    (t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(
                        t.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppTheme.white),
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selected = value);
                  ref.read(pomodoroProvider.notifier).reset();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
