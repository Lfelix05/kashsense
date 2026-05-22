import 'dart:async';

import 'package:kashsense/models/transaction_model.dart';
import '../models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
// Simulação de um banco de dados em memória
class Database {
  static Map<String, List<Transaction>> transactionsByUser = {};  // armazenamento das transações por usuário
  static Map<String, double> budgetLimitByUser = {};              // armazenamento dos limites de orçamento por usuário
  static final StreamController<String> _transactionsController =
      StreamController<String>.broadcast();

  static Future<User?> getUserById(String userId) async {
    try {
      final doc = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
    } catch (e) {
      print('Erro ao buscar usuário: $e');
    }
    return Future.error('Usuário não encontrado');
  }

  static Future<User> getUserByEmail(String email) async {
    try {
      final querySnapshot = await firestore.FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return User.fromJson(querySnapshot.docs.first.data());
      }
    } catch (e) {
      print('Erro ao buscar usuário por email: $e');
    }
    return Future.error('Usuário não encontrado');
  }

  static Future<User> updateUser(User user) async {
    try {
      await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toJson(), firestore.SetOptions(merge: true));
      return user;
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      throw Exception('Erro ao atualizar usuário');
    }
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
