// lib/providers/Project_provider.dart
import 'package:flutter/foundation.dart';
import 'package:gestion_tiempo/models/project.dart' as model;
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

class ProjectProvider extends ChangeNotifier {
  final LocalStorage storage;
  final List<model.Project> _projects = [];

  ProjectProvider({required this.storage}) {
    _load();
  }

  List<model.Project> get projects => List.unmodifiable(_projects);

  model.Project? getById(String id) {
    try {
      return _projects.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void _load() {
    final raw = storage.getItem('projects');
    if (raw != null) {
      final decoded = jsonDecode(raw as String) as List;
      _projects
        ..clear()
        ..addAll(decoded.map((e) => model.Project.fromJson(e)));
    }
    notifyListeners();
  }

  void addProject(model.Project c) {
    _projects.add(c);
    _save();
    notifyListeners();
  }

  void _save() {
    storage.setItem('projects',
      jsonEncode(_projects.map((c) => c.toJson()).toList())
    );
  }

  void removeProject(String id) {
    _projects.removeWhere((c) => c.id == id);
    _save();
    notifyListeners();
  }
}
