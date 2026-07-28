import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../../core/theme.dart' hide BlushyColors;

class BlushyCommunityScreen extends StatefulWidget {
  const BlushyCommunityScreen({super.key});

  @override
  State<BlushyCommunityScreen> createState() => _BlushyCommunityScreenState();
}

class _BlushyCommunityScreenState extends State<BlushyCommunityScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _activeTab = 'All'; // All, Stories, Questions, Articles
  String _searchQuery = '';
  bool _showSearchOverview = false;

  // Interactive Voice Recording simulation state
  bool _showVoiceModal = false;
  int _voiceStep = 0; // 0: Recording, 1: Formatting text, 2: Finished ready to publish
  String _voiceProcessedText = '';
  String _voiceTitle = '';
  List<String> _voiceTags = [];

  // Interactive Collections simulation state
  bool _showCollectionsModal = false;
  String _selectedCollection = '';
  final List<String> _collections = ['Hormones', 'Mental Health', 'Productivity', 'PMS', 'Nutrition', 'Pregnancy'];

  // Interactive AI Companion popup simulation
  bool _showCompanionModal = false;
  String _companionContextTitle = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlushyColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Natural AI Search Input
                  _buildAISearchBar(),

                  if (_showSearchOverview) ...[
                    // Search mode showing Sia's synthesized community review
                    _buildAISearchOverview(),
                  ] else ...[
                    // Standard Feed Mode
                    
                    // 2. Voice-First Posting Header Card
                    _buildVoicePostingCTA(),
                    
                    // 3. Patterns Across Women (Living insight card)
                    _buildPatternsAcrossWomenCard(),

                    // 4. Tab Navigation (Stories, Questions, Articles)
                    _buildNavigationTabs(),

                    const SizedBox(height: 16),

                    // 5. Feed Items (V2 Evolved Cards)
                    _buildCommunityFeed(),
                  ],
                  const SizedBox(height: 48),
                ],
              ),
            ),

            // Voice Modal Overlay
            if (_showVoiceModal) _buildVoiceModalOverlay(),

            // Collections Modal Overlay
            if (_showCollectionsModal) _buildCollectionsModalOverlay(),

            // AI Companion Modal Overlay
            if (_showCompanionModal) _buildCompanionModalOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildAISearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BlushyTheme.getPagePadding(context), vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BlushyColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: BlushyColors.primary, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _showSearchOverview = val.isNotEmpty;
                      });
                    },
                    style: GoogleFonts.poppins(fontSize: 14, color: BlushyColors.text),
                    decoration: InputDecoration(
                      hintText: 'Ask naturally: \"Why am I exhausted?\"',
                      hintStyle: GoogleFonts.poppins(fontSize: 13, color: BlushyColors.secondaryText),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _showSearchOverview = false;
                      });
                    },
                    child: const Icon(Icons.close_rounded, color: BlushyColors.secondaryText, size: 18),
                  ),
              ],
            ),
          ),
          if (!_showSearchOverview) ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildNaturalQueryChip('Why am I crying before meetings?'),
                  _buildNaturalQueryChip('Does luteal phase affect productivity?'),
                  _buildNaturalQueryChip('Is this normal?'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNaturalQueryChip(String query) {
    return GestureDetector(
      onTap: () {
        _searchController.text = query;
        setState(() {
          _searchQuery = query;
          _showSearchOverview = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFEA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          query,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: BlushyColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAISearchOverview() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BlushyTheme.getPagePadding(context), vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: BlushyColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'SIA SEARCHED 8,462 ANONYMOUS EXPERIENCES',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: BlushyColors.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Statistics Overview
                Row(
                  children: [
                    Text(
                      '72% ',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: BlushyColors.text,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'of women experienced similar symptoms',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: BlushyColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Most common during: Luteal Phase',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6F42F5),
                  ),
                ),
                const Divider(height: 24, color: Color(0xFFFCA5A5)),

                // Coping strategies list
                Text(
                  'Most Common Coping Advice:',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: BlushyColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                _buildBulletPoint('Sleep consistency & early wind-downs'),
                _buildBulletPoint('Reduce afternoon caffeine consumption'),
                _buildBulletPoint('Proactive hydration strategies'),
                
                const SizedBox(height: 12),
                Text(
                  'Doctor Insight:',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: BlushyColors.secondaryText,
                  ),
                ),
                Text(
                  'Temporary progesterone fluctuations often elevate core temperature and lower energy. These are normal biological patterns.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: BlushyColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recommended Reading',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: BlushyColors.text,
            ),
          ),
          const SizedBox(height: 16),
          _buildStoryCard(
            title: 'Hormones & Headaches: Managing Mid-Cycle Spikes',
            excerpt: 'Understanding the vascular effects of estrogen drops and progesterone increments on cerebral blood flow.',
            author: 'Dr. Sarah Jenkins, OBGYN',
            readTime: '6 min read',
            categoryTag: 'LUTEAL PHASE',
            helpfulCount: 42,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12, color: BlushyColors.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoicePostingCTA() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BlushyTheme.getPagePadding(context), vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showVoiceModal = true;
            _voiceStep = 0;
          });
          _simulateVoicePipeline();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BlushyColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: BlushyColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic_rounded, color: BlushyColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell Your Story',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: BlushyColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Speak naturally. Sia formats your authentic voice.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: BlushyColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: BlushyColors.secondaryText, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateVoicePipeline() {
    // Simulating Voice speech-to-text and AI parsing pipeline steps
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _showVoiceModal) {
        setState(() {
          _voiceStep = 1;
          _voiceProcessedText = "“i was feeling really bad on day 19 like i had massive brain fog and design work was muddy and i couldn’t think then i rested and did raw writing and it worked well”";
        });
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _showVoiceModal) {
        setState(() {
          _voiceStep = 2;
          _voiceTitle = "Navigating Mid-Cycle Brain Fog & Creativity Loss";
          _voiceProcessedText = "“Why my design layouts felt muddy on day 19, and how shifting to raw writing saved my editorial workflow.”";
          _voiceTags = ['Luteal', 'Brain Fog', 'Productivity', 'PMS'];
        });
      }
    });
  }

  Widget _buildPatternsAcrossWomenCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BlushyTheme.getPagePadding(context), vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFCF7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF3EFE0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFB800), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Pattern Across Women',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB38600),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Among women with similar cycle length, age, and sleep habits:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: BlushyColors.text,
              ),
            ),
            const SizedBox(height: 12),
            _buildPatternRow('74% reported increased fatigue during the late luteal phase.'),
            _buildPatternRow('Coping strategies: Improved sleep consistency, hydration, and lighter exercise.'),
            _buildPatternRow('Symptoms typical duration: Resolved within 2–3 days after menstruation began.'),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF8B8000), size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: BlushyColors.text,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTabs() {
    return Padding(
      padding: EdgeInsets.only(left: BlushyTheme.getPagePadding(context), top: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildTabItem('All'),
            _buildTabItem('Stories'),
            _buildTabItem('Questions'),
            _buildTabItem('Articles'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label) {
    final active = _activeTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? BlushyColors.text : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? BlushyColors.text : BlushyColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.white : BlushyColors.secondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityFeed() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BlushyTheme.getPagePadding(context)),
      child: Column(
        children: [
          if (_activeTab == 'All' || _activeTab == 'Questions') ...[
            _buildQuestionCard(
              title: 'Crying before meetings during Luteal Phase',
              question: 'Does anyone else cry before meetings during luteal phase?',
              respondentsCount: 324,
              averageDuration: '2–4 days',
              percentageSim: '82%',
              mostCommonSolutions: 'Sleep, Hydration, Iron',
            ),
            const SizedBox(height: 20),
          ],
          if (_activeTab == 'All' || _activeTab == 'Stories') ...[
            _buildJournalStoryCard(
              title: 'My Mid-Cycle Brain Fog & Design loss',
              author: 'Anonymous Designer',
              timeline: [
                _TimelineStop('Day 1', 'Progesterone levels baseline. High mental energy.'),
                _TimelineStop('Day 3', 'Mild headaches started. Design layout feels mudded.'),
                _TimelineStop('Day 5', 'Brain fog. Switched to writing raw lists to track ideas.'),
                _TimelineStop('Day 7', 'Menstruation start. Focus returning. Completed design.'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required String title,
    required String question,
    required int respondentsCount,
    required String averageDuration,
    required String percentageSim,
    required String mostCommonSolutions,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BlushyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Evolved Women Like You Tags
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildWomenLikeYouTag('Age 22–28'),
                  const SizedBox(width: 4),
                  _buildWomenLikeYouTag('Luteal'),
                  const SizedBox(width: 4),
                  _buildWomenLikeYouTag('Working Professional'),
                ],
              ),
              const Icon(Icons.verified_outlined, size: 14, color: BlushyColors.success),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: BlushyColors.text,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),

          // V2 AI Quick Summary & Community Intelligence Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: BlushyColors.primary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'AI Quick Summary',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: BlushyColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$respondentsCount women reported similar experiences. Copy strategies suggest hydration and tracking symptoms.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: BlushyColors.text,
                    height: 1.4,
                  ),
                ),
                const Divider(height: 20, color: BlushyColors.border),
                
                // Community intelligence data
                _buildIntelligenceRow('Similar experiences:', percentageSim),
                _buildIntelligenceRow('Average symptom duration:', averageDuration),
                _buildIntelligenceRow('Helpful solutions:', mostCommonSolutions),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ask Sia About This Trigger Button
          GestureDetector(
            onTap: () {
              setState(() {
                _companionContextTitle = title;
                _showCompanionModal = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BlushyColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_outlined, color: Color(0xFF6F42F5), size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'Ask Sia About This',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6F42F5),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, color: BlushyColors.secondaryText, size: 10),
                ],
              ),
            ),
          ),
          const Divider(color: BlushyColors.border, height: 32),

          // Trust System V2 Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTrustAction(Icons.thumb_up_alt_outlined, 'This Helped Me'),
              _buildTrustAction(Icons.bookmark_outline_rounded, 'Save', onTap: () {
                setState(() {
                  _showCollectionsModal = true;
                });
              }),
              _buildTrustAction(Icons.share_outlined, 'Share'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWomenLikeYouTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFEA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: BlushyColors.secondaryText,
        ),
      ),
    );
  }

  Widget _buildIntelligenceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: BlushyColors.secondaryText),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: BlushyColors.text),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalStoryCard({
    required String title,
    required String author,
    required List<_TimelineStop> timeline,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BlushyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STORY TIMELINE • JOURNAL',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: BlushyColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              _buildWomenLikeYouTag('Luteal Phase'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: BlushyColors.text,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Logged anonymously by a $author',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: BlushyColors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),

          // Story journal timeline representation
          Column(
            children: timeline.map((stop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: BlushyColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 1.5,
                        height: 36,
                        color: BlushyColors.border,
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.day,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: BlushyColors.primary,
                          ),
                        ),
                        Text(
                          stop.content,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: BlushyColors.text,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                _companionContextTitle = title;
                _showCompanionModal = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BlushyColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_outlined, color: Color(0xFF6F42F5), size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'Ask Sia About This Journey',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6F42F5),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, color: BlushyColors.secondaryText, size: 10),
                ],
              ),
            ),
          ),
          const Divider(color: BlushyColors.border, height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTrustAction(Icons.thumb_up_alt_outlined, 'This Helped Me'),
              _buildTrustAction(Icons.bookmark_outline_rounded, 'Save', onTap: () {
                setState(() {
                  _showCollectionsModal = true;
                });
              }),
              _buildTrustAction(Icons.translate_rounded, 'Translate'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard({
    required String title,
    required String excerpt,
    required String author,
    required String readTime,
    required String categoryTag,
    required int helpfulCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BlushyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryTag,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: BlushyColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: BlushyColors.text,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            excerpt,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: BlushyColors.secondaryText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$author • $readTime',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: BlushyColors.secondaryText,
                ),
              ),
            ],
          ),
          const Divider(color: BlushyColors.border, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTrustAction(Icons.bookmark_outline_rounded, 'Save', onTap: () {
                setState(() {
                  _showCollectionsModal = true;
                });
              }),
              _buildTrustAction(Icons.thumb_up_alt_outlined, 'This Helped'),
              _buildTrustAction(Icons.translate_rounded, 'Translate'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustAction(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Row(
        children: [
          Icon(icon, size: 14, color: BlushyColors.secondaryText),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: BlushyColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // --- Voice Modal Overlay Simulation ---
  Widget _buildVoiceModalOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        alignment: Alignment.center,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Voice Story',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: BlushyColors.text,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showVoiceModal = false;
                      });
                    },
                    child: const Icon(Icons.close_rounded, color: BlushyColors.secondaryText),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_voiceStep == 0) ...[
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(color: BlushyColors.primary),
                ),
                const SizedBox(height: 20),
                Text(
                  'Converting speech to text...',
                  style: GoogleFonts.poppins(fontSize: 12, color: BlushyColors.secondaryText),
                ),
              ] else if (_voiceStep == 1) ...[
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(color: BlushyColors.accent),
                ),
                const SizedBox(height: 16),
                Text(
                  'Removing filler words & fixing grammar...',
                  style: GoogleFonts.poppins(fontSize: 12, color: BlushyColors.secondaryText),
                ),
                const SizedBox(height: 12),
                Text(
                  _voiceProcessedText,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: BlushyColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(
                  'Sia AI Structured Post',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: BlushyColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _voiceTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: BlushyColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _voiceProcessedText,
                  style: GoogleFonts.poppins(fontSize: 13, color: BlushyColors.text),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  children: _voiceTags.map((tag) {
                    return Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 9, color: Colors.white)),
                      backgroundColor: BlushyColors.primary,
                      padding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showVoiceModal = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Anonymous experience shared successfully!')),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: BlushyColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Approve & Publish',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- Collections Modal Overlay Simulation ---
  Widget _buildCollectionsModalOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        alignment: Alignment.center,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Save to Collection',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: BlushyColors.text,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showCollectionsModal = false;
                      });
                    },
                    child: const Icon(Icons.close_rounded, color: BlushyColors.secondaryText),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: _collections.map((col) {
                  return ListTile(
                    title: Text(col, style: GoogleFonts.poppins(fontSize: 13)),
                    trailing: _selectedCollection == col
                        ? const Icon(Icons.check_rounded, color: BlushyColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCollection = col;
                        _showCollectionsModal = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saved to $col collection')),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- AI Companion Modal Overlay Simulation ---
  Widget _buildCompanionModalOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        alignment: Alignment.center,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sia AI Companion',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: BlushyColors.text,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showCompanionModal = false;
                      });
                    },
                    child: const Icon(Icons.close_rounded, color: BlushyColors.secondaryText),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'This discussion is highly relevant to you because:',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: BlushyColors.text,
                ),
              ),
              const SizedBox(height: 12),
              _buildCompanionPoint('You are also in your luteal phase today.'),
              _buildCompanionPoint('Your recent journal entry mentions feeling fatigued.'),
              _buildCompanionPoint('Your sleep data decreased by 1.2h this week.'),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showCompanionModal = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Personalized recovery brief sent to Sia Chat!')),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6F42F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Get Personalized Explanation',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanionPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF6F42F5), size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12, color: BlushyColors.text, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStop {
  final String day;
  final String content;
  _TimelineStop(this.day, this.content);
}
