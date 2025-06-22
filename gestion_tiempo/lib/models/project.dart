import 'package:uuid/uuid.dart';

class Project {
  final String id;
  final String name;

  Project({
    String? id,
    required this.name,
  }) : id = id ?? const Uuid().v4();

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
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
