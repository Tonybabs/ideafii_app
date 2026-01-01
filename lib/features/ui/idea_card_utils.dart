import 'package:flutter/material.dart';

import '../ideas/idea_blueprint.dart';

class IdeaCardInfo {
  final String chipLabel;
  final Color chipColor;
  final String emoji;
  final List<IdeaMetaItem> meta;

  const IdeaCardInfo({
    required this.chipLabel,
    required this.chipColor,
    required this.emoji,
    required this.meta,
  });
}

class IdeaMetaItem {
  final IconData icon;
  final String label;
  final Color color;

  const IdeaMetaItem(this.icon, this.label, this.color);
}

IdeaCardInfo deriveIdeaCardInfo({
  required String ideaText,
  IdeaBlueprint? blueprint,
}) {
  final text = ideaText.toLowerCase();

  final chipLabel = (blueprint?.cardTag ?? '').trim().isNotEmpty
      ? blueprint!.cardTag
      : _deriveChipLabel(text);
  final chipColor = _chipColorForLabel(chipLabel);

  final emoji = (blueprint?.cardIcon ?? '').trim().isNotEmpty
      ? blueprint!.cardIcon
      : _deriveEmoji(text);

  final difficulty = (blueprint?.difficulty ?? '').trim().isNotEmpty
      ? blueprint!.difficulty
      : _deriveDifficulty(text);
  final cost = (blueprint?.cost ?? '').trim().isNotEmpty
      ? blueprint!.cost
      : _deriveCost(text);
  final duration = (blueprint?.durationWeeks ?? '').trim().isNotEmpty
      ? blueprint!.durationWeeks
      : _deriveDuration(text);

  final meta = [
    IdeaMetaItem(
      Icons.trending_up_rounded,
      difficulty,
      _difficultyColor(difficulty),
    ),
    IdeaMetaItem(
      Icons.attach_money_rounded,
      cost,
      _costColor(cost),
    ),
    IdeaMetaItem(
      Icons.schedule_rounded,
      duration,
      const Color(0xB3FFFFFF),
    ),
  ];

  return IdeaCardInfo(
    chipLabel: chipLabel,
    chipColor: chipColor,
    emoji: emoji,
    meta: meta,
  );
}

String _deriveChipLabel(String text) {
  if (text.contains('ai') || text.contains('automation')) return 'AI Tools';
  if (text.contains('local')) return 'Local';
  if (text.contains('digital') || text.contains('newsletter')) return 'Digital';
  if (text.contains('low cost') || text.contains('no-code')) return 'Low Cost';
  return 'Startup';
}

Color _chipColorForLabel(String label) {
  switch (label.toLowerCase()) {
    case 'ai tools':
      return const Color(0xFF4AA3FF);
    case 'local':
      return const Color(0xFFFF9F45);
    case 'digital':
      return const Color(0xFFB076FF);
    case 'low cost':
      return const Color(0xFF4CD964);
    default:
      return const Color(0xFF6B7280);
  }
}

String _deriveEmoji(String text) {
  if (text.contains('art')) return '🎨';
  if (text.contains('social')) return '📱';
  if (text.contains('newsletter')) return '📰';
  if (text.contains('print') || text.contains('shop')) return '🛒';
  if (text.contains('meal') || text.contains('food')) return '🍽️';
  if (text.contains('fitness')) return '💪';
  if (text.contains('travel')) return '✈️';
  if (text.contains('finance') || text.contains('money')) return '💸';
  if (text.contains('education') || text.contains('course')) return '🎓';
  if (text.contains('saas') || text.contains('software')) return '🧩';
  return '💡';
}

String _deriveDifficulty(String text) {
  if (text.contains('no-code') || text.contains('template')) return 'Beginner';
  if (text.contains('marketplace') || text.contains('saas') || text.contains('platform')) {
    return 'Advanced';
  }
  return 'Intermediate';
}

String _deriveCost(String text) {
  if (text.contains('low cost') || text.contains('no-code')) return r'$';
  if (text.contains('ads') || text.contains('subscription')) return r'$$';
  if (text.contains('hardware') || text.contains('inventory')) return r'$$$';
  return r'$$';
}

String _deriveDuration(String text) {
  if (text.contains('7 days') || text.contains('one week') || text.contains('1 week')) {
    return '1 week';
  }
  if (text.contains('month')) return '4-6 weeks';
  if (text.contains('2-3')) return '2-3 weeks';
  return '2-3 weeks';
}

Color _difficultyColor(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case 'beginner':
      return const Color(0xFF4CD964);
    case 'advanced':
      return const Color(0xFFFF6B6B);
    default:
      return const Color(0xFFFFC857);
  }
}

Color _costColor(String cost) {
  switch (cost) {
    case r'$':
      return const Color(0xFF4CD964);
    case r'$$$':
    case r'$$$$':
      return const Color(0xFFFF8B5C);
    default:
      return const Color(0xFF4CD964);
  }
}
