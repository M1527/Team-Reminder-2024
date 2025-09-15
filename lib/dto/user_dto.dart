class UserDto {
  final String? id;
  final String username;
  final String email;
  final String password;
  String? role;

  UserDto({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.role,
  });

  factory UserDto.fromMap(Map<String, dynamic> data, String documentId) {
    return UserDto(
      id: documentId,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      role: data['role'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}
