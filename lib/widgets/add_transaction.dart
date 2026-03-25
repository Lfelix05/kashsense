import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../providers/providers.dart';

Widget buildAddTransaction(BuildContext context) {
  TransactionCategory selectedCategory = TransactionCategory.outros;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final String userId = 'user123';

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Adicionar Transação',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Título',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          controller: titleController,
        ),
        const SizedBox(height: 16),
        TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Valor',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          controller: amountController,
        ),
        const SizedBox(height: 16),
        StatefulBuilder(
          builder: (context, setLocalState) {
            return DropdownButtonFormField<TransactionCategory>(
              initialValue: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: TransactionCategory.values
                  .map(
                    (category) => DropdownMenuItem<TransactionCategory>(
                      value: category,
                      child: Text(_categoryLabel(category)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setLocalState(() {
                  selectedCategory = value;
                });
              },
            );
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (titleController.text.isEmpty || amountController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preencha todos os campos')),
              );
              return;
            } else {
              addTransaction(
                userId,
                titleController.text,
                double.tryParse(amountController.text) ?? 0.0,
                DateTime.now(),
                TransactionType.expense,
                selectedCategory,
              );
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 69, 69),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Salvar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 36),
      ],
    ),
  );
}

String _categoryLabel(TransactionCategory category) {
  switch (category) {
    case TransactionCategory.comida:
      return 'Comida';
    case TransactionCategory.transporte:
      return 'Transporte';
    case TransactionCategory.lazer:
      return 'Lazer';
    case TransactionCategory.saude:
      return 'Saude';
    case TransactionCategory.contas:
      return 'Contas';
    case TransactionCategory.salario:
      return 'Salario';
    case TransactionCategory.outros:
      return 'Outros';
  }
}
