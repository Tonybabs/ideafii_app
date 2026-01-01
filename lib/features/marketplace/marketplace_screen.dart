import 'dart:ui';

import 'package:flutter/material.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _MarketColors.bg,
      appBar: AppBar(
        title: const Text('Marketplace'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final packColumns = width >= 820 ? 2 : 1;
            final templateColumns = width >= 1100 ? 3 : width >= 720 ? 2 : 1;
            final toolColumns = width >= 1100 ? 3 : width >= 720 ? 2 : 1;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MarketplaceHeader(),
                  const SizedBox(height: 18),
                  const _SectionTitle(
                    icon: Icons.emoji_events_rounded,
                    iconColor: _MarketColors.accentA,
                    title: 'Idea Packs',
                    subtitle: 'Premium packs to accelerate your journey',
                  ),
                  const SizedBox(height: 12),
                  _PackGrid(columns: packColumns),
                  const SizedBox(height: 22),
                  const _SectionTitle(
                    icon: Icons.description_rounded,
                    iconColor: _MarketColors.purple,
                    title: 'Templates',
                    subtitle: 'Premium templates to ship faster',
                  ),
                  const SizedBox(height: 12),
                  _TemplateGrid(columns: templateColumns),
                  const SizedBox(height: 22),
                  const _SectionTitle(
                    icon: Icons.link_rounded,
                    iconColor: _MarketColors.accentA,
                    title: 'Recommended Tools',
                    subtitle: 'Trusted tools to build and scale',
                  ),
                  const SizedBox(height: 12),
                  _ToolGrid(columns: toolColumns),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MarketplaceHeader extends StatelessWidget {
  const _MarketplaceHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Marketplace 🛍️',
          style: TextStyle(
            color: _MarketColors.text,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Premium packs, templates, and tools to accelerate your journey',
          style: TextStyle(
            color: _MarketColors.subtext,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: _MarketColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: _MarketColors.subtext,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PackGrid extends StatelessWidget {
  final int columns;

  const _PackGrid({required this.columns});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: columns == 1 ? 1.1 : 1.45,
      children: const [
        _PackCard(
          emoji: '📱',
          title: 'TikTok Business Pack',
          price: '£9.99',
          badge: 'Best Seller',
          description:
              '10 proven TikTok-based business ideas with step-by-step guides',
          rating: '4.8 (124)',
        ),
        _PackCard(
          emoji: '🏠',
          title: 'Real Estate Pack',
          price: '£14.99',
          description:
              '8 real estate side hustles that don’t require huge capital',
          rating: '4.7 (89)',
        ),
        _PackCard(
          emoji: '🤖',
          title: 'AI Automations Pack',
          price: '£19.99',
          badge: 'New',
          description:
              '15 AI-powered business ideas for the future with workflows',
          rating: '4.9 (156)',
        ),
        _PackCard(
          emoji: '💻',
          title: 'Digital Product Pack',
          price: '£12.99',
          description:
              '12 digital product ideas you can launch this weekend',
          rating: '4.6 (67)',
        ),
      ],
    );
  }
}

class _PackCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String price;
  final String description;
  final String rating;
  final String? badge;

  const _PackCard({
    required this.emoji,
    required this.title,
    required this.price,
    required this.description,
    required this.rating,
    this.badge,
  });

  @override
  State<_PackCard> createState() => _PackCardState();
}

class _PackCardState extends State<_PackCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _MarketColors.card,
              border: Border.all(color: _MarketColors.stroke),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _hovered
                    ? [
                        _MarketColors.accentA.withOpacity(0.26),
                        Colors.transparent,
                        _MarketColors.purple.withOpacity(0.16),
                      ]
                    : [
                        _MarketColors.accentA.withOpacity(0.06),
                        _MarketColors.purple.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ],
                stops: _hovered ? const [0.0, 0.55, 1.0] : null,
              ),
              boxShadow: const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _MarketColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.price,
                      style: const TextStyle(
                        color: _MarketColors.accentA,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (widget.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: widget.badge == 'New'
                          ? _MarketColors.purple.withOpacity(0.2)
                          : _MarketColors.green.withOpacity(0.2),
                    ),
                    child: Text(
                      widget.badge!,
                      style: TextStyle(
                        color: widget.badge == 'New'
                            ? _MarketColors.purple
                            : _MarketColors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  widget.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _MarketColors.subtext,
                    height: 1.35,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: _MarketColors.gold, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      widget.rating,
                      style: const TextStyle(
                        color: _MarketColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _OutlineButton(label: 'View Pack'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateGrid extends StatelessWidget {
  final int columns;

  const _TemplateGrid({required this.columns});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: columns == 1 ? 1.05 : 1.0,
      children: const [
        _TemplateCard(
          icon: Icons.description_rounded,
          title: 'Business Plan Template',
          description: 'Professional business plan template with AI fill assistance',
          price: '£4.99',
        ),
        _TemplateCard(
          icon: Icons.checklist_rounded,
          title: 'Launch Checklist',
          description: 'Complete 50-point checklist for launching any business',
          price: '£2.99',
        ),
        _TemplateCard(
          icon: Icons.campaign_rounded,
          title: 'Social Media Kit',
          description: '30 customizable social media templates for any niche',
          price: '£7.99',
        ),
      ],
    );
  }
}

class _TemplateCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final String price;

  const _TemplateCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _MarketColors.card,
              border: Border.all(color: _MarketColors.stroke),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _hovered
                    ? [
                        _MarketColors.accentA.withOpacity(0.25),
                        Colors.transparent,
                        _MarketColors.purple.withOpacity(0.18),
                      ]
                    : [
                        _MarketColors.accentA.withOpacity(0.05),
                        _MarketColors.purple.withOpacity(0.06),
                        Colors.white.withOpacity(0.02),
                      ],
                stops: _hovered ? const [0.0, 0.55, 1.0] : null,
              ),
              boxShadow: const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(widget.icon, color: _MarketColors.purple, size: 26),
                const SizedBox(height: 14),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: _MarketColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: const TextStyle(
                    color: _MarketColors.subtext,
                    height: 1.35,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      widget.price,
                      style: const TextStyle(
                        color: _MarketColors.purple,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Get',
                      style: TextStyle(
                        color: _MarketColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolGrid extends StatelessWidget {
  final int columns;

  const _ToolGrid({required this.columns});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: columns == 1 ? 4.2 : 3.4,
      children: const [
        _ToolCard(
          emoji: '🛒',
          title: 'Shopify',
          subtitle: 'E-commerce platform',
        ),
        _ToolCard(
          emoji: '🎨',
          title: 'Canva',
          subtitle: 'Design made easy',
        ),
        _ToolCard(
          emoji: '⚡',
          title: 'Make.com',
          subtitle: 'Automation workflows',
        ),
        _ToolCard(
          emoji: '🤖',
          title: 'ChatGPT',
          subtitle: 'AI assistant',
        ),
        _ToolCard(
          emoji: '📝',
          title: 'Notion',
          subtitle: 'All-in-one workspace',
        ),
        _ToolCard(
          emoji: '💳',
          title: 'Stripe',
          subtitle: 'Payment processing',
        ),
      ],
    );
  }
}

class _ToolCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _ToolCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _MarketColors.card,
              border: Border.all(color: _MarketColors.stroke),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _hovered
                    ? [
                        _MarketColors.accentA.withOpacity(0.22),
                        Colors.transparent,
                        _MarketColors.purple.withOpacity(0.14),
                      ]
                    : [
                        _MarketColors.accentA.withOpacity(0.04),
                        _MarketColors.purple.withOpacity(0.04),
                        Colors.white.withOpacity(0.02),
                      ],
                stops: _hovered ? const [0.0, 0.55, 1.0] : null,
              ),
              boxShadow: const [],
            ),
            child: Row(
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: _MarketColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: _MarketColors.subtext,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;

  const _OutlineButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: _MarketColors.accentA,
        side: BorderSide(color: _MarketColors.accentA.withOpacity(0.7)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_rounded, size: 16),
        ],
      ),
    );
  }
}

class _MarketColors {
  static const bg = Color(0xFF0A0C12);
  static const card = Color(0x18131722);
  static const stroke = Color(0x22FFFFFF);
  static const text = Color(0xFFEAF0FF);
  static const subtext = Color(0xB3EAF0FF);
  static const accentA = Color(0xFF58F3C2);
  static const purple = Color(0xFFB064FF);
  static const green = Color(0xFF4CD964);
  static const gold = Color(0xFFFFC857);
}
