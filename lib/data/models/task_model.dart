import 'package:hive/hive.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String title;
  @HiveField(2)
  String? description;
  @HiveField(3)
  late int priority;
  @HiveField(4)
  late int status;
  @HiveField(5)
  late DateTime createdAt;
  @HiveField(6)
  late int pomodorosCompleted;

  TaskModel();

  factory TaskModel.fromEntity(Task task) => TaskModel()
    ..id = task.id
    ..title = task.title
    ..description = task.description
    ..priority = task.priority.index
    ..status = task.status.index
    ..createdAt = task.createdAt
    ..pomodorosCompleted = task.pomodorosCompleted;

  Task toEntity() => Task(
    id: id,
    title: title,
    description: description,
    priority: TaskPriority.values[priority],
    status: TaskStatus.values[status],
    createdAt: createdAt,
    pomodorosCompleted: pomodorosCompleted,
  );
}
