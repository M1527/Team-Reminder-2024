import 'dart:convert';

import 'package:abc/model/task_mode.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ListModel {
  final String name;
  final String description;
  final String createdBy;
  final String? id;
  // list of tasks
  List<TaskCard> tasks = [];
  ListModel({
    required this.name,
    required this.description,
    required this.createdBy,
    this.id,
    this.tasks = const [],
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'tasks': tasks.map((e) => e.toMap()).toList(),
    };
  }

  factory ListModel.fromMap(Map<String, dynamic> map, String documentId) {
    var tasksData = map['tasks'] as List<dynamic>? ?? [];

    List<TaskCard> tasksList = tasksData
        .map((e) => TaskCard.fromMap(e as Map<String, dynamic>, ""))
        .toList();
    return ListModel(
      id: documentId,
      name: map['name'] as String,
      description: map['description'] as String,
      createdBy: map['createdBy'] as String,
      tasks: tasksList,
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'ListModel(id: $id name: $name, description: $description, createdBy: $createdBy , tasks: $tasks)';
  }

  @override
  bool operator ==(covariant ListModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.description == description &&
        other.createdBy == createdBy;
  }

  @override
  int get hashCode {
    return name.hashCode ^ description.hashCode ^ createdBy.hashCode;
  }
}
