import 'package:flutter/material.dart';
import 'package:todo/screens/category.dart';
import 'package:todo/screens/task_form.dart';
import '../services/firebase_service.dart';
import '../services/category_service.dart';
import '../models/task.dart';
import '../models/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService firebaseService = FirebaseService();
  final CategoryService categoryService = CategoryService();
  late Future<List<Task>> tasks;
  late Future<List<Category>> categories;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchTasks();
    fetchCategories();
  }

  void fetchTasks() {
    setState(() {
      tasks = firebaseService.fetchTasks();
    });
  }

  void fetchCategories() {
    setState(() {
      categories = categoryService.fetchCategories(); // Carregar categorias do Firebase
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          // Botão para redirecionar para a tela de categorias
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryScreen(),
                ),
              );
            },
          ),
          // Use a FutureBuilder para carregar categorias dinamicamente
          FutureBuilder<List<Category>>(
            future: categories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar categorias.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text(''));
              } else {
                final categoryList = snapshot.data!;
                return PopupMenuButton<String>(
                  onSelected: (category) {
                    setState(() {
                      selectedCategory = category == "Todas" ? null : category;
                    });
                  },
                  itemBuilder: (context) {
                    // Adicionar as categorias dinâmicas aqui
                    List<PopupMenuEntry<String>> menuItems = [
                      const PopupMenuItem(value: "Todas", child: Text("Todas")),
                    ];
                    menuItems.addAll(categoryList.map((category) {
                      return PopupMenuItem(value: category.name, child: Text(category.name));
                    }).toList());

                    return menuItems;
                  },
                );
              }
            },
          )
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Nenhuma Tarefa por aqui.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa disponível.'));
          } else {
            final filteredTasks = snapshot.data!.where((task) {
              return selectedCategory == null || task.category == selectedCategory;
            }).toList();
            return ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                final isDueSoon = task.dueDate.difference(DateTime.now()).inDays <= 1;
                return ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      color: isDueSoon ? Colors.red : null,
                    ),
                  ),
                  subtitle: Text('${task.category} - ${task.dueDate.toLocal()}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await firebaseService.deleteTask(task.id);
                      fetchTasks();
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskFormScreen(task: task, onSave: fetchTasks),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskFormScreen(onSave: fetchTasks),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
