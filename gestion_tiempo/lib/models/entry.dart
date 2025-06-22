import 'package:uuid/uuid.dart';

class Entry {
  final String id;
  final String projectId;
  final String taskId;
  final DateTime date;
  final double hours;
  final String notes;

  Entry({
    String? id,
    required this.projectId,
    required this.taskId,
    DateTime? date,
    required this.hours,
    this.notes = '',
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      taskId: json['taskId'] as String,
      date: DateTime.parse(json['date'] as String),
      hours: (json['hours'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'taskId': taskId,
      'date': date.toIso8601String(),
      'hours': hours,
      'notes': notes,
    };
  }
}
