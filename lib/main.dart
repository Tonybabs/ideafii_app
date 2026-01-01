import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'services/supabase_service.dart';
import 'services/profile_store.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/app_shell.dart';
import 'app_state.dart';
import 'services/theme_store.dart';
import 'features/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/entitlements_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();

  // ✅ Load saved theme
  themeModeNotifier.value = await ThemeStore.load();

  runApp(const IdeafiiApp());
}

class IdeafiiApp extends StatelessWidget {
  const IdeafiiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Ideafii',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const _IdeafiiScrollBehavior(),
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          home: StreamBuilder<AuthState>(
            stream: Supabase.instance.client.auth.onAuthStateChange,
            builder: (context, authSnap) {
              final session = authSnap.data?.session ??
                  Supabase.instance.client.auth.currentSession;
              _syncPlanTier(session);
              if (session == null) {
                return const LoginScreen();
              }

              return FutureBuilder(
                future: ProfileStore.load(),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snap.hasData || snap.data == null) {
                    return const OnboardingScreen();
                  }
                  return const AppShell();
                },
              );
            },
          ),
        );
      },
    );
  }
}

void _syncPlanTier(Session? session) {
  if (session == null) {
    EntitlementsService.setTier(PlanTier.free);
    return;
  }

  final rawPlan = session.user.userMetadata?['plan'] ??
      session.user.appMetadata?['plan'] ??
      'free';
  final plan = rawPlan.toString().toLowerCase();
  if (plan == 'premium') {
    EntitlementsService.setTier(PlanTier.premium);
  } else if (plan == 'premium_x') {
    EntitlementsService.setTier(PlanTier.premiumX);
  } else {
    EntitlementsService.setTier(PlanTier.free);
  }
}

class _IdeafiiScrollBehavior extends MaterialScrollBehavior {
  const _IdeafiiScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.unknown,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
