import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

class Task {
  int? taskId;
  String taskName;
  String? createdDate;
  String? updatedDate;
  String taskDetails;
  bool isFavourite;
  bool isCompleted;
  DateTime? dueDate;
  TaskPriority priority;
  String category;

  Task({
    this.taskId,
    required this.taskName,
    this.createdDate,
    this.updatedDate,
    required this.taskDetails,
    this.isFavourite = false,
    this.isCompleted = false,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.category = 'General',
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['task_id'],
      taskName: json['task_name'],
      createdDate: json['created_date'],
      updatedDate: json['updated_date'],
      taskDetails: json['task_details'],
      isFavourite: json['is_favourite'] ?? false,
      isCompleted: json['is_completed'] ?? false,
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      priority: _priorityFromString(json['priority'] ?? 'medium'),
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (taskId != null) data['task_id'] = taskId;
    data['task_name'] = taskName;
    data['task_details'] = taskDetails;
    data['is_favourite'] = isFavourite;
    data['is_completed'] = isCompleted;
    if (dueDate != null) data['due_date'] = dueDate!.toIso8601String();
    data['priority'] = _priorityToString(priority);
    data['category'] = category;
    return data;
  }

  static TaskPriority _priorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  static String _priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'high';
      case TaskPriority.low:
        return 'low';
      default:
        return 'medium';
    }
  }

  Color getPriorityColor() {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red.shade400;
      case TaskPriority.medium:
        return Colors.orange.shade400;
      case TaskPriority.low:
        return Colors.green.shade400;
    }
  }

  String getPriorityText() {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  // Create a copy of the task with updated fields
  Task copyWith({
    int? taskId,
    String? taskName,
    String? createdDate,
    String? updatedDate,
    String? taskDetails,
    bool? isFavourite,
    bool? isCompleted,
    DateTime? dueDate,
    TaskPriority? priority,
    String? category,
  }) {
    return Task(
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      taskDetails: taskDetails ?? this.taskDetails,
      isFavourite: isFavourite ?? this.isFavourite,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }
}
