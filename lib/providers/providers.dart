import '../models/transaction_model.dart';
import '../models/user.dart';
import '../services/database.dart';

Future<String> addTransaction(
  String userId,
  String title,
  double amount,
  DateTime date,
  TransactionType type,
  TransactionCategory category,
) async {
  final transaction = Transaction(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    userId: userId,
    title: title,
    amount: amount,
    date: date,
    type: type,
    category: category,
  );

  Database.addTransaction(userId, transaction);
  return transaction.id;
}

Future<String> addUser(String name, String email, String password) async {
  Database.addUser(name, email, password);
  return 'Usuário $name adicionado com sucesso!';
}

Future<List<Transaction>> getTransactionsForUser(String userId) async {
  return Database.getTransactions(userId);
}

Future<double> getBalanceForUser(String userId) async {
  return Database.getBalance(userId);
}

Future<double> addBalance(String userId, double amount) async {
  if (amount <= 0) {
    throw ArgumentError('O valor precisa ser maior que zero.');
  }
  return Database.addBalance(userId, amount);
}

Future<String> addBudget(String userId, double amount) async {
  final newBalance = await addBalance(userId, amount);
  return 'Saldo atualizado: R\$ ${newBalance.toStringAsFixed(2)}';
}

Future<User?> getUserForProfile(String userId) async {
  return Database.getUserById(userId);
}

Future<User?> updateUserProfileInfo(
  String userId, {
  required String name,
  String? profilePictureUrl,
}) async {
  return Database.updateUserProfile(
    userId,
    name: name,
    profilePictureUrl: profilePictureUrl,
  );
}
