// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:abc/model/user_model.dart';

class TaskCard {
  String? taskId;
  String heading;
  String body;
  String endTime;
  String? actualEndTime;
  String totalTimeSpend;
  int? inProcessTime;
  List<UserModel> members;
  String status;
  String createdAt;
  String createdBy;

  TaskCard({
    this.taskId,
    required this.createdAt,
    required this.createdBy,
    required this.heading,
    required this.body,
    required this.endTime,
    this.actualEndTime,
    this.totalTimeSpend = "0",
    this.inProcessTime,
    required this.members,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'taskId': taskId,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'heading': heading,
      'body': body,
      'endTime': endTime,
      'actualEndTime': actualEndTime,
      'totalTimeSpend': totalTimeSpend,
      'inProcessTime': inProcessTime,
      'members': members.map((x) => x.toJson()).toList(),
      'status': status,
    };
  }

  factory TaskCard.fromMap(Map<String, dynamic> map, String id) {
    return TaskCard(
      taskId: id == "" ? map['taskId'] as String : id,
      createdAt: map['createdAt'] as String,
      createdBy: map['createdBy'] as String,
      heading: map['heading'] as String,
      body: map['body'] as String,
      endTime: map['endTime'] as String,
      actualEndTime:
          map['actualEndTime'] != null ? map['actualEndTime'] as String : null,
      totalTimeSpend: map['totalTimeSpend'] as String,
      inProcessTime:
          map['inProcessTime'] != null ? map['inProcessTime'] as int : null,
      members: List<UserModel>.from(map['members']
              ?.map((x) => UserModel.fromJson(x as Map<String, dynamic>))
          as Iterable),
      status: map['status'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'TaskCard(taskId: $taskId, createdAt: $createdAt, createdBy: $createdBy, heading: $heading, body: $body, endTime: $endTime, actualEndTime: $actualEndTime, totalTimeSpend: $totalTimeSpend, inProcessTime: $inProcessTime, members: $members, status: $status)';
  }

  @override
  bool operator ==(covariant TaskCard other) {
    if (identical(this, other)) return true;

    return other.taskId == taskId &&
        other.createdAt == createdAt &&
        other.createdBy == createdBy &&
        other.heading == heading &&
        other.body == body &&
        other.endTime == endTime &&
        other.actualEndTime == actualEndTime &&
        other.totalTimeSpend == totalTimeSpend &&
        other.inProcessTime == inProcessTime &&
        other.members == members &&
        other.status == status;
  }

  @override
  int get hashCode {
    return taskId.hashCode ^
        createdAt.hashCode ^
        createdBy.hashCode ^
        heading.hashCode ^
        body.hashCode ^
        endTime.hashCode ^
        actualEndTime.hashCode ^
        totalTimeSpend.hashCode ^
        inProcessTime.hashCode ^
        members.hashCode ^
        status.hashCode;
  }
}
