class IdeaBlueprint {
  final String summary;
  final String whoItHelps;
  final String whyNow;
  final String startupCost;
  final String incomePotential;
  final List<String> toolsNeeded;
  final List<String> stepByStepPlan;
  final List<String> marketingPlan;
  final List<String> nameIdeas;
  final List<String> roadmap7Days;
  final List<String> noCodeVersion;
  final List<String> risksAndFixes;
  final List<String> mvpFeatures;
  final String cardTag;
  final String cardIcon;
  final String difficulty;
  final String cost;
  final String durationWeeks;
  final String blueprintMode;
  
Map<String, dynamic> toJson() {
  return {
    'summary': summary,
    'whoItHelps': whoItHelps,
    'whyNow': whyNow,
    'startupCost': startupCost,
    'incomePotential': incomePotential,
    'toolsNeeded': toolsNeeded,
    'stepByStepPlan': stepByStepPlan,
    'marketingPlan': marketingPlan,
    'nameIdeas': nameIdeas,
    'roadmap7Days': roadmap7Days,
    'risksAndFixes': risksAndFixes,
    'noCodeVersion': noCodeVersion,
    'mvpFeatures': mvpFeatures,
    'cardTag': cardTag,
    'cardIcon': cardIcon,
    'difficulty': difficulty,
    'cost': cost,
    'durationWeeks': durationWeeks,
    'blueprintMode': blueprintMode,
  };
}



  IdeaBlueprint({
    required this.summary,
    required this.whoItHelps,
    required this.whyNow,
    required this.startupCost,
    required this.incomePotential,
    required this.toolsNeeded,
    required this.stepByStepPlan,
    required this.marketingPlan,
    required this.nameIdeas,
    required this.roadmap7Days,
    required this.risksAndFixes,
    required this.noCodeVersion,
    required this.mvpFeatures,
    this.cardTag = '',
    this.cardIcon = '',
    this.difficulty = '',
    this.cost = '',
    this.durationWeeks = '',
    this.blueprintMode = 'full',
  });

  factory IdeaBlueprint.fromJson(Map<String, dynamic> json) {
    return IdeaBlueprint(
      summary: json['summary'] ?? '',
      whoItHelps: json['whoItHelps'] ?? '',
      whyNow: json['whyNow'] ?? '',
      startupCost: json['startupCost'] ?? '',
      incomePotential: json['incomePotential'] ?? '',

      toolsNeeded: List<String>.from(json['toolsNeeded'] ?? []),
      stepByStepPlan: List<String>.from(json['stepByStepPlan'] ?? []),
      marketingPlan: List<String>.from(json['marketingPlan'] ?? []),
      nameIdeas: List<String>.from(json['nameIdeas'] ?? []),
      roadmap7Days: List<String>.from(json['roadmap7Days'] ?? []),
      risksAndFixes: List<String>.from(json['risksAndFixes'] ?? []),
      noCodeVersion: List<String>.from(json['noCodeVersion'] ?? []),
      mvpFeatures: List<String>.from(json['mvpFeatures'] ?? []),
      cardTag: json['cardTag'] ?? '',
      cardIcon: json['cardIcon'] ?? '',
      difficulty: json['difficulty'] ?? '',
      cost: json['cost'] ?? '',
      durationWeeks: json['durationWeeks'] ?? '',
      blueprintMode: json['blueprintMode'] ?? json['mode'] ?? 'full',
    );
  }
}
