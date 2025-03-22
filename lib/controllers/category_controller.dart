import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:task_manegement/models/category_model.dart';
import 'package:task_manegement/services/local_storage_service.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class CategoryController extends GetxController {
  static const String _categoriesKey = 'task_categories';

  var categories = <Category>[].obs;
  var selectedCategoryId = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }

  void _loadCategories() {
    // Add default categories if none exist
    if (categories.isEmpty) {
      _addDefaultCategories();
    }

    final savedCategories = LocalStorageService.getString(_categoriesKey);
    if (savedCategories != null && savedCategories.isNotEmpty) {
      try {
        final List<dynamic> decodedList = json.decode(savedCategories);
        categories.value =
            decodedList.map((item) => Category.fromJson(item)).toList();
      } catch (e) {
        print('Error loading categories: $e');
        _addDefaultCategories();
      }
    } else {
      _addDefaultCategories();
    }
  }

  void _addDefaultCategories() {
    categories.value = [
      Category(
        id: 'general',
        name: 'General',
        color: Colors.blue,
        icon: Icons.list_alt,
      ),
      Category(
        id: 'work',
        name: 'Work',
        color: Colors.orange,
        icon: Icons.work,
      ),
      Category(
        id: 'personal',
        name: 'Personal',
        color: Colors.purple,
        icon: Icons.person,
      ),
      Category(
        id: 'shopping',
        name: 'Shopping',
        color: Colors.green,
        icon: Icons.shopping_cart,
      ),
      Category(
        id: 'health',
        name: 'Health',
        color: Colors.red,
        icon: Icons.favorite,
      ),
    ];
    _saveCategories();
  }

  void _saveCategories() {
    final encodedList = json.encode(
      categories.map((category) => category.toJson()).toList(),
    );
    LocalStorageService.setString(_categoriesKey, encodedList);
  }

  void addCategory(String name, Color color, IconData icon) {
    final newCategory = Category(
      id: const Uuid().v4(),
      name: name,
      color: color,
      icon: icon,
    );

    categories.add(newCategory);
    _saveCategories();
  }

  void updateCategory(Category category) {
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      _saveCategories();
    }
  }

  void deleteCategory(String id) {
    categories.removeWhere((category) => category.id == id);
    if (selectedCategoryId.value == id) {
      selectedCategoryId.value = 'all';
    }
    _saveCategories();
  }

  void selectCategory(String id) {
    selectedCategoryId.value = id;
  }

  Category? getCategoryById(String id) {
    if (id == 'all') return null;
    return categories.firstWhere(
      (category) => category.id == id,
      orElse: () => categories.first,
    );
  }

  Category getCategoryByName(String name) {
    return categories.firstWhere(
      (category) => category.name == name,
      orElse: () => categories.first,
    );
  }
}
