import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/google_logo.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Uses the app-wide AuthBloc so signing in updates every screen.
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is Authenticated,
      listener: (context, _) {
        // Back to the screen that opened sign-in; Home if opened directly.
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  void _onSignInPressed(BuildContext context) {
    context.read<AuthBloc>().add(const SignInWithGoogleRequested());
  }

  /// Google's standard sign-in button: neutral fill, outline, official "G".
  Widget _buildSignInButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF131314) : Colors.white;
    final foreground = isDark
        ? const Color(0xFFE3E3E3)
        : const Color(0xFF1F1F1F);
    final outline = isDark ? const Color(0xFF8E918F) : const Color(0xFF747775);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _onSignInPressed(context),
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: BorderSide(color: outline),
          minimumSize: const Size.fromHeight(AppSpacing.xxl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GoogleLogo(),
            const SizedBox(width: AppSpacing.smd),
            Text(
              t.auth.login.google,
              style: AppTypography.labelLarge.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }

  /// The app logo from `assets/images/logo.png`, or a placeholder mark if
  /// the asset is missing.
  Widget _buildLogo(Color fallbackColor) {
    return Image.asset(
      'assets/images/logo.png',
      width: 96,
      height: 96,
      semanticLabel: t.auth.login.logo,
      errorBuilder: (_, _, _) =>
          Icon(PiconsRegular.wallet, size: 80, color: fallbackColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final palette = context.palette;
    final primaryColor = palette.brand;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(),
                ),
                const Spacer(),
                _buildLogo(primaryColor),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  t.common.appName,
                  style: AppTypography.headlineLarge.copyWith(
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  t.auth.login.pitch,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                const Spacer(),
                if (state is AuthLoading)
                  Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.md),
                      Text(t.auth.login.signingIn),
                    ],
                  )
                else
                  _buildSignInButton(context),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
