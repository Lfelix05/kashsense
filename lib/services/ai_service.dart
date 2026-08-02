import 'package:firebase_ai/firebase_ai.dart';

class AiService {
  static final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3.6-flash',
  );

  // envia um prompt simples e retorna a resposta completa de uma vez
  static Future<String> generateResponse(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Não foi possível gerar uma resposta.';
    } catch (e) {
      print('Erro ao gerar resposta da IA: $e');
      throw Exception('Erro ao gerar resposta da IA');
    }
  }

  // versão em stream, útil para exibir a resposta sendo escrita aos poucos
  static Stream<String> generateResponseStream(String prompt) async* {
    try {
      final response = _model.generateContentStream([Content.text(prompt)]);
      await for (final chunk in response) {
        if (chunk.text != null) yield chunk.text!;
      }
    } catch (e) {
      print('Erro ao gerar resposta da IA: $e');
      throw Exception('Erro ao gerar resposta da IA');
    }
  }
}
