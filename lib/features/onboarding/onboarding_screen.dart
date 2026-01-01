import 'package:flutter/material.dart';
import '../../services/profile_store.dart';
import 'user_profile.dart';
import '../shell/app_shell.dart';
import '../ui/ideafii_ui.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;

  String intent = 'explore';
  String skillLevel = 'no_code';
  int hoursPerWeek = 5;
  String budget = '0_100';
  String tone = 'coach';

  Future<void> _finish() async {
    final profile = UserProfile(
      intent: intent,
      skillLevel: skillLevel,
      hoursPerWeek: hoursPerWeek,
      budget: budget,
      tone: tone,
    );

    await ProfileStore.save(profile);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stepTitle = step == 0
        ? 'What are you trying to do?'
        : step == 1
            ? 'How hands-on are you?'
            : 'Time and budget';

    return Scaffold(
      backgroundColor: IdeafiiColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Setup Ideafii'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: isWide ? 620 : double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GradientHeading(
                        title: 'Let’s tailor your ideas',
                        subtitle: 'Set your intent, skill, and budget to match your goals.',
                      ),
                      const SizedBox(height: 18),
                      _StepDots(step: step),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          stepTitle,
                          key: ValueKey(step),
                          style: const TextStyle(
                            color: IdeafiiColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _buildStep(step),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          if (step > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() => step -= 1),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: IdeafiiColors.text,
                                  side: const BorderSide(
                                      color: IdeafiiColors.stroke),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: const Text('Back'),
                              ),
                            ),
                          if (step > 0) const SizedBox(width: 12),
                          Expanded(
                            child: GradientButton(
                              text: step < 2 ? 'Next' : 'Finish',
                              onTap: () {
                                if (step < 2) {
                                  setState(() => step += 1);
                                } else {
                                  _finish();
                                }
                              },
                            ),
                          ),
                        ],
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

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return Column(
          key: const ValueKey('step-0'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _choice('Start a side hustle', intent == 'side_hustle',
                () => setState(() => intent = 'side_hustle')),
            _choice('Build a full business', intent == 'full_business',
                () => setState(() => intent = 'full_business')),
            _choice('Just explore ideas', intent == 'explore',
                () => setState(() => intent = 'explore')),
            _choice('Validate an idea I already have', intent == 'validate',
                () => setState(() => intent = 'validate')),
          ],
        );
      case 1:
        return Column(
          key: const ValueKey('step-1'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _choice('Non-technical (no-code only)', skillLevel == 'no_code',
                () => setState(() => skillLevel = 'no_code')),
            _choice('Some technical skills', skillLevel == 'some_tech',
                () => setState(() => skillLevel = 'some_tech')),
            _choice('Developer / builder', skillLevel == 'developer',
                () => setState(() => skillLevel = 'developer')),
            const SizedBox(height: 16),
            const Text(
              'Tone',
              style: TextStyle(
                color: IdeafiiColors.subtext,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _choice('Straight to the point', tone == 'direct',
                () => setState(() => tone = 'direct')),
            _choice('Step-by-step coach', tone == 'coach',
                () => setState(() => tone = 'coach')),
            _choice('Motivational + practical', tone == 'motivational',
                () => setState(() => tone = 'motivational')),
          ],
        );
      default:
        return Column(
          key: const ValueKey('step-2'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hours per week',
              style: TextStyle(
                color: IdeafiiColors.subtext,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: IdeafiiColors.accentA,
                inactiveTrackColor: IdeafiiColors.stroke,
                thumbColor: IdeafiiColors.accentB,
                overlayColor: IdeafiiColors.accentA.withOpacity(0.15),
              ),
              child: Slider(
                value: hoursPerWeek.toDouble(),
                min: 1,
                max: 40,
                divisions: 39,
                label: '$hoursPerWeek hrs/week',
                onChanged: (v) => setState(() => hoursPerWeek = v.round()),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Budget',
              style: TextStyle(
                color: IdeafiiColors.subtext,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _choice('£0–£100', budget == '0_100',
                () => setState(() => budget = '0_100')),
            _choice('£100–£1,000', budget == '100_1000',
                () => setState(() => budget = '100_1000')),
            _choice('£1,000+', budget == '1000_plus',
                () => setState(() => budget = '1000_plus')),
          ],
        );
    }
  }

  Widget _choice(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: PillButton(
          label: label,
          selected: selected,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  final int step;

  const _StepDots({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final active = index == step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          width: active ? 22 : 10,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: active ? IdeafiiColors.accentA : IdeafiiColors.stroke,
          ),
        );
      }),
    );
  }
}
