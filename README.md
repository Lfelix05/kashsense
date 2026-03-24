# KashSense

Aplicativo de finanças pessoais desenvolvido em Flutter. Permite registrar receitas e despesas, acompanhar o saldo, visualizar gráficos de resumo mensal e monitorar o progresso do orçamento.

## Funcionalidades

- **Autenticação** — Telas de login e cadastro de usuário
- **Resumo financeiro** — Visão geral do mês com saldo atual, total de receitas e despesas
- **Gráfico PieChart** — Distribuição visual entre receitas e despesas com `fl_chart`
- **Termômetro de orçamento** — Barra de progresso que muda de azul → laranja → vermelho conforme o limite mensal é consumido
- **Ações rápidas** — Botões para adicionar transação, adicionar saldo e acessar relatórios
- **Tela de transações** — Listagem e registro de movimentações financeiras
- **Configurações** — Tela de preferências do usuário

## Tecnologias

| Tech                                                    | Uso                 |
| ------------------------------------------------------- | ------------------- |
| Flutter                                                 | Framework principal |
| Dart `^3.11.1`                                          | Linguagem           |
| [fl_chart](https://pub.dev/packages/fl_chart) `^0.70.2` | Gráficos            |
| JetBrains Mono                                          | Fonte personalizada |

## Estrutura do projeto

```
lib/
├── main.dart
├── models/
│   ├── transaction_model.dart   # Modelo de transação (receita/despesa + categorias)
│   └── user.dart                # Modelo de usuário
├── providers/
│   └── providers.dart           # Gerenciamento de estado
├── services/
│   └── database.dart            # Camada de dados (usuários)
├── view/
│   ├── home.dart                # Rota inicial
│   ├── login.dart               # Tela de login
│   ├── register.dart            # Tela de cadastro
│   ├── master.dart              # Navegação principal (BottomNavigationBar)
│   └── record.dart              # Tela de registro
└── widgets/
    ├── summary_screen.dart      # Resumo, gráfico e orçamento
    ├── transaction_screen.dart  # Listagem de transações
    ├── settings_screen.dart     # Configurações
    ├── action_button.dart       # Botão de ação rápida reutilizável
    ├── add_transaction.dart     # Formulário de nova transação
    ├── add_balance.dart         # Formulário para adicionar saldo
    └── budget_progress.dart     # Termômetro de orçamento
```

## Como executar

**Pré-requisitos:** Flutter SDK instalado e configurado.

```bash
# Instalar dependências
flutter pub get

# Rodar o app
flutter run
```

## Categorias de transação

`food` · `transport` · `leisure` · `health` · `bills` · `salary` · `others`
