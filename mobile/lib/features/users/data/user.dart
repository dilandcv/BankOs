class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;
  final String status;
  final String createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      createdAt: (json['created_at'] as String?) ?? '',
    );
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
