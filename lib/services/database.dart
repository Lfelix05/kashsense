import 'dart:async';

import 'package:kashsense/models/transaction_model.dart';
import '../models/user.dart';

class Database {
  static List<User> users = [];

  static Map<String, List<Transaction>> transactionsByUser = {};
  static final StreamController<String> _transactionsController =
      StreamController<String>.broadcast();

  static User addUser(String name, String email, String password) {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: password,
    );
    users.add(user);
    transactionsByUser[user.id] = [];
    return user;
  }

  static User? getUserByCredentials(String email, String password) {
    for (final user in users) {
      if (user.email == email && user.password == password) {
        return user;
      }
    }
    return null;
  }

  static bool emailExists(String email) {
    for (final user in users) {
      if (user.email == email) {
        return true;
      }
    }
    return false;
  }

  static double getBalance(String userId) {
    final transactions = getTransactions(userId);
    return transactions.fold(0.0, (balance, transaction) {
      if (transaction.type == TransactionType.income) {
        return balance + transaction.amount;
      }
      return balance - transaction.amount;
    });
  }

  static double addBalance(String userId, double amount) {
    final balanceTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: 'Adição de saldo',
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.income,
      category: TransactionCategory.salario,
    );

    addTransaction(userId, balanceTransaction);
    return getBalance(userId);
  }

  static void addTransaction(String userId, Transaction transaction) {
    transactionsByUser.putIfAbsent(userId, () => []);
    transactionsByUser[userId]!.add(transaction);
    _transactionsController.add(userId);
  }

  static List<Transaction> getTransactions(String userId) {
    return transactionsByUser[userId] ?? [];
  }

  static Stream<List<Transaction>> watchTransactions(String userId) async* {
    yield getTransactions(userId);

    await for (final changedUserId in _transactionsController.stream) {
      if (changedUserId == userId) {
        yield getTransactions(userId);
      }
    }
  }
}
