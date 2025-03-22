import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_manegement/models/task_model.dart';

class ApiService {
  static const String baseUrl = 'https://hushed-foggy-dollar.glitch.me';

  // Get all tasks
  static Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/glitch-tasks'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  // Add or update a task
  static Future<Task> addOrUpdateTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/add-task'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Task.fromJson(data['task']);
      } else {
        throw Exception('Failed to save task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving task: $e');
    }
  }
}
