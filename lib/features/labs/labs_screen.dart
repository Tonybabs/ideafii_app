import 'dart:ui';

import 'package:flutter/material.dart';

import '../plans/plans_screen.dart';

class LabsScreen extends StatelessWidget {
  const LabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const isFreeTier = true;
    return Scaffold(
      backgroundColor: _LabsColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Fii Labs'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final columns = isWide ? 3 : 2;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              primary: true,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI-Powered Tools',
                    style: TextStyle(
                      color: _LabsColors.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Create content for your business instantly',
                    style: TextStyle(
                      color: _LabsColors.subtext,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GridView.count(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      _LabCard(
                        icon: Icons.label_rounded,
                        title: 'Name Generator',
                        subtitle: 'AI-powered business name ideas',
                      ),
                      _LabCard(
                        icon: Icons.chat_bubble_rounded,
                        title: 'Tagline Creator',
                        subtitle: 'Catchy slogans for your business',
                      ),
                      _LabCard(
                        icon: Icons.description_rounded,
                        title: 'Business Plan',
                        subtitle: 'Full business plan document',
                        isPro: true,
                      ),
                      _LabCard(
                        icon: Icons.web_rounded,
                        title: 'Landing Page Copy',
                        subtitle: 'Website content that converts',
                        isPro: true,
                      ),
                      _LabCard(
                        icon: Icons.campaign_rounded,
                        title: 'Social Captions',
                        subtitle: 'Engaging posts for any platform',
                      ),
                      _LabCard(
                        icon: Icons.ads_click_rounded,
                        title: 'Ad Copy Generator',
                        subtitle: 'Compelling ads that sell',
                        isPro: true,
                      ),
                    ],
                  ),
                  if (isFreeTier) const SizedBox(height: 18),
                  if (isFreeTier)
                    _LabsUpgradeCta(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PlansScreen()),
                        );
                      },
                    ),
                  if (isFreeTier) const SizedBox(height: 6),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LabCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPro;

  const _LabCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isPro = false,
  });

  @override
  State<_LabCard> createState() => _LabCardState();
}

class _LabCardState extends State<_LabCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _hovered
                    ? _LabsColors.accentA.withOpacity(0.6)
                    : _LabsColors.stroke,
              ),
              color: _LabsColors.card,
              boxShadow: const [],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _hovered
                    ? [
                        _LabsColors.accentA.withOpacity(0.26),
                        Colors.transparent,
                        _LabsColors.accentB.withOpacity(0.16),
                      ]
                    : [
                        _LabsColors.accentA.withOpacity(0.08),
                        _LabsColors.accentB.withOpacity(0.06),
                        Colors.white.withOpacity(0.02),
                      ],
                stops: _hovered ? const [0.0, 0.55, 1.0] : null,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _LabsColors.iconBg,
                      ),
                      child: Icon(
                        widget.icon,
                        color: _LabsColors.accentA,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    if (widget.isPro)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: _LabsColors.proBg,
                        ),
                        child: const Text(
                          '⚡ PRO',
                          style: TextStyle(
                            color: _LabsColors.proText,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: _LabsColors.text,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    color: _LabsColors.subtext,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class _LabsColors {
  static const bg = Color(0xFF0A0C12);
  static const card = Color(0x160B1020);
  static const stroke = Color(0x22FFFFFF);
  static const text = Color(0xFFEAF0FF);
  static const subtext = Color(0xB3EAF0FF);
  static const accentA = Color(0xFF58F3C2);
  static const accentB = Color(0xFF8A5CFF);
  static const iconBg = Color(0x220B1020);
  static const proBg = Color(0x332C1447);
  static const proText = Color(0xFFB88CFF);
}

class _LabsUpgradeCta extends StatelessWidget {
  final VoidCallback onTap;

  const _LabsUpgradeCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A1D75),
            Color(0xFF7A2BCF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A2BCF).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fii Pro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock premium tools and advanced AI workflows.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5B1FAE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
              child: const Text('Upgrade Now'),
            ),
          ),
        ],
      ),
    );
  }
}
