import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'storage.dart';

enum AppEntryState {
  unauthenticated,
  onboardingRequired,
  authenticated
}

enum CycleTrackingPreference { enabled, disabled, unknown }
enum CyclePattern { predictable, variable, unknown }
enum DataConfidence { high, medium, low }
enum LifeContext {
  none,
  pregnancy,
  postpartum,
  breastfeeding,
  perimenopause,
  menopause,
  hormonalContraception,
  other
}

class UserPreferences {
  final bool wantsCycleTracking;
  final bool wantsVoiceFeatures;
  final bool wantsPersonalizedRecommendations;
  final bool wantsSiaMemory;
  final bool wantsNotifications;

  UserPreferences({
    this.wantsCycleTracking = true,
    this.wantsVoiceFeatures = true,
    this.wantsPersonalizedRecommendations = true,
    this.wantsSiaMemory = true,
    this.wantsNotifications = true,
  });
}

class BehavioralSignals {
  final int siaConversationCount;
  final List<String> engagedArticles;
  final int totalLoggedSymptoms;

  BehavioralSignals({
    this.siaConversationCount = 0,
    this.engagedArticles = const [],
    this.totalLoggedSymptoms = 0,
  });
}

class Medication {
  final String name;
  final String? category;
  final String? notes;
  final DateTime? startDate;

  Medication({
    required this.name,
    this.category,
    this.notes,
    this.startDate,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'notes': notes,
    'startDate': startDate?.toIso8601String(),
  };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    name: json['name'],
    category: json['category'],
    notes: json['notes'],
    startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
  );
}

class PersonalContext {
  final String? userName;
  final DateTime? dateOfBirth;
  final CycleTrackingPreference trackingPreference;
  final CyclePattern cyclePattern;
  final DataConfidence confidence;
  final Set<LifeContext> lifeContexts;
  final Set<String> userGoals;
  final Set<String> medicalConditions;
  final UserPreferences preferences;
  final int? cycleLength;
  final int? cycleDay;
  final String? cyclePhase;
  final DateTime? lastPeriodStart;
  final List<Medication> medications;

  PersonalContext({
    this.userName,
    this.dateOfBirth,
    required this.trackingPreference,
    required this.cyclePattern,
    required this.confidence,
    required this.lifeContexts,
    required this.userGoals,
    this.medicalConditions = const {},
    required this.preferences,
    this.cycleLength,
    this.cycleDay,
    this.cyclePhase,
    this.lastPeriodStart,
    this.medications = const [],
  });
}



class CurrentWellbeingState {
  final int? energy;          // 1 - 10
  final int? mood;            // 1 - 10
  final int? sleepQuality;    // 1 - 10
  final List<String> symptoms;
  final DateTime? lastCheckIn;
  final DateTime? lastSiaConversation;
  final bool periodActive;

  CurrentWellbeingState({
    this.energy,
    this.mood,
    this.sleepQuality,
    this.symptoms = const [],
    this.lastCheckIn,
    this.lastSiaConversation,
    this.periodActive = false,
  });
}

class SiaInsight {
  final String id;
  final String title;
  final String description;
  final String type; // 'observation' | 'recommendation' | 'reminder'
  final double confidence;

  SiaInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.confidence = 1.0,
  });
}

enum CycleCardMode { predictable, variable, learning, wellbeing, lifeContext }

class ContextResolver {
  static CycleCardMode resolve(PersonalContext context, CurrentWellbeingState wellbeing) {
    if (!context.preferences.wantsCycleTracking || context.trackingPreference == CycleTrackingPreference.disabled) {
      return CycleCardMode.wellbeing;
    }
    if (context.lifeContexts.isNotEmpty && !context.lifeContexts.contains(LifeContext.none)) {
      return CycleCardMode.lifeContext;
    }
    if (context.confidence == DataConfidence.low) {
      return CycleCardMode.learning;
    }
    if (context.cyclePattern == CyclePattern.variable) {
      return CycleCardMode.variable;
    }
    return CycleCardMode.predictable;
  }
}

class CandidateAction {
  final String id;
  final String label;
  final IconData icon;
  int priority;
  final String destination;

  CandidateAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.priority,
    required this.destination,
  });
}

class AdaptiveActionRanker {
  static List<CandidateAction> rankActions(PersonalContext context, CurrentWellbeingState wellbeing) {
    List<CandidateAction> actions = [
      CandidateAction(id: 'a1', label: 'Log Symptoms', icon: Icons.health_and_safety, priority: 5, destination: 'log'),
      CandidateAction(id: 'a2', label: 'Breathing Exercise', icon: Icons.air, priority: 4, destination: 'breathe'),
      CandidateAction(id: 'a3', label: 'Sia Chat', icon: Icons.chat_bubble_outline, priority: 3, destination: 'chat'),
      CandidateAction(id: 'a4', label: 'Hydration', icon: Icons.water_drop_outlined, priority: 2, destination: 'water'),
      CandidateAction(id: 'a5', label: 'Cycle Insights', icon: Icons.auto_graph, priority: 1, destination: 'insights'),
    ];

    if (wellbeing.symptoms.isNotEmpty) {
       actions.firstWhere((a) => a.id == 'a1').priority += 5;
    }
    if (context.cyclePhase == 'Luteal Phase' || wellbeing.energy != null && wellbeing.energy! < 5) {
       actions.firstWhere((a) => a.id == 'a2').priority += 5;
    }
    if (wellbeing.periodActive) {
       actions.firstWhere((a) => a.id == 'a1').priority += 10;
       actions.firstWhere((a) => a.id == 'a4').priority += 5;
    }

    actions.sort((a, b) => b.priority.compareTo(a.priority));
    return actions.take(4).toList();
  }
}

class SiaMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? actionSuggestions;

  SiaMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionSuggestions,
  });
}

class JournalEntry {
  final String content;
  final String mood;
  final DateTime timestamp;

  JournalEntry({
    required this.content,
    required this.mood,
    required this.timestamp,
  });
}

class BlushyOSState extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _onboardingCompleted = false;
  int _onboardingStep = 0;
  bool _argumentModeActive = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get onboardingCompleted => _onboardingCompleted;
  int get onboardingStep => _onboardingStep;
  bool get argumentModeActive => _argumentModeActive;

  void setArgumentModeActive(bool val) {
    _argumentModeActive = val;
    _saveState();
    notifyListeners();
  }

  AppEntryState get entryState {
    if (!_isAuthenticated) return AppEntryState.unauthenticated;
    if (!_onboardingCompleted) return AppEntryState.onboardingRequired;
    return AppEntryState.authenticated;
  }

  BlushyOSState() {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final file = File('blushy_prefs.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        _isAuthenticated = data['isAuthenticated'] ?? false;
        _onboardingCompleted = data['onboardingCompleted'] ?? false;
        _onboardingStep = data['onboardingStep'] ?? 0;
        _argumentModeActive = data['argumentModeActive'] ?? false;
        _customAiBriefing = data['customAiBriefing'];

        if (data['personalContext'] != null) {
          final pc = data['personalContext'];
          final List<dynamic> rawMedications = pc['medications'] ?? [];
          final meds = rawMedications.map((m) => Medication.fromJson(m)).toList();
          
          _personalContext = PersonalContext(
            userName: pc['userName'],
            dateOfBirth: pc['dateOfBirth'] != null ? DateTime.parse(pc['dateOfBirth']) : null,
            trackingPreference: CycleTrackingPreference.values.firstWhere(
              (e) => e.toString() == pc['trackingPreference'],
              orElse: () => CycleTrackingPreference.unknown,
            ),
            cyclePattern: CyclePattern.values.firstWhere(
              (e) => e.toString() == pc['cyclePattern'],
              orElse: () => CyclePattern.unknown,
            ),
            confidence: DataConfidence.values.firstWhere(
              (e) => e.toString() == pc['confidence'],
              orElse: () => DataConfidence.low,
            ),
            lifeContexts: (pc['lifeContexts'] as List<dynamic>?)
                    ?.map((l) => LifeContext.values.firstWhere((e) => e.toString() == l))
                    .toSet() ?? {LifeContext.none},
            userGoals: (pc['userGoals'] as List<dynamic>?)?.map((g) => g.toString()).toSet() ?? {},
            medicalConditions: (pc['medicalConditions'] as List<dynamic>?)?.map((c) => c.toString()).toSet() ?? {},
            preferences: UserPreferences(
              wantsCycleTracking: pc['preferences']?['wantsCycleTracking'] ?? true,
              wantsVoiceFeatures: pc['preferences']?['wantsVoiceFeatures'] ?? true,
              wantsPersonalizedRecommendations: pc['preferences']?['wantsPersonalizedRecommendations'] ?? true,
              wantsSiaMemory: pc['preferences']?['wantsSiaMemory'] ?? true,
              wantsNotifications: pc['preferences']?['wantsNotifications'] ?? true,
            ),
            cycleLength: pc['cycleLength'],
            cycleDay: pc['cycleDay'],
            cyclePhase: pc['cyclePhase'],
            lastPeriodStart: pc['lastPeriodStart'] != null ? DateTime.parse(pc['lastPeriodStart']) : null,
            medications: meds,
          );
        }

        if (data['wellbeingState'] != null) {
          final wb = data['wellbeingState'];
          _wellbeingState = CurrentWellbeingState(
            energy: wb['energy'],
            mood: wb['mood'],
            sleepQuality: wb['sleepQuality'],
            symptoms: (wb['symptoms'] as List<dynamic>?)?.map((s) => s.toString()).toList() ?? const [],
            lastCheckIn: wb['lastCheckIn'] != null ? DateTime.parse(wb['lastCheckIn']) : null,
            lastSiaConversation: wb['lastSiaConversation'] != null ? DateTime.parse(wb['lastSiaConversation']) : null,
            periodActive: wb['periodActive'] ?? false,
          );
        }

        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveState() async {
    try {
      final file = File('blushy_prefs.json');
      final data = {
        'isAuthenticated': _isAuthenticated,
        'onboardingCompleted': _onboardingCompleted,
        'onboardingStep': _onboardingStep,
        'argumentModeActive': _argumentModeActive,
        'customAiBriefing': _customAiBriefing,
        'personalContext': {
          'userName': _personalContext.userName,
          'dateOfBirth': _personalContext.dateOfBirth?.toIso8601String(),
          'trackingPreference': _personalContext.trackingPreference.toString(),
          'cyclePattern': _personalContext.cyclePattern.toString(),
          'confidence': _personalContext.confidence.toString(),
          'lifeContexts': _personalContext.lifeContexts.map((l) => l.toString()).toList(),
          'userGoals': _personalContext.userGoals.toList(),
          'medicalConditions': _personalContext.medicalConditions.toList(),
          'cycleLength': _personalContext.cycleLength,
          'cycleDay': _personalContext.cycleDay,
          'cyclePhase': _personalContext.cyclePhase,
          'lastPeriodStart': _personalContext.lastPeriodStart?.toIso8601String(),
          'medications': _personalContext.medications.map((m) => m.toJson()).toList(),
          'preferences': {
            'wantsCycleTracking': _personalContext.preferences.wantsCycleTracking,
            'wantsVoiceFeatures': _personalContext.preferences.wantsVoiceFeatures,
            'wantsPersonalizedRecommendations': _personalContext.preferences.wantsPersonalizedRecommendations,
            'wantsSiaMemory': _personalContext.preferences.wantsSiaMemory,
            'wantsNotifications': _personalContext.preferences.wantsNotifications,
          }
        },
        'wellbeingState': {
          'energy': _wellbeingState.energy,
          'mood': _wellbeingState.mood,
          'sleepQuality': _wellbeingState.sleepQuality,
          'symptoms': _wellbeingState.symptoms,
          'lastCheckIn': _wellbeingState.lastCheckIn?.toIso8601String(),
          'lastSiaConversation': _wellbeingState.lastSiaConversation?.toIso8601String(),
          'periodActive': _wellbeingState.periodActive,
        }
      };
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }


  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    _saveState();
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _onboardingCompleted = false;
    _onboardingStep = 0;
    _personalContext = PersonalContext(
      userName: null,
      dateOfBirth: null,
      trackingPreference: CycleTrackingPreference.unknown,
      cyclePattern: CyclePattern.unknown,
      confidence: DataConfidence.low,
      lifeContexts: {LifeContext.none},
      userGoals: {},
      medicalConditions: {},
      preferences: UserPreferences(),
      cycleLength: null,
      cycleDay: null,
      cyclePhase: null,
      lastPeriodStart: null,
      medications: [],
    );
    _wellbeingState = CurrentWellbeingState(
      energy: null,
      mood: null,
      sleepQuality: null,
      symptoms: const [],
      lastCheckIn: null,
      periodActive: false,
    );
    _saveState();
    notifyListeners();
  }

  void setOnboardingCompleted(bool value) {
    _onboardingCompleted = value;
    _saveState();
    notifyListeners();
  }

  void setOnboardingStep(int step) {
    _onboardingStep = step;
    _saveState();
    notifyListeners();
  }

  // --- Orthogonal Models ---
  PersonalContext _personalContext = PersonalContext(
    userName: null,
    dateOfBirth: null,
    trackingPreference: CycleTrackingPreference.unknown,
    cyclePattern: CyclePattern.unknown,
    confidence: DataConfidence.low,
    lifeContexts: {LifeContext.none},
    userGoals: {},
    medicalConditions: {},
    preferences: UserPreferences(),
    cycleLength: null,
    cycleDay: null,
    cyclePhase: null,
    lastPeriodStart: null,
    medications: [],
  );


  CurrentWellbeingState _wellbeingState = CurrentWellbeingState(
    energy: null,
    mood: null,
    sleepQuality: null,
    symptoms: const [],
    lastCheckIn: null,
    periodActive: false,
  );

  BehavioralSignals _behavioralSignals = BehavioralSignals(
    siaConversationCount: 0,
    engagedArticles: const [],
    totalLoggedSymptoms: 0,
  );

  PersonalContext get personalContext => _personalContext;
  CurrentWellbeingState get wellbeingState => _wellbeingState;
  BehavioralSignals get behavioralSignals => _behavioralSignals;

  void updatePersonalContext(PersonalContext newContext) {
    _personalContext = newContext;
    _saveState();
    notifyListeners();
  }

  void updateWellbeingState(CurrentWellbeingState newState) {
    _wellbeingState = newState;
    _saveState();
    notifyListeners();
  }

  void updateBehavioralSignals(BehavioralSignals newSignals) {
    _behavioralSignals = newSignals;
    notifyListeners();
  }

  String? _customAiBriefing;

  // AI Briefing Dynamic Update
  String get dynamicAiBriefingSummary {
    if (_customAiBriefing != null) return _customAiBriefing!;
    final name = _personalContext.userName ?? "there";
    if (_wellbeingState.periodActive) {
      return "$name, your period is active. Focus on rest and hydration today.";
    }
    if (_personalContext.lifeContexts.contains(LifeContext.pregnancy)) {
      return "Hello $name, taking care of your changing body is key right now. Sia is adapting to your pregnancy context.";
    }
    if (_personalContext.cyclePhase == 'Luteal Phase' && _wellbeingState.symptoms.contains('fatigue')) {
      return "$name, Sia noticed your logged fatigue matches Luteal Phase changes. Prioritizing rest and setting boundaries could help today.";
    }
    if (_wellbeingState.symptoms.isNotEmpty) {
      final symptom = _wellbeingState.symptoms.join(', ');
      return "Sia noticed you logged $symptom. Focus on gentle movement and recovery today.";
    }
    return "Hello $name, Sia is here and ready to support you. Let's look at what matters to you today.";
  }

  void updateDynamicAiBriefing(String briefing) {
    _customAiBriefing = briefing;
    _saveState();
    notifyListeners();
  }

  
  // Developer context simulation methods
  void setTrackingPreference(CycleTrackingPreference pref) {
    _personalContext = PersonalContext(
      userName: _personalContext.userName,
      trackingPreference: pref,
      cyclePattern: _personalContext.cyclePattern,
      confidence: _personalContext.confidence,
      lifeContexts: _personalContext.lifeContexts,
      userGoals: _personalContext.userGoals,
      preferences: _personalContext.preferences,
      cycleLength: _personalContext.cycleLength,
      cycleDay: _personalContext.cycleDay,
      cyclePhase: _personalContext.cyclePhase,
      lastPeriodStart: _personalContext.lastPeriodStart,
      medications: _personalContext.medications,
    );
    _saveState();
    notifyListeners();
  }

  void setCyclePattern(CyclePattern pattern) {
    _personalContext = PersonalContext(
      userName: _personalContext.userName,
      trackingPreference: _personalContext.trackingPreference,
      cyclePattern: pattern,
      confidence: _personalContext.confidence,
      lifeContexts: _personalContext.lifeContexts,
      userGoals: _personalContext.userGoals,
      preferences: _personalContext.preferences,
      cycleLength: _personalContext.cycleLength,
      cycleDay: _personalContext.cycleDay,
      cyclePhase: _personalContext.cyclePhase,
      lastPeriodStart: _personalContext.lastPeriodStart,
      medications: _personalContext.medications,
    );
    _saveState();
    notifyListeners();
  }

  void setDataConfidence(DataConfidence conf) {
    _personalContext = PersonalContext(
      userName: _personalContext.userName,
      trackingPreference: _personalContext.trackingPreference,
      cyclePattern: _personalContext.cyclePattern,
      confidence: conf,
      lifeContexts: _personalContext.lifeContexts,
      userGoals: _personalContext.userGoals,
      preferences: _personalContext.preferences,
      cycleLength: _personalContext.cycleLength,
      cycleDay: _personalContext.cycleDay,
      cyclePhase: _personalContext.cyclePhase,
      lastPeriodStart: _personalContext.lastPeriodStart,
      medications: _personalContext.medications,
    );
    _saveState();
    notifyListeners();
  }

  void toggleLifeContext(LifeContext lc) {
    final newContexts = Set<LifeContext>.from(_personalContext.lifeContexts);
    if (newContexts.contains(lc)) {
      newContexts.remove(lc);
    } else {
      newContexts.add(lc);
      if (lc != LifeContext.none) newContexts.remove(LifeContext.none);
      if (lc == LifeContext.none) {
        newContexts.clear(); 
        newContexts.add(LifeContext.none);
      }
    }
    if (newContexts.isEmpty) newContexts.add(LifeContext.none);
    
    _personalContext = PersonalContext(
      userName: _personalContext.userName,
      trackingPreference: _personalContext.trackingPreference,
      cyclePattern: _personalContext.cyclePattern,
      confidence: _personalContext.confidence,
      lifeContexts: newContexts,
      userGoals: _personalContext.userGoals,
      preferences: _personalContext.preferences,
      cycleLength: _personalContext.cycleLength,
      cycleDay: _personalContext.cycleDay,
      cyclePhase: _personalContext.cyclePhase,
      lastPeriodStart: _personalContext.lastPeriodStart,
      medications: _personalContext.medications,
    );
    _saveState();
    notifyListeners();
  }

  void toggleSymptom(String symptom) {
    final newSymptoms = List<String>.from(_wellbeingState.symptoms);
    if (newSymptoms.contains(symptom)) {
      newSymptoms.remove(symptom);
    } else {
      newSymptoms.add(symptom);
    }
    _wellbeingState = CurrentWellbeingState(
      energy: _wellbeingState.energy,
      mood: _wellbeingState.mood,
      sleepQuality: _wellbeingState.sleepQuality,
      symptoms: newSymptoms,
      lastCheckIn: _wellbeingState.lastCheckIn,
      lastSiaConversation: _wellbeingState.lastSiaConversation,
      periodActive: _wellbeingState.periodActive,
    );
    _saveState();
    notifyListeners();
  }

  void setPeriodActive(bool active) {
    _wellbeingState = CurrentWellbeingState(
      energy: _wellbeingState.energy,
      mood: _wellbeingState.mood,
      sleepQuality: _wellbeingState.sleepQuality,
      symptoms: _wellbeingState.symptoms,
      lastCheckIn: _wellbeingState.lastCheckIn,
      lastSiaConversation: _wellbeingState.lastSiaConversation,
      periodActive: active,
    );
    _saveState();
    notifyListeners();
  }

  // Legacy variables for backward compatibility if needed in UI
  String get cyclePhase => _personalContext.cyclePhase ?? 'Unknown';
  int get cycleDay => _personalContext.cycleDay ?? 0;
  
  // Active navigation view state
  int currentViewIndex = 0; // 0: Today, 1: Journey, 2: Explore, 3: Sia

  void setViewIndex(int index) {
    currentViewIndex = index;
    notifyListeners();
  }
}


class BlushyOSProvider extends InheritedNotifier<BlushyOSState> {
  const BlushyOSProvider({
    super.key,
    required BlushyOSState super.notifier,
    required super.child,
  });

  static BlushyOSState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<BlushyOSProvider>();
    assert(provider != null, "No BlushyOSProvider found in context");
    return provider!.notifier!;
  }
}
