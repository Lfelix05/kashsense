import 'dart:async';

import 'package:kashsense/models/transaction_model.dart';
import '../models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

const String _defaultAccountId = 'primary';

class Database {
  static final StreamController<String> _transactionsController =
      StreamController<String>.broadcast();

  // ----- Users -----
  static Future<User?> getUserById(String userId) async {
    try {
      final doc = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  static Future<User?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await firestore.FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return User.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário por email: $e');
      return null;
    }
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

  static Future<User> addUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      final users = firestore.FirebaseFirestore.instance.collection('users');
      final newDoc = users.doc();
      final user = User(
        id: newDoc.id,
        name: name,
        email: email,
        password: password,
      );
      await newDoc.set(user.toJson());

      // Cria conta padrão para o usuário
      final accountRef = newDoc.collection('accounts').doc(_defaultAccountId);
      await accountRef.set({
        'id': _defaultAccountId,
        'userId': user.id,
        'name': 'Carteira',
        'balance': 0.0,
        'color': '#6200EE',
        'budgetLimit': 0.0,
      });

      return user;
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
      throw Exception('Erro ao adicionar usuário');
    }
  }

  static Future<User> updateUserProfile(
    String userId, {
    required String name,
    String? profilePictureUrl,
  }) async {
    try {
      final userRef = firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
      await userRef.set({
        'name': name,
        'profilePictureUrl': profilePictureUrl,
      }, firestore.SetOptions(merge: true));
      final doc = await userRef.get();
      return User.fromJson(doc.data()!);
    } catch (e) {
      print('Erro ao atualizar perfil do usuário: $e');
      throw Exception('Erro ao atualizar perfil do usuário');
    }
  }

  // ----- Accounts / Balance -----
  static firestore.DocumentReference _accountDocRef(
    String userId, [
    String accountId = _defaultAccountId,
  ]) {
    return firestore.FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(accountId);
  }

  static Future<double> getBalance(
    String userId, [
    String accountId = _defaultAccountId,
  ]) async {
    try {
      final doc = await _accountDocRef(userId, accountId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()! as Map<String, dynamic>;
        return (data['balance'] as num?)?.toDouble() ?? 0.0;
      }

      // Fallback: soma de transações
      final snapshot = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      double balance = 0;
      for (var d in snapshot.docs) {
        final transaction = Transaction.fromJson(d.data());
        balance += (transaction.type == TransactionType.income)
            ? transaction.amount
            : -transaction.amount;
      }
      return balance;
    } catch (e) {
      print('Erro ao calcular saldo: $e');
      throw Exception('Erro ao calcular saldo');
    }
  }

  static Future<double> addBalance(
    String userId,
    double amount, {
    TransactionCategory category = TransactionCategory.salario,
    String title = 'Saldo adicionado',
    String accountId = _defaultAccountId,
  }) async {
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.income,
      category: category,
    );

    return addTransaction(userId, transaction, accountId);
  }

  static Future<void> updateBalance(
    String userId,
    double newBalance, [
    String accountId = _defaultAccountId,
  ]) async {
    try {
      await _accountDocRef(
        userId,
        accountId,
      ).set({'balance': newBalance}, firestore.SetOptions(merge: true));
    } catch (e) {
      print('Erro ao atualizar saldo: $e');
      throw Exception('Erro ao atualizar saldo');
    }
  }

  // ----- Transactions -----
  static Future<double> addTransaction(
    String userId,
    Transaction transaction, [
    String accountId = _defaultAccountId,
  ]) async {
    try {
      final firestoreDb = firestore.FirebaseFirestore.instance;
      final accountRef = _accountDocRef(userId, accountId);
      final txRef = firestoreDb
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id);

      final updatedBalance = await firestoreDb.runTransaction<double>((
        tx,
      ) async {
        final accSnap = await tx.get(accountRef);
        double current = 0.0;
        if (accSnap.exists && accSnap.data() != null) {
          final data = accSnap.data()! as Map<String, dynamic>;
          current = (data['balance'] as num?)?.toDouble() ?? 0.0;
        }

        final delta = transaction.type == TransactionType.income
            ? transaction.amount
            : -transaction.amount;
        final updated = current + delta;

        tx.set(txRef, transaction.toJson());
        tx.set(accountRef, {
          'balance': updated,
        }, firestore.SetOptions(merge: true));
        return updated;
      });

      _transactionsController.add(userId);
      return updatedBalance;
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
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Transaction.fromJson(doc.data()))
              .toList(),
        );
  }

  static Future<double> getBudgetLimit(String userId) async {
    try {
      final doc = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return data?['budgetLimit']?.toDouble() ?? 0.0;
      }
    } catch (e) {
      print('Erro ao buscar limite de orçamento: $e');
    }
    return 0.0;
  }

  static Future<void> setBudgetLimit(String userId, double limit) async {
    try {
      await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'budgetLimit': limit}, firestore.SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar limite de orçamento: $e');
      throw Exception('Erro ao salvar limite de orçamento');
    }
  }
}
