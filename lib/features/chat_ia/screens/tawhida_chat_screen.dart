import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/core/services/tts_service.dart';
import '../services/chat_service.dart';

class TawhidaChatScreen extends StatefulWidget {
  const TawhidaChatScreen({super.key});

  @override
  State<TawhidaChatScreen> createState() => _TawhidaChatScreenState();
}

class _TawhidaChatScreenState extends State<TawhidaChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'tawhida',
      'content': 'Asslema! 🌿 Marhba bik fi Cartas. Ena Tawhida+, el morafe9a mtaak lyoum. Kifeh najem n3awnek?',
      'time': DateTime.now(),
    }
  ];
  bool _isLoading = false;
  bool _isVoiceEnabled = true;
  final TtsService _ttsService = TtsService();

  @override
  void dispose() {
    _ttsService.stop();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'content': text,
        'time': DateTime.now(),
      });
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    final response = await ChatService.getTawhidaResponse(text);

    if (mounted) {
      setState(() {
        _messages.add({
          'role': 'tawhida',
          'content': response,
          'time': DateTime.now(),
        });
        _isLoading = false;
      });
      _scrollToBottom();
      
      if (_isVoiceEnabled) {
        _ttsService.speak(response);
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petalCream,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.rosePale.withOpacity(0.5),
              AppColors.petalCream,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildChatList()),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.roseDeep, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/tawhida_avatar.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tawhida+', style: AppTextStyles.title(18, AppColors.roseDeep)),
                Text('En ligne', style: AppTextStyles.body(12, Colors.green, weight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
              color: AppColors.gold,
            ),
            onPressed: () {
              setState(() => _isVoiceEnabled = !_isVoiceEnabled);
              if (!_isVoiceEnabled) _ttsService.stop();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.gold),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _buildTypingIndicator();
        }
        final msg = _messages[index];
        final isTawhida = msg['role'] == 'tawhida';
        return _buildMessageBubble(msg['content'], isTawhida);
      },
    );
  }

  Widget _buildMessageBubble(String content, bool isTawhida) {
    return Align(
      alignment: isTawhida ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isTawhida ? Colors.white : AppColors.roseDeep,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isTawhida ? 0 : 20),
            bottomRight: Radius.circular(isTawhida ? 20 : 0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(right: isTawhida ? 30 : 0),
              child: Text(
                content,
                style: AppTextStyles.body(
                  14,
                  isTawhida ? AppColors.textPrimary : Colors.white,
                  weight: isTawhida ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (isTawhida)
              Positioned(
                right: -10,
                bottom: -10,
                child: IconButton(
                  icon: const Icon(Icons.play_circle_outline, 
                    color: AppColors.gold, size: 20),
                  onPressed: () => _ttsService.speak(content),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideX(begin: isTawhida ? -0.1 : 0.1, end: 0),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
            ),
            const SizedBox(width: 10),
            Text('Tawhida+ kteb...', style: AppTextStyles.body(12, AppColors.textMuted)),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSuggestions(),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.petalCream.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question à Tawhida+...',
                      hintStyle: AppTextStyles.body(14, AppColors.textDim),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      {'label': '🌿 Phyto Lab', 'message': 'N7eb njarreb el Virtual Phyto Lab.'},
      {'label': '📖 Herbier', 'message': 'Warini el Herbier Digital.'},
      {'label': '🛍️ Boutique', 'message': 'Chniya andkom jdid fl Boutique?'},
      {'label': '👩‍⚕️ Expert', 'message': 'N7eb na3mel consultation.'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: suggestions.map((s) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ActionChip(
            label: Text(s['label']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.rosePale.withOpacity(0.3),
            side: const BorderSide(color: AppColors.rosePale),
            onPressed: () {
              _messageController.text = s['message']!;
              _sendMessage();
            },
          ),
        )).toList(),
      ),
    );
  }
}
