import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:task_manegement/controllers/category_controller.dart';
import 'package:task_manegement/models/category_model.dart';
import 'package:task_manegement/theme/app_theme.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({Key? key}) : super(key: key);

  final CategoryController _categoryController = Get.find<CategoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _categoryController.categories.length,
          itemBuilder: (context, index) {
            final category = _categoryController.categories[index];
            return _buildCategoryItem(context, category);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color,
          child: Icon(category.icon, color: Colors.white),
        ),
        title: Text(category.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditCategoryDialog(context, category),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, category),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;
    IconData selectedIcon = Icons.list_alt;

    Get.dialog(
      AlertDialog(
        title: const Text('Add Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Color'),
              const SizedBox(height: 8),
              BlockPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  selectedColor = color;
                },
              ),
              const SizedBox(height: 16),
              const Text('Select Icon'),
              const SizedBox(height: 8),
              _buildIconSelector((icon) {
                selectedIcon = icon;
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _categoryController.addCategory(
                  nameController.text,
                  selectedColor,
                  selectedIcon,
                );
                Get.back();
              } else {
                Get.snackbar(
                  'Error',
                  'Category name cannot be empty',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    final nameController = TextEditingController(text: category.name);
    Color selectedColor = category.color;
    IconData selectedIcon = category.icon;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Color'),
              const SizedBox(height: 8),
              BlockPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  selectedColor = color;
                },
              ),
              const SizedBox(height: 16),
              const Text('Select Icon'),
              const SizedBox(height: 8),
              _buildIconSelector((icon) {
                selectedIcon = icon;
              }, initialIcon: selectedIcon),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _categoryController.updateCategory(
                  Category(
                    id: category.id,
                    name: nameController.text,
                    color: selectedColor,
                    icon: selectedIcon,
                  ),
                );
                Get.back();
              } else {
                Get.snackbar(
                  'Error',
                  'Category name cannot be empty',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector(Function(IconData) onIconSelected,
      {IconData? initialIcon}) {
    final icons = [
      Icons.list_alt,
      Icons.work,
      Icons.person,
      Icons.shopping_cart,
      Icons.favorite,
      Icons.school,
      Icons.home,
      Icons.fitness_center,
      Icons.local_dining,
      Icons.directions_car,
      Icons.flight,
      Icons.book,
      Icons.movie,
      Icons.music_note,
      Icons.sports_esports,
      Icons.brush,
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        IconData selectedIcon = initialIcon ?? icons[0];

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: icons.map((icon) {
            final isSelected = selectedIcon == icon;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIcon = icon;
                });
                onIconSelected(icon);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _categoryController.deleteCategory(category.id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
