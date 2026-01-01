import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home/home_screen.dart';
import '../ideas/history_screen.dart';
import '../ideas/idea_input_screen.dart';
import '../labs/labs_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../plans/plans_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';
import '../ui/ideafii_ui.dart';
import '../../services/entitlements_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  final pages = const [
    HomeScreen(),
    HistoryScreen(),
    LabsScreen(),
    ProfileScreen(),
  ];

  Future<void> _openIdeaInput() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const IdeaInputScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _AppDrawer(
        onSelectIndex: (i) {
          setState(() => index = i);
          Navigator.of(context).pop();
        },
        onOpenPlans: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PlansScreen()),
          );
        },
        onOpenMarketplace: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
          );
        },
      ),
      body: Stack(
        children: [
          pages[index],
          Positioned(
            top: 8,
            left: 8,
            child: SafeArea(
              child: Builder(
                builder: (context) => IconButton(
                  tooltip: 'Menu',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          color: Colors.transparent,
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: IdeafiiColors.glass,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: IdeafiiColors.stroke),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  IdeafiiColors.accentA.withOpacity(0.08),
                  IdeafiiColors.accentB.withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    selected: index == 0,
                    onTap: () => setState(() => index = 0),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.bookmark_border,
                    label: 'Saved',
                    selected: index == 1,
                    onTap: () => setState(() => index = 1),
                  ),
                ),
                Expanded(
                  child: _CreateNavItem(
                    onTap: _openIdeaInput,
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.bolt_outlined,
                    label: 'Labs',
                    selected: index == 2,
                    onTap: () => setState(() => index = 2),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    selected: index == 3,
                    onTap: () => setState(() => index = 3),
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

class _AppDrawer extends StatelessWidget {
  final ValueChanged<int> onSelectIndex;
  final VoidCallback onOpenPlans;
  final VoidCallback onOpenMarketplace;

  const _AppDrawer({
    required this.onSelectIndex,
    required this.onOpenPlans,
    required this.onOpenMarketplace,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> signOut() async {
      await Supabase.instance.client.auth.signOut();
      await EntitlementsService.setTier(PlanTier.free);
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const ListTile(
              title: Text(
                'Ideafii',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () => onSelectIndex(0),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Saved'),
              onTap: () => onSelectIndex(1),
            ),
            ListTile(
              leading: const Icon(Icons.bolt_outlined),
              title: const Text('Labs'),
              onTap: () => onSelectIndex(2),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () => onSelectIndex(3),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.workspace_premium_rounded),
              title: const Text('Plans'),
              onTap: onOpenPlans,
            ),
            ListTile(
              leading: const Icon(Icons.storefront_rounded),
              title: const Text('Marketplace'),
              onTap: onOpenMarketplace,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Sign out'),
              onTap: signOut,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? IdeafiiColors.accentA : IdeafiiColors.subtext;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateNavItem extends StatelessWidget {
  final VoidCallback? onTap;

  const _CreateNavItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.25)),
                gradient: const LinearGradient(
                  colors: [IdeafiiColors.accentA, IdeafiiColors.accentB],
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 2),
            const Text(
              '',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
