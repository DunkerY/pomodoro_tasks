import '../../domain/entities/task.dart';
import '../../domain/entities/pomodoro_session.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/hive_datasource.dart';
import '../models/task_model.dart';
import '../models/pomodoro_session_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final HiveDataSource _dataSource;

  TaskRepositoryImpl(this._dataSource);

  @override
  Future<List<Task>> getAllTasks() async {
    final models = await _dataSource.getAllTasks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final model = await _dataSource.getTaskById(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveTask(Task task) async {
    await _dataSource.saveTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> deleteTask(String id) async {
    await _dataSource.deleteTask(id);
  }

  @override
  Future<List<PomodoroSession>> getSessionsByDate(DateTime date) async {
    final models = await _dataSource.getSessionsByDate(date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveSession(PomodoroSession session) async {
    await _dataSource.saveSession(PomodoroSessionModel.fromEntity(session));
  }
}
