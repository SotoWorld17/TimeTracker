import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';

import '../models/entry.dart';

class EntryProvider extends ChangeNotifier {
  final LocalStorage storage;
  final List<Entry> _entries = [];

  EntryProvider({required this.storage}) {
    _loadFromStorage();
  }

  List<Entry> get entries => List.unmodifiable(_entries);

  // Carga al arrancar
  void _loadFromStorage() {
    final data = storage.getItem('entries');
    if (data != null) {
      final List decoded = jsonDecode(data as String);
      _entries
        ..clear()
        ..addAll(decoded.map((e) => Entry.fromJson(e as Map<String, dynamic>)));
      notifyListeners();
    }
  }

  // Guarda tras cada cambio
  void _saveToStorage() {
    final encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    storage.setItem('entries', encoded);
  }

  // Métodos CRUD
  void addEntry(Entry e) {
    _entries.add(e);
    _saveToStorage();
    notifyListeners();
  }

  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    _saveToStorage();
    notifyListeners();
  }
}
