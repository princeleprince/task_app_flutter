import 'package:flutter/material.dart';

enum Priority { high, medium, low }
enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final Priority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? category;
  final String userId;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = Priority.medium,
    required this.createdAt,
    this.dueDate,
    this.category,
    required this.userId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == 'TaskStatus.${json['status']}',
        orElse: () => TaskStatus.todo,
      ),
      priority: Priority.values.firstWhere(
        (e) => e.toString() == 'Priority.${json['priority']}',
        orElse: () => Priority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      category: json['category'],
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'category': category,
      'userId': userId,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    Priority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    String? category,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      userId: userId ?? this.userId,
    );
  }

  Color get priorityColor {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.pending;
      case TaskStatus.done:
        return Icons.check_circle;
    }
  }

  String get statusText {
    switch (status) {
      case TaskStatus.todo:
        return 'À faire';
      case TaskStatus.inProgress:
        return 'En cours';
      case TaskStatus.done:
        return 'Terminée';
    }
  }

  String get priorityText {
    switch (priority) {
      case Priority.high:
        return 'Haute';
      case Priority.medium:
        return 'Moyenne';
      case Priority.low:
        return 'Basse';
    }
  }
}