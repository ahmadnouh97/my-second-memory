class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String email;
  final DateTime createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  UserModel copyWith({String? id, String? email, DateTime? createdAt}) =>
      UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        createdAt: createdAt ?? this.createdAt,
      );
}
