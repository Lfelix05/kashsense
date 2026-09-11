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
- Telas de Notificações e Segurança com interface completa em modo demonstração
- Proteção contra sobreposição da barra de navegação do sistema em telas com scroll
- Correção de perda de dados em formulários de adicionar saldo/transação ao abrir ou fechar teclado
- App travado em orientação vertical (`portraitUp` e `portraitDown`)

## Novidades recentes

- Nova identidade visual nas telas de entrada para melhorar apresentação e usabilidade
- Estrutura de área segura reutilizável com `lib/widgets/safe_area_condition.dart`
- Ajuste de formulários para preservar estado no bottom sheet durante mudanças de layout
- Revisão das telas de Configurações com mais conteúdo visual e seções explicativas

## Tecnologias e dependências

- Flutter
- Dart `^3.11.1`
- `fl_chart: ^0.70.2` para gráficos
- `file_picker: ^10.3.2` para seleção de foto de perfil
- Fonte personalizada JetBrains Mono

## Estrutura principal

```text
lib
 ┣ models
 ┃ ┣ account_model.dart
 ┃ ┣ transaction_model.dart
 ┃ ┗ user.dart
 ┣ providers
 ┃ ┣ providers.dart
 ┃ ┗ validator.dart
 ┣ services
 ┃ ┣ ai_service.dart
 ┃ ┣ database.dart
 ┃ ┗ finance_context_service.dart
 ┣ theme
 ┃ ┗ app_theme.dart
 ┣ view
 ┃ ┣ home.dart
 ┃ ┣ login.dart
 ┃ ┣ master.dart
 ┃ ┣ notifications_sett.dart
 ┃ ┣ profile.dart
 ┃ ┣ record.dart
 ┃ ┣ register.dart
 ┃ ┣ security_sett.dart
 ┃ ┣ settings_screen.dart
 ┃ ┣ summary_screen.dart
 ┃ ┗ transaction_screen.dart
 ┣ widgets
 ┃ ┣ action_button.dart
 ┃ ┣ add_balance.dart
 ┃ ┣ add_transaction.dart
 ┃ ┣ ai_chat.dart
 ┃ ┣ budget_progress.dart
 ┃ ┣ month_graph.dart
 ┃ ┗ safe_area_condition.dart
 ┣ firebase_options.dart
 ┗ main.dart
```

## Limitações atuais

- Os dados continuam em memória (sem persistência em banco local/remoto)
- Recursos de Notificações e Segurança estão em modo demonstração (UI pronta, sem backend)
- Não há integração com autenticação externa/online

## Roteiro de demonstração (3-5 minutos)

1. Abertura: mostrar Home e proposta de valor
2. Login com usuário de teste
3. Resumo: saldo, gráfico mensal e orçamento
4. Ações rápidas: adicionar saldo e adicionar transação
5. Relatórios por categoria
6. Configurações: perfil, notificações e segurança
7. Encerramento: destacar melhorias de UX (safe area e preservação de estado)

## Como executar

Pré-requisitos:

- Flutter SDK instalado
- Dispositivo/emulador configurado

```bash
flutter pub get
flutter run
```

### Configurando o chat com IA (Google Gemini)

O widget de chat (`lib/widgets/ai_chat.dart` + `lib/services/ai_service.dart`) chama a API do Gemini
diretamente e precisa de uma chave de API (gerada em `aistudio.google.com/apikey`) passada via `--dart-define`.
Sem ela, o app inicia normalmente mas o chat sempre falha com "Chave da API do Gemini não configurada".

1. Copie `env.json.example` para `env.json` (esse arquivo é ignorado pelo git, não vai para o repositório):

   ```bash
   cp env.json.example env.json
   ```

2. Edite `env.json` e coloque sua chave real no lugar de `sua-chave-aqui`.
3. Rode o app passando o arquivo de defines:

   ```bash
   flutter run --dart-define-from-file=env.json
   ```

## Categorias de transação (atuais)

- comida
- transporte
- lazer
- saude
- contas
- salario
- investimento
- benefícios
- outros
