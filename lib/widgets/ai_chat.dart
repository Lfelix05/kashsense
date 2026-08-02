import 'package:flutter/material.dart';

import '../services/ai_service.dart';
import '../theme/app_theme.dart';

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}

// bolha flutuante que fica por cima do app; ao tocar, abre o painel de chat
class AiChatBubble extends StatefulWidget {
  final String userId;
  final Widget child;

  const AiChatBubble({super.key, required this.userId, required this.child});

  @override
  State<AiChatBubble> createState() => _AiChatBubbleState();
}

class _AiChatBubbleState extends State<AiChatBubble> {
  static const double _bubbleSize = 56;
  static const double _panelWidth = 300;
  static const double _panelHeight = 400;

  Offset? _bubbleOffset;
  bool _isOpen = false;
  bool _isSending = false;
  final List<_ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleOpen() {
    setState(() => _isOpen = !_isOpen);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(const _ChatMessage(text: '', isUser: false));
      _isSending = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      await for (final chunk in AiService.generateResponseStream(text)) {
        final current = _messages.last.text;
        setState(() {
          _messages[_messages.length - 1] = _ChatMessage(
            text: current + chunk,
            isUser: false,
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages[_messages.length - 1] = const _ChatMessage(
          text: 'Desculpe, não consegui responder agora.',
          isUser: false,
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    _bubbleOffset ??= Offset(
      screenSize.width - _bubbleSize - 16,
      screenSize.height - _bubbleSize - 100,
    );

    final bubblePos = Offset(
      _bubbleOffset!.dx.clamp(0.0, screenSize.width - _bubbleSize),
      _bubbleOffset!.dy.clamp(0.0, screenSize.height - _bubbleSize),
    );

    var panelLeft = bubblePos.dx + _bubbleSize - _panelWidth;
    panelLeft = panelLeft.clamp(8.0, screenSize.width - _panelWidth - 8);

    var panelTop = bubblePos.dy - _panelHeight - 12;
    if (panelTop < 8) {
      panelTop = bubblePos.dy + _bubbleSize + 12;
    }

    return Stack(
      children: [
        widget.child,
        if (_isOpen)
          Positioned(
            left: panelLeft,
            top: panelTop,
            width: _panelWidth,
            height: _panelHeight,
            child: _ChatPanel(
              messages: _messages,
              isSending: _isSending,
              inputController: _inputController,
              scrollController: _scrollController,
              onSend: _sendMessage,
              onClose: _toggleOpen,
              panelWidth: _panelWidth,
            ),
          ),
        Positioned(
          left: bubblePos.dx,
          top: bubblePos.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _bubbleOffset = Offset(
                  (_bubbleOffset!.dx + details.delta.dx).clamp(
                    0.0,
                    screenSize.width - _bubbleSize,
                  ),
                  (_bubbleOffset!.dy + details.delta.dy).clamp(
                    0.0,
                    screenSize.height - _bubbleSize,
                  ),
                );
              });
            },
            onTap: _toggleOpen,
            child: Material(
              elevation: 6,
              shape: const CircleBorder(),
              color: AppColors.primary,
              child: SizedBox(
                width: _bubbleSize,
                height: _bubbleSize,
                child: Icon(
                  _isOpen ? Icons.close : Icons.smart_toy_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatPanel extends StatelessWidget {
  final List<_ChatMessage> messages;
  final bool isSending;
  final TextEditingController inputController;
  final ScrollController scrollController;
  final VoidCallback onSend;
  final VoidCallback onClose;
  final double panelWidth;

  const _ChatPanel({
    required this.messages,
    required this.isSending,
    required this.inputController,
    required this.scrollController,
    required this.onSend,
    required this.onClose,
    required this.panelWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: AppColors.primary,
            child: Row(
              children: [
                const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Assistente IA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Pergunte algo sobre suas finanças!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: panelWidth * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? AppColors.primary
                                : AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.text.isEmpty ? '...' : message.text,
                            style: TextStyle(
                              color: message.isUser
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputController,
                    enabled: !isSending,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Digite sua pergunta...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundStart,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: AppColors.primary),
                  onPressed: isSending ? null : onSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
