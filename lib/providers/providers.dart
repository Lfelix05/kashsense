import '../models/transaction_model.dart';
import '../services/database.dart';

Future<String> addTransaction(
  String userId,
  String title,
  double amount,
  DateTime date,
  TransactionType type,
  TransactionCategory category,
) async {
  final transaction = TransactionModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    userId: userId,
    title: title,
    amount: amount,
    date: date,
    type: type,
    category: category,
  );

  Database.transactions.add(transaction);
  return transaction.id;
}

Future<String> addUser(String name, String email, String password) async {
  Database.addUser(name, email, password);
  return 'Usuário $name adicionado com sucesso!';
}

Future<List<TransactionModel>> getTransactionsForUser(String userId) async {
  return Database.transactions.where((t) => t.userId == userId).toList();
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
