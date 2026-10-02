import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.headset_mic_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text('SupportCRM',
                      style: AppTypography.h5.copyWith(color: AppColors.primary)),
                ]),
                const SizedBox(height: 32),
                Text('Create your account',
                    style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('Get started with SupportCRM today',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 28),
                const TextField(decoration: InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded, size: 18))),
                const SizedBox(height: 14),
                const TextField(decoration: InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined, size: 18))),
                const SizedBox(height: 14),
                const TextField(decoration: InputDecoration(labelText: 'Company name', prefixIcon: Icon(Icons.business_outlined, size: 18))),
                const SizedBox(height: 14),
                const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline_rounded, size: 18))),
                const SizedBox(height: 14),
                const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline_rounded, size: 18))),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutes.dashboard),
                    child: const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Already have an account? ',
                      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: Text('Sign in',
                        style: AppTypography.bodySmMedium.copyWith(color: AppColors.primary)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
