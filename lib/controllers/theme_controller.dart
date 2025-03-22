import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manegement/services/local_storage_service.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';

  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final savedTheme = LocalStorageService.getString(_themeKey);
    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    update();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    String themeString;

    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }

    LocalStorageService.setString(_themeKey, themeString);
    update();
  }

  bool get isDarkMode =>
      _themeMode == ThemeMode.dark ||
      (_themeMode == ThemeMode.system &&
          Get.mediaQuery.platformBrightness == Brightness.dark);

  void toggleTheme() {
    if (isDarkMode) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}
