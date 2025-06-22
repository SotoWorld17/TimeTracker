import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import 'dialogs.dart'; 

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen.TaskManagementScreen({super.key});
  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final taskProv = context.watch<TaskProvider>();
    final tasks    = taskProv.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas', style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Colors.white, 
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tasks.length,
        itemBuilder: (context, i) {
          final tag = tasks[i];
          return ListTile(
            title: Text(tag.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Borramos a través del provider
                taskProv.removeTask(tag.id);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Mostramos diálogo y añadimos vía provider
          final name = await showAddItemDialog(context, 'Tarea');
          if (name != null) {
            taskProv.addTask(Task(name: name));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
