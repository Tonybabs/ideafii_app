// idea_blueprint_screen.dart
// [FILE: Blueprint Screen] Mobile-first UI for viewing the AI-generated blueprint (tabs + collapsible coach cards)

import 'dart:ui'; // [NOTE: Glass blur] Needed for ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'idea_blueprint.dart';
import '../../services/ai_service.dart';
import '../../services/entitlements_service.dart';
import '../../services/profile_store.dart';
import '../onboarding/user_profile.dart';
import '../plans/plans_screen.dart';

// [SECTION: Screen Widget]
class IdeaBlueprintScreen extends StatefulWidget {
  final IdeaBlueprint blueprint;
  final String? ideaTitle;
  final String? ideaInput;

  const IdeaBlueprintScreen({
    super.key,
    required this.blueprint,
    this.ideaTitle,
    this.ideaInput,
  });

  @override
  State<IdeaBlueprintScreen> createState() => _IdeaBlueprintScreenState();
}

// [SECTION: Screen State]
class _IdeaBlueprintScreenState extends State<IdeaBlueprintScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late IdeaBlueprint _currentBlueprint;

  // [NOTE: UX] Simple MVP toggle to open/close all cards
  bool _expandAll = false;
  bool _isSaved = false;
  bool _saving = false;
  bool _rerunLoading = false;
  UserProfile? _profile;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentBlueprint = widget.blueprint;
    _loadSavedState();
    _loadProfile();
    _loadTier();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // [SECTION: Helpers]
  Future<void> _loadProfile() async {
    final p = await ProfileStore.load();
    if (!mounted) return;
    setState(() => _profile = p);
  }

  Future<void> _loadTier() async {
    final premium = await EntitlementsService.isPremium();
    if (!mounted) return;
    setState(() => _isPremium = premium);
  }

  Future<void> _rerunWithModifier(String modifier) async {
    if (_rerunLoading) return;
    if (!_isPremium) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upgrade to rerun variations')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PlansScreen()),
      );
      return;
    }
    final ideaInput = _resolveIdeaInput();
    if (ideaInput == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing idea input')),
      );
      return;
    }

    setState(() => _rerunLoading = true);
    try {
      final blueprint = await AiService.generateBlueprint(
        ideaInput,
        modifier: modifier,
        mode: 'full',
      );
      if (!mounted) return;
      setState(() => _currentBlueprint = blueprint);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _rerunLoading = false);
    }
  }

  Future<void> _copyText(String text, {String toast = 'Copied'}) async {
    final t = text.trim();
    if (t.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: t));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(toast)),
    );
  }

  Future<void> _shareText(String text, {String? subject}) async {
    final t = text.trim();
    if (t.isEmpty) return;
    await Share.share(t, subject: subject);
  }

  String _buildNextMove(IdeaBlueprint b) {
    // [NOTE: UX] “Next Move” should feel actionable, not a full section dump
    final items = <String>[];

    if (b.roadmap7Days.isNotEmpty) {
      items.add('Today: ${b.roadmap7Days.first}');
    }
    if (b.stepByStepPlan.isNotEmpty) {
      items.add('Next: ${b.stepByStepPlan.first}');
    }
    if (b.toolsNeeded.isNotEmpty) {
      items.add('Tool: ${b.toolsNeeded.first}');
    }

    return items.join('\n');
  }

  int _completenessPercent(IdeaBlueprint b) {
    final fields = [
      b.summary,
      b.whoItHelps,
      b.whyNow,
      b.startupCost,
      b.incomePotential,
      b.toolsNeeded,
      b.stepByStepPlan,
      b.marketingPlan,
      b.nameIdeas,
      b.roadmap7Days,
      b.noCodeVersion,
      b.risksAndFixes,
      b.mvpFeatures,
    ];

    int present = 0;
    for (final f in fields) {
      if (f is String && f.trim().isNotEmpty) present++;
      if (f is List && f.where((e) => e.toString().trim().isNotEmpty).isNotEmpty) {
        present++;
      }
    }

    return ((present / fields.length) * 100).round();
  }

  String _labelForBudget(String? budget) {
    switch (budget) {
      case '0_100':
        return r'$0-100';
      case '100_1000':
        return r'$100-1k';
      case '1000_plus':
        return r'>$1k';
      default:
        return 'Budget: —';
    }
  }

  String _labelForSkill(String? skill) {
    switch (skill) {
      case 'no_code':
        return 'No-code';
      case 'some_tech':
        return 'Some tech';
      case 'developer':
        return 'Developer';
      default:
        return 'Skill: —';
    }
  }

String _labelForTime(int? hours) {
  if (hours == null || hours == 0) return 'Time: —';
  if (hours <= 5) return '1-5 hrs/wk';
  if (hours <= 15) return '6-15 hrs/wk';
  return '16+ hrs/wk';
}

bool _hasText(String value) {
  return value.trim().isNotEmpty;
}

bool _hasList(List<String> values) {
  return values.any((v) => v.trim().isNotEmpty);
}

String? _resolveIdeaInput() {
  final raw = widget.ideaInput ?? widget.ideaTitle;
  if (raw == null) return null;
  final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _loadSavedState() async {
    final user = Supabase.instance.client.auth.currentUser;
    final ideaInput = _resolveIdeaInput();
    if (user == null || user.email == null || ideaInput == null) return;

    final res = await Supabase.instance.client
        .from('ideas')
        .select('id')
        .eq('user_id', user.id)
        .eq('idea_input', ideaInput)
        .limit(1);

    if (!mounted) return;
    setState(() => _isSaved = (res as List).isNotEmpty);
  }

  Future<void> _toggleSave() async {
    if (_saving) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in with email to save ideas')),
      );
      return;
    }

    final ideaInput = _resolveIdeaInput();
    if (ideaInput == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing idea input')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final client = Supabase.instance.client;

      if (_isSaved) {
        await client
            .from('ideas')
            .delete()
            .eq('user_id', user.id)
            .eq('idea_input', ideaInput);
        if (!mounted) return;
        setState(() => _isSaved = false);
      } else {
        final currentCount = await _countSavedIdeas(user.id);
        final canSave = await EntitlementsService.canSaveMore(currentCount);
        if (!canSave) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upgrade to save more ideas')),
          );
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PlansScreen()),
          );
          return;
        }
        await client.from('ideas').insert({
          'user_id': user.id,
          'title': ideaInput.length > 40
              ? ideaInput.substring(0, 40)
              : ideaInput,
          'idea_input': ideaInput,
          'blueprint': _currentBlueprint.toJson(),
        });
        if (!mounted) return;
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved ✅')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<int> _countSavedIdeas(String userId) async {
    final res = await Supabase.instance.client
        .from('ideas')
        .select('id')
        .eq('user_id', userId);
    return (res as List).length;
  }

  @override
  Widget build(BuildContext context) {
    final b = _currentBlueprint;
    final isLite = b.blueprintMode == 'lite';

    // [NOTE: Desktop] Center content on wide screens (macOS)
    return Scaffold(
      backgroundColor: _IdeafiiColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Blueprint'),
        actions: [
          _SaveToggleButton(
            isSaved: _isSaved,
            isLoading: _saving,
            onTap: _toggleSave,
          ),
          // [ACTION: Expand/Collapse All]
          IconButton(
            tooltip: _expandAll ? 'Collapse all' : 'Expand all',
            onPressed: () => setState(() => _expandAll = !_expandAll),
            icon: Icon(_expandAll ? Icons.unfold_less : Icons.unfold_more),
          ),
          // [ACTION: Copy Summary]
          IconButton(
            tooltip: 'Copy summary',
            onPressed: () => _copyText(
              b.summary,
              toast: 'Summary copied',
            ),
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktopWide = constraints.maxWidth >= 900;

            final content = Column(
              children: [
                // [SECTION: Next Move Title]
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Move',
                        style: TextStyle(
                          color: _IdeafiiColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Skim first. Expand what you need. Then take the next step.',
                        style: TextStyle(
                          color: _IdeafiiColors.subtext,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isPremium)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _RerunRow(
                      loading: _rerunLoading,
                      onCheaper: () => _rerunWithModifier('Make it cheaper'),
                      onNoCode: () => _rerunWithModifier('Make it no-code'),
                      onFaster: () =>
                          _rerunWithModifier('Make it faster (7 days)'),
                    ),
                  ),

                // [SECTION: Tabs]
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _GlassTabBar(
                    controller: _tabController,
                    tabs: const [
                      // [NOTE: Padding fixes “indicator too tight”]
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Text('OVERVIEW'),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Text('PLAN'),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Text('MARKETING'),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Text('ROADMAP'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // [SECTION: Tab Views]
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ---------------- OVERVIEW ----------------
                      _TabList(
                        children: [
                          if (_hasText(b.summary) || !isLite)
                            _CoachCard.text(
                              title: '💡 Summary',
                              text: b.summary,
                              expandAll: _expandAll,
                              onCopy: () => _copyText(b.summary),
                              onShare: () => _shareText(
                                b.summary,
                                subject: 'Idea Summary',
                              ),
                            ),
                          if (_hasText(b.whoItHelps) || !isLite)
                            _CoachCard.text(
                              title: '🎯 Who this helps',
                              text: b.whoItHelps,
                              expandAll: _expandAll,
                              onCopy: () => _copyText(b.whoItHelps),
                              onShare: () => _shareText(
                                b.whoItHelps,
                                subject: 'Who This Helps',
                              ),
                            ),
                          if (_hasText(b.whyNow) || !isLite)
                            _CoachCard.text(
                              title: '⏰ Why now',
                              text: b.whyNow,
                              expandAll: _expandAll,
                              onCopy: () => _copyText(b.whyNow),
                              onShare: () => _shareText(
                                b.whyNow,
                                subject: 'Why Now',
                              ),
                            ),
                          if (_hasText(b.startupCost) || !isLite)
                            _CoachCard.text(
                              title: '💰 Startup cost',
                              text: b.startupCost,
                              expandAll: _expandAll,
                              onCopy: () => _copyText(b.startupCost),
                              onShare: () => _shareText(
                                b.startupCost,
                                subject: 'Startup Cost',
                              ),
                            ),
                          if (_hasText(b.incomePotential) || !isLite)
                            _CoachCard.text(
                              title: '📈 Income potential',
                              text: b.incomePotential,
                              expandAll: _expandAll,
                              onCopy: () => _copyText(b.incomePotential),
                              onShare: () => _shareText(
                                b.incomePotential,
                                subject: 'Income Potential',
                              ),
                            ),
                          if (_hasList(b.toolsNeeded) || !isLite)
                            _CoachCard.list(
                              title: '🛠 Tools needed',
                              items: b.toolsNeeded,
                              expandAll: _expandAll,
                              onCopy: () =>
                                  _copyText(b.toolsNeeded.join('\n')),
                              onShare: () => _shareText(
                                b.toolsNeeded.join('\n'),
                                subject: 'Tools Needed',
                              ),
                              renderMode: _CoachCardRenderMode.toolStack,
                            ),
                          if (_hasList(b.risksAndFixes) || !isLite)
                            _CoachCard.risks(
                              title: '⚠️ Risks → Fixes',
                              items: b.risksAndFixes,
                              expandAll: _expandAll,
                              onCopy: () =>
                                  _copyText(b.risksAndFixes.join('\n')),
                              onShare: () => _shareText(
                                b.risksAndFixes.join('\n'),
                                subject: 'Risks and Fixes',
                              ),
                              variant: _CoachCardVariant.warning,
                            ),
                          if (_hasList(b.nameIdeas) || !isLite)
                            _CoachCard.list(
                              title: '🏷 Name ideas',
                              items: b.nameIdeas,
                              expandAll: _expandAll,
                              onCopy: () => _copyText(b.nameIdeas.join('\n')),
                              onShare: () => _shareText(
                                b.nameIdeas.join('\n'),
                                subject: 'Name Ideas',
                              ),
                            ),
                          if (_hasList(b.noCodeVersion) || !isLite)
                            _CoachCard.list(
                              title: '🧩 No-code / low-cost version',
                              items: b.noCodeVersion,
                              expandAll: _expandAll,
                              onCopy: () =>
                                  _copyText(b.noCodeVersion.join('\n')),
                              onShare: () => _shareText(
                                b.noCodeVersion.join('\n'),
                                subject: 'No-code Version',
                              ),
                            ),
                        ],
                      ),

                      // ---------------- PLAN ----------------
                      _TabList(
                        children: [
                          if (_hasList(b.stepByStepPlan) || !isLite)
                            _CoachCard.numbered(
                              title: '🚀 Step-by-step plan',
                              items: b.stepByStepPlan,
                              expandAll: _expandAll,
                              onCopy: () =>
                                  _copyText(b.stepByStepPlan.join('\n')),
                              onShare: () => _shareText(
                                b.stepByStepPlan.join('\n'),
                                subject: 'Step-by-step Plan',
                              ),
                            ),
                        ],
                      ),

                      // ---------------- MARKETING ----------------
                      _TabList(
                        children: [
                          if (_hasList(b.marketingPlan) || !isLite)
                            _CoachCard.list(
                              title: '📣 Marketing plan',
                              items: b.marketingPlan,
                              expandAll: _expandAll,
                              onCopy: () =>
                                  _copyText(b.marketingPlan.join('\n')),
                              onShare: () => _shareText(
                                b.marketingPlan.join('\n'),
                                subject: 'Marketing Plan',
                              ),
                            ),
                        ],
                      ),

                      // ---------------- ROADMAP ----------------
                      _TabList(
                        children: [
                          if (_hasList(b.roadmap7Days) || !isLite)
                            _CoachCard.numberedCards(
                              title: '🗓 7-day action plan',
                              items: b.roadmap7Days,
                              expandAll: _expandAll,
                              onCopy: () =>
                                  _copyText(b.roadmap7Days.join('\n')),
                              onShare: () => _shareText(
                                b.roadmap7Days.join('\n'),
                                subject: '7-day Action Plan',
                              ),
                            ),
                          if (_hasList(b.roadmap7Days))
                            const SizedBox(height: 8),
                          if (_hasList(b.roadmap7Days))
                            _ActionButton(
                              icon: Icons.copy_rounded,
                              label: 'Copy Next Move',
                              onTap: () {
                                final nextMove = _buildNextMove(b);
                                _copyText(nextMove, toast: 'Next move copied');
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );

            if (!isDesktopWide) return content;

            // [SECTION: Desktop Centering]
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// [SECTION: Design Tokens]
// ============================================================
class _IdeafiiColors {
  static const bg = Color(0xFF070B14);

  // [NOTE: Glass] Dark tint (avoid grey slabs)
  static const glass = Color(0x160B1020);
  static const stroke = Color(0x22FFFFFF);

  static const text = Color(0xFFEAF0FF);
  static const subtext = Color(0xB3EAF0FF);

  static const accentA = Color(0xFF58F3C2);
  static const accentB = Color(0xFF8A5CFF);

  static const warning = Color(0xFFFF5D5D);
}

// ============================================================
// [SECTION: Top Summary]
// ============================================================
class _TopSummaryCard extends StatelessWidget {
  final String ideaTitle;
  final String budget;
  final String time;
  final String skill;
  final int completeness;

  const _TopSummaryCard({
    required this.ideaTitle,
    required this.budget,
    required this.time,
    required this.skill,
    required this.completeness,
  });

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
            border: Border.all(color: _IdeafiiColors.stroke),
            color: _IdeafiiColors.glass,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _IdeafiiColors.accentA.withOpacity(0.08),
                _IdeafiiColors.accentB.withOpacity(0.06),
                Colors.white.withOpacity(0.02),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Blueprint Quality',
                style: TextStyle(
                  color: _IdeafiiColors.subtext,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ideaTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _IdeafiiColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(label: budget),
                  _InfoChip(label: time),
                  _InfoChip(label: skill),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Blueprint completeness: $completeness%',
                style: const TextStyle(
                  color: _IdeafiiColors.subtext,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: completeness / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    _IdeafiiColors.accentA,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _IdeafiiColors.stroke),
        color: const Color(0x140B1020),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _IdeafiiColors.subtext,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

// ============================================================
// [SECTION: Hero Card]
// ============================================================
class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String primaryCtaText;
  final VoidCallback onPrimaryCta;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.primaryCtaText,
    required this.onPrimaryCta,
  });

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
            border: Border.all(color: _IdeafiiColors.stroke),
            color: _IdeafiiColors.glass,
            boxShadow: [
            BoxShadow(color: _IdeafiiColors.accentA.withOpacity(0.13), 
            blurRadius: 18, spreadRadius: 1, offset: const Offset(0, 0)),
            BoxShadow(color: _IdeafiiColors.accentB.withOpacity(0.14), 
            blurRadius: 22, spreadRadius: 1, offset: const Offset(0, 8)),
            ],

            gradient: LinearGradient(
              colors: [
                _IdeafiiColors.accentA.withOpacity(0.12),
                _IdeafiiColors.accentB.withOpacity(0.10),
                Colors.white.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0x221FFFFFF),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: _IdeafiiColors.text,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _IdeafiiColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _IdeafiiColors.subtext,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _GradientButton(
                        text: primaryCtaText,
                        onTap: onPrimaryCta,
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

// ============================================================
// [SECTION: Re-run Buttons]
// ============================================================
class _RerunRow extends StatelessWidget {
  final bool loading;
  final VoidCallback onCheaper;
  final VoidCallback onNoCode;
  final VoidCallback onFaster;

  const _RerunRow({
    required this.loading,
    required this.onCheaper,
    required this.onNoCode,
    required this.onFaster,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _IdeafiiColors.stroke),
            color: _IdeafiiColors.glass,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Re-run with a new angle',
                style: TextStyle(
                  color: _IdeafiiColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RerunButton(
                    label: 'Make it cheaper',
                    onTap: loading ? null : onCheaper,
                  ),
                  _RerunButton(
                    label: 'Make it no-code',
                    onTap: loading ? null : onNoCode,
                  ),
                  _RerunButton(
                    label: 'Make it faster (7 days)',
                    onTap: loading ? null : onFaster,
                  ),
                ],
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Rebuilding blueprint...',
                    style: TextStyle(
                      color: _IdeafiiColors.subtext,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RerunButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _RerunButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: enabled ? _IdeafiiColors.text : _IdeafiiColors.subtext,
        side: BorderSide(
          color: enabled ? _IdeafiiColors.stroke : _IdeafiiColors.stroke.withOpacity(0.4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Text(label),
    );
  }
}

// ============================================================
// [SECTION: Glass Tab Bar]
// ============================================================
class _GlassTabBar extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;

  const _GlassTabBar({
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _IdeafiiColors.stroke),
            color: _IdeafiiColors.glass,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _IdeafiiColors.accentA.withOpacity(0.08),
                _IdeafiiColors.accentB.withOpacity(0.06),
                Colors.white.withOpacity(0.03),
              ],
            ),
          ),
          child: TabBar(
            controller: controller,
            tabs: tabs,
            labelColor: _IdeafiiColors.text,
            unselectedLabelColor: _IdeafiiColors.subtext,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            isScrollable: true,

            // [NOTE: Fix indicator being “too tight”]
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(2),

            // [NOTE: Remove Material 3 dividers/overlays]
            dividerColor: Colors.transparent,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            splashFactory: NoSplash.splashFactory,

            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [_IdeafiiColors.accentA, _IdeafiiColors.accentB],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// [SECTION: Tab List Wrapper]
// ============================================================
class _TabList extends StatelessWidget {
  final List<Widget> children;

  const _TabList({required this.children});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      physics: const BouncingScrollPhysics(),
      children: children,
    );
  }
}

// ============================================================
// [SECTION: Coach Cards]
// ============================================================
enum _CoachCardVariant { normal, warning }
enum _CoachCardRenderMode { bullets, toolStack }

class _CoachCard extends StatefulWidget {
  final String title;
  final Widget body;
  final String? preview;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final bool expandAll;
  final _CoachCardVariant variant;

  const _CoachCard._({
    required this.title,
    required this.body,
    required this.preview,
    required this.onCopy,
    required this.onShare,
    required this.expandAll,
    required this.variant,
  });

  // [FACTORY: Text Card]
  factory _CoachCard.text({
    required String title,
    required String text,
    required bool expandAll,
    VoidCallback? onCopy,
    VoidCallback? onShare,
    _CoachCardVariant variant = _CoachCardVariant.normal,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return _CoachCard._(
        title: title,
        body: const SizedBox.shrink(),
        preview: null,
        onCopy: null,
        onShare: null,
        expandAll: expandAll,
        variant: variant,
      );
    }

    final preview =
        trimmed.length > 120 ? '${trimmed.substring(0, 120)}…' : trimmed;

    return _CoachCard._(
      title: title,
      preview: preview,
      onCopy: onCopy,
      onShare: onShare,
      expandAll: expandAll,
      variant: variant,
      body: Text(
        trimmed,
        style: const TextStyle(
          color: _IdeafiiColors.subtext,
          height: 1.5,
          fontSize: 15.5,
        ),
      ),
    );
  }

  // [FACTORY: Bullet List Card]
  factory _CoachCard.list({
    required String title,
    required List<String> items,
    required bool expandAll,
    VoidCallback? onCopy,
    VoidCallback? onShare,
    _CoachCardRenderMode renderMode = _CoachCardRenderMode.bullets,
    _CoachCardVariant variant = _CoachCardVariant.normal,
  }) {
    final cleaned = items.where((e) => e.trim().isNotEmpty).toList();
    if (cleaned.isEmpty) {
      return _CoachCard._(
        title: title,
        body: const SizedBox.shrink(),
        preview: null,
        onCopy: null,
        onShare: null,
        expandAll: expandAll,
        variant: variant,
      );
    }

    final preview = cleaned.take(3).map((e) => '• ${e.trim()}').join('\n');

    return _CoachCard._(
      title: title,
      preview: preview,
      onCopy: onCopy,
      onShare: onShare,
      expandAll: expandAll,
      variant: variant,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: renderMode == _CoachCardRenderMode.toolStack
            ? cleaned.map((e) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _IdeafiiColors.stroke),
                    color: const Color(0x140B1020),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _IdeafiiColors.accentA.withOpacity(0.18),
                        ),
                        child: const Icon(
                          Icons.build_rounded,
                          color: _IdeafiiColors.accentA,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.trim(),
                          style: const TextStyle(
                            color: _IdeafiiColors.subtext,
                            height: 1.35,
                            fontSize: 15.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()
            : cleaned.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 7),
                        decoration: BoxDecoration(
                          color: _IdeafiiColors.accentA,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e.trim(),
                          style: const TextStyle(
                            color: _IdeafiiColors.subtext,
                            height: 1.45,
                            fontSize: 15.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
      ),
    );
  }

  factory _CoachCard.risks({
    required String title,
    required List<String> items,
    required bool expandAll,
    VoidCallback? onCopy,
    VoidCallback? onShare,
    _CoachCardVariant variant = _CoachCardVariant.warning,
  }) {
    final cleaned = items.where((e) => e.trim().isNotEmpty).toList();
    if (cleaned.isEmpty) {
      return _CoachCard._(
        title: title,
        body: const SizedBox.shrink(),
        preview: null,
        onCopy: null,
        onShare: null,
        expandAll: expandAll,
        variant: variant,
      );
    }

    final preview = cleaned.take(2).map((e) => '⚠️ ${e.trim()}').join('\n');

    return _CoachCard._(
      title: title,
      preview: preview,
      onCopy: onCopy,
      onShare: onShare,
      expandAll: expandAll,
      variant: variant,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cleaned.map((e) {
          final parts = _splitRiskFix(e);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _IdeafiiColors.warning.withOpacity(0.35)),
              color: const Color(0x140B1020),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TagChip(
                      label: '⚠️ Risk',
                      color: _IdeafiiColors.warning,
                    ),
                    if (parts.fix.isNotEmpty)
                      _TagChip(
                        label: '✅ Fix',
                        color: _IdeafiiColors.accentA,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  parts.risk,
                  style: const TextStyle(
                    color: _IdeafiiColors.subtext,
                    height: 1.4,
                    fontSize: 15.2,
                  ),
                ),
                if (parts.fix.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    parts.fix,
                    style: const TextStyle(
                      color: _IdeafiiColors.subtext,
                      height: 1.4,
                      fontSize: 14.8,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // [FACTORY: Numbered Steps Card]
  factory _CoachCard.numbered({
    required String title,
    required List<String> items,
    required bool expandAll,
    VoidCallback? onCopy,
    VoidCallback? onShare,
  }) {
    final cleaned = items.where((e) => e.trim().isNotEmpty).toList();
    if (cleaned.isEmpty) {
      return _CoachCard._(
        title: title,
        body: const SizedBox.shrink(),
        preview: null,
        onCopy: null,
        onShare: null,
        expandAll: expandAll,
        variant: _CoachCardVariant.normal,
      );
    }

    final preview = cleaned.take(2).toList().asMap().entries.map((entry) {
      final i = entry.key + 1;
      return '$i) ${entry.value.trim()}';
    }).join('\n');

    return _CoachCard._(
      title: title,
      preview: preview,
      onCopy: onCopy,
      onShare: onShare,
      expandAll: expandAll,
      variant: _CoachCardVariant.normal,
      body: Column(
        children: cleaned.asMap().entries.map((entry) {
          final i = entry.key + 1;
          final text = entry.value.trim();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _IdeafiiColors.accentA,
                  ),
                  child: Text(
                    '$i',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: _IdeafiiColors.subtext,
                      height: 1.45,
                      fontSize: 15.2,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  factory _CoachCard.numberedCards({
    required String title,
    required List<String> items,
    required bool expandAll,
    VoidCallback? onCopy,
    VoidCallback? onShare,
  }) {
    final cleaned = items.where((e) => e.trim().isNotEmpty).toList();
    if (cleaned.isEmpty) {
      return _CoachCard._(
        title: title,
        body: const SizedBox.shrink(),
        preview: null,
        onCopy: null,
        onShare: null,
        expandAll: expandAll,
        variant: _CoachCardVariant.normal,
      );
    }

    final preview = cleaned.take(2).toList().asMap().entries.map((entry) {
      final i = entry.key + 1;
      return '$i) ${entry.value.trim()}';
    }).join('\n');

    return _CoachCard._(
      title: title,
      preview: preview,
      onCopy: onCopy,
      onShare: onShare,
      expandAll: expandAll,
      variant: _CoachCardVariant.normal,
      body: Column(
        children: cleaned.asMap().entries.map((entry) {
          final i = entry.key + 1;
          final text = entry.value.trim();
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _IdeafiiColors.stroke),
              color: const Color(0x140B1020),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _IdeafiiColors.accentB.withOpacity(0.2),
                  ),
                  child: Text(
                    '$i',
                    style: const TextStyle(
                      color: _IdeafiiColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: _IdeafiiColors.subtext,
                      height: 1.45,
                      fontSize: 15.2,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  State<_CoachCard> createState() => _CoachCardState();
}

class _CoachCardState extends State<_CoachCard> {
  // [NOTE: State] Must exist to toggle expand/collapse
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open = widget.expandAll;
  }

  @override
  void didUpdateWidget(covariant _CoachCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // [NOTE: Expand All] Drive card state from parent toggle
    if (oldWidget.expandAll != widget.expandAll) {
      _open = widget.expandAll;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.preview == null) return const SizedBox.shrink();

    final isWarning = widget.variant == _CoachCardVariant.warning;

    final borderColor = isWarning
        ? _IdeafiiColors.warning.withOpacity(0.35)
        : _IdeafiiColors.stroke;

    final baseTint = isWarning ? const Color(0x140B1020) : _IdeafiiColors.glass;

    final sheenA = isWarning
        ? _IdeafiiColors.warning.withOpacity(0.06)
        : _IdeafiiColors.accentA.withOpacity(0.05);

    final sheenB = isWarning
        ? _IdeafiiColors.warning.withOpacity(0.03)
        : _IdeafiiColors.accentB.withOpacity(0.04);

    // [NOTE: Glass Card] This is what removes the “flat grey slab” look
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            color: baseTint,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                sheenA,
                sheenB,
                Colors.white.withOpacity(0.02),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // [ROW: Title + Actions]
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: _IdeafiiColors.text,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: _open ? 'Collapse' : 'Expand',
                    onPressed: () => setState(() => _open = !_open),
                    icon: Icon(
                      _open
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 22,
                    ),
                    color: _IdeafiiColors.subtext,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (widget.onCopy != null || widget.onShare != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (widget.onCopy != null)
                      _ActionButton(
                        icon: Icons.copy_rounded,
                        label: 'Copy',
                        onTap: widget.onCopy,
                      ),
                    if (widget.onShare != null)
                      _ActionButton(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        onTap: widget.onShare,
                      ),
                  ],
                ),
              const SizedBox(height: 8),

              // [TEXT: Collapsed Preview]
              if (!_open)
                Text(
                  widget.preview!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _IdeafiiColors.subtext,
                    height: 1.4,
                    fontSize: 14.8,
                  ),
                ),

              // [BODY: Expanded Content]
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: widget.body,
                ),
                crossFadeState: _open
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
                sizeCurve: Curves.easeOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiskFixParts {
  final String risk;
  final String fix;

  const _RiskFixParts({required this.risk, required this.fix});
}

_RiskFixParts _splitRiskFix(String input) {
  final raw = input.trim();
  final separators = ['->', '→', '—', ':'];
  for (final sep in separators) {
    final idx = raw.indexOf(sep);
    if (idx > 0) {
      final risk = raw.substring(0, idx).trim();
      final fix = raw.substring(idx + sep.length).trim();
      return _RiskFixParts(risk: risk.isEmpty ? raw : risk, fix: fix);
    }
  }
  return _RiskFixParts(risk: raw, fix: '');
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: _IdeafiiColors.subtext,
        side: BorderSide(color: _IdeafiiColors.stroke),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ============================================================
// [SECTION: Gradient Button]
// ============================================================
class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _GradientButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 360;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 16,
            vertical: isCompact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [_IdeafiiColors.accentA, _IdeafiiColors.accentB],
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.black,
                size: isCompact ? 18 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveToggleButton extends StatelessWidget {
  final bool isSaved;
  final bool isLoading;
  final VoidCallback onTap;

  const _SaveToggleButton({
    required this.isSaved,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
      label: Text(isSaved ? 'Saved' : 'Save'),
    );
  }
}
