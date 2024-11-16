import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';

class CategoryService {
  static const String baseUrl = 'https://todo-prog4-default-rtdb.firebaseio.com';

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories.json'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>? ?? {};
      return data.entries
          .map((e) => Category.fromJson(e.value as Map<String, dynamic>, e.key))
          .toList();
    } else {
      throw Exception('Failed to fetch categories');
    }
  }

  Future<void> addCategory(Category category) async {
    await http.post(
      Uri.parse('$baseUrl/categories.json'),
      body: json.encode(category.toJson()),
    );
  }

  Future<void> updateCategory(Category category) async {
    await http.patch(
      Uri.parse('$baseUrl/categories/${category.id}.json'),
      body: json.encode(category.toJson()),
    );
  }

  Future<void> deleteCategory(String id) async {
    await http.delete(Uri.parse('$baseUrl/categories/$id.json'));
  }
}
