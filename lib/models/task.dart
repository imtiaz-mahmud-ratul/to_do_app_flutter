import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskType { study, work, personal, other }

enum TaskPriority { high, medium, low }

enum TaskStatus { pending, completed }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDateTime;
  final TaskType type;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDateTime,
    required this.type,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  factory Task.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDateTime: (data['dueDateTime'] as Timestamp).toDate(),
      type: _typeFromString(data['type'] ?? 'other'),
      priority: _priorityFromString(data['priority'] ?? 'low'),
      status: _statusFromString(data['status'] ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDateTime': Timestamp.fromDate(dueDateTime),
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static TaskType _typeFromString(String s) {
    switch (s) {
      case 'study':
        return TaskType.study;
      case 'work':
        return TaskType.work;
      case 'personal':
        return TaskType.personal;
      default:
        return TaskType.other;
    }
  }

  static TaskPriority _priorityFromString(String s) {
    switch (s) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      default:
        return TaskPriority.low;
    }
  }

  static TaskStatus _statusFromString(String s) {
    switch (s) {
      case 'completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.pending;
    }
  }
}
