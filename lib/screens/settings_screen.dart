import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:task_manegement/controllers/task_controller.dart';
import 'package:task_manegement/controllers/theme_controller.dart';
import 'package:task_manegement/services/local_storage_service.dart';
import 'package:task_manegement/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeController _themeController = Get.find<ThemeController>();
  final TaskController _taskController = Get.find<TaskController>();
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader('Appearance'),
          _buildThemeSettings(),
          const SizedBox(height: 16),
          _buildSectionHeader('Task Settings'),
          _buildTaskSettings(),
          const SizedBox(height: 16),
          _buildSectionHeader('Data Management'),
          _buildDataSettings(),
          const SizedBox(height: 16),
          _buildSectionHeader('About'),
          _buildAboutSettings(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildThemeSettings() {
    return GetBuilder<ThemeController>(
      builder: (controller) => Column(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme Mode'),
            subtitle: const Text('Change app appearance'),
            trailing: DropdownButton<ThemeMode>(
              value: controller.themeMode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.setThemeMode(value);
                }
              },
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark mode'),
            value: controller.isDarkMode,
            onChanged: (value) {
              controller.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSettings() {
    return Column(
      children: [
        Obx(() => SwitchListTile(
              secondary: const Icon(Icons.check_circle),
              title: const Text('Show Completed Tasks'),
              subtitle: const Text('Display completed tasks in the list'),
              value: _taskController.showCompletedTasks.value,
              onChanged: (value) {
                _taskController.toggleShowCompletedTasks();
              },
            )),
        ListTile(
          leading: const Icon(Icons.sort),
          title: const Text('Default Sort'),
          subtitle: const Text('Choose default sorting method'),
          trailing: Obx(() => DropdownButton<String>(
                value: _taskController.sortOption.value,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: 'date',
                    child: Text('Due Date'),
                  ),
                  DropdownMenuItem(
                    value: 'priority',
                    child: Text('Priority'),
                  ),
                  DropdownMenuItem(
                    value: 'name',
                    child: Text('Name'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _taskController.setSortOption(value);
                  }
                },
              )),
        ),
      ],
    );
  }

  Widget _buildDataSettings() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.sync),
          title: const Text('Sync Data'),
          subtitle: const Text('Refresh data from server'),
          onTap: () async {
            final result = await _taskController.fetchTasks();
            Get.snackbar(
              'Sync Complete',
              'Your tasks have been synchronized',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title:
              const Text('Clear All Data', style: TextStyle(color: Colors.red)),
          subtitle: const Text('Delete all local data'),
          onTap: () {
            Get.dialog(
              AlertDialog(
                title: const Text('Clear All Data'),
                content: const Text(
                  'Are you sure you want to clear all local data? This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await LocalStorageService.clear();
                      Get.back();
                      Get.snackbar(
                        'Data Cleared',
                        'All local data has been cleared',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      _taskController.fetchTasks();
                    },
                    child: const Text('Clear',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSettings() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('App Version'),
          subtitle: Text(_appVersion),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('Source Code'),
          subtitle: const Text('View on GitHub'),
          onTap: () async {
            const url = 'https://github.com/yourusername/flutter_task_manager';
            if (await canLaunch(url)) {
              await launch(url);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: const Text('Report an Issue'),
          subtitle: const Text('Help us improve the app'),
          onTap: () async {
            const url =
                'https://github.com/yourusername/flutter_task_manager/issues';
            if (await canLaunch(url)) {
              await launch(url);
            }
          },
        ),
      ],
    );
  }
}
