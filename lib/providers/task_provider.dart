import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService service;
  List<Task> tasks = [];
  bool loading = true;

  TaskProvider({required this.service}) {
    _subscribe();
  }

  void _subscribe() {
    service.streamTasks().listen((data) {
      tasks = data;
      loading = false;
      notifyListeners();
    });
  }

  int get total => tasks.length;
  int get completed =>
      tasks.where((t) => t.status == TaskStatus.completed).length;
  int get pending => tasks.where((t) => t.status == TaskStatus.pending).length;

  Future<void> addTask(Task task) async {
    await service.addTask(task);
    await NotificationService.scheduleOneDayBefore(
      id: task.id.isEmpty
          ? '${DateTime.now().millisecondsSinceEpoch}'
          : task.id,
      title: 'Upcoming Task',
      body: '${task.title} due ${task.dueDateTime}',
      dueDateTime: task.dueDateTime,
    );
  }

  Future<void> toggleComplete(Task task) async {
    final newStatus = task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;
    await service.updateTaskStatus(task.id, newStatus);
  }

  Future<void> deleteTask(Task task) async {
    await service.deleteTask(task.id);
  }
}
