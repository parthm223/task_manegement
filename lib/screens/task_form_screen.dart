import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:task_manegement/controllers/category_controller.dart';
import 'package:task_manegement/controllers/task_controller.dart';
import 'package:task_manegement/models/task_model.dart';
import 'package:task_manegement/theme/app_theme.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _detailsController = TextEditingController();
  bool _isFavorite = false;
  bool _isCompleted = false;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  String _category = 'General';

  final TaskController _taskController = Get.find<TaskController>();
  final CategoryController _categoryController = Get.find<CategoryController>();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _nameController.text = widget.task!.taskName;
      _detailsController.text = widget.task!.taskDetails;
      _isFavorite = widget.task!.isFavourite;
      _isCompleted = widget.task!.isCompleted;
      _dueDate = widget.task!.dueDate;
      _priority = widget.task!.priority;
      _category = widget.task!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (widget.task == null) {
        // Create new task
        final newTask = Task(
          taskName: _nameController.text,
          taskDetails: _detailsController.text,
          isFavourite: _isFavorite,
          isCompleted: _isCompleted,
          dueDate: _dueDate,
          priority: _priority,
          category: _category,
        );
        _taskController.addTask(newTask);
      } else {
        // Update existing task
        final updatedTask = Task(
          taskId: widget.task!.taskId,
          taskName: _nameController.text,
          taskDetails: _detailsController.text,
          isFavourite: _isFavorite,
          isCompleted: _isCompleted,
          dueDate: _dueDate,
          priority: _priority,
          category: _category,
        );
        _taskController.updateTask(updatedTask);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppTheme.primaryColor,
                onPrimary: Colors.white,
                onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add New Task' : 'Edit Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_taskController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task name field
                  const Text(
                    'Task Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter task name',
                      prefixIcon: Icon(Icons.task_alt),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Task details field
                  const Text(
                    'Task Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _detailsController,
                    decoration: const InputDecoration(
                      hintText: 'Enter task details',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter task details';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Due date picker
                  const Text(
                    'Due Date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            _dueDate == null
                                ? 'Select due date'
                                : DateFormat('MMM dd, yyyy - hh:mm a')
                                    .format(_dueDate!),
                            style: TextStyle(
                              color: _dueDate == null
                                  ? Colors.grey
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                            ),
                          ),
                          const Spacer(),
                          if (_dueDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _dueDate = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Priority selection
                  const Text(
                    'Priority',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<TaskPriority>(
                          title: Row(
                            children: [
                              Icon(Icons.flag, color: Colors.red.shade400),
                              const SizedBox(width: 8),
                              const Text('High'),
                            ],
                          ),
                          value: TaskPriority.high,
                          groupValue: _priority,
                          onChanged: (value) {
                            setState(() {
                              _priority = value!;
                            });
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                        RadioListTile<TaskPriority>(
                          title: Row(
                            children: [
                              Icon(Icons.flag, color: Colors.orange.shade400),
                              const SizedBox(width: 8),
                              const Text('Medium'),
                            ],
                          ),
                          value: TaskPriority.medium,
                          groupValue: _priority,
                          onChanged: (value) {
                            setState(() {
                              _priority = value!;
                            });
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                        RadioListTile<TaskPriority>(
                          title: Row(
                            children: [
                              Icon(Icons.flag, color: Colors.green.shade400),
                              const SizedBox(width: 8),
                              const Text('Low'),
                            ],
                          ),
                          value: TaskPriority.low,
                          groupValue: _priority,
                          onChanged: (value) {
                            setState(() {
                              _priority = value!;
                            });
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category selection
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _category,
                        items: _categoryController.categories
                            .map((category) => DropdownMenuItem<String>(
                                  value: category.name,
                                  child: Row(
                                    children: [
                                      Icon(category.icon,
                                          color: category.color),
                                      const SizedBox(width: 8),
                                      Text(category.name),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _category = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Toggles
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Mark as Favorite'),
                          value: _isFavorite,
                          activeColor: AppTheme.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              _isFavorite = value;
                            });
                          },
                          secondary: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? AppTheme.accentColor : null,
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Mark as Completed'),
                          value: _isCompleted,
                          activeColor: AppTheme.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              _isCompleted = value;
                            });
                          },
                          secondary: Icon(
                            _isCompleted
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: _isCompleted ? Colors.green : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(
                        widget.task == null ? 'Add Task' : 'Update Task',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
