import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../../core/state.dart';
import '../../core/theme.dart' hide BlushyColors;

class BlushyPartnerScreen extends StatefulWidget {
  const BlushyPartnerScreen({super.key});

  @override
  State<BlushyPartnerScreen> createState() => _BlushyPartnerScreenState();
}

class _BlushyPartnerScreenState extends State<BlushyPartnerScreen> {
  // Segmented space: 'My Space' or 'Our Space'
  String _activeSpace = 'Our Space';

  // Category navigation tabs
  final List<String> _tabs = [
    'Overview',
    'Messenger',
    'Activities',
    'Letters',
    'Memory Book',
    'Relationship AI',
    'Gifts'
  ];
  int _selectedTabIndex = 0;

  // Garden state metrics (Simulated shared interactions)
  int _flowersCount = 3;
  int _treesCount = 1;
  int _butterfliesCount = 0;
  bool _hasPond = false;

  // Messenger simulation states
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'sender': 'Aarav',
      'text': 'Hey, looking forward to our walk after dinner tonight!',
      'isAudio': false,
      'isCard': false,
    },
    {
      'sender': 'Aarav',
      'text': 'Listen to this reflection voice memo from my day',
      'isAudio': true,
      'isCard': false,
      'duration': '1:24',
    },
    {
      'sender': 'Sia',
      'text': 'I noticed this conversation has a warm tone. Complete a shared gratitude activity to grow a flower.',
      'isAudio': false,
      'isCard': true,
      'cardType': 'Quiz',
      'title': 'Daily Couple Quiz',
      'subtitle': 'What is one thing you appreciate about Nithya today?',
    }
  ];
  final TextEditingController _msgController = TextEditingController();

  // Active message actions modal target
  int _selectedMessageIndexForActions = -1;
  bool _showComposerActionsMenu = false;

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  String _getFloatingActionText() {
    switch (_tabs[_selectedTabIndex]) {
      case 'Overview':
        return 'Grow Garden';
      case 'Messenger':
        return 'Send Msg';
      case 'Activities':
        return 'Start Activity';
      case 'Letters':
        return 'Send Letter';
      case 'Memory Book':
        return 'Add Photo';
      default:
        return 'Connect';
    }
  }

  IconData _getFloatingActionIcon() {
    switch (_tabs[_selectedTabIndex]) {
      case 'Overview':
        return Icons.local_florist_rounded;
      case 'Messenger':
        return Icons.send_rounded;
      case 'Activities':
        return Icons.rocket_launch_rounded;
      case 'Letters':
        return Icons.email_outlined;
      case 'Memory Book':
        return Icons.add_a_photo_rounded;
      default:
        return Icons.favorite_rounded;
    }
  }

  void _onFloatingActionTap() {
    final activeTab = _tabs[_selectedTabIndex];
    if (activeTab == 'Overview') {
      setState(() {
        _flowersCount += 2;
        _butterfliesCount += 1;
        if (_flowersCount > 6) _hasPond = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completed daily check-in. The Relationship Garden is growing!')),
      );
    } else if (activeTab == 'Messenger') {
      _sendTextMessage();
    } else if (activeTab == 'Activities') {
      _showActivityTriggerDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Starting $activeTab action...')),
      );
    }
  }

  void _sendTextMessage() {
    if (_msgController.text.isNotEmpty) {
      setState(() {
        _chatMessages.add({
          'sender': 'Nithya',
          'text': _msgController.text,
          'isAudio': false,
          'isCard': false,
        });
        _msgController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = BlushyOSProvider.of(context);
    final isHome = _selectedTabIndex == 0;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isHome && _tabs[_selectedTabIndex] != 'Messenger') ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: BlushyTheme.getPagePadding(context), vertical: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded, color: BlushyColors.dark, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedTabIndex = 0;
                            });
                          },
                        ),
                        Text(
                          _tabs[_selectedTabIndex],
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: BlushyColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: BlushyColors.border),
                ],

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                    child: _buildWorkspaceTabContent(state),
                  ),
                ),
              ],
            ),

            // Message long press action menu overlay
            if (_selectedMessageIndexForActions != -1) _buildMessageActionsOverlay(),

            // Adaptive Floating Action Button (Not visible in Messenger for clean layout)
            if (_tabs[_selectedTabIndex] != 'Messenger') _buildAdaptiveFloatingActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildArgumentModeToggle(BlushyOSState state) {
    final active = state.argumentModeActive;
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
      child: GestureDetector(
        onTap: () {
          if (!active) {
            _showArgumentModeConfirmationDialog(state);
          } else {
            state.setArgumentModeActive(false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Argument Mode disabled. Resuming normal sharing.')),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFDF2F2) : const Color(0xFFF3EFEA),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: active ? BlushyColors.secondary : BlushyColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? Icons.circle : Icons.circle_outlined,
                size: 14,
                color: active ? BlushyColors.success : BlushyColors.secondaryText,
              ),
              const SizedBox(width: 8),
              const Icon(Icons.bolt_rounded, size: 16, color: BlushyColors.warning),
              const SizedBox(width: 4),
              Text(
                active ? "Argument Mode ON" : "Argument Mode OFF",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: active ? BlushyColors.danger : BlushyColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showArgumentModeConfirmationDialog(BlushyOSState state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Turn on Argument Mode?"),
          content: const Text(
            "While Argument Mode is enabled, your personal insights, mood, cycle and wellbeing updates won't be shared with your partner.\n\nShared relationship activities and milestones will continue to work."
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                state.setArgumentModeActive(true);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Argument Mode enabled. Personal insights paused.')),
                );
              },
              child: const Text("Turn On"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BlushyOSState state) {
    String insightText = state.argumentModeActive
        ? "Personal insights are currently paused."
        : "Aarav has completed three thoughtful check-ins this week.";
    if (!state.argumentModeActive) {
      if (_selectedTabIndex == 3) insightText = "You haven't exchanged a Time Capsule in 18 days.";
      if (_selectedTabIndex == 1) insightText = "You both completed your evening reflection yesterday.";
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BlushyTheme.getPagePadding(context), vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Evening, Nithya',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: BlushyColors.text,
            ),
          ),
          Text(
            'Today is a good day to connect.',
            style: GoogleFonts.poppins(fontSize: 12, color: BlushyColors.secondaryText),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BlushyColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: BlushyColors.warning, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insightText,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: BlushyColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCategoryBar() {
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
                  border: Border.all(color: active ? BlushyColors.text : BlushyColors.border),
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

  Widget _buildWorkspaceTabContent(BlushyOSState state) {
    switch (_tabs[_selectedTabIndex]) {
      case 'Overview':
        return _buildOverviewTab(state);
      case 'Messenger':
        return _buildMessengerTab(state);
      case 'Activities':
        return _buildActivitiesTab();
      case 'Letters':
        return _buildLettersTab();
      case 'Memory Book':
        return _buildMemoryBookTab();
      case 'Relationship AI':
        return _buildRelationshipAITab(state);
      case 'Gifts':
        return _buildGiftsTab();
      default:
        return _buildOverviewTab(state);
    }
  }

  // --- TAB 1: OVERVIEW & RELATIONSHIP GARDEN ---
  Widget _buildOverviewTab(BlushyOSState state) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        _buildRelationshipStatusCard(state),
        _buildGardenHeroCard(state),
        _buildQuickActionsRow(),
        _buildRelationshipTimeline(state),
        const SizedBox(height: 24),
        _buildRecentMomentsCarousel(state),
      ],
    );
  }

  Widget _buildRelationshipStatusCard(BlushyOSState state) {
    final active = state.argumentModeActive;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BlushyColors.border),
        boxShadow: [
          BoxShadow(
            color: BlushyColors.dark.withOpacity(0.01),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BlushyColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded, color: BlushyColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aarav',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: BlushyColors.text,
                      ),
                    ),
                    Text(
                      'Connected for 1 year 4 months • Living Steady',
                      style: GoogleFonts.poppins(fontSize: 10, color: BlushyColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: BlushyColors.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    active ? Icons.circle : Icons.circle_outlined,
                    size: 10,
                    color: active ? BlushyColors.success : BlushyColors.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Argument Mode",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: active ? BlushyColors.danger : BlushyColors.text,
                    ),
                  ),
                ],
               ),
               GestureDetector(
                 onTap: () {
                   if (!active) {
                     _showArgumentModeConfirmationDialog(state);
                   } else {
                     state.setArgumentModeActive(false);
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Argument Mode disabled. Resuming normal sharing.')),
                     );
                   }
                 },
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(
                     color: active ? const Color(0xFFFDF2F2) : const Color(0xFFFAF6F0),
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: active ? BlushyColors.secondary : BlushyColors.border),
                   ),
                   child: Text(
                     active ? "ON" : "OFF",
                     style: GoogleFonts.poppins(
                       fontSize: 10,
                       fontWeight: FontWeight.w900,
                       color: active ? BlushyColors.success : BlushyColors.secondaryText,
                     ),
                   ),
                 ),
               ),
             ],
           ),
           if (active) ...[
             const SizedBox(height: 12),
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
               decoration: BoxDecoration(
                 color: const Color(0xFFFFF9F9),
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: BlushyColors.secondary),
               ),
               child: Row(
                 children: [
                   Icon(Icons.lock_person_rounded, size: 14, color: BlushyColors.danger),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text(
                       "Argument Mode is ON. Aarav won't receive any new personal insights until you turn it off.",
                       style: GoogleFonts.poppins(fontSize: 10, color: BlushyColors.danger, height: 1.4),
                     ),
                   ),
                 ],
               ),
             ),
           ],
         ],
       ),
     );
   }

  Widget _buildGardenHeroCard(BlushyOSState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAF6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD6F1DF)),
        boxShadow: [
          BoxShadow(
            color: BlushyColors.dark.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RELATIONSHIP GARDEN',
                style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w900, color: BlushyColors.success, letterSpacing: 1.5),
              ),
              Text(
                'SEASON 01 • BLOOMING',
                style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w900, color: BlushyColors.success, letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(_treesCount, (index) => const Text('', style: TextStyle(fontSize: 28))),
              const SizedBox(width: 4),
              ...List.generate(_flowersCount, (index) => const Text('', style: TextStyle(fontSize: 20))),
              const SizedBox(width: 4),
              if (_butterfliesCount > 0)
                ...List.generate(_butterfliesCount, (index) => const Text('', style: TextStyle(fontSize: 16))),
              if (_hasPond) const Text('', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            state.argumentModeActive
                ? '“Personal insights are currently paused.”'
                : '“Aarav completed his check-in. Tending to your relationship garden builds healthy mutual rhythms.”',
            style: GoogleFonts.poppins(
               fontSize: 18,
               fontStyle: FontStyle.italic,
               color: BlushyColors.success,
               height: 1.45,
             ),
             textAlign: TextAlign.center,
           ),
           const SizedBox(height: 20),
           Center(
             child: OutlinedButton(
               onPressed: () {
                 setState(() {
                   _flowersCount += 1;
                 });
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text("Watered the garden. Blossoms are forming!")),
                 );
               },
               style: OutlinedButton.styleFrom(
                 side: BorderSide(color: BlushyColors.success),
                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text('Grow Together', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: BlushyColors.success)),
                   const SizedBox(width: 8),
                   Icon(Icons.arrow_forward_rounded, size: 12, color: BlushyColors.success),
                 ],
               ),
             ),
           ),
         ],
       ),
     );
   }

  Widget _buildQuickActionsRow() {
    final actions = [
      {'label': 'Send Letter', 'icon': Icons.mail_outline_rounded, 'tab': 3},
      {'label': 'Shared Activity', 'icon': Icons.task_alt_rounded, 'tab': 2},
      {'label': 'Ask Relationship AI', 'icon': Icons.psychology_alt_rounded, 'tab': 5},
      {'label': 'Memory Book', 'icon': Icons.photo_library_outlined, 'tab': 4},
      {'label': 'Surprise', 'icon': Icons.card_giftcard_rounded, 'tab': 6},
      {'label': 'Message', 'icon': Icons.chat_bubble_outline_rounded, 'tab': 1},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: actions.map((act) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = act['tab'] as int;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BlushyColors.border),
                boxShadow: [
                  BoxShadow(
                    color: BlushyColors.dark.withOpacity(0.01),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(act['icon'] as IconData, size: 14, color: BlushyColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    act['label'] as String,
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: BlushyColors.text),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRelationshipTimeline(BlushyOSState state) {
    final events = [
      {'title': 'Anniversary Coming Up', 'time': 'August 14 • 14 days left', 'icon': Icons.favorite_rounded, 'color': const Color(0xFFFDF2F2)},
      {'title': 'Shared Activity Completed', 'time': 'Gratitude Checklist completed by Aarav', 'icon': Icons.task_alt_rounded, 'color': const Color(0xFFF3FAF6)},
      {'title': 'Garden Grew', 'time': 'A new flower bloomed in Season 1', 'icon': Icons.local_florist_rounded, 'color': const Color(0xFFF3FAF6)},
      {'title': 'New Letter Added', 'time': '1 letter sealed in time capsule', 'icon': Icons.mail_outline_rounded, 'color': const Color(0xFFFFF9F2)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Timeline',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: BlushyColors.text,
            ),
          ),
          const SizedBox(height: 12),
          ...events.map((evt) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
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
                      color: evt['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(evt['icon'] as IconData, size: 16, color: BlushyColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evt['title'] as String,
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: BlushyColors.text),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          evt['time'] as String,
                          style: GoogleFonts.poppins(fontSize: 10, color: BlushyColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentMomentsCarousel(BlushyOSState state) {
    final moments = [
      {'title': "Aarav's Check-in", 'desc': 'Completed evening review', 'icon': Icons.sentiment_very_satisfied_rounded},
      {'title': 'Letter From Aarav', 'desc': 'Unseals on Anniversary', 'icon': Icons.mail_outline_rounded},
      {'title': 'Memory Added', 'desc': 'Photo from Sunday walk', 'icon': Icons.photo_library_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recent Moments',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: BlushyColors.text,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: moments.map((mom) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF6F0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: BlushyColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: BlushyColors.dark.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(mom['icon'] as IconData, size: 20, color: BlushyColors.primary),
                    const SizedBox(height: 14),
                    Text(
                      mom['title'] as String,
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: BlushyColors.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mom['desc'] as String,
                      style: GoogleFonts.poppins(fontSize: 10, color: BlushyColors.secondaryText),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- TAB 2: MESSENGER (INSTAGRAM-QUALITY REDESIGN) ---
  Widget _buildMessengerTab(BlushyOSState state) {
    final messages = state.argumentModeActive
        ? _chatMessages.where((msg) => msg['sender'] != 'Sia' || msg['isCard'] == false).toList()
        : _chatMessages;

    return Column(
      key: const ValueKey('messenger_tab'),
      children: [
        // 1. Messenger Instagram-inspired Header Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: BlushyColors.border)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: BlushyColors.dark, size: 18),
                onPressed: () {
                  setState(() {
                    _selectedTabIndex = 0; // Back to Overview
                  });
                },
              ),
              CircleAvatar(
                backgroundColor: BlushyColors.primary.withOpacity(0.1),
                radius: 18,
                child: Text('A', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: BlushyColors.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aarav',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Active 5m ago',
                      style: GoogleFonts.poppins(fontSize: 9, color: BlushyColors.success),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.call_rounded, color: BlushyColors.dark, size: 20),
              const SizedBox(width: 16),
              const Icon(Icons.videocam_rounded, color: BlushyColors.dark, size: 22),
            ],
          ),
        ),

        // 2. Chat history body
        Expanded(
          child: Container(
            color: const Color(0xFFFAF6F0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (context, idx) {
                final msg = messages[idx];
                final isMe = msg['sender'] == 'Nithya';
                return _buildMessageRow(msg, idx, isMe);
              },
            ),
          ),
        ),

        // Composer dynamic helper triggers drawer
        if (_showComposerActionsMenu) _buildComposerActionsDrawer(),

        // 3. Instagram-inspired Message Composer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: BlushyColors.border)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showComposerActionsMenu = !_showComposerActionsMenu;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3EFEA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded, color: BlushyColors.dark, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7F5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: BlushyColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Talk to Aarav...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      const Icon(Icons.sentiment_satisfied_alt_rounded, color: BlushyColors.disabled, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _sendTextMessage,
                child: const CircleAvatar(
                  backgroundColor: Color(0xFF6F42F5),
                  radius: 16,
                  child: Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageRow(Map<String, dynamic> msg, int index, bool isMe) {
    if (msg['isCard'] == true) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: BlushyColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: BlushyColors.warning, size: 14),
                const SizedBox(width: 8),
                Text(
                  msg['title'] ?? '',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: BlushyColors.warning),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              msg['subtitle'] ?? '',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              msg['text'] ?? '',
              style: GoogleFonts.poppins(fontSize: 11, color: BlushyColors.secondaryText),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  _flowersCount += 1;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gratitude logged! Blossoms are forming in your Garden.')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: BlushyColors.dark,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text('Complete Check-in', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: () {
            setState(() {
              _selectedMessageIndexForActions = index;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? BlushyColors.border : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: isMe ? null : Border.all(color: BlushyColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg['isAudio'] == true) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow_rounded, color: Color(0xFF6F42F5)),
                      const SizedBox(width: 6),
                      // Simulated waveform lines
                      ...List.generate(12, (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 2,
                        height: 6.0 + math.Random().nextDouble() * 12.0,
                        color: const Color(0xFF6F42F5),
                      )),
                      const SizedBox(width: 8),
                      Text(
                        msg['duration'] ?? '',
                        style: GoogleFonts.poppins(fontSize: 10, color: BlushyColors.secondaryText),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    msg['text'] ?? '',
                    style: GoogleFonts.poppins(fontSize: 13, color: BlushyColors.text),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Message Actions Panel overlay ---
  Widget _buildMessageActionsOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.3),
        alignment: Alignment.center,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AI Communication Hub',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _buildOverlayActionItem('Rewrite Kindly', Icons.auto_awesome_rounded, () {
                setState(() {
                  _chatMessages[_selectedMessageIndexForActions]['text'] = "“I value our walks. Let\'s connect tonight.”";
                  _selectedMessageIndexForActions = -1;
                });
              }),
              _buildOverlayActionItem('Save to Memory Book', Icons.bookmark_outline_rounded, () {
                setState(() {
                  _selectedMessageIndexForActions = -1;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved to shared scrapbook memory!')),
                );
              }),
              _buildOverlayActionItem('Close', Icons.close_rounded, () {
                setState(() {
                  _selectedMessageIndexForActions = -1;
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayActionItem(String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: BlushyColors.primary, size: 18),
      title: Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      onTap: onTap,
    );
  }

  // --- Composer activities drawer drawer ---
  Widget _buildComposerActionsDrawer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BlushyColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActivityComposerItem('Couple Quiz', Icons.quiz_outlined, () {
            setState(() {
              _chatMessages.add({
                'sender': 'Sia',
                'text': 'Complete a shared gratitude check-in to grow flowers in your Garden.',
                'isAudio': false,
                'isCard': true,
                'cardType': 'Quiz',
                'title': 'Daily Couple Quiz',
                'subtitle': 'What is one thing you appreciate about Nithya today?',
              });
              _showComposerActionsMenu = false;
            });
          }),
          _buildActivityComposerItem('Date Ideas', Icons.restaurant_rounded, () {
            setState(() {
              _showComposerActionsMenu = false;
            });
          }),
          _buildActivityComposerItem('Breathing Sync', Icons.air_rounded, () {
            setState(() {
              _showComposerActionsMenu = false;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildActivityComposerItem(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: BlushyColors.primary.withOpacity(0.1),
            radius: 20,
            child: Icon(icon, color: BlushyColors.primary, size: 18),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: BlushyColors.text)),
        ],
      ),
    );
  }

  // --- TAB 3: SHARED ACTIVITIES ---
  Widget _buildActivitiesTab() {
    return Column(
      key: const ValueKey('activities'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SHARED RELATIONSHIP ACTIVITIES',
          style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: BlushyColors.secondaryText),
        ),
        const SizedBox(height: 14),
        _buildActivityCard('Daily Gratitude Challenge', 'Encourages genuine positive communication log'),
        const SizedBox(height: 10),
        _buildActivityCard('Weekend Planner', 'Build custom bucket lists and date schedules'),
        const SizedBox(height: 10),
        _buildActivityCard('Calm Breathing Together', 'Soothing synchronization parasympathetic reset'),
      ],
    );
  }

  Widget _buildActivityCard(String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BlushyColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.rocket_launch_rounded, color: BlushyColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  sub,
                  style: GoogleFonts.poppins(fontSize: 10, color: BlushyColors.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String title, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BlushyColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: BlushyColors.primary, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              Text(
                sub,
                style: GoogleFonts.poppins(fontSize: 10, color: BlushyColors.secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 4: LETTERS ---
  Widget _buildLettersTab() {
    return Column(
      key: const ValueKey('letters'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverviewItem('Letter to Aarav', 'Delivering on Anniversary • Sealed', Icons.mail_outline_rounded),
      ],
    );
  }

  // --- TAB 5: MEMORY BOOK Scrapbook ---
  Widget _buildMemoryBookTab() {
    return Column(
      key: const ValueKey('memory_book'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BlushyColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            'Scrapbook is building over time as you complete activities.',
            style: GoogleFonts.poppins(fontSize: 12, color: BlushyColors.secondaryText),
          ),
        ),
      ],
    );
  }

  // --- TAB 6: RELATIONSHIP AI ---
  Widget _buildRelationshipAITab(BlushyOSState state) {
    return Column(
      key: const ValueKey('relationship_ai'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EEFA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE4D6F1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SIA RELATIONSHIP ADVICE',
                style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF6F42F5)),
              ),
              const SizedBox(height: 10),
              Text(
                state.argumentModeActive
                    ? '“Your partner has chosen not to share personal insights right now.”'
                    : '“Aarav completed a check-in yesterday. I suggest planning a simple post-dinner walk to connect in a calm luteal phase environment.”',
                style: GoogleFonts.poppins(fontSize: 12, height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 7: GIFTS ---
  Widget _buildGiftsTab() {
    return Column(
      key: const ValueKey('gifts'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverviewItem('Send Digital Flowers', 'Send a sweet postcard and customizable flower bloom', Icons.local_florist_rounded),
      ],
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

  void _showActivityTriggerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Start Shared Activity'),
          content: const Text('Would you like to notify Aarav to start the Gratitude Checklist together?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _flowersCount += 1;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Activity started! Aarav has been notified.')),
                );
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }
}
