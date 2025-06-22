import 'package:flutter/material.dart';
import 'package:gestion_tiempo/models/project.dart';
import 'package:gestion_tiempo/providers/project_provider.dart';
import 'package:provider/provider.dart';
import 'dialogs.dart'; // donde esté showAddItemDialog

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});
  @override
  State<ProjectManagementScreen> createState() => _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final projProv   = context.watch<ProjectProvider>();
    final projects = projProv.projects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos', style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Colors.white, 
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: projects.length,
        itemBuilder: (context, i) {
          final proj = projects[i];
          return ListTile(
            title: Text(proj.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Color.fromARGB(255, 174, 33, 2)),
              onPressed: () {
                projProv.removeProject(proj.id);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 2) Añade usando el provider:
          final name = await showAddItemDialog(context, 'Proyecto');
          if (name != null) {
            projProv.addProject(Project(name: name));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
