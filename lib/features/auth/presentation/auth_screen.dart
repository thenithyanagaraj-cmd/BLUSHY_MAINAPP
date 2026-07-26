import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/state.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import 'email_auth_flow.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode? _activeEmailMode;

  @override
  Widget build(BuildContext context) {
    if (_activeEmailMode != null) {
      return EmailAuthFlow(
        initialMode: _activeEmailMode!,
        onBackToWelcome: () {
          setState(() {
            _activeEmailMode = null;
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: BlushyColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: BlushySpacing.lg, vertical: BlushySpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Welcome to Blushy',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: BlushyColors.text,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A space to understand your body, your wellbeing, and yourself.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: BlushyColors.secondaryText,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              _buildAuthButton(
                icon: Icons.g_mobiledata,
                label: 'Continue with Google',
                onPressed: () => _handleThirdPartyLogin(context),
              ),
              const SizedBox(height: 14),
              _buildAuthButton(
                icon: Icons.apple,
                label: 'Continue with Apple',
                onPressed: () => _handleThirdPartyLogin(context),
              ),
              const SizedBox(height: 14),
              _buildAuthButton(
                icon: Icons.email_outlined,
                label: 'Continue with Email',
                onPressed: () {
                  setState(() {
                    _activeEmailMode = AuthMode.signupEmail;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.inter(
                      color: BlushyColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeEmailMode = AuthMode.login;
                      });
                    },
                    child: Text(
                      'Log in',
                      style: GoogleFonts.inter(
                        color: BlushyColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'By continuing, you agree to our Terms and Privacy Policy.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: BlushyColors.secondaryText.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleThirdPartyLogin(BuildContext context) {
    final state = BlushyOSProvider.of(context);
    state.setAuthenticated(true);
  }

  Widget _buildAuthButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: BlushyColors.cardBg,
        foregroundColor: BlushyColors.text,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: BlushyColors.border),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: BlushyColors.text),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

