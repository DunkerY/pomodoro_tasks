import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/hive_datasource.dart';
import '../../data/datasources/notification_service.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/pomodoro_session.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_provider.dart';

final _uuid = Uuid();

const kWorkDuration = Duration(minutes: 25);
const kShortBreak = Duration(minutes: 5);
const kLongBreak = Duration(minutes: 15);

enum PomodoroState { idle, running, paused, finished }

class PomodoroStatus {
  final PomodoroState state;
  final SessionType sessionType;
  final Duration remaining;
  final int completedPomodoros;
  final String? activeTaskId;

  const PomodoroStatus({
    required this.state,
    required this.sessionType,
    required this.remaining,
    required this.completedPomodoros,
    this.activeTaskId,
  });

  PomodoroStatus copyWith({
    PomodoroState? state,
    SessionType? sessionType,
    Duration? remaining,
    int? completedPomodoros,
    String? activeTaskId,
  }) => PomodoroStatus(
    state: state ?? this.state,
    sessionType: sessionType ?? this.sessionType,
    remaining: remaining ?? this.remaining,
    completedPomodoros: completedPomodoros ?? this.completedPomodoros,
    activeTaskId: activeTaskId ?? this.activeTaskId,
  );
}

final pomodoroProvider = NotifierProvider<PomodoroNotifier, PomodoroStatus>(
  PomodoroNotifier.new,
);

class PomodoroNotifier extends Notifier<PomodoroStatus> {
  Timer? _timer;
  DateTime? _sessionStart;

  TaskRepository get _repo => TaskRepositoryImpl(HiveDataSource());

  @override
  PomodoroStatus build() => PomodoroStatus(
    state: PomodoroState.idle,
    sessionType: SessionType.work,
    remaining: kWorkDuration,
    completedPomodoros: 0,
  );

  void start({String? taskId}) {
    _sessionStart = DateTime.now();
    state = state.copyWith(state: PomodoroState.running, activeTaskId: taskId);
    _tick();
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(state: PomodoroState.paused);
  }

  void resume() {
    state = state.copyWith(state: PomodoroState.running);
    _tick();
  }

  void reset() {
    _timer?.cancel();
    state = PomodoroStatus(
      state: PomodoroState.idle,
      sessionType: SessionType.work,
      remaining: kWorkDuration,
      completedPomodoros: state.completedPomodoros,
    );
  }

  void _tick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remaining <= Duration.zero) {
        _onFinish();
      } else {
        state = state.copyWith(
          remaining: state.remaining - const Duration(seconds: 1),
        );
      }
    });
  }

  Future<void> _onFinish() async {
    _timer?.cancel();
    state = state.copyWith(state: PomodoroState.finished);

    // Dispara a notificação
    final wasWork = state.sessionType == SessionType.work;
    await NotificationService.showPomodoroFinished(
      title: wasWork ? '🍅 Pomodoro concluído!' : '⏰ Pausa finalizada!',
      body: wasWork
          ? 'Bom trabalho! Hora de descansar.'
          : 'Pausa encerrada. Pronto para focar?',
    );

    // Salva a sessão
    final session = PomodoroSession(
      id: _uuid.v4(),
      taskId: state.activeTaskId,
      type: state.sessionType,
      startedAt: _sessionStart ?? DateTime.now(),
      finishedAt: DateTime.now(),
      completed: true,
    );
    await _repo.saveSession(session);

    // Se era work, incrementa pomodoro na tarefa
    if (state.sessionType == SessionType.work && state.activeTaskId != null) {
      final task = await _repo.getTaskById(state.activeTaskId!);
      if (task != null) {
        await _repo.saveTask(
          task.copyWith(pomodorosCompleted: task.pomodorosCompleted + 1),
        );
        ref.invalidate(taskListProvider);
      }
    }

    // Decide próxima sessão
    final completed = state.sessionType == SessionType.work
        ? state.completedPomodoros + 1
        : state.completedPomodoros;

    final next = state.sessionType != SessionType.work
        ? SessionType.work
        : (completed % 4 == 0 ? SessionType.longBreak : SessionType.shortBreak);

    final nextDuration = switch (next) {
      SessionType.work => kWorkDuration,
      SessionType.shortBreak => kShortBreak,
      SessionType.longBreak => kLongBreak,
    };

    state = PomodoroStatus(
      state: PomodoroState.idle,
      sessionType: next,
      remaining: nextDuration,
      completedPomodoros: completed,
    );
  }
}
