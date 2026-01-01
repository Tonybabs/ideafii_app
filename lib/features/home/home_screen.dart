import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../onboarding/user_profile.dart';
import '../../services/profile_store.dart';
import '../../services/daily_spark_service.dart';
import '../ideas/idea_blueprint.dart';
import '../ideas/idea_blueprint_screen.dart';
import '../ideas/idea_input_screen.dart';
import '../ideas/idea_service.dart';
import '../plans/plans_screen.dart';
import '../ui/ideafii_ui.dart';
import '../ui/idea_card_utils.dart';
import '../ui/idea_showcase_card.dart';
import '../../services/entitlements_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient _client = Supabase.instance.client;

  List<_SavedIdea> _recentIdeas = [];
  bool _loadingRecent = false;
  UserProfile? _profile;
  String _dailyIdea = '';
  bool _loadingSpark = true;

  @override
  void initState() {
    super.initState();
    _loadRecentIdeas();
    _loadProfile();
    _loadDailySpark();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileStore.load();
    if (!mounted) return;
    setState(() {
      _profile = profile;
    });
  }

  Future<void> _loadDailySpark() async {
    if (!mounted) return;
    setState(() => _loadingSpark = true);
    try {
      final spark = await DailySparkService.getDailySpark();
      if (!mounted) return;
      setState(() {
        _dailyIdea = spark;
        _loadingSpark = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSpark = false);
    }
  }

  Future<void> _loadRecentIdeas() async {
    final user = _client.auth.currentUser;
    if (user == null || user.email == null) {
      if (!mounted) return;
      setState(() => _recentIdeas = []);
      return;
    }

    if (!mounted) return;
    setState(() => _loadingRecent = true);

    try {
      final res = await _client
          .from('ideas')
          .select('id, title, idea_input, blueprint, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(3);

      final rows = (res as List).cast<Map<String, dynamic>>();

      if (!mounted) return;
      setState(() {
        _recentIdeas = rows.map(_SavedIdea.fromRow).toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _recentIdeas = []);
    } finally {
      if (mounted) setState(() => _loadingRecent = false);
    }
  }

  Future<void> _openIdeaInput() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const IdeaInputScreen()),
    );

    if (mounted) _loadRecentIdeas();
  }

  Future<void> _buildDailySpark() async {
    final idea = _dailyIdea.trim();
    if (idea.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily Spark is empty')),
      );
      return;
    }

    try {
      final mode = await EntitlementsService.modeForBlueprint();
      final blueprint = await IdeaService.saveIdea(
        ideaInput: idea,
        mode: mode,
        allowAnonymous: kDebugMode,
      );
      if (!mounted) return;
      await _openBlueprint(blueprint, ideaInput: idea);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _openBlueprint(
    IdeaBlueprint blueprint, {
    String? ideaInput,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IdeaBlueprintScreen(
          blueprint: blueprint,
          ideaInput: ideaInput,
          ideaTitle: _shorten(ideaInput ?? 'Your idea', 42),
        ),
      ),
    );

    if (mounted) _loadRecentIdeas();
  }

  Future<void> _openSavedIdea(_SavedIdea idea) async {
    try {
      final blueprint = idea.toBlueprint();
      await _openBlueprint(blueprint, ideaInput: idea.ideaInput);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open blueprint: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _client.auth.currentUser;
    const isFreeTier = true;

    return Scaffold(
      backgroundColor: IdeafiiColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ideafii'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadingRecent || _loadingSpark
                ? null
                : () {
                    _loadRecentIdeas();
                    _loadDailySpark();
                  },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktopWide = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              primary: true,
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktopWide ? 760 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const GradientHeading(
                        title: 'Build your next idea',
                        subtitle: 'Capture it fast. Generate a blueprint.',
                      ),
                      const SizedBox(height: 14),

                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daily Spark',
                              style: TextStyle(
                                color: IdeafiiColors.text,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _loadingSpark
                                  ? 'Loading your personalized idea...'
                                  : _dailyIdea.isEmpty
                                      ? 'Tap refresh to try again.'
                                      : _dailyIdea,
                              style: const TextStyle(
                                color: IdeafiiColors.subtext,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _profile == null
                                  ? 'Based on your onboarding choices.'
                                  : 'Based on your onboarding: '
                                      '${_labelIntent(_profile!.intent)}, '
                                      '${_labelSkill(_profile!.skillLevel)}, '
                                      '${_labelBudget(_profile!.budget)}.',
                              style: const TextStyle(
                                color: IdeafiiColors.subtext,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                text: 'Generate blueprint',
                                onTap: _loadingSpark ? null : _buildDailySpark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Text(
                        'Start a new idea',
                        style: TextStyle(
                          color: IdeafiiColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          text: 'New idea',
                          onTap: _openIdeaInput,
                        ),
                      ),
                      const SizedBox(height: 18),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          const Text(
                            'Recent ideas',
                            style: TextStyle(
                              color: IdeafiiColors.text,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (_loadingRecent)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          const Spacer(),
                          if (_recentIdeas.isNotEmpty)
                            Text(
                              '${_recentIdeas.length} shown',
                              style: const TextStyle(
                                color: IdeafiiColors.subtext,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (user == null || user.email == null)
                        const EmptyRecent(
                          text: 'No saved ideas yet (sign in to enable saving).',
                        )
                      else if (!_loadingRecent && _recentIdeas.isEmpty)
                        const EmptyRecent(
                          text: 'No saved ideas yet. Build your first one above.',
                        )
                      else
                        Column(
                          children: _recentIdeas.map((idea) {
                            final ideaTitle = idea.title.isNotEmpty
                                ? idea.title
                                : _shorten(idea.ideaInput, 42);
                            IdeaBlueprint? parsed;
                            try {
                              parsed = idea.toBlueprint();
                            } catch (_) {}
                            final info = deriveIdeaCardInfo(
                              ideaText: idea.ideaInput,
                              blueprint: parsed,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: IdeaShowcaseCard(
                                title: ideaTitle,
                                description: _shorten(idea.ideaInput, 120),
                                chipLabel: info.chipLabel,
                                chipColor: info.chipColor,
                                emoji: info.emoji,
                                meta: info.meta,
                                onTap: () => _openSavedIdea(idea),
                              ),
                            );
                          }).toList(),
                        ),
                      if (isFreeTier) const SizedBox(height: 16),
                      if (isFreeTier)
                        _UpgradeCta(
                          title: 'Fii Pro',
                          subtitle:
                              'Unlock unlimited AI generations and detailed blueprints.',
                          cta: 'Upgrade Now',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PlansScreen(),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SavedIdea {
  final String id;
  final String title;
  final String ideaInput;
  final dynamic blueprint;
  final DateTime? createdAt;

  _SavedIdea({
    required this.id,
    required this.title,
    required this.ideaInput,
    required this.blueprint,
    required this.createdAt,
  });

  factory _SavedIdea.fromRow(Map<String, dynamic> row) {
    return _SavedIdea(
      id: (row['id'] ?? '').toString(),
      title: (row['title'] ?? '').toString(),
      ideaInput: (row['idea_input'] ?? '').toString(),
      blueprint: row['blueprint'],
      createdAt: row['created_at'] == null
          ? null
          : DateTime.tryParse(row['created_at'].toString()),
    );
  }

  IdeaBlueprint toBlueprint() {
    final raw = blueprint;

    if (raw is Map<String, dynamic>) {
      return IdeaBlueprint.fromJson(raw);
    }

    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return IdeaBlueprint.fromJson(decoded);
      }
    }

    if (raw is Map) {
      return IdeaBlueprint.fromJson(Map<String, dynamic>.from(raw));
    }

    throw Exception('Blueprint format not supported');
  }
}

String _shorten(String s, int max) {
  final t = s.trim();
  if (t.length <= max) return t;
  return '${t.substring(0, max)}…';
}

String _labelIntent(String value) {
  switch (value) {
    case 'side_hustle':
      return 'Side Hustle';
    case 'full_business':
      return 'Full Business';
    case 'validate':
      return 'Validate';
    default:
      return 'Explore';
  }
}

String _labelSkill(String value) {
  switch (value) {
    case 'no_code':
      return 'No-code';
    case 'some_tech':
      return 'Some Tech';
    case 'developer':
      return 'Developer';
    default:
      return 'No-code';
  }
}

String _labelBudget(String value) {
  switch (value) {
    case '0_100':
      return r'£0–£100';
    case '100_1000':
      return r'£100–£1k';
    case '1000_plus':
      return r'£1k+';
    default:
      return r'£0–£100';
  }
}

class _UpgradeCta extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;

  const _UpgradeCta({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
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
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
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
              child: Text(cta),
            ),
          ),
        ],
      ),
    );
  }
}
