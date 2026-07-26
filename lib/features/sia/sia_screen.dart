import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';

class BlushySiaScreen extends StatefulWidget {
  final String? initialQuestion;
  const BlushySiaScreen({super.key, this.initialQuestion});

  @override
  State<BlushySiaScreen> createState() => _BlushySiaScreenState();
}

class _BlushySiaScreenState extends State<BlushySiaScreen> with TickerProviderStateMixin {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  
  // Waveform Animation for Voice Mode
  late final AnimationController _waveController;
  bool _isListeningVoice = false;
  bool _isThinking = false;

  // Placeholder rotation
  late final Timer _placeholderTimer;
  int _placeholderIndex = 0;
  final List<String> _placeholders = [
    "Why am I feeling emotional today?",
    "Should I work out today?",
    "Explain my cycle.",
    "Why am I so tired?",
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _placeholderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _placeholderIndex = (_placeholderIndex + 1) % _placeholders.length;
        });
      }
    });

    if (widget.initialQuestion != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendUserMessage(widget.initialQuestion!);
      });
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _waveController.dispose();
    _placeholderTimer.cancel();
    super.dispose();
  }

  void _sendUserMessage(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _messages.add({'sender': 'user', 'text': query});
      _chatController.clear();
      _isThinking = true;
    });

    // Sia response simulation
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isThinking = false;
          if (query.toLowerCase().contains('recovery') || query.toLowerCase().contains('plan')) {
            _messages.add({
              'sender': 'sia',
              'text': 'Here is your personalized recovery plan based on today\'s Luteal phase metrics:',
              'rich': 'checklist'
            });
          } else if (query.toLowerCase().contains('fatigue') || query.toLowerCase().contains('exhaust')) {
            _messages.add({
              'sender': 'sia',
              'text': 'Compared with last month, your energy tends to decrease around Day 20. This pattern has appeared in four consecutive cycles. 4,281 women in our community reported similar fatigue symptoms during this phase.',
              'rich': 'community'
            });
          } else {
            _messages.add({
              'sender': 'sia',
              'text': 'I remember you mentioned feeling similarly last Tuesday. I recommend starting a brief, calming breathing exercise to stabilize heart rate fluctuations.',
              'rich': 'breathe'
            });
          }
        });
      }
    });
  }

  void _startVoiceListening() {
    setState(() {
      _isListeningVoice = true;
    });
    
    // Simulate voice transcription after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isListeningVoice) {
        setState(() {
          _isListeningVoice = false;
        });
        _sendUserMessage("Explain today's fatigue");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0), // Warm Cream Editorial Background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Animated Breathing Orb Identity Section
                    Center(child: const _SiaBreathingOrb()),
                    const SizedBox(height: 12),

                    // 2. Personalized Context Greeting
                    Center(
                      child: Text(
                        'Good evening, Taara.',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: BlushyColors.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Proactive Conversational AI Insight Card (Replaces Purple CTA)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2F2), // Soft blush
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFFFD6D6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                "SIA NOTICED SOMETHING TODAY",
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.red.shade900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "I've noticed you've slept almost 90 minutes less than usual this week. Combined with your luteal phase, that could explain today's fatigue.",
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              height: 1.5,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _sendUserMessage("Explain today's fatigue"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6F42F5), // Brand Accent
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "Explain More",
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: () => _sendUserMessage("Create today's recovery plan"),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: const Color(0xFF6F42F5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                                child: Text(
                                  "Recovery Plan",
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6F42F5)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Redesigned Today's Context Cards Grid (Non-spreadsheet style)
                    Text(
                      "TODAY'S CONTEXT",
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: BlushyColors.secondaryText,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildEditorialContextCard("🌙", "Luteal Phase", "Day 20"),
                        _buildEditorialContextCard("😴", "Sleep", "5h 42m"),
                        _buildEditorialContextCard("⚡", "Energy", "Moderate"),
                        _buildEditorialContextCard("🧠", "Stress", "High"),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 5. Chat timeline or suggestions
                    if (_messages.isEmpty && !_isThinking) ...[
                      Text(
                        'DYNAMIC CONVERSATION STARTERS',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: BlushyColors.secondaryText,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildStarterChip('Explain today\'s fatigue'),
                            const SizedBox(width: 8),
                            _buildStarterChip('Create today\'s recovery plan'),
                            const SizedBox(width: 8),
                            _buildStarterChip('Compare with last month'),
                            const SizedBox(width: 8),
                            _buildStarterChip('Why am I emotional today?'),
                          ],
                        ),
                      ),
                    ] else ...[
                      Column(
                        children: [
                          ..._messages.map((msg) => _buildMessageBubble(msg)),
                          if (_isThinking) _buildThinkingBubble(),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),

                    // 6. Continuous Premium Editorial Sections
                    _buildJournalContinuousSection(
                      "Pattern You've Been Building",
                      "You usually report 20% fewer symptoms when you stay hydrated during luteal cycle transitions. Keep up the high fluid count!",
                      Icons.trending_up_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildJournalContinuousSection(
                      "Journal Prompt",
                      "How does your body feel different today compared to yesterday? Reflect and log.",
                      Icons.edit_note_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildJournalContinuousSection(
                      "Voice Reflection",
                      "Record a 1-minute voice snapshot of your thoughts to allow Sia to track emotional trends.",
                      Icons.mic_none_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildJournalContinuousSection(
                      "Community Discussion",
                      "4,281 women in the community logged luteal exhaustion today. Share suggestions and support.",
                      Icons.forum_outlined,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // 7. Redesigned alive chat input panel
            _buildInputControlPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorialContextCard(String emoji, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Off-white action card
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BlushyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 10, color: BlushyColors.secondaryText, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BlushyColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalContinuousSection(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BlushyColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6F42F5)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: BlushyColors.text),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GoogleFonts.inter(fontSize: 10.5, color: BlushyColors.secondaryText, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarterChip(String label) {
    return GestureDetector(
      onTap: () => _sendUserMessage(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: BlushyColors.border),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: BlushyColors.text,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> msg) {
    final isSia = msg['sender'] == 'sia';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Align(
        alignment: isSia ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSia ? Colors.white : const Color(0xFFF3EFEA),
            borderRadius: BorderRadius.circular(24),
            border: isSia ? Border.all(color: BlushyColors.border) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSia ? 'Sia Companion' : 'You',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSia ? const Color(0xFF6F42F5) : BlushyColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                msg['text'] ?? '',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: BlushyColors.text,
                  height: 1.45,
                ),
              ),
              if (isSia && msg['rich'] != null) ...[
                const SizedBox(height: 16),
                _buildRichComponent(msg['rich']!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRichComponent(String type) {
    if (type == 'checklist') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BlushyColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Luteal Recovery Action Checklist',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _buildCheckItem('Log afternoon hydration intake', true),
            _buildCheckItem('calming breathing cycle (5 minutes)', false),
            _buildCheckItem('Plan light evening stretching routine', false),
          ],
        ),
      );
    }

    if (type == 'breathe') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEEFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6F42F5).withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: Color(0xFF6F42F5), shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calm Breathing Exercise',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF6F42F5)),
                  ),
                  Text(
                    'Cycle-stabilizing parasympathetic booster • 5 min',
                    style: GoogleFonts.inter(fontSize: 10, color: BlushyColors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (type == 'community') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFADCDC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people_alt_outlined, color: BlushyColors.primary, size: 14),
                const SizedBox(width: 8),
                Text(
                  'Community Insights: Fatigue',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: BlushyColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '4,281 women reported similar symptoms in their late luteal cycles. 78% found relief by increasing iron-rich nutrition.',
              style: GoogleFonts.inter(fontSize: 12, color: BlushyColors.text, height: 1.4),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCheckItem(String label, bool initialChecked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(
            initialChecked ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
            color: initialChecked ? Colors.green : BlushyColors.secondaryText,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: initialChecked ? BlushyColors.secondaryText : BlushyColors.text,
                decoration: initialChecked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BlushyColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6F42F5)),
              ),
              const SizedBox(width: 10),
              Text(
                'Sia is thinking...',
                style: GoogleFonts.inter(fontSize: 12, color: BlushyColors.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BlushyColors.border),
        boxShadow: const [
          BoxShadow(
            color: BlushyColors.shadow,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_isListeningVoice) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (index) {
                final randomHeight = 5.0 + math.Random().nextDouble() * 25.0;
                return AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    final heightFactor = math.sin(_waveController.value * 2.0 * math.pi + index) * 8.0;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 3,
                      height: (randomHeight + heightFactor).clamp(4.0, 32.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6F42F5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              'Listening to your voice...',
              style: GoogleFonts.inter(fontSize: 11, color: BlushyColors.secondaryText),
            ),
            const SizedBox(height: 8),
          ],
          
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: const Icon(Icons.add_circle_outline_rounded, color: BlushyColors.secondaryText, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: BlushyColors.border),
                  ),
                  child: TextField(
                    controller: _chatController,
                    style: GoogleFonts.inter(fontSize: 13, color: BlushyColors.text),
                    decoration: InputDecoration(
                      hintText: _placeholders[_placeholderIndex],
                      hintStyle: GoogleFonts.inter(fontSize: 12, color: BlushyColors.secondaryText),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onSubmitted: _sendUserMessage,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  if (_chatController.text.isNotEmpty) {
                    _sendUserMessage(_chatController.text);
                  } else {
                    _startVoiceListening();
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6F42F5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _chatController.text.isNotEmpty ? Icons.send_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SiaBreathingOrb extends StatefulWidget {
  const _SiaBreathingOrb();

  @override
  State<_SiaBreathingOrb> createState() => _SiaBreathingOrbState();
}

class _SiaBreathingOrbState extends State<_SiaBreathingOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 0.15);
        final opacity = 0.2 + (_controller.value * 0.3);
        return Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF8B5CF6).withOpacity(opacity),
                const Color(0xFFC084FC).withOpacity(0.0),
              ],
            ),
          ),
          alignment: Alignment.center,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
