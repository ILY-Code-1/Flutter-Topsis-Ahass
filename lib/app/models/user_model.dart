class UserModel {
  final String id;
  final String username;
  final String password;
  final String role;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.isActive,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
      role: map['role'] as String? ?? 'staff',
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'role': role,
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? password,
    String? role,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}
