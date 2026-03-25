class User {
  final String id;
  final String name;
  final String email;
  final String? password;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'password': password, 'profilePictureUrl': profilePictureUrl};
  }
}
