import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Serviço de acesso à API da Anthropic (Claude)
class AiService {
  static const String _apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _anthropicVersion = '2023-06-01';
  static const String _model = 'claude-haiku-4-5';
  static const int _maxTokens = 1024;

  static const String _systemPrompt =
      'Você é o conselheiro financeiro pessoal do app KashSense. Seu '
      'objetivo é ajudar o usuário a entender seus gastos, economizar e '
      'tomar melhores decisões financeiras e de investimento, com base nos '
      'dados reais fornecidos a seguir.\n\n'
      'Instruções:\n'
      '- Responda sempre em português do Brasil.\n'
      '- Seja direto e conciso — a conversa acontece em um painel de chat '
      'pequeno.\n'
      '- Baseie suas respostas nos dados financeiros fornecidos sempre que '
      'possível.\n'
      '- Se não houver dados suficientes para responder algo, diga isso '
      'claramente em vez de inventar números.\n'
      '- Suas sugestões de investimento são orientações gerais, não '
      'recomendações financeiras regulamentadas.';

  static void _ensureApiKeyConfigured() {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Chave da API da Anthropic não configurada. Rode o app com '
        '--dart-define=ANTHROPIC_API_KEY=sua-chave.',
      );
    }
  }

  static Map<String, String> get _headers => {
    'content-type': 'application/json',
    'x-api-key': _apiKey,
    'anthropic-version': _anthropicVersion,
  };

  static String _buildSystemPrompt(String? financialContext) {
    if (financialContext == null || financialContext.trim().isEmpty) {
      return _systemPrompt;
    }
    return '$_systemPrompt\n\nDados financeiros do usuário:\n$financialContext';
  }

  static List<Map<String, String>> _buildMessages(
    String prompt,
    List<Map<String, String>>? history,
  ) {
    return [...?history, {'role': 'user', 'content': prompt}];
  }

  static String _errorMessageFor(int statusCode, String body) {
    switch (statusCode) {
      case 401:
        return 'Chave da API da Anthropic inválida.';
      case 429:
        return 'Limite de requisições da API atingido. Tente novamente em instantes.';
      default:
        if (statusCode >= 500) {
          return 'O serviço da IA está indisponível no momento.';
        }
        return 'Erro ao chamar a API da IA ($statusCode): $body';
    }
  }

  // envia um prompt simples e retorna a resposta completa de uma vez
  static Future<String> generateResponse(
    String prompt, {
    String? financialContext,
    List<Map<String, String>>? history,
  }) async {
    _ensureApiKeyConfigured();
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: _headers,
        body: jsonEncode({
          'model': _model,
          'max_tokens': _maxTokens,
          'system': _buildSystemPrompt(financialContext),
          'messages': _buildMessages(prompt, history),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(_errorMessageFor(response.statusCode, response.body));
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['content'] as List<dynamic>?;
      final textBlock = content?.firstWhere(
        (block) => block['type'] == 'text',
        orElse: () => null,
      );
      return textBlock?['text'] as String? ??
          'Não foi possível gerar uma resposta.';
    } catch (e) {
      print('Erro ao gerar resposta da IA: $e');
      throw Exception('Erro ao gerar resposta da IA');
    }
  }

  // versão em stream, para exibir a resposta sendo escrita aos poucos
  static Stream<String> generateResponseStream(
    String prompt, {
    String? financialContext,
    List<Map<String, String>>? history,
  }) async* {
    _ensureApiKeyConfigured();

    final request = http.Request('POST', Uri.parse(_apiUrl))
      ..headers.addAll(_headers)
      ..body = jsonEncode({
        'model': _model,
        'max_tokens': _maxTokens,
        'system': _buildSystemPrompt(financialContext),
        'messages': _buildMessages(prompt, history),
        'stream': true,
      });

    final client = http.Client();
    try {
      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        final body = await streamedResponse.stream.bytesToString();
        throw Exception(_errorMessageFor(streamedResponse.statusCode, body));
      }

      final lines = streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6).trim();
        if (data.isEmpty) continue;

        Map<String, dynamic> event;
        try {
          event = jsonDecode(data) as Map<String, dynamic>;
        } catch (_) {
          continue;
        }

        if (event['type'] == 'content_block_delta') {
          final delta = event['delta'] as Map<String, dynamic>?;
          if (delta?['type'] == 'text_delta') {
            yield delta!['text'] as String;
          }
        } else if (event['type'] == 'error') {
          final message =
              event['error']?['message'] as String? ?? 'Erro desconhecido da API.';
          throw Exception(message);
        }
      }
    } catch (e) {
      print('Erro ao gerar resposta da IA: $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}
