import 'package:hive/hive.dart';
import '../../domain/entities/pomodoro_session.dart';

part 'pomodoro_session_model.g.dart';

@HiveType(typeId: 1)
class PomodoroSessionModel extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  String? taskId;
  @HiveField(2)
  late int type;
  @HiveField(3)
  late DateTime startedAt;
  @HiveField(4)
  DateTime? finishedAt;
  @HiveField(5)
  late bool completed;

  PomodoroSessionModel();

  factory PomodoroSessionModel.fromEntity(PomodoroSession s) =>
      PomodoroSessionModel()
        ..id = s.id
        ..taskId = s.taskId
        ..type = s.type.index
        ..startedAt = s.startedAt
        ..finishedAt = s.finishedAt
        ..completed = s.completed;

  PomodoroSession toEntity() => PomodoroSession(
    id: id,
    taskId: taskId,
    type: SessionType.values[type],
    startedAt: startedAt,
    finishedAt: finishedAt,
    completed: completed,
  );
}
