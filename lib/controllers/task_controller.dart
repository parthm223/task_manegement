import 'package:get/get.dart';
import 'package:task_manegement/controllers/category_controller.dart';
import 'dart:convert';

import 'package:task_manegement/models/task_model.dart';
import 'package:task_manegement/services/api_service.dart';
import 'package:task_manegement/services/local_storage_service.dart';

class TaskController extends GetxController {
  static const String _tasksKey = 'cached_tasks';
  static const String _lastSyncKey = 'last_sync_time';

  var isLoading = false.obs;
  var tasks = <Task>[].obs;
  var filteredTasks = <Task>[].obs;
  var searchQuery = ''.obs;
  var filterFavorites = false.obs;
  var filterCompleted = RxBool(false);
  var showCompletedTasks = RxBool(true);
  var sortOption = RxString('date'); // 'date', 'priority', 'name'
  var sortAscending = RxBool(false);

  final CategoryController _categoryController = Get.find<CategoryController>();

  @override
  void onInit() {
    super.onInit();

    // Listen to category changes
    ever(_categoryController.selectedCategoryId, (_) => applyFilters());

    // Listen to filter changes
    ever(filterFavorites, (_) => applyFilters());
    ever(filterCompleted, (_) => applyFilters());
    ever(showCompletedTasks, (_) => applyFilters());
    ever(sortOption, (_) => applyFilters());
    ever(sortAscending, (_) => applyFilters());

    // Load cached tasks first, then fetch from API
    _loadCachedTasks();
    fetchTasks();
  }

  void _loadCachedTasks() {
    final cachedTasksJson = LocalStorageService.getString(_tasksKey);
    if (cachedTasksJson != null && cachedTasksJson.isNotEmpty) {
      try {
        final List<dynamic> decodedList = json.decode(cachedTasksJson);
        final cachedTasks =
            decodedList.map((item) => Task.fromJson(item)).toList();
        tasks.value = cachedTasks;
        applyFilters();
      } catch (e) {
        print('Error loading cached tasks: $e');
      }
    }
  }

  void _cacheTasks() {
    final encodedList =
        json.encode(tasks.map((task) => task.toJson()).toList());
    LocalStorageService.setString(_tasksKey, encodedList);
    LocalStorageService.setString(
        _lastSyncKey, DateTime.now().toIso8601String());
  }

  // Fetch all tasks from API
  Future<void> fetchTasks() async {
    try {
      isLoading(true);
      final fetchedTasks = await ApiService.getTasks();
      tasks.value = fetchedTasks;
      applyFilters();
      _cacheTasks();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tasks: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      // If API fails, we'll still have cached tasks
    } finally {
      isLoading(false);
    }
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    try {
      isLoading(true);
      final newTask = await ApiService.addOrUpdateTask(task);
      tasks.add(newTask);
      applyFilters();
      _cacheTasks();
      Get.back();
      Get.snackbar(
        'Success',
        'Task added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add task: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    try {
      isLoading(true);
      final updatedTask = await ApiService.addOrUpdateTask(task);
      final index = tasks.indexWhere((t) => t.taskId == task.taskId);
      if (index != -1) {
        tasks[index] = updatedTask;
        applyFilters();
        _cacheTasks();
      }
      Get.back();
      Get.snackbar(
        'Success',
        'Task updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Task task) async {
    final updatedTask = task.copyWith(isFavourite: !task.isFavourite);

    try {
      final result = await ApiService.addOrUpdateTask(updatedTask);
      final index = tasks.indexWhere((t) => t.taskId == task.taskId);
      if (index != -1) {
        tasks[index] = result;
        applyFilters();
        _cacheTasks();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update favorite status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Toggle completed status
  Future<void> toggleCompleted(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

    try {
      final result = await ApiService.addOrUpdateTask(updatedTask);
      final index = tasks.indexWhere((t) => t.taskId == task.taskId);
      if (index != -1) {
        tasks[index] = result;
        applyFilters();
        _cacheTasks();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update completion status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete task
  Future<void> deleteTask(Task task) async {
    try {
      isLoading(true);
      // API doesn't have delete endpoint, so we'll just remove locally
      tasks.removeWhere((t) => t.taskId == task.taskId);
      applyFilters();
      _cacheTasks();
      Get.snackbar(
        'Success',
        'Task deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete task: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Apply search and filters
  void applyFilters() {
    var result = List<Task>.from(tasks);

    // Filter by category
    if (_categoryController.selectedCategoryId.value != 'all') {
      final categoryName = _categoryController
          .getCategoryById(_categoryController.selectedCategoryId.value)
          ?.name;
      if (categoryName != null) {
        result = result.where((task) => task.category == categoryName).toList();
      }
    }

    // Filter by completion status
    if (!showCompletedTasks.value) {
      result = result.where((task) => !task.isCompleted).toList();
    } else if (filterCompleted.value) {
      result = result.where((task) => task.isCompleted).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result
          .where((task) =>
              task.taskName
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              task.taskDetails
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    // Apply favorites filter
    if (filterFavorites.value) {
      result = result.where((task) => task.isFavourite).toList();
    }

    // Apply sorting
    switch (sortOption.value) {
      case 'date':
        result.sort((a, b) {
          final aDate = a.dueDate ?? DateTime.now();
          final bDate = b.dueDate ?? DateTime.now();
          return sortAscending.value
              ? aDate.compareTo(bDate)
              : bDate.compareTo(aDate);
        });
        break;
      case 'priority':
        result.sort((a, b) {
          final aValue = a.priority.index;
          final bValue = b.priority.index;
          return sortAscending.value
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        });
        break;
      case 'name':
        result.sort((a, b) {
          return sortAscending.value
              ? a.taskName.compareTo(b.taskName)
              : b.taskName.compareTo(a.taskName);
        });
        break;
    }

    filteredTasks.value = result;
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // Toggle favorites filter
  void toggleFavoritesFilter() {
    filterFavorites.value = !filterFavorites.value;
    applyFilters();
  }

  // Toggle completed filter
  void toggleCompletedFilter() {
    filterCompleted.value = !filterCompleted.value;
    applyFilters();
  }

  // Toggle show completed tasks
  void toggleShowCompletedTasks() {
    showCompletedTasks.value = !showCompletedTasks.value;
    applyFilters();
  }

  // Set sort option
  void setSortOption(String option) {
    if (sortOption.value == option) {
      // Toggle sort direction if same option selected
      sortAscending.value = !sortAscending.value;
    } else {
      sortOption.value = option;
      sortAscending.value = true; // Default to ascending for new sort option
    }
    applyFilters();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final favoriteTasks = tasks.where((task) => task.isFavourite).length;
    final overdueTasks = tasks
        .where((task) =>
            !task.isCompleted &&
            task.dueDate != null &&
            task.dueDate!.isBefore(DateTime.now()))
        .length;

    final completionRate = totalTasks > 0
        ? (completedTasks / totalTasks * 100).toStringAsFixed(1)
        : '0';

    // Tasks by priority
    final highPriorityTasks =
        tasks.where((task) => task.priority == TaskPriority.high).length;
    final mediumPriorityTasks =
        tasks.where((task) => task.priority == TaskPriority.medium).length;
    final lowPriorityTasks =
        tasks.where((task) => task.priority == TaskPriority.low).length;

    // Tasks by category
    final Map<String, int> tasksByCategory = {};
    for (final task in tasks) {
      tasksByCategory[task.category] =
          (tasksByCategory[task.category] ?? 0) + 1;
    }

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'favoriteTasks': favoriteTasks,
      'overdueTasks': overdueTasks,
      'completionRate': completionRate,
      'highPriorityTasks': highPriorityTasks,
      'mediumPriorityTasks': mediumPriorityTasks,
      'lowPriorityTasks': lowPriorityTasks,
      'tasksByCategory': tasksByCategory,
    };
  }
}
