import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String name;

  Task({
    String? id, 
    required this.name,
  }) : id = id ?? const Uuid().v4();

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}