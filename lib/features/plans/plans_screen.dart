import 'dart:ui';

import 'package:flutter/material.dart';
import '../ui/ideafii_ui.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IdeafiiColors.bg,
      appBar: AppBar(
        title: const Text('Plans'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _PlanHero(
                title: 'Pick your plan',
                subtitle: 'Unlock more ideas, deeper blueprints, and execution.',
              ),
              SizedBox(height: 16),
              _PlanCard(
                name: 'Free',
                price: '£0',
                tagline: 'Try the core experience',
                features: [
                  'Daily Spark (1/day)',
                  '5 ideas/day',
                  '3 Lite Blueprints (lifetime)',
                  'Save up to 5 blueprints',
                  'No PDF/Notion export',
                ],
              ),
              SizedBox(height: 14),
              _PlanCard(
                name: 'Premium',
                price: '£7.99 / month',
                secondaryPrice: '£79.99 / year (2 months free)',
                tagline: 'For builders moving fast',
                highlight: true,
                features: [
                  '30 Full Blueprints/month',
                  'Unlimited saved vault',
                  'Export to PDF + Notion',
                  'Rerun blueprint variations',
                  'Templates included',
                ],
                ctaLabel: 'Go Premium',
              ),
              SizedBox(height: 14),
              _PlanCard(
                name: 'Premium X',
                price: '£25–£39 / month',
                tagline: 'Advanced AI growth stack',
                features: [
                  'Competitor scans (10/mo)',
                  'Market reports (5/mo)',
                  'AI cofounder chat',
                  'Automation recipes',
                ],
                ctaLabel: 'Join Premium X',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanHero extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PlanHero({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
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
                IdeafiiColors.accentA.withOpacity(0.08),
                IdeafiiColors.accentB.withOpacity(0.06),
                Colors.white.withOpacity(0.02),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: IdeafiiColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: IdeafiiColors.subtext,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatefulWidget {
  final String name;
  final String price;
  final String? secondaryPrice;
  final String tagline;
  final List<String> features;
  final bool highlight;
  final String ctaLabel;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.tagline,
    required this.features,
    this.secondaryPrice,
    this.highlight = false,
    this.ctaLabel = 'Choose plan',
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.highlight ? IdeafiiColors.accentA : IdeafiiColors.stroke;
    final badgeBg = widget.highlight
        ? IdeafiiColors.accentA.withOpacity(0.15)
        : _PlansColors.iconBg;
    final highlightShadows = widget.highlight
        ? [
            BoxShadow(
              color: IdeafiiColors.accentA.withOpacity(0.2),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: IdeafiiColors.accentB.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ]
        : <BoxShadow>[];

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              color: IdeafiiColors.glass,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _hovered
                    ? [
                        IdeafiiColors.accentA.withOpacity(0.24),
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
              boxShadow: highlightShadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: badgeBg,
                      ),
                      child: Text(
                        widget.name,
                        style: const TextStyle(
                          color: IdeafiiColors.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.price,
                      style: const TextStyle(
                        color: IdeafiiColors.text,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (widget.secondaryPrice != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.secondaryPrice!,
                    style: const TextStyle(
                      color: IdeafiiColors.subtext,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  widget.tagline,
                  style: const TextStyle(
                    color: IdeafiiColors.subtext,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: IdeafiiColors.accentA, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(
                              color: IdeafiiColors.subtext,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: widget.highlight
                      ? GradientButton(
                          text: widget.ctaLabel,
                          onTap: () {},
                        )
                      : PillButton(
                          label: widget.ctaLabel,
                          onTap: () {},
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlansColors {
  static const iconBg = Color(0x1C1F2A);
}
