class UserProfile {
  final String intent;      // side_hustle | full_business | explore | validate
  final String skillLevel;  // no_code | some_tech | developer
  final int hoursPerWeek;   // 1–40
  final String budget;      // 0_100 | 100_1000 | 1000_plus
  final String tone;        // direct | coach | motivational

  const UserProfile({
    required this.intent,
    required this.skillLevel,
    required this.hoursPerWeek,
    required this.budget,
    required this.tone,
  });

  Map<String, dynamic> toJson() => {
        'intent': intent,
        'skillLevel': skillLevel,
        'hoursPerWeek': hoursPerWeek,
        'budget': budget,
        'tone': tone,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        intent: json['intent'] ?? 'explore',
        skillLevel: json['skillLevel'] ?? 'no_code',
        hoursPerWeek: (json['hoursPerWeek'] ?? 5) as int,
        budget: json['budget'] ?? '0_100',
        tone: json['tone'] ?? 'coach',
      );
}
