import 'dart:async';

import 'package:kashsense/models/transaction_model.dart';
import '../models/user.dart';
// Simulação de um banco de dados em memória
class Database {
  static List<User> users = [];

  static Map<String, List<Transaction>> transactionsByUser = {};  // armazenamento das transações por usuário
  static Map<String, double> budgetLimitByUser = {};              // armazenamento dos limites de orçamento por usuário
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
    budgetLimitByUser[user.id] = 2000;
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

  static User? getUserById(String userId) {
    for (final user in users) {
      if (user.id == userId) {
        return user;
      }
    }
    return null;
  }

  static User? updateUserProfile(
    String userId, {
    required String name,
    String? profilePictureUrl,
  }) {
    final index = users.indexWhere((user) => user.id == userId);
    if (index == -1) {
      return null;
    }

    final currentUser = users[index];
    final updatedUser = User(
      id: currentUser.id,
      name: name,
      email: currentUser.email,
      password: currentUser.password,
      profilePictureUrl: profilePictureUrl ?? currentUser.profilePictureUrl,
    );
    users[index] = updatedUser;
    return updatedUser;
  }

  static bool emailExists(String email) {
    for (final user in users) {
      if (user.email == email) {
        return true;
      }
    }
    return false;
  }
//calcular saldo
  static double getBalance(String userId) {
    final transactions = getTransactions(userId);
    return transactions.fold(0.0, (balance, transaction) {
      if (transaction.type == TransactionType.income) {
        return balance + transaction.amount;
      }
      return balance - transaction.amount;
    });
  }
//adicionar saldo
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

  static double getBudgetLimit(String userId) {
    return budgetLimitByUser[userId] ?? 2000;
  }

  static void setBudgetLimit(String userId, double limit) {
    budgetLimitByUser[userId] = limit;
  }
}
