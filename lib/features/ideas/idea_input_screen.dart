// idea_input_screen.dart
// [FILE: Idea Input] Focused capture for a single idea + blueprint generation
//
// [NOTES]
// - Keeps AI examples (reduced to 3)
// - Opens IdeaBlueprintScreen via Navigator.push

import 'dart:async'; // [SECTION: Loading steps] Timer for progress text
import 'dart:ui'; // [SECTION: Glass blur] ImageFilter.blur

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'idea_blueprint.dart';
import 'idea_blueprint_screen.dart';
import 'idea_service.dart';
import '../../services/entitlements_service.dart';
import '../plans/plans_screen.dart';
import '../ui/ideafii_ui.dart';

class IdeaInputScreen extends StatefulWidget {
  const IdeaInputScreen({super.key});

  @override
  State<IdeaInputScreen> createState() => _IdeaInputScreenState();
}

class _IdeaInputScreenState extends State<IdeaInputScreen> {
  // ============================================================
  // [SECTION: State]
  // ============================================================
  final TextEditingController _ideaController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool loading = false;

  // [SECTION: Supabase]
  final SupabaseClient _client = Supabase.instance.client;

  // [SECTION: Loading UX]
  final List<String> _loadingSteps = const [
    'Clarifying the idea',
    'Mapping the customer',
    'Shaping the MVP',
    'Building a launch plan',
    'Writing the first 7 days',
  ];
  int _stepIndex = 0;
  Timer? _stepTimer;

  // [SECTION: AI Examples] (reduced to 3)
  final List<String> _examples = const [
    'An AI-powered dog walking marketplace in London',
    'A no-code CRM for tradespeople (plumbers, electricians)',
    'A meal prep subscription for busy professionals (UK)',
  ];

  @override
  void dispose() {
    _stepTimer?.cancel();
    _ideaController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ============================================================
  // [SECTION: Actions]
  // ============================================================

  void _startLoadingSteps() {
    _stepTimer?.cancel();
    _stepIndex = 0;

    _stepTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted || !loading) return;
      setState(() {
        _stepIndex = (_stepIndex + 1) % _loadingSteps.length;
      });
    });
  }

  void _stopLoadingSteps() {
    _stepTimer?.cancel();
    _stepTimer = null;
  }

  void _applyExample(String example) {
    setState(() {
      _ideaController.text = example;
      _ideaController.selection = TextSelection.fromPosition(
        TextPosition(offset: _ideaController.text.length),
      );
    });
    _focusNode.requestFocus();
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
  }

  Future<void> _buildIdea() async {
    final user = _client.auth.currentUser;
    if (user == null || user.email == null) {
      if (!kDebugMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in with email to generate ideas')),
        );
        return;
      }
    }

    final idea = _ideaController.text.trim();

    if (idea.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an idea')),
      );
      return;
    }

    final canGenerate = await EntitlementsService.canGenerateBlueprint();
    if (!canGenerate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upgrade to generate more blueprints')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PlansScreen()),
      );
      return;
    }

    final mode = await EntitlementsService.modeForBlueprint();

    setState(() => loading = true);
    _startLoadingSteps();

    try {
      // [NOTE] Uses your existing save flow (generate + insert to Supabase)
      final blueprint = await IdeaService.saveIdea(
        ideaInput: idea,
        mode: mode,
        allowAnonymous: kDebugMode,
      );

      if (!mounted) return;

      // [NOTE] Open blueprint, then refresh recent list after returning
      await _openBlueprint(blueprint, ideaInput: idea);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      _stopLoadingSteps();
      if (mounted) setState(() => loading = false);
    }
  }

  // ============================================================
  // [SECTION: UI]
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = _client.auth.currentUser;

    return Scaffold(
      backgroundColor: IdeafiiColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('New idea'),
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktopWide = constraints.maxWidth >= 900;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  primary: true,
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktopWide ? 760 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // [SECTION: Input Card]
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'New idea',
                                  style: TextStyle(
                                    color: IdeafiiColors.text,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'One sentence is enough. You can refine it later.',
                                  style: TextStyle(
                                    color: IdeafiiColors.subtext,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                _IdeaTextField(
                                  controller: _ideaController,
                                  focusNode: _focusNode,
                                  enabled: !loading,
                                ),

                                const SizedBox(height: 16),

                                // [SECTION: AI Examples]
                                const Text(
                                  'Need Inspiration?',
                                  style: TextStyle(
                                    color: IdeafiiColors.text,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: _examples
                                      .map(
                                        (e) => _ExampleChip(
                                          label: _shorten(e, 28),
                                          onTap:
                                              loading ? null : () => _applyExample(e),
                                        ),
                                      )
                                      .toList(),
                                ),

                                const SizedBox(height: 18),

                                // [SECTION: Primary CTA]
                                GradientButton(
                                  text: loading ? 'Building…' : 'Build this idea',
                                  onTap: loading ? null : _buildIdea,
                                  isLoading: loading,
                                ),

                                const SizedBox(height: 10),

                                // [SECTION: Secondary Row]
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: loading
                                          ? null
                                          : () => _applyExample(_examples.first),
                                      child: const Text('Use an example'),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: loading
                                          ? null
                                          : () => setState(() => _ideaController.clear()),
                                      child: const Text('Clear'),
                                    ),
                                  ],
                                ),

                                // [NOTE: Auth hint]
                                if (user == null || user.email == null)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text(
                                      'Sign in with email to generate and save ideas.',
                                      style: TextStyle(
                                        color: IdeafiiColors.subtext,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // [SECTION: Loading Overlay]
                if (loading)
                  _LoadingOverlay(
                    title: 'Building your blueprint…',
                    step: _loadingSteps[_stepIndex],
                    steps: _loadingSteps,
                    currentIndex: _stepIndex,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// [SECTION: Helpers]
// ============================================================

String _shorten(String s, int max) {
  final t = s.trim();
  if (t.length <= max) return t;
  return '${t.substring(0, max)}…';
}

// ============================================================
// [SECTION: Components]
// ============================================================

class _IdeaTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;

  const _IdeaTextField({
    required this.controller,
    required this.focusNode,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // [NOTE: Inner surface] Slightly darker than card for depth
      decoration: BoxDecoration(
        color: const Color(0x16000000),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: IdeafiiColors.stroke),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        maxLines: 4,
        style: const TextStyle(
          color: IdeafiiColors.text,
          fontSize: 15.5,
          height: 1.4,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'e.g. An AI-powered dog walking marketplace',
          hintStyle: TextStyle(color: IdeafiiColors.subtext),
        ),
        textInputAction: TextInputAction.done,
      ),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _ExampleChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: IdeafiiColors.stroke),
          color: const Color(0x140B1020),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: IdeafiiColors.subtext,
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// [SECTION: Loading Overlay]
// ============================================================

class _LoadingOverlay extends StatelessWidget {
  final String title;
  final String step;
  final List<String> steps;
  final int currentIndex;

  const _LoadingOverlay({
    required this.title,
    required this.step,
    required this.steps,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: 520,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: IdeafiiColors.stroke),
                    color: IdeafiiColors.glass,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        IdeafiiColors.accentA.withOpacity(0.10),
                        IdeafiiColors.accentB.withOpacity(0.08),
                        Colors.white.withOpacity(0.02),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Building your blueprint…',
                            style: TextStyle(
                              color: IdeafiiColors.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          step,
                          key: ValueKey(step),
                          style: const TextStyle(
                            color: IdeafiiColors.subtext,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: steps.asMap().entries.map((entry) {
                          final i = entry.key;
                          final s = entry.value;
                          final done = i < currentIndex;
                          final active = i == currentIndex;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  done
                                      ? Icons.check_circle_rounded
                                      : active
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                  size: 18,
                                  color: done
                                      ? IdeafiiColors.accentA
                                      : active
                                          ? IdeafiiColors.accentB
                                          : IdeafiiColors.subtext,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      color: done
                                          ? IdeafiiColors.text
                                          : IdeafiiColors.subtext,
                                      fontWeight: active
                                          ? FontWeight.w900
                                          : FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 6),
                      const Text(
                        'You don’t need everything figured out — just a starting plan.',
                        style: TextStyle(
                          color: IdeafiiColors.subtext,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
