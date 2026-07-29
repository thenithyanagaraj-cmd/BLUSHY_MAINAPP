import 'package:flutter/material.dart';

class CycleInsight {
  final String title;
  final String observation;
  final String evidence;
  final String confidenceLevel; // e.g. "High", "Medium", "Low"
  final String timestamp;

  CycleInsight({
    required this.title,
    required this.observation,
    required this.evidence,
    required this.confidenceLevel,
    required this.timestamp,
  });

  factory CycleInsight.fromJson(Map<String, dynamic> json) {
    return CycleInsight(
      title: json['title'] ?? '',
      observation: json['observation'] ?? '',
      evidence: json['evidence'] ?? '',
      confidenceLevel: json['confidenceLevel'] ?? 'Medium',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class TimelineSummary {
  final String month;
  final String cycleLength;
  final String keyChange;
  final String aiSummary;

  TimelineSummary({
    required this.month,
    required this.cycleLength,
    required this.keyChange,
    required this.aiSummary,
  });

  factory TimelineSummary.fromJson(Map<String, dynamic> json) {
    return TimelineSummary(
      month: json['month'] ?? '',
      cycleLength: json['cycleLength'] ?? '',
      keyChange: json['keyChange'] ?? '',
      aiSummary: json['aiSummary'] ?? '',
    );
  }
}

class Recommendation {
  final String title;
  final String description;
  final String reason;
  final String priority; // e.g. "High", "Medium", "Low"
  final String category; // e.g. "energy", "nutrition", "sleep", "mind"
  final String actionLabel;

  Recommendation({
    required this.title,
    required this.description,
    required this.reason,
    required this.priority,
    required this.category,
    required this.actionLabel,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      reason: json['reason'] ?? '',
      priority: json['priority'] ?? 'Medium',
      category: json['category'] ?? 'general',
      actionLabel: json['actionLabel'] ?? 'Start',
    );
  }
}

class ReflectionPrompt {
  final String title;
  final String question;
  final String placeholder;
  final List<String> chips;
  final String replyText;

  ReflectionPrompt({
    required this.title,
    required this.question,
    required this.placeholder,
    required this.chips,
    required this.replyText,
  });

  factory ReflectionPrompt.fromJson(Map<String, dynamic> json) {
    return ReflectionPrompt(
      title: json['title'] ?? '',
      question: json['question'] ?? '',
      placeholder: json['placeholder'] ?? '',
      chips: List<String>.from(json['chips'] ?? []),
      replyText: json['replyText'] ?? 'Thanks for sharing that with me. I\'ve noted it down in your diary. Have a beautiful rest of your day!',
    );
  }
}

class PeriodConfirmationState {
  final bool hasLoggedPeriod;
  final DateTime predictedStartDate;
  final DateTime? actualStartDate;
  final bool isDismissed;
  final String status; // "pending", "confirmed", "dismissed"

  PeriodConfirmationState({
    required this.hasLoggedPeriod,
    required this.predictedStartDate,
    this.actualStartDate,
    required this.isDismissed,
    required this.status,
  });

  factory PeriodConfirmationState.fromJson(Map<String, dynamic> json) {
    return PeriodConfirmationState(
      hasLoggedPeriod: json['hasLoggedPeriod'] ?? false,
      predictedStartDate: json['predictedStartDate'] != null 
          ? DateTime.parse(json['predictedStartDate']) 
          : DateTime.now().add(const Duration(days: 9)),
      actualStartDate: json['actualStartDate'] != null 
          ? DateTime.parse(json['actualStartDate']) 
          : null,
      isDismissed: json['isDismissed'] ?? false,
      status: json['status'] ?? 'pending',
    );
  }

  PeriodConfirmationState copyWith({
    bool? hasLoggedPeriod,
    DateTime? predictedStartDate,
    DateTime? actualStartDate,
    bool? isDismissed,
    String? status,
  }) {
    return PeriodConfirmationState(
      hasLoggedPeriod: hasLoggedPeriod ?? this.hasLoggedPeriod,
      predictedStartDate: predictedStartDate ?? this.predictedStartDate,
      actualStartDate: actualStartDate ?? this.actualStartDate,
      isDismissed: isDismissed ?? this.isDismissed,
      status: status ?? this.status,
    );
  }
}

class ConditionInsight {
  final String title;
  final String description;
  final String observationType;
  final String explanation;
  final String contextLabel;

  ConditionInsight({
    required this.title,
    required this.description,
    required this.observationType,
    required this.explanation,
    required this.contextLabel,
  });
}

class AppointmentSummary {
  final String title;
  final String summary;
  final List<String> recentChanges;
  final List<String> discussionPoints;
  final String notes;
  final DateTime generatedAt;

  AppointmentSummary({
    required this.title,
    required this.summary,
    required this.recentChanges,
    required this.discussionPoints,
    required this.notes,
    required this.generatedAt,
  });
}

class CareRecommendation {
  final IconData icon;
  final String title;
  final String description;
  final String reason;
  final String priority; // High, Medium, Low
  final String category; // energy, nutrition, sleep, mind, medical

  CareRecommendation({
    required this.icon,
    required this.title,
    required this.description,
    required this.reason,
    required this.priority,
    required this.category,
  });
}

class CommunityPost {
  final String user;
  final String content;
  final String category; // PCOS, Endometriosis, PMDD, Hormonal Health
  final bool medicalReview;
  final bool misinformationWarning;
  final bool professionalGuidance;

  CommunityPost({
    required this.user,
    required this.content,
    required this.category,
    this.medicalReview = false,
    this.misinformationWarning = false,
    this.professionalGuidance = false,
  });
}

class TtcMonthlyReflection {
  final String state; // pregnancyConfirmed, cycleCompleted, incompleteCycle
  final String title;
  final String description;
  final List<String> milestones;
  final String helperNote;

  TtcMonthlyReflection({
    required this.state,
    required this.title,
    required this.description,
    required this.milestones,
    required this.helperNote,
  });
}

class PartnerPermission {
  bool shareFertileWindow;
  bool shareCycleDates;
  bool shareAppointmentReminders;
  bool shareCarePlanProgress;
  bool shareMood;
  bool shareSymptoms;
  bool shareJournal;
  bool shareConversations;

  PartnerPermission({
    this.shareFertileWindow = false,
    this.shareCycleDates = false,
    this.shareAppointmentReminders = false,
    this.shareCarePlanProgress = false,
    this.shareMood = false,
    this.shareSymptoms = false,
    this.shareJournal = false,
    this.shareConversations = false,
  });
}

class TtcEmotionalCheckIn {
  final String emotion; // Hopeful, Calm, Anxious, Frustrated, Overwhelmed, Prefer not to say
  final String note;

  TtcEmotionalCheckIn({
    required this.emotion,
    required this.note,
  });
}

class TtcDailyRecommendation {
  final IconData icon;
  final String title;
  final String description;
  final String reason;
  final String priority;
  final String category;

  TtcDailyRecommendation({
    required this.icon,
    required this.title,
    required this.description,
    required this.reason,
    required this.priority,
    required this.category,
  });
}

class TtcSettings {
  bool enableLhTracking;
  bool enableBbt;
  bool enableCervicalMucus;

  TtcSettings({
    this.enableLhTracking = true,
    this.enableBbt = true,
    this.enableCervicalMucus = true,
  });
}

class RedFlagSymptom {
  final String id;
  final String name;
  final String category; // bleeding, pain, movement, headache, swelling, leakage, contractions

  RedFlagSymptom({
    required this.id,
    required this.name,
    required this.category,
  });
}

class SafetyRules {
  final List<String> redFlagSymptomIds;
  final List<String> emergencyInstructions;
  final String actionPlan;
  final String emergencyContact;

  SafetyRules({
    required this.redFlagSymptomIds,
    required this.emergencyInstructions,
    required this.actionPlan,
    required this.emergencyContact,
  });
}

class MedicalReference {
  final String category; // babyGrowth, weeklyMilestone, clinicalChecklist, prepGuidance, vaccinationReminder, trimesterEducation
  final String title;
  final String content;
  final String source;
  final int? week;

  MedicalReference({
    required this.category,
    required this.title,
    required this.content,
    required this.source,
    this.week,
  });
}

class PregnancyTransition {
  final bool isActive;
  final String? exitReason; // loss, birth, etc.
  final String? destination; // recovery, TTC, hormonalHealth, generalWellness

  PregnancyTransition({
    required this.isActive,
    this.exitReason,
    this.destination,
  });
}
