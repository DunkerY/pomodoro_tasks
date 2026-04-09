enum SessionType { work, shortBreak, longBreak }

class PomodoroSession {
  final String id;
  final String? taskId; // null = sessão livre, sem tarefa vinculada
  final SessionType type;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final bool completed;

  const PomodoroSession({
    required this.id,
    this.taskId,
    required this.type,
    required this.startedAt,
    this.finishedAt,
    this.completed = false,
  });

  Duration get duration {
    final end = finishedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  PomodoroSession copyWith({DateTime? finishedAt, bool? completed}) {
    return PomodoroSession(
      id: id,
      taskId: taskId,
      type: type,
      startedAt: startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      completed: completed ?? this.completed,
    );
  }
}
