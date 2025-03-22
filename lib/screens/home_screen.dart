import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:task_manegement/controllers/task_controller.dart';
import 'package:task_manegement/screens/task_form_screen.dart';
import 'package:task_manegement/theme/app_theme.dart';
import 'package:task_manegement/widgets/empty_state.dart';
import 'package:task_manegement/widgets/task_list_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(taskController),
          _buildSearchBar(taskController),
          _buildTaskList(taskController),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => TaskFormScreen()),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(TaskController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Task Manager',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => IconButton(
                    onPressed: controller.toggleFavoritesFilter,
                    icon: Icon(
                      controller.filterFavorites.value
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.white,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            final totalTasks = controller.tasks.length;
            final completedTasks =
                controller.tasks.where((task) => task.isFavourite).length;

            return RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'You have ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: '$totalTasks tasks',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: ' with ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: '$completedTasks favorites',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar(TaskController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTaskList(TaskController controller) {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          );
        }

        if (controller.filteredTasks.isEmpty) {
          return EmptyState(
            message: controller.filterFavorites.value
                ? 'No favorite tasks found'
                : (controller.searchQuery.value.isNotEmpty
                    ? 'No tasks match your search'
                    : 'No tasks yet. Add your first task!'),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchTasks,
          color: AppTheme.primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.filteredTasks.length,
            itemBuilder: (context, index) {
              final task = controller.filteredTasks[index];
              return TaskListItem(
                task: task,
                onTap: () => Get.to(() => TaskFormScreen(task: task)),
                onFavoriteToggle: () => controller.toggleFavorite(task),
              );
            },
          ),
        );
      }),
    );
  }
}
