class AccountModel {
  final String id;
  final String userId; // associar a conta a um usuário específico
  final String name; // Ex: "Carteira", "Banco Inter"
  final double balance; // Saldo ATUAL da conta
  final String color; // Para diferenciar no gráfico (ex: Roxo para Nubank)

  AccountModel({required this.id, required this.userId, required this.name, required this.balance, required this.color});
}