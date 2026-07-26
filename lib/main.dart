import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'features/home/blushy_shell.dart';
import 'core/state.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/auth/presentation/onboarding_wizard.dart';
import 'features/auth/presentation/partner_onboarding_wizard.dart';
import 'features/auth/presentation/choose_experience_screen.dart';
import 'features/dev/developer_playground.dart';

void main() {
  runApp(const BlushyApp());
}

class BlushyApp extends StatelessWidget {
  const BlushyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlushyOSProvider(
      notifier: BlushyOSState(),
      child: MaterialApp(
        title: 'blushy.life',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: BlushyColors.background,
          useMaterial3: true,
        ),
        home: const AppRouter(),
        routes: {
          '/dev': (context) => const DeveloperPlaygroundScreen(),
          '/onboarding/choose': (context) => ChooseExperienceScreen(
                onSelectForMe: () {
                  Navigator.of(context).pushReplacementNamed('/onboarding/women');
                },
                onSelectPartner: () {
                  Navigator.of(context).pushReplacementNamed('/onboarding/partner');
                },
              ),
          '/onboarding/women': (context) => const OnboardingWizard(),
          '/onboarding/partner': (context) => const PartnerOnboardingWizard(),
          '/home': (context) => const BlushyOSShell(),
        },
      ),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final state = BlushyOSProvider.of(context);
    if (!state.isAuthenticated) {
      return const AuthScreen();
    }
    if (!state.onboardingCompleted) {
      return ChooseExperienceScreen(
        onSelectForMe: () {
          Navigator.of(context).pushReplacementNamed('/onboarding/women');
        },
        onSelectPartner: () {
          Navigator.of(context).pushReplacementNamed('/onboarding/partner');
        },
      );
    }
    return const BlushyOSShell();
  }
}

