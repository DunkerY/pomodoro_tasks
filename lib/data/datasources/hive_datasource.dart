import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../models/pomodoro_session_model.dart';

class HiveDataSource {
  static const _tasksBox = 'tasks';
  static const _sessionsBox = 'sessions';

  Future<Box<TaskModel>> get _tasks => Hive.openBox<TaskModel>(_tasksBox);
  Future<Box<PomodoroSessionModel>> get _sessions =>
      Hive.openBox<PomodoroSessionModel>(_sessionsBox);

  Future<List<TaskModel>> getAllTasks() async {
    final box = await _tasks;
    return box.values.toList();
  }

  Future<TaskModel?> getTaskById(String id) async {
    final box = await _tasks;
    try {
      return box.values.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTask(TaskModel model) async {
    final box = await _tasks;
    await box.put(model.id, model);
  }

  Future<void> deleteTask(String id) async {
    final box = await _tasks;
    await box.delete(id);
  }

  Future<List<PomodoroSessionModel>> getSessionsByDate(DateTime date) async {
    final box = await _sessions;
    return box.values.where((s) {
      return s.startedAt.year == date.year &&
          s.startedAt.month == date.month &&
          s.startedAt.day == date.day;
    }).toList();
  }

  Future<void> saveSession(PomodoroSessionModel model) async {
    final box = await _sessions;
    await box.put(model.id, model);
  }
}
