import 'user_model.dart';

class BoardModel {
  final String id;
  final String name;
  final String createdBy;
  List<UserModel> members = [];

  BoardModel({
    required this.id,
    required this.name,
    required this.createdBy,
    this.members = const [],
  });
  factory BoardModel.fromMap(Map<String, dynamic> data, String documentId) {
    return BoardModel(
      id: documentId,
      name: data['name'] ?? 'Untitled',
      createdBy: data['createdBy'] ?? 'Unknown',
      members: data['members'] != null
          ? List<UserModel>.from(
              data['members'].map((x) => UserModel.fromJson(x)),
            )
          : [],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdBy': createdBy,
      'members': members.map((x) => x.toJson()).toList(),
    };
  }
}
