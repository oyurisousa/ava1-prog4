import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../services/firebase_service.dart';
import '../models/task.dart';
import '../models/category.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final VoidCallback onSave;

  const TaskFormScreen({this.task, required this.onSave});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  final CategoryService categoryService = CategoryService();
  late String title;
  late String description;
  late DateTime dueDate;
  String? selectedCategory;
  late Future<List<Category>> categories;

  @override
  void initState() {
    super.initState();
    title = widget.task?.title ?? '';
    description = widget.task?.description ?? '';
    dueDate = widget.task?.dueDate ?? DateTime.now();
    selectedCategory = widget.task?.category; 
    categories = categoryService.fetchCategories(); 
  }

  Future<void> _selectDueDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && selectedDate != dueDate) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(dueDate),
      );
      if (selectedTime != null) {
        setState(() {
          dueDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nova Tarefa' : 'Editar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Título'),
                onSaved: (value) => title = value!,
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Descrição'),
                onSaved: (value) => description = value!,
              ),
              
              FutureBuilder<List<Category>>(
                future: categories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();  
                  } else if (snapshot.hasError) {
                    return Text('Erro ao carregar categorias: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Nenhuma categoria disponível.');
                  } else {
                    final categoryList = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categoryList
                          .map((category) => DropdownMenuItem<String>(
                                value: category.name,
                                child: Text(category.name),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        selectedCategory = value;
                      }),
                      decoration: const InputDecoration(labelText: 'Categoria'),
                    );
                  }
                },
              ),
              GestureDetector(
                onTap: _selectDueDate,  
                child: AbsorbPointer(  
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Data de Vencimento',
                      hintText: "${dueDate.toLocal()}".split(' ')[0], 
                    ),
                    controller: TextEditingController(
                      text: "${dueDate.toLocal()}".split(' ')[0], 
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final task = Task(
                      id: widget.task?.id ?? '',
                      title: title,
                      description: description,
                      dueDate: dueDate,
                      category: selectedCategory ?? '', 
                    );
                    if (widget.task == null) {
                      await _firebaseService.addTask(task);
                    } else {
                      await _firebaseService.updateTask(task);
                    }
                    widget.onSave();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
