import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/hive_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

final _uuid = Uuid();

// Provider do datasource e repositório
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(HiveDataSource());
});

// Provider da lista de tarefas
final taskListProvider = AsyncNotifierProvider<TaskListNotifier, List<Task>>(
  TaskListNotifier.new,
);

class TaskListNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    return ref.read(taskRepositoryProvider).getAllTasks();
  }

  Future<void> addTask(
    String title, {
    String? description,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      createdAt: DateTime.now(),
    );
    await ref.read(taskRepositoryProvider).saveTask(task);
    ref.invalidateSelf();
  }

  Future<void> updateTask(Task task) async {
    await ref.read(taskRepositoryProvider).saveTask(task);
    ref.invalidateSelf();
  }

  Future<void> deleteTask(String id) async {
    await ref.read(taskRepositoryProvider).deleteTask(id);
    ref.invalidateSelf();
  }

  Future<void> toggleDone(Task task) async {
    final updated = task.copyWith(
      status: task.status == TaskStatus.done
          ? TaskStatus.pending
          : TaskStatus.done,
    );
    await updateTask(updated);
  }
}
