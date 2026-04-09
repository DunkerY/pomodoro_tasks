import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child:
                tasksAsync.whenData((tasks) {
                  final done = tasks
                      .where((t) => t.status == TaskStatus.done)
                      .length;
                  return Center(
                    child: Text(
                      '$done/${tasks.length}',
                      style: const TextStyle(
                        color: AppTheme.gray4,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).value ??
                const SizedBox.shrink(),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 56,
                      color: AppTheme.purple1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nenhuma tarefa ainda',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crie uma com o botão abaixo!',
                    style: TextStyle(color: AppTheme.gray4),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: tasks.length,
            itemBuilder: (context, index) => _TaskCard(task: tasks[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.gray2.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(
                  color: AppTheme.purple1.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.gray4.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nova tarefa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: const InputDecoration(labelText: 'Título *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Prioridade',
                    style: TextStyle(color: AppTheme.gray4, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: TaskPriority.values.map((p) {
                      final selected = selectedPriority == p;
                      final color = _priorityColor(p);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedPriority = p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withOpacity(0.2)
                                  : AppTheme.gray3,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? color : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _priorityLabel(p),
                                style: TextStyle(
                                  color: selected ? color : AppTheme.gray4,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        ref
                            .read(taskListProvider.notifier)
                            .addTask(
                              titleController.text.trim(),
                              description: descController.text.trim().isEmpty
                                  ? null
                                  : descController.text.trim(),
                              priority: selectedPriority,
                            );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Criar tarefa',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _priorityColor(TaskPriority p) => switch (p) {
    TaskPriority.high => const Color(0xFFFF5252),
    TaskPriority.medium => const Color(0xFFFFAB40),
    TaskPriority.low => const Color(0xFF69F0AE),
  };

  String _priorityLabel(TaskPriority p) => switch (p) {
    TaskPriority.high => 'Alta',
    TaskPriority.medium => 'Média',
    TaskPriority.low => 'Baixa',
  };
}

class _TaskCard extends ConsumerWidget {
  final Task task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status == TaskStatus.done;
    final priorityColor = switch (task.priority) {
      TaskPriority.high => const Color(0xFFFF5252),
      TaskPriority.medium => const Color(0xFFFFAB40),
      TaskPriority.low => const Color(0xFF69F0AE),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.gray2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? AppTheme.gray3 : AppTheme.purple1.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Barra lateral de prioridade
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                color: isDone ? AppTheme.gray3 : priorityColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        ref.read(taskListProvider.notifier).toggleDone(task),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? AppTheme.purple1 : Colors.transparent,
                        border: Border.all(
                          color: isDone ? AppTheme.purple1 : AppTheme.gray4,
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: AppTheme.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            color: isDone ? AppTheme.gray4 : AppTheme.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppTheme.gray4,
                          ),
                        ),
                        if (task.description != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            task.description!,
                            style: const TextStyle(
                              color: AppTheme.gray4,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                switch (task.priority) {
                                  TaskPriority.high => 'Alta',
                                  TaskPriority.medium => 'Média',
                                  TaskPriority.low => 'Baixa',
                                },
                                style: TextStyle(
                                  fontSize: 11,
                                  color: priorityColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (task.pomodorosCompleted > 0) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.local_fire_department,
                                size: 13,
                                color: AppTheme.purple1,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${task.pomodorosCompleted}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.purple1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.gray4,
                      size: 20,
                    ),
                    onPressed: () =>
                        ref.read(taskListProvider.notifier).deleteTask(task.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
