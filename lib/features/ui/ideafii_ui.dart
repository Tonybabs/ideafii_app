import 'dart:ui';

import 'package:flutter/material.dart';

class IdeafiiColors {
  static const bg = Color(0xFF070B14);

  // [NOTE: Glass] Dark tint (avoids grey slabs)
  static const glass = Color(0x160B1020);
  static const stroke = Color(0x22FFFFFF);

  static const text = Color(0xFFEAF0FF);
  static const subtext = Color(0xB3EAF0FF);

  static const accentA = Color(0xFF58F3C2);
  static const accentB = Color(0xFF8A5CFF);
}

class HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const HeroCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: IdeafiiColors.stroke),
            color: IdeafiiColors.glass,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IdeafiiColors.accentA.withOpacity(0.12),
                IdeafiiColors.accentB.withOpacity(0.10),
                Colors.white.withOpacity(0.02),
              ],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0x221FFFFFF),
                child: Icon(Icons.auto_awesome_rounded,
                    color: IdeafiiColors.text),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: IdeafiiColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: IdeafiiColors.subtext,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatefulWidget {
  final Widget child;
  final bool hoverEffect;

  const GlassCard({
    super.key,
    required this.child,
    this.hoverEffect = true,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: IdeafiiColors.stroke),
        color: IdeafiiColors.glass,
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
                  IdeafiiColors.accentA.withOpacity(0.06),
                  IdeafiiColors.accentB.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
          stops: _hovered ? const [0.0, 0.55, 1.0] : null,
        ),
        boxShadow: const [],
      ),
      child: widget.child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: widget.hoverEffect
            ? MouseRegion(
                onEnter: (_) => setState(() => _hovered = true),
                onExit: (_) => setState(() => _hovered = false),
                child: content,
              )
            : content,
      ),
    );
  }
}

class GradientHeading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const GradientHeading({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: IdeafiiColors.text,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 64,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [IdeafiiColors.accentA, IdeafiiColors.accentB],
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: const TextStyle(
              color: IdeafiiColors.subtext,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.onTap == null ? 0.7 : 1,
      child: Material(
        color: Colors.transparent,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [IdeafiiColors.accentA, IdeafiiColors.accentB],
                ),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: IdeafiiColors.accentA.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: IdeafiiColors.accentB.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                  if (widget.isLoading) const SizedBox(width: 10),
                  Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.black),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final IconData? icon;
  final bool compact;

  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: onTap == null ? 0.6 : 1,
      duration: const Duration(milliseconds: 160),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.transparent : IdeafiiColors.stroke,
          ),
          gradient: selected
              ? const LinearGradient(
                  colors: [IdeafiiColors.accentA, IdeafiiColors.accentB],
                )
              : null,
          color: selected ? null : const Color(0x140B1020),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: IdeafiiColors.accentA.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 14 : 18,
                vertical: compact ? 10 : 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: selected ? Colors.black : IdeafiiColors.text,
                      size: compact ? 18 : 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            selected ? Colors.black : IdeafiiColors.subtext,
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 13.5 : 14.5,
                      ),
                    ),
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

class RecentIdeaTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const RecentIdeaTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.7 : 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: IdeafiiColors.stroke),
                color: IdeafiiColors.glass,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    IdeafiiColors.accentA.withOpacity(0.05),
                    IdeafiiColors.accentB.withOpacity(0.04),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0x221FFFFFF),
                    child: Icon(Icons.history_rounded,
                        color: IdeafiiColors.text),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: IdeafiiColors.text,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: IdeafiiColors.subtext,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.chevron_right_rounded,
                      color: IdeafiiColors.subtext),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyRecent extends StatelessWidget {
  final String text;

  const EmptyRecent({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          const Icon(Icons.inbox_rounded, color: IdeafiiColors.subtext),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: IdeafiiColors.subtext,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
