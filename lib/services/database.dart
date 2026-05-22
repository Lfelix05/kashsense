import 'dart:async';

import 'package:kashsense/models/transaction_model.dart';
import '../models/user.dart';
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
  static Future<double> getBalance(String userId) async {
    try {
      final snapshot = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      double balance = 0;
      for (var doc in snapshot.docs) {
        final transaction = Transaction.fromJson(doc.data());
        if (transaction.type == TransactionType.income) {
          balance += transaction.amount;
        } else {
          balance -= transaction.amount;
        }
      }
      return balance;
    } catch (e) {
      print('Erro ao calcular saldo: $e');
      throw Exception('Erro ao calcular saldo');
    }
  }
//adicionar saldo
  static Future<void> updateBalance(String userId, double newBalance) async {
    try {
      await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'balance': newBalance});
    } catch (e) {
      print('Erro ao atualizar saldo: $e');
      throw Exception('Erro ao atualizar saldo');
    }
  }

  static Future<void> addTransaction(String userId, Transaction transaction) async {
    try {
      await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toJson());

      _transactionsController.add(userId);
    } catch (e) {
      print('Erro ao adicionar transação: $e');
      throw Exception('Erro ao adicionar transação');
    }
  }

  static Future<List<Transaction>> getTransactions(String userId) async {
    try {
      final snapshot = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      return snapshot.docs
          .map((doc) => Transaction.fromJson(doc.data()))
            .toList();
    
    } catch (e) {
      print('Erro ao buscar transações: $e');
      throw Exception('Erro ao buscar transações');
    }
  }

  static Stream<List<Transaction>> watchTransactions(String userId) {
  return firestore.FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('transactions')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Transaction.fromJson(doc.data()))
          .toList());
  }
}