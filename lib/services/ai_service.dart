import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Serviço de acesso à API do Gemini (Google AI Studio)
class AiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  // Alias sempre gratuito e atualizado automaticamente pelo Google.
  // Alternativa fixa, caso prefira não depender do alias: 'gemini-2.5-flash'.
  static const String _model = 'gemini-flash-latest';
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
        'Chave da API do Gemini não configurada. Rode o app com '
        '--dart-define=GEMINI_API_KEY=sua-chave.',
      );
    }
  }

  static Map<String, String> get _headers => {
    'content-type': 'application/json',
    'x-goog-api-key': _apiKey,
  };

  static String _buildSystemPrompt(String? financialContext) {
    if (financialContext == null || financialContext.trim().isEmpty) {
      return _systemPrompt;
    }
    return '$_systemPrompt\n\nDados financeiros do usuário:\n$financialContext';
  }

  static String _mapRole(String role) => role == 'assistant' ? 'model' : 'user';

  static List<Map<String, dynamic>> _buildContents(
    String prompt,
    List<Map<String, String>>? history,
  ) {
    final turns = [...?history, {'role': 'user', 'content': prompt}];
    return turns
        .map(
          (m) => {
            'role': _mapRole(m['role']!),
            'parts': [
              {'text': m['content']},
            ],
          },
        )
        .toList();
  }

  static String _errorMessageFor(int statusCode, String body) {
    switch (statusCode) {
      case 401:
        return 'Chave da API do Gemini inválida.';
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
    try {
      _ensureApiKeyConfigured();
      final response = await http.post(
        Uri.parse('$_baseUrl/$_model:generateContent'),
        headers: _headers,
        body: jsonEncode({
          'contents': _buildContents(prompt, history),
          'systemInstruction': {
            'parts': [
              {'text': _buildSystemPrompt(financialContext)},
            ],
          },
          'generationConfig': {'maxOutputTokens': _maxTokens},
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(_errorMessageFor(response.statusCode, response.body));
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final candidates = data['candidates'] as List<dynamic>?;
      final parts =
          (candidates != null && candidates.isNotEmpty)
              ? (candidates.first['content']?['parts'] as List<dynamic>?)
              : null;
      final text =
          (parts != null && parts.isNotEmpty)
              ? (parts.first['text'] as String?)
              : null;
      return text ?? 'Não foi possível gerar uma resposta.';
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
    final client = http.Client();
    try {
      _ensureApiKeyConfigured();

      final request =
          http.Request(
              'POST',
              Uri.parse('$_baseUrl/$_model:streamGenerateContent?alt=sse'),
            )
            ..headers.addAll(_headers)
            ..body = jsonEncode({
              'contents': _buildContents(prompt, history),
              'systemInstruction': {
                'parts': [
                  {'text': _buildSystemPrompt(financialContext)},
                ],
              },
              'generationConfig': {'maxOutputTokens': _maxTokens},
            });

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

        if (event.containsKey('error')) {
          final message =
              event['error']?['message'] as String? ??
              'Erro desconhecido da API.';
          throw Exception(message);
        }

        final candidates = event['candidates'] as List<dynamic>?;
        final parts =
            (candidates != null && candidates.isNotEmpty)
                ? (candidates.first['content']?['parts'] as List<dynamic>?)
                : null;
        final chunkText =
            (parts != null && parts.isNotEmpty)
                ? (parts.first['text'] as String?)
                : null;
        if (chunkText != null && chunkText.isNotEmpty) {
          yield chunkText;
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
