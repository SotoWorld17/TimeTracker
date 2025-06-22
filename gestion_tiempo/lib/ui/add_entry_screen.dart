import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gestion_tiempo/models/project.dart';
import 'package:gestion_tiempo/models/task.dart';
import 'package:gestion_tiempo/models/entry.dart';
import 'package:gestion_tiempo/providers/entry_provider.dart';
import 'package:gestion_tiempo/providers/project_provider.dart';
import 'package:gestion_tiempo/providers/task_provider.dart';
import 'package:provider/provider.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});
  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen>{
  final _formKey = GlobalKey<FormState>();
  String? _selectedProjectId;
  String? _selectedTaskId;
  DateTime _selectedDate = DateTime.now();
  final _hoursController = TextEditingController();
  final _notesController = TextEditingController();


  @override
  void dispose() {
    _hoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save(){
    if(_formKey.currentState!.validate()){

      final newEntry = Entry(
        projectId: _selectedProjectId!, 
        taskId: _selectedTaskId!,
        date: _selectedDate,
        hours: double.parse(_hoursController.text),
        notes: _notesController.text,
      );

      context.read<EntryProvider>().addEntry(newEntry);
      Navigator.of(context).pop(); 
    }
  }

  @override
  Widget build(BuildContext context){
    final catProv = context.watch<ProjectProvider>();
    final taskProv = context.watch<TaskProvider>();
    final projects = catProv.projects;
    final tasks = taskProv.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Entrada'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Proyecto',
                  prefixIcon: Icon(Icons.folder),
                ),
                value: _selectedProjectId,
                items: projects.map((project) {
                  return DropdownMenuItem<String>(
                    value: project.id,
                    child: Text(project.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                  });
                },
                validator: (value) => value == null
                    ? 'Por favor, selecciona un proyecto.'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tarea',
                  prefixIcon: Icon(Icons.assignment),
                ),
                value: _selectedTaskId,
                items: tasks.map((task) {
                  return DropdownMenuItem<String>(
                    value: task.id,
                    child: Text(task.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTaskId = value;
                  });
                },
                validator: (value) => value == null
                    ? 'Por favor, selecciona una tarea.'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ],
              ),
              TextFormField(
                controller: _hoursController,
                decoration: const InputDecoration(
                  labelText: 'Total de Horas',
                  prefixIcon: Icon(Icons.watch_later_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, ingresa una cantidad válida.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Guardar entrada'),
              )
            ],
          ),
        ),
      ),
    );
  }
}