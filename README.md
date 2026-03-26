# KashSense

Aplicativo de finanças pessoais desenvolvido com Flutter para controle de receitas, despesas e orçamento mensal.

## Estado atual do projeto

O app possui autenticação local, fluxo principal por abas (Resumo, Transações, Configurações), gráficos dinâmicos baseados nos dados do usuário e edição de perfil com foto.

Observação: os dados são mantidos em memória (`Database` estático), sem persistência em banco local/remoto por enquanto.

## Funcionalidades implementadas

- Login e cadastro de usuário
- Resumo com saldo atual, nome do usuário e foto de perfil
- Gráfico mensal de pizza (receitas x despesas) atualizado em tempo real
- Orçamento mensal com limite configurável por usuário (toque no card para editar)
- Ações rápidas para adicionar transação, adicionar saldo e abrir relatórios
- Tela de transações com stream reativa e total de gastos
- Tela de relatórios com gráfico de colunas empilhadas por categoria
- Toque nas categorias do relatório para ver detalhamento (receitas, despesas e gasto total da categoria)
- Configurações de perfil com alteração de nome e foto (via seletor de arquivo)
- App travado em orientação vertical (`portraitUp` e `portraitDown`)

## Tecnologias e dependências

- Flutter
- Dart `^3.11.1`
- `fl_chart: ^0.70.2` para gráficos
- `file_picker: ^10.3.2` para seleção de foto de perfil
- Fonte personalizada JetBrains Mono

## Estrutura principal

```text
lib/
├── main.dart
├── models/
│   ├── account_model.dart
│   ├── transaction_model.dart
│   └── user.dart
├── providers/
│   ├── providers.dart
│   └── validator.dart
├── services/
│   └── database.dart
├── view/
│   ├── home.dart
│   ├── login.dart
│   ├── master.dart
│   ├── profile.dart
│   ├── record.dart
│   ├── register.dart
│   ├── settings_screen.dart
│   ├── summary_screen.dart
│   └── transaction_screen.dart
└── widgets/
    ├── action_button.dart
    ├── add_balance.dart
    ├── add_transaction.dart
    ├── budget_progress.dart
    └── month_graph.dart
```

## Como executar

Pré-requisitos:

- Flutter SDK instalado
- Dispositivo/emulador configurado

```bash
flutter pub get
flutter run
```

## Categorias de transação (atuais)

- comida
- transporte
- lazer
- saude
- contas
- salario
- outros
