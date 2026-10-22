<p align="center">
  <img src="assets/Icon/KashSenseIcon.png" alt="KashSense" width="120" />
</p>

<h1 align="center">KashSense</h1>

<p align="center">
  Finanças pessoais com um conselheiro de IA no bolso.<br/>
  Registre receitas e despesas, acompanhe seu orçamento e converse com uma IA que conhece os seus números.
</p>

<p align="center">
  <a href="https://github.com/Lfelix05/kashsense/releases/latest"><b>⬇️ Baixar o APK para Android</b></a>
</p>

---

## Sobre o projeto

O KashSense é um app Android de controle financeiro pessoal feito com Flutter e Firebase. O objetivo é
deixar fácil ver para onde o dinheiro está indo e, com a ajuda de um assistente de IA, entender o que
fazer com essa informação.

## Funcionalidades

- **Resumo financeiro**: saldo atual, gráfico mensal de receitas x despesas e acompanhamento do orçamento.
- **Transações**: registre gastos e entradas por categoria (comida, transporte, lazer, saúde, contas,
  salário, investimentos, benefícios e outros), com a lista sempre atualizada em tempo real.
- **Relatórios por categoria**: gráfico de colunas com o detalhamento de cada categoria.
- **Orçamento mensal**: defina um limite e veja quanto já foi consumido.
- **Conselheiro de IA**: um chat flutuante, com o Google Gemini, que responde com base nas suas
  transações, saldo e orçamento dos últimos 60 dias.
- **Personalização**: perfil com nome e foto, tema claro/escuro, opção de ocultar valores e
  preferências de notificação.
- **Sincronização na nuvem**: conta com e-mail e senha, e os dados ficam salvos no Firebase, acessíveis
  só por você.

## Instalação

1. Acesse a página de [Releases](https://github.com/Lfelix05/kashsense/releases/latest) e baixe o
   arquivo `.apk` mais recente.
2. No celular, abra o arquivo e permita a instalação de apps de fontes desconhecidas quando o Android pedir.
3. Abra o KashSense, crie sua conta e comece a registrar suas transações.

> Requer Android com acesso à internet.

## Privacidade e segurança

- O login é feito pelo Firebase Authentication; a senha não é armazenada no banco de dados.
- As regras do Firestore ([`firestore.rules`](firestore.rules)) garantem que cada usuário só leia e
  altere os próprios dados.
- Ao usar o chat, um resumo das suas finanças é enviado ao Google Gemini para gerar a resposta.

> As sugestões da IA são orientações gerais e **não** substituem recomendações financeiras de um
> profissional.

## Tecnologias

| Camada | Ferramentas |
| --- | --- |
| App | [Flutter](https://flutter.dev) / Dart |
| Autenticação e dados | Firebase Authentication, Cloud Firestore |
| Inteligência artificial | Google Gemini API |
| Gráficos | [fl_chart](https://pub.dev/packages/fl_chart) |
| Chat | [flutter_markdown_plus](https://pub.dev/packages/flutter_markdown_plus) |
| Tipografia | JetBrains Mono |

## Estrutura do código

```text
lib/
├── models/      # Usuário, transação, conta e configurações
├── providers/   # Funções de acesso usadas pelas telas e validações
├── services/    # Firestore, contexto financeiro e integração com a IA
├── theme/       # Tema claro/escuro
├── view/        # Telas (login, resumo, transações, relatórios, configurações)
└── widgets/     # Componentes (gráficos, orçamento, chat de IA, formulários)
```

## Rodando a partir do código

Pré-requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) e um dispositivo ou emulador Android.

```bash
git clone https://github.com/Lfelix05/kashsense.git
cd kashsense
flutter pub get
```

O chat de IA precisa de uma chave da API do Gemini, gerada em
[aistudio.google.com/apikey](https://aistudio.google.com/apikey). Copie `env.json.example` para
`env.json`, coloque a sua chave e rode:

```bash
flutter run --dart-define-from-file=env.json
```

Sem a chave, o app funciona normalmente, só o chat fica indisponível.

## Autor

Desenvolvido por [Lucas Felix](https://github.com/Lfelix05).
