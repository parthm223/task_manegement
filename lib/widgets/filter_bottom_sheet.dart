import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manegement/controllers/task_controller.dart';
import 'package:task_manegement/theme/app_theme.dart';

class FilterBottomSheet extends StatelessWidget {
  FilterBottomSheet({Key? key}) : super(key: key);

  final TaskController _taskController = Get.find<TaskController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => SwitchListTile(
                title: const Text('Show Completed Tasks'),
                value: _taskController.showCompletedTasks.value,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) {
                  _taskController.toggleShowCompletedTasks();
                },
              )),
          Obx(() => SwitchListTile(
                title: const Text('Only Completed Tasks'),
                value: _taskController.filterCompleted.value,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) {
                  _taskController.toggleCompletedFilter();
                },
              )),
          const SizedBox(height: 10),
          const Text(
            'Priority',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildPriorityFilter(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityFilter() {
    return StatefulBuilder(
      builder: (context, setState) {
        final selectedPriorities = <String>{'high', 'medium', 'low'};

        return Column(
          children: [
            CheckboxListTile(
              title: Row(
                children: [
                  Icon(Icons.flag, color: Colors.red.shade400),
                  const SizedBox(width: 8),
                  const Text('High Priority'),
                ],
              ),
              value: selectedPriorities.contains('high'),
              activeColor: AppTheme.primaryColor,
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    selectedPriorities.add('high');
                  } else {
                    selectedPriorities.remove('high');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: Row(
                children: [
                  Icon(Icons.flag, color: Colors.orange.shade400),
                  const SizedBox(width: 8),
                  const Text('Medium Priority'),
                ],
              ),
              value: selectedPriorities.contains('medium'),
              activeColor: AppTheme.primaryColor,
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    selectedPriorities.add('medium');
                  } else {
                    selectedPriorities.remove('medium');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: Row(
                children: [
                  Icon(Icons.flag, color: Colors.green.shade400),
                  const SizedBox(width: 8),
                  const Text('Low Priority'),
                ],
              ),
              value: selectedPriorities.contains('low'),
              activeColor: AppTheme.primaryColor,
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    selectedPriorities.add('low');
                  } else {
                    selectedPriorities.remove('low');
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}
