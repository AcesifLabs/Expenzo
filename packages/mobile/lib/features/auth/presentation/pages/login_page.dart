import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.getIt<AuthBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  void _onSignInPressed(BuildContext context) {
    context.read<AuthBloc>().add(const SignInWithGoogleRequested());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                if (state is AuthLoading)
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Signing in...'),
                    ],
                  )
                else
                  _buildSignInButton(context),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Spacer(),
        Icon(PiconsRegular.wallet, size: 80, color: AppColors.primary),
        const SizedBox(height: 24),
        Text(
          'Expenzo',
          style: AppTypography.headlineLarge.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          'Track your expenses effortlessly',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _onSignInPressed(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDB4437),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.g_mobiledata, size: 24),
          const SizedBox(width: 12),
          Text(
            'Sign in with Google',
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
