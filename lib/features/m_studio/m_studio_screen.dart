import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../../core/theme.dart' hide BlushyColors;

class BlushyMStudioScreen extends StatefulWidget {
  const BlushyMStudioScreen({super.key});

  @override
  State<BlushyMStudioScreen> createState() => _BlushyMStudioScreenState();
}

class _BlushyMStudioScreenState extends State<BlushyMStudioScreen> with TickerProviderStateMixin {
  // Tab index names
  final List<String> _tabs = [
    'Reflect',
    'Creative Journal',
    'Recovery',
    'Guided Calm',
    'Time Capsules',
    'AI Reflections',
    'Journey'
  ];
  int _selectedTabIndex = 0;

  // Active view states
  bool _isEditorOpen = false;
  String _activeJournalTemplate = 'Daily Reflection';
  String _editorTheme = 'Default'; // Default, Travel, Gratitude, Pink Self-Love
  bool _isDecorated = false;

  final TextEditingController _editorController = TextEditingController(
    text: "Walked along the botanical paths today. Felt extremely introspective and calm as my luteal cycle starts to set in. Focus is high."
  );

  // Voice recording modal simulation
  bool _isRecordingVoice = false;
  String _voiceTranscription = '';

  // Simulation variables for Recovery
  bool _recoveryRunning = false;
  int _recoveryPhase = 0;

  // Time capsules state variables
  String _capsuleRecipient = 'Future Me';
  String _capsuleDate = 'Six Months';
  final List<Map<String, String>> _capsules = [
    {'title': 'Letter to Future Me', 'sub': 'Sealed: Jun 14 • Deliver in 6 Months'},
    {'title': 'Birthday note to Daughter', 'sub': 'Sealed: Jun 10 • Deliver on Birthday'},
  ];

  @override
  void dispose() {
    _editorController.dispose();
    super.dispose();
  }

  // Helper to determine the floating button label and icon based on selected tab
  String _getFloatingActionText() {
    switch (_tabs[_selectedTabIndex]) {
      case 'Reflect':
        return 'New Reflection';
      case 'Creative Journal':
        return 'New Journal';
      case 'Recovery':
        return 'Start Recovery';
      case 'Time Capsules':
        return 'New Capsule';
      case 'AI Reflections':
        return 'Generate Reflection';
      case 'Journey':
        return 'Add Memory';
      default:
        return 'Create';
    }
  }

  IconData _getFloatingActionIcon() {
    switch (_tabs[_selectedTabIndex]) {
      case 'Reflect':
        return Icons.mic_rounded;
      case 'Creative Journal':
        return Icons.auto_stories_rounded;
      case 'Recovery':
        return Icons.spa_rounded;
      case 'Time Capsules':
        return Icons.hourglass_empty_rounded;
      case 'AI Reflections':
        return Icons.auto_awesome_rounded;
      case 'Journey':
        return Icons.add_rounded;
      default:
        return Icons.add_rounded;
    }
  }

  void _onFloatingActionTap() {
    final currentTab = _tabs[_selectedTabIndex];
    if (currentTab == 'Reflect') {
      _startVoiceRecordingFlow();
    } else if (currentTab == 'Creative Journal') {
      setState(() {
        _activeJournalTemplate = 'Blank Canvas';
        _editorTheme = 'Default';
        _isDecorated = false;
        _isEditorOpen = true;
      });
    } else if (currentTab == 'Recovery') {
      _startRecoveryFlow();
    } else if (currentTab == 'Time Capsules') {
      _showCreateCapsuleDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Starting ${currentTab} creation...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditorOpen) {
      return _buildJournalEditor();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0), // Handcrafted cream paper background
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. EDITORIAL HEADER & AI CONTEXT MESSAGE
                _buildHeader(),

                // 2. HORIZONTAL TAB NAVIGATION (Pill capsules list)
                _buildHorizontalTabNavigation(),

                // 3. MAIN WORKSPACE CONTAINER (Morphing view switcher)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: BlushyTheme.getPagePadding(context), vertical: 16.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: child,
                      ),
                      child: _buildWorkspaceTabContent(),
                    ),
                  ),
                ),
              ],
            ),

            // 4. FLOATING ADAPTIVE ACTION BUTTON
            _buildAdaptiveFloatingActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Dynamic context message based on selected tab
    String contextMsg = "Your next Time Capsule arrives in 12 days.";
    if (_selectedTabIndex == 0) contextMsg = "You've written four reflections this week.";
    if (_selectedTabIndex == 2) contextMsg = "You completed two recovery sessions yesterday.";
    if (_selectedTabIndex == 5) contextMsg = "Sia generated a new Weekly Review for you.";

    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Evening, Nithya',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: BlushyColors.text,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            contextMsg,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: BlushyColors.secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalTabNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: BlushyColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final active = _selectedTabIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                margin: EdgeInsets.only(left: index == 0 ? 24 : 8, right: index == _tabs.length - 1 ? 24 : 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? BlushyColors.text : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? BlushyColors.text : BlushyColors.border,
                  ),
                ),
                child: Text(
                  _tabs[index],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white : BlushyColors.secondaryText,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildWorkspaceTabContent() {
    switch (_tabs[_selectedTabIndex]) {
      case 'Reflect':
        return _buildReflectTab();
      case 'Creative Journal':
        return _buildCreativeJournalTab();
      case 'Recovery':
        return _buildRecoveryTab();
      case 'Guided Calm':
        return _buildGuidedCalmTab();
      case 'Time Capsules':
        return _buildTimeCapsulesTab();
      case 'AI Reflections':
        return _buildAIReflectionsTab();
      case 'Journey':
        return _buildJourneyTab();
      default:
        return _buildReflectTab();
    }
  }

  // --- TAB 1: REFLECT ---
  Widget _buildReflectTab() {
    return Column(
      key: const ValueKey('reflect_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkspaceActionCard(
          title: 'Continue Yesterday',
          sub: '“Had a peaceful walk after lunch. Felt very introspective...”',
          icon: Icons.history_rounded,
          onTap: () {
            setState(() {
              _activeJournalTemplate = 'Daily Reflection';
              _isEditorOpen = true;
            });
          },
        ),
        const SizedBox(height: 16),
        
        Text(
          'SUGGESTED PROMPTS',
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: BlushyColors.secondaryText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        _buildPromptRow('What did your body need today that it didn\'t get?'),
        _buildPromptRow('Describe a moment of calm during your luteal phase today.'),
        
        const SizedBox(height: 20),
        Text(
          'TODAY\'S AI REFLECTION',
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: BlushyColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BlushyColors.border),
          ),
          child: Text(
            'Your logs indicate a 15% increase in rest cycles. Estrogen levels are stabilizing.',
            style: GoogleFonts.poppins(fontSize: 12, color: BlushyColors.secondaryText, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: BlushyColors.warning, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12, color: BlushyColors.text, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: CREATIVE JOURNAL ---
  Widget _buildCreativeJournalTab() {
    final templates = [
      'Daily Reflection',
      'Gratitude',
      'Cycle Reflection',
      'Memory Page',
      'Dream Journal',
      'Travel Journal',
    ];

    return Column(
      key: const ValueKey('creative_journal_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHOOSE TEMPLATE',
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: BlushyColors.secondaryText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: templates.map((temp) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _activeJournalTemplate = temp;
                  _editorTheme = temp == 'Gratitude' ? 'Gratitude' : 'Default';
                  _isDecorated = false;
                  _isEditorOpen = true;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: BlushyColors.border),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F7F3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.description_outlined, color: BlushyColors.disabled, size: 28),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        temp,
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- TAB 3: RECOVERY ---
  Widget _buildRecoveryTab() {
    return Column(
      key: const ValueKey('recovery_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recovery score box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFCEFF0),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF9D6D8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RECOVERY SCORE',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: BlushyColors.primary, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Optimal Calm State',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Text(
                '84%',
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600, color: BlushyColors.primary, height: 1.1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (_recoveryRunning) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BlushyColors.border),
            ),
            child: Column(
              children: [
                if (_recoveryPhase == 0) ...[
                  const CircularProgressIndicator(color: BlushyColors.primary),
                  const SizedBox(height: 12),
                  Text('Enabling Do Not Disturb...', style: GoogleFonts.poppins(fontSize: 12)),
                ] else if (_recoveryPhase == 1) ...[
                  const Icon(Icons.music_note_rounded, color: BlushyColors.success, size: 28),
                  const SizedBox(height: 12),
                  Text('Connecting spotify calm loops playlist...', style: GoogleFonts.poppins(fontSize: 12)),
                ] else ...[
                  Text(
                    '“You are stronger than this temporary wave.”',
                    style: GoogleFonts.poppins(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => setState(() => _recoveryRunning = false),
                    child: const Text('Complete Session'),
                  ),
                ],
              ],
            ),
          ),
        ] else ...[
          _buildWorkspaceActionCard(
            title: 'Start Recovery Mode',
            sub: 'One-tap guided breathing, DND trigger, and Spotify music sync.',
            icon: Icons.spa_rounded,
            onTap: _startRecoveryFlow,
          ),
        ],
      ],
    );
  }

  void _startRecoveryFlow() {
    setState(() {
      _recoveryRunning = true;
      _recoveryPhase = 0;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _recoveryPhase = 1);
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _recoveryPhase = 2);
    });
  }

  // --- TAB 4: GUIDED CALM ---
  Widget _buildGuidedCalmTab() {
    return Column(
      key: const ValueKey('guided_calm_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECOMMENDED FOR YOU',
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: BlushyColors.secondaryText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 14),
        _buildWorkspaceActionCard(
          title: 'Period Pain Relief Meditation',
          sub: 'Coping strategies & muscle relaxation logs • 12 min',
          icon: Icons.self_improvement_rounded,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildWorkspaceActionCard(
          title: 'Luteal Phase Anxiety Breathing',
          sub: 'Parasympathetic booster • 8 min',
          icon: Icons.air_rounded,
          onTap: () {},
        ),
      ],
    );
  }

  // --- TAB 5: TIME CAPSULES ---
  Widget _buildTimeCapsulesTab() {
    return Column(
      key: const ValueKey('time_capsules_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkspaceActionCard(
          title: 'Create New Capsule',
          sub: 'Seal letters, voice recordings, or photos for the future.',
          icon: Icons.hourglass_top_rounded,
          onTap: _showCreateCapsuleDialog,
        ),
        const SizedBox(height: 24),
        Text(
          'ACTIVE SEALED CAPSULES',
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: BlushyColors.secondaryText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: _capsules.map((cap) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BlushyColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: BlushyColors.primary, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cap['title'] ?? '',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          cap['sub'] ?? '',
                          style: GoogleFonts.poppins(fontSize: 10, color: BlushyColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showCreateCapsuleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                'New Time Capsule',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _capsuleRecipient,
                    decoration: const InputDecoration(labelText: 'Recipient'),
                    items: ['Future Me', 'Partner', 'Family'].map((r) {
                      return DropdownMenuItem(value: r, child: Text(r));
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        _capsuleRecipient = val ?? 'Future Me';
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _capsuleDate,
                    decoration: const InputDecoration(labelText: 'Delivery Options'),
                    items: ['One Month', 'Six Months', 'One Year'].map((r) {
                      return DropdownMenuItem(value: r, child: Text(r));
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        _capsuleDate = val ?? 'Six Months';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _capsules.add({
                        'title': 'Letter to $_capsuleRecipient',
                        'sub': 'Sealed: Today • Deliver in $_capsuleDate'
                      });
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Time Capsule sealed! You left something for yourself.')),
                    );
                  },
                  child: const Text('Seal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- TAB 6: AI REFLECTIONS ---
  Widget _buildAIReflectionsTab() {
    return Column(
      key: const ValueKey('ai_reflections_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF6F0),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: BlushyColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A LETTER FROM SIA • JUNE',
                style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: BlushyColors.primary),
              ),
              const SizedBox(height: 14),
              Text(
                'Dear Nithya,\n\nDuring your luteal phase, you prioritised rest and post-lunch walks. This decreased stress factors by 14% compared to last cycle.\n\nKeep listening to your body.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  height: 1.45,
                  color: BlushyColors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 7: JOURNEY ---
  Widget _buildJourneyTab() {
    return Column(
      key: const ValueKey('journey_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimelineEvent('TODAY', 'Voice reflection entry logged. Emotional fatigue reset.', Icons.mic_rounded),
        _buildTimelineEvent('YESTERDAY', 'Completed Guided Calm pain relief cycle.', Icons.self_improvement_rounded),
        _buildTimelineEvent('JUNE 12', 'Sealed a Time Capsule to Future Me.', Icons.hourglass_top_rounded),
      ],
    );
  }

  Widget _buildTimelineEvent(String date, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: BlushyColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: BlushyColors.secondaryText),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.poppins(fontSize: 13, color: BlushyColors.text, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceActionCard({
    required String title,
    required String sub,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: BlushyColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BlushyColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: BlushyColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: BlushyColors.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: GoogleFonts.poppins(fontSize: 11, color: BlushyColors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdaptiveFloatingActionButton() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: FloatingActionButton.extended(
        backgroundColor: BlushyColors.dark,
        onPressed: _onFloatingActionTap,
        label: Text(
          _getFloatingActionText(),
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        icon: Icon(_getFloatingActionIcon(), color: Colors.white, size: 16),
      ),
    );
  }

  // --- VOICE RECORDING SIMULATION PIPELINE ---
  void _startVoiceRecordingFlow() {
    setState(() {
      _isRecordingVoice = true;
      _voiceTranscription = 'Listening to your voice...';
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Voice Reflection', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(color: BlushyColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    _voiceTranscription,
                    style: GoogleFonts.poppins(fontSize: 12, color: BlushyColors.secondaryText),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _isRecordingVoice = false;
                      _editorController.text = "“I spent some time listening to nature today and felt extremely content.”";
                      _activeJournalTemplate = 'Daily Reflection';
                      _isEditorOpen = true;
                    });
                  },
                  child: const Text('Stop & Format'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- FREE-FORM JOURNAL CANVAS EDITOR ---
  Widget _buildJournalEditor() {
    Color paperColor = const Color(0xFFFAF6F0);
    if (_editorTheme == 'Gratitude') paperColor = const Color(0xFFFFFDF9);
    if (_editorTheme == 'Pink Self-Love') paperColor = const Color(0xFFFFF0F2);
    if (_editorTheme == 'Travel') paperColor = const Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: paperColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: BlushyColors.dark),
          onPressed: () => setState(() => _isEditorOpen = false),
        ),
        title: Text(
          _activeJournalTemplate,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: BlushyColors.text,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Journal keepsake saved!')),
              );
              setState(() => _isEditorOpen = false);
            },
            child: Text(
              'Save',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: BlushyColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isDecorated) ...[
                    if (_editorTheme == 'Travel') _buildTravelDecorations(),
                    if (_editorTheme == 'Gratitude') _buildGratitudeDecorations(),
                    if (_editorTheme == 'Pink Self-Love') _buildSelfLoveDecorations(),
                  ],
                  TextField(
                    controller: _editorController,
                    maxLines: null,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: BlushyColors.text,
                      height: 1.6,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Start writing or speak your thoughts...',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Editor Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: BlushyColors.border)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDecorated = true;
                      _editorTheme = _activeJournalTemplate == 'Gratitude' ? 'Gratitude' : 'Travel';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6F42F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 13),
                        const SizedBox(width: 6),
                        Text(
                          'AI Decorate',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.text_fields_rounded, color: BlushyColors.disabled),
                const SizedBox(width: 16),
                const Icon(Icons.photo_outlined, color: BlushyColors.disabled),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelDecorations() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8DCC4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('️ Paris Stamp', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD3E4CD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(' Beach Sticker', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildGratitudeDecorations() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFBE7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: BlushyColors.secondary),
            ),
            child: Text(
              ' Floral Divider',
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: BlushyColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfLoveDecorations() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(' Self Love Sticker', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: BlushyColors.primary)),
          ),
        ],
      ),
    );
  }
}
