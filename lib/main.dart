import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manegement/controllers/category_controller.dart';
import 'package:task_manegement/controllers/task_controller.dart';
import 'package:task_manegement/controllers/theme_controller.dart';
import 'package:task_manegement/screens/splash_screen.dart';
import 'package:task_manegement/services/local_storage_service.dart';
import 'package:task_manegement/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await LocalStorageService.init();

  // Initialize controllers in the correct order
  final themeController = Get.put(ThemeController());
  final categoryController =
      Get.put(CategoryController()); // Initialize this first
  final taskController =
      Get.put(TaskController()); // This depends on CategoryController

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Make sure controllers are available throughout the app
    Get.put(ThemeController(), permanent: true);
    Get.put(CategoryController(), permanent: true);
    Get.put(TaskController(), permanent: true);

    return GetBuilder<ThemeController>(
      builder: (controller) => GetMaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: controller.themeMode,
        defaultTransition: Transition.cupertino,
        home: const SplashScreen(),
      ),
    );
  }
}
