import '../entities/task.dart';
import '../entities/pomodoro_session.dart';

abstract interface class TaskRepository {
  // --- Tarefas ---
  Future<List<Task>> getAllTasks();
  Future<Task?> getTaskById(String id);
  Future<void> saveTask(Task task);
  Future<void> deleteTask(String id);

  // --- Sessões Pomodoro ---
  Future<List<PomodoroSession>> getSessionsByDate(DateTime date);
  Future<void> saveSession(PomodoroSession session);
}
