import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService categoryService = CategoryService();
  late Future<List<Category>> categories;

  @override
  void initState() {
    super.initState();
    categories = categoryService.fetchCategories();
  }

  void _refreshCategories() {
    setState(() {
      categories = categoryService.fetchCategories();
    });
  }

  void _showCategoryDialog({Category? category}) {
    final _formKey = GlobalKey<FormState>();
    String name = category?.name ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(category == null ? 'Nova Categoria' : 'Editar Categoria'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              initialValue: name,
              decoration: const InputDecoration(labelText: 'Nome da Categoria'),
              validator: (value) =>
                  value!.isEmpty ? 'O nome não pode ser vazio' : null,
              onSaved: (value) => name = value!,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newCategory = Category(
                    id: category?.id ?? '',
                    name: name,
                  );
                  if (category == null) {
                    await categoryService.addCategory(newCategory);
                  } else {
                    await categoryService.updateCategory(newCategory);
                  }
                  _refreshCategories();
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
      ),
      body: FutureBuilder<List<Category>>(
        future: categories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar categorias.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma categoria cadastrada.'));
          } else {
            final categories = snapshot.data!;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await categoryService.deleteCategory(category.id);
                      _refreshCategories();
                    },
                  ),
                  onTap: () => _showCategoryDialog(category: category),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
