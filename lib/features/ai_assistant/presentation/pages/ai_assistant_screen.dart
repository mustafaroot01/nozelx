import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/features/ai_assistant/data/ai_knowledge_base.dart';
import 'package:auto_lube/features/ai_assistant/data/chat_memory_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  String _userId = 'guest';

  final List<Map<String, dynamic>> _suggestions = [
    {
      'icon': Icons.oil_barrel,
      'text': 'زيت محرك لسيارتي',
      'color': AppColors.primary,
    },
    {
      'icon': Icons.directions_car,
      'text': 'توصيات الصيانة',
      'color': AppColors.secondary,
    },
    {
      'icon': Icons.local_gas_station,
      'text': 'أفضل أنواع الزيوت',
      'color': AppColors.warning,
    },
    {
      'icon': Icons.help_outline,
      'text': 'الأسئلة الشائعة',
      'color': AppColors.info,
    },
    {
      'icon': Icons.shopping_cart,
      'text': 'عروضي الحالية',
      'color': AppColors.success,
    },
    {
      'icon': Icons.track_changes,
      'text': 'تتبع طلبي',
      'color': AppColors.tertiary,
    },
    {'icon': Icons.build, 'text': 'مشكلة في السيارة', 'color': AppColors.error},
    {
      'icon': Icons.local_offer,
      'text': 'كوبونات الخصم',
      'color': AppColors.warning,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Get user ID
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      _userId = userJson.hashCode.toString();
    }

    // Load previous chat history
    final history = await ChatMemoryService.getChatHistory(_userId);

    if (history.isNotEmpty) {
      setState(() {
        _messages = history;
      });
    } else {
      // Welcome message
      final welcomeMsg = AIKnowledgeBase.getResponse('مرحبا');
      _messages = [
        {'text': welcomeMsg, 'isUser': false, 'time': 'الآن'},
      ];
    }
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add({'text': text, 'isUser': true, 'time': 'الآن'});
    });
    _messageController.clear();
    _scrollToBottom();

    // Save user message to memory
    await ChatMemoryService.saveMessage(_userId, text, true);

    setState(() => _isTyping = true);

    // Process the message using Iraqi language processor
    final processedText = IraqiLanguageProcessor.preprocessText(text);
    final intent = IraqiLanguageProcessor.extractIntent(text);

    // Get AI response based on intent
    await Future.delayed(const Duration(milliseconds: 1500), () async {
      if (mounted) {
        final response = AIKnowledgeBase.getResponse(processedText);

        setState(() {
          _isTyping = false;
          _messages.add({'text': response, 'isUser': false, 'time': 'الآن'});
        });

        // Save AI response to memory
        await ChatMemoryService.saveMessage(_userId, response, false);

        _scrollToBottom();
      }
    });
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

  Future<void> _clearChat() async {
    await ChatMemoryService.clearChatHistory(_userId);
    setState(() {
      _messages = [
        {
          'text': AIKnowledgeBase.getResponse('مرحبا'),
          'isUser': false,
          'time': 'الآن',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      if (_messages.length <= 2) _buildSuggestions(),
                      const SizedBox(height: 20),
                      ..._messages.asMap().entries.map(
                        (entry) => _buildMessageBubble(entry.key, entry.value),
                      ),
                      if (_isTyping) _buildTypingIndicator(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildQuickActions(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
          ).animate().shimmer(duration: 2000.ms, delay: 1000.ms),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المساعد الذكي 🤖',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 1000.ms),
                    const SizedBox(width: 6),
                    Text(
                      'متصل دائماً لمساعدتك',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
              ),
            ),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(
                      Icons.history,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text('سجل المحادثات', style: GoogleFonts.cairo()),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: _clearChat,
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text('مسح السجل', style: GoogleFonts.cairo()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.lightbulb_outline,
              color: AppColors.warning,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'جرب هذه الأسئلة',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _suggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestion = entry.value;
            return _buildSuggestionChip(index, suggestion);
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1);
  }

  Widget _buildSuggestionChip(int index, Map<String, dynamic> suggestion) {
    final color = suggestion['color'] as Color;
    return GestureDetector(
      onTap: () => _sendMessage(suggestion['text'] as String),
      child:
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      suggestion['icon'] as IconData,
                      color: color,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      suggestion['text'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: Duration(milliseconds: index * 100))
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.2),
    );
  }

  Widget _buildMessageBubble(int index, Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child:
          Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: isUser ? AppColors.primaryGradient : null,
                  color: isUser ? null : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  border: isUser ? null : Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isUser ? 0.1 : 0.05,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.82,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['text'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: isUser ? Colors.white : AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isUser) ...[
                          const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          message['time'] as String,
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color:
                                (isUser ? Colors.white : AppColors.textTertiary)
                                    .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate(delay: Duration(milliseconds: index * 100))
              .fadeIn(duration: 300.ms)
              .slideX(begin: isUser ? 0.2 : -0.2),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ).animate().fadeIn(duration: 200.ms),
    );
  }

  Widget _buildDot(int index) {
    return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        )
        .animate(delay: Duration(milliseconds: index * 200))
        .fadeIn(duration: 300.ms)
        .then()
        .fadeOut(duration: 300.ms);
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mic, color: AppColors.primary, size: 22),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 4,
                  minLines: 1,
                  style: GoogleFonts.cairo(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك هنا... (يفهم اللهجة العراقية)',
                    hintStyle: GoogleFonts.cairo(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _sendMessage(_messageController.text),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'quick1',
          onPressed: () => _sendMessage('أريد زيت محرك'),
          backgroundColor: AppColors.surface,
          child: const Icon(Icons.oil_barrel, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'quick2',
          onPressed: () => _sendMessage('العروض الحالية'),
          backgroundColor: AppColors.surface,
          child: const Icon(Icons.local_offer, color: AppColors.warning),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'quick3',
          onPressed: () => _sendMessage('مشكلة في السيارة'),
          backgroundColor: AppColors.surface,
          child: const Icon(Icons.build, color: AppColors.error),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'main',
          onPressed: () {},
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.smart_toy, color: Colors.white),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideX(begin: 1);
  }
}
