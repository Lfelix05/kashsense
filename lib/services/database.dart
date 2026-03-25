import 'package:kashsense/models/transaction_model.dart';
import '../models/user.dart';

class Database {
  static List<User> users = [];

  static List<TransactionModel> transactions = [];

  static Map<String, double> balancesByUser = {};

  static void addUser(String name, String email, String password) {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: password,
    );
    users.add(user);
    balancesByUser[user.id] = 0;
  }

  static double getBalance(String userId) {
    return balancesByUser[userId] ?? 0;
  }

  static double addBalance(String userId, double amount) {
    final currentBalance = getBalance(userId);
    final updatedBalance = currentBalance + amount;
    balancesByUser[userId] = updatedBalance;
    return updatedBalance;
  }
}
