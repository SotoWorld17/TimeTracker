// lib/providers/Task_provider.dart

import 'package:flutter/foundation.dart';
import 'package:gestion_tiempo/models/task.dart' as model;
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

class TaskProvider extends ChangeNotifier {
  final LocalStorage storage;
  final List<model.Task> _tasks = [];

  TaskProvider({required this.storage}) {
    _load();
  }

  /// Lista inmutable de etiquetas
  List<model.Task> get tasks => List.unmodifiable(_tasks);

  /// Obtiene una etiqueta por su ID, o null si no existe
  model.Task? getById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Carga las etiquetas desde LocalStorage al iniciar
  void _load() {
    final raw = storage.getItem('Tasks');
    if (raw != null) {
      final decoded = jsonDecode(raw as String) as List;
      _tasks
        ..clear()
        ..addAll(decoded.map((e) => model.Task.fromJson(e as Map<String, dynamic>)));
    }
    notifyListeners();
  }

  /// Añade una nueva etiqueta, guarda y notifica a los listeners
  void addTask(model.Task t) {
    _tasks.add(t);
    _save();
    notifyListeners();
  }

  /// Elimina una etiqueta por ID, guarda y notifica
  void removeTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }

  /// Persiste la lista de etiquetas en LocalStorage
  void _save() {
    storage.setItem(
      'Tasks',
      jsonEncode(_tasks.map((t) => t.toJson()).toList()),
    );
  }
}
