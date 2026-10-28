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
import 'package:expense_tracker/shared/presentation/widgets/offline_gate.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _onAuthenticated(BuildContext context, AuthState _) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is Authenticated,
      listener: _onAuthenticated,
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  void _onSignInPressed(BuildContext context) {
    context.read<AuthBloc>().add(const SignInWithGoogleRequested());
  }

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
            Flexible(
              child: Text(
                t.auth.login.google,
                textAlign: TextAlign.center,
                style: AppTypography.labelLarge.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
    final strings = t.auth.login;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - AppSpacing.lg * 2,
              ),
              child: IntrinsicHeight(
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
                      strings.pitch,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    OfflineGate(
                      child: Column(
                        children: [
                          if (state is AuthLoading)
                            Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: AppSpacing.md),
                                Text(strings.signingIn),
                              ],
                            )
                          else
                            _buildSignInButton(context),
                          if (state is AuthError) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium.copyWith(
                                color: palette.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
