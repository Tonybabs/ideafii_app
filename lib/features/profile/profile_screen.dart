import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app_state.dart';
import '../../services/profile_store.dart';
import '../../services/theme_store.dart';
import '../auth/login_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../onboarding/user_profile.dart';
import '../plans/plans_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await ProfileStore.load();
    if (!mounted) return;
    setState(() {
      profile = p;
      loading = false;
    });
  }

  Future<void> _editOnboarding() async {
    await ProfileStore.clear();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  Future<void> _toggleTheme(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    themeModeNotifier.value = mode;
    await ThemeStore.save(mode);
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed out')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = themeModeNotifier.value;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: _ProfileColors.bg,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 4),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _ProfileColors.accentA,
                              _ProfileColors.accentB,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Entrepreneur',
                        style: TextStyle(
                          color: _ProfileColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: _ProfileColors.chipBg,
                        ),
                        child: const Text(
                          'Free Plan',
                          style: TextStyle(
                            color: _ProfileColors.accentA,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _sectionTitle('Preferences'),
                const SizedBox(height: 10),
                _profileTile(
                  icon: Icons.business_center_rounded,
                  label: 'Business Type',
                  value: _labelForIntent(profile?.intent),
                ),
                _profileTile(
                  icon: Icons.schedule_rounded,
                  label: 'Time Commitment',
                  value: _labelForTime(profile?.hoursPerWeek),
                ),
                _profileTile(
                  icon: Icons.attach_money_rounded,
                  label: 'Budget',
                  value: _labelForBudget(profile?.budget),
                ),
                _profileTile(
                  icon: Icons.school_rounded,
                  label: 'Skill Level',
                  value: _labelForSkill(profile?.skillLevel),
                ),

                const SizedBox(height: 18),
                _sectionTitle('Appearance'),
                const SizedBox(height: 10),
                _switchTile(
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark Mode',
                  value: mode == ThemeMode.dark,
                  onChanged: _toggleTheme,
                ),

                const SizedBox(height: 18),
                _sectionTitle('Account'),
                const SizedBox(height: 10),
                _profileTile(
                  icon: Icons.credit_card_rounded,
                  label: 'Upgrade to Premium',
                  value: '',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PlansScreen()),
                    );
                  },
                ),
                _profileTile(
                  icon: Icons.help_center_rounded,
                  label: 'Help & Support',
                  value: '',
                  onTap: () => _showHelpSupport(context),
                ),
                _profileTile(
                  icon: Icons.info_rounded,
                  label: 'About Ideafii',
                  value: '',
                  onTap: () => _showAbout(context),
                ),

                const SizedBox(height: 18),
                _dangerButton(
                  label: 'Reset Onboarding',
                  onTap: _editOnboarding,
                ),

                if (user == null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Sign in'),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  _dangerButton(
                    label: 'Sign out',
                    onTap: _signOut,
                  ),
                ],
              ],
            ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _ProfileColors.text,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _ProfileColors.card,
        border: Border.all(color: _ProfileColors.stroke),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            _IconBadge(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _ProfileColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(
                  color: _ProfileColors.subtext,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                color: _ProfileColors.subtext),
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _ProfileColors.card,
        border: Border.all(color: _ProfileColors.stroke),
      ),
      child: Row(
        children: [
          _IconBadge(icon: icon, isAccent: true),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _ProfileColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _ProfileColors.accentA,
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _dangerButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.restart_alt_rounded),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: _ProfileColors.danger,
          side: BorderSide(color: _ProfileColors.danger.withOpacity(0.5)),
          backgroundColor: _ProfileColors.dangerBg,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _InfoSheet(
          title: 'Help & Support',
          body: const [
            'Need help getting started? Try a Daily Spark or build from a saved idea.',
            'Having issues with sign-in or blueprints? Restart the app and try again.',
            'Contact support at support@ideafii.com (response within 24–48 hours).',
            'Follow updates and tips on our socials soon.',
          ],
        );
      },
    );
  }

  void _showAbout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _InfoSheet(
          title: 'About Ideafii',
          body: const [
            'Ideafii helps you turn raw ideas into practical startup blueprints.',
            'We focus on clarity: what to build, who it’s for, and how to launch.',
            'Built for solo founders and builders who want fast momentum.',
            'Version 1.0 (Beta).',
          ],
        );
      },
    );
  }


  String _labelForIntent(String? intent) {
    switch (intent) {
      case 'side_hustle':
        return 'Side Hustle';
      case 'full_business':
        return 'Full Business';
      case 'validate':
        return 'Validate';
      case 'explore':
      default:
        return 'Explore';
    }
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
        return '—';
    }
  }

  String _labelForSkill(String? skill) {
    switch (skill) {
      case 'no_code':
        return 'Beginner';
      case 'some_tech':
        return 'Intermediate';
      case 'developer':
        return 'Advanced';
      default:
        return '—';
    }
  }

  String _labelForTime(int? hours) {
    if (hours == null || hours == 0) return '—';
    if (hours <= 5) return '1-5 hrs/week';
    if (hours <= 15) return '10 hrs/week';
    return '20+ hrs/week';
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final bool isAccent;

  const _IconBadge({required this.icon, this.isAccent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isAccent ? _ProfileColors.iconBgAlt : _ProfileColors.iconBg,
      ),
      child: Icon(
        icon,
        color: isAccent ? _ProfileColors.accentB : _ProfileColors.accentA,
        size: 20,
      ),
    );
  }
}

class _ProfileColors {
  static const bg = Color(0xFF0A0C12);
  static const card = Color(0x18131722);
  static const stroke = Color(0x22FFFFFF);
  static const text = Color(0xFFEAF0FF);
  static const subtext = Color(0xB3EAF0FF);
  static const accentA = Color(0xFF58F3C2);
  static const accentB = Color(0xFF8A5CFF);
  static const chipBg = Color(0x1A1C2633);
  static const iconBg = Color(0x1C1F2A);
  static const iconBgAlt = Color(0x241B1230);
  static const avatarA = Color(0xFF3CCBCB);
  static const avatarB = Color(0xFF7B5CFF);
  static const danger = Color(0xFFFF4D4D);
  static const dangerBg = Color(0x220F0A0A);
}

class _InfoSheet extends StatelessWidget {
  final String title;
  final List<String> body;

  const _InfoSheet({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: _ProfileColors.card,
          padding: const EdgeInsets.all(18),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ProfileColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ...body.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      line,
                      style: const TextStyle(
                        color: _ProfileColors.subtext,
                        height: 1.35,
                      ),
                    ),
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
