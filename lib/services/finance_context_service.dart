import '../models/transaction_model.dart';
import 'database.dart';

/// monta um resumo textual e compacto da situação financeira do usuário
class FinanceContextService {
  static const int _lookbackDays = 60;
  static const int _recentTransactionsCount = 10;

  static String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  static String _categoryLabel(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.comida:
        return 'Comida';
      case TransactionCategory.transporte:
        return 'Transporte';
      case TransactionCategory.lazer:
        return 'Lazer';
      case TransactionCategory.saude:
        return 'Saúde';
      case TransactionCategory.contas:
        return 'Contas';
      case TransactionCategory.salario:
        return 'Salário';
      case TransactionCategory.investimentos:
        return 'Investimentos';
      case TransactionCategory.outros:
        return 'Outros';
    }
  }

  /// Busca saldo, orçamento e transações recentes do Firestore (via
  /// [Database], sem duplicar leituras) e monta um resumo em português para
  /// ser enviado como contexto ao modelo de IA.
  static Future<String> buildSummary(String userId) async {
    final balance = await Database.getBalance(userId);
    final budgetLimit = await Database.getBudgetLimit(userId);
    final transactions = await Database.getTransactions(userId);

    final cutoff = DateTime.now().subtract(
      const Duration(days: _lookbackDays),
    );
    final recent = transactions.where((t) => t.date.isAfter(cutoff)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final buffer = StringBuffer();
    buffer.writeln('Saldo atual: ${_formatCurrency(balance)}');
    if (budgetLimit > 0) {
      buffer.writeln(
        'Limite de orçamento mensal: ${_formatCurrency(budgetLimit)}',
      );
    }

    if (recent.isEmpty) {
      buffer.writeln(
        'Nenhuma transação registrada nos últimos $_lookbackDays dias.',
      );
      return buffer.toString().trim();
    }

    double totalIncome = 0;
    double totalExpense = 0;
    final expenseByCategory = <TransactionCategory, double>{};
    double totalInvestments = 0;

    for (final t in recent) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
        expenseByCategory.update(
          t.category,
          (value) => value + t.amount,
          ifAbsent: () => t.amount,
        );
      }
      if (t.category == TransactionCategory.investimentos) {
        totalInvestments += t.amount;
      }
    }

    buffer.writeln(
      'Nos últimos $_lookbackDays dias: receitas de '
      '${_formatCurrency(totalIncome)} e despesas de '
      '${_formatCurrency(totalExpense)}.',
    );

    if (totalInvestments > 0) {
      buffer.writeln(
        'Movimentação em investimentos no período: '
        '${_formatCurrency(totalInvestments)}.',
      );
    }

    if (expenseByCategory.isNotEmpty) {
      buffer.writeln('Gastos por categoria no período:');
      final sortedCategories = expenseByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedCategories) {
        buffer.writeln(
          '- ${_categoryLabel(entry.key)}: ${_formatCurrency(entry.value)}',
        );
      }
    }

    buffer.writeln('Últimas transações:');
    for (final t in recent.take(_recentTransactionsCount)) {
      final sign = t.type == TransactionType.income ? '+' : '-';
      buffer.writeln(
        '- ${_formatDate(t.date)} | ${t.title} '
        '(${_categoryLabel(t.category)}): $sign${_formatCurrency(t.amount)}',
      );
    }

    return buffer.toString().trim();
  }
}
