import '../models/user.dart';
class Database {

  static List<User> users = [];

  static void addUser(String name, String email, String password) {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: password,
    );
    users.add(user);
  }
}