class UserModel {
  UserModel({
    required this.image,
    required this.about,
    required this.username,
    required this.createdAt,
    required this.id,
    required this.email,
    required this.pushToken,
    this.role,
  });
  late String image;
  late String about;
  late String username;
  late String createdAt;
  late String id;
  late String email;
  late String pushToken;
  String? role;

  UserModel.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    username = json['username'] ?? '';
    createdAt = json['created_at'] ?? '';
    id = json['id'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['username'] = username;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['email'] = email;
    data['push_token'] = pushToken;
    data['role'] = role;
    return data;
  }
  // toString method

  @override
  String toString() {
    return 'UserModel{image: $image, about: $about, username: $username, createdAt: $createdAt, id: $id, email: $email, pushToken: $pushToken ,role $role} ';
  }
}
