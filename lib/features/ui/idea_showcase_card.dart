import 'dart:ui';

import 'package:flutter/material.dart';

import 'ideafii_ui.dart';
import 'idea_card_utils.dart';

class IdeaShowcaseCard extends StatefulWidget {
  final String title;
  final String description;
  final String chipLabel;
  final Color chipColor;
  final String? emoji;
  final IconData icon;
  final VoidCallback? onTap;
  final List<IdeaMetaItem> meta;

  const IdeaShowcaseCard({
    super.key,
    required this.title,
    required this.description,
    required this.chipLabel,
    this.chipColor = const Color(0xFF6B7280),
    this.emoji,
    this.icon = Icons.lightbulb_outline_rounded,
    this.onTap,
    this.meta = const [
      IdeaMetaItem(Icons.trending_up_rounded, 'Easy', Colors.tealAccent),
      IdeaMetaItem(Icons.attach_money_rounded, r'$$', Colors.tealAccent),
      IdeaMetaItem(Icons.schedule_rounded, '2-3 days', Colors.white54),
    ],
  });

  @override
  State<IdeaShowcaseCard> createState() => _IdeaShowcaseCardState();
}

class _IdeaShowcaseCardState extends State<IdeaShowcaseCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: InkWell(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _hovered
                      ? IdeafiiColors.accentA.withOpacity(0.55)
                      : IdeafiiColors.stroke,
                ),
                color: IdeafiiColors.glass,
                boxShadow: const [],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _hovered
                      ? [
                          IdeafiiColors.accentA.withOpacity(0.26),
                          Colors.transparent,
                          IdeafiiColors.accentB.withOpacity(0.16),
                        ]
                      : [
                          IdeafiiColors.accentA.withOpacity(0.08),
                          IdeafiiColors.accentB.withOpacity(0.06),
                          Colors.white.withOpacity(0.02),
                        ],
                  stops: _hovered ? const [0.0, 0.55, 1.0] : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0x1A0B1020),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: widget.emoji == null || widget.emoji!.isEmpty
                              ? Icon(
                                  widget.icon,
                                  color: IdeafiiColors.text,
                                  size: 22,
                                )
                              : Text(
                                  widget.emoji!,
                                  style: const TextStyle(fontSize: 22),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: IdeafiiColors.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.favorite_border_rounded,
                          color: IdeafiiColors.subtext, size: 20),
                      const SizedBox(width: 8),
                      const Icon(Icons.bookmark_border_rounded,
                          color: IdeafiiColors.subtext, size: 20),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Chip(label: widget.chipLabel, color: widget.chipColor),
                  const SizedBox(height: 10),
                  Text(
                    widget.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: IdeafiiColors.subtext,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: widget.meta
                        .map(
                          (m) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(m.icon, color: m.color, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                m.label,
                                style: TextStyle(
                                  color: m.color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: IdeafiiColors.text,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
