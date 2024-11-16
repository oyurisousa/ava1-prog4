import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class FirebaseService {
  static const String baseUrl = 'https://todo-prog4-default-rtdb.firebaseio.com';

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks.json'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data.entries.map((e) {
        final taskData = e.value as Map<String, dynamic>;
        return Task.fromJson(taskData)..id = e.key;
      }).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> addTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks.json'),
      body: json.encode(task.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add task');
    }
  }

  Future<void> updateTask(Task task) async {
    await http.patch(
      Uri.parse('$baseUrl/tasks/${task.id}.json'),
      body: json.encode(task.toJson()),
    );
  }

  Future<void> deleteTask(String id) async {
    await http.delete(Uri.parse('$baseUrl/tasks/$id.json'));
  }
}
