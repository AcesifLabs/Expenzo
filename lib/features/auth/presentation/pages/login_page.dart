import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../shared/presentation/widgets/app_icons.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          debugPrint('LoginPage: BlocConsumer state: $state');
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          if (state is Authenticated) {
            debugPrint('LoginPage: Authenticated, user: ${state.user}');
          }
        },
        builder: (context, state) {
          debugPrint('LoginPage: builder state: $state');
          return SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const Icon(
                      LucideIcons.wallet,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Expenzo',
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your expenses effortlessly',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const Spacer(),
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
          );
        },
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        debugPrint('LoginPage: Sign in button pressed');
        context.read<AuthBloc>().add(const SignInWithGoogleRequested());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDB4437),
        foregroundColor: Colors.white,
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
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
