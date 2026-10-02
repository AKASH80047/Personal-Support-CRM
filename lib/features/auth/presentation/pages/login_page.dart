import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _loading = false);
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isMobile ? _buildMobile() : _buildDesktop(),
    );
  }

  Widget _buildDesktop() {
    return Row(
      children: [
        // ─ Left panel ─
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.headset_mic_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text('SupportCRM',
                          style: AppTypography.h4.copyWith(
                              color: Colors.white)),
                    ]),
                    const SizedBox(height: 48),
                    Text(
                      'The support platform\nyour team will love.',
                      style: AppTypography.h2
                          .copyWith(color: Colors.white, height: 1.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Manage tickets, chat with customers,\nand deliver exceptional support—all in one place.',
                      style: AppTypography.bodyMd.copyWith(
                          color: AppColors.neutral400),
                    ),
                    const SizedBox(height: 48),
                    ...[
                      '✅  AI-powered reply suggestions',
                      '✅  Real-time live chat',
                      '✅  SLA management & alerts',
                      '✅  Powerful analytics dashboard',
                    ].map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(f,
                              style: AppTypography.bodySm
                                  .copyWith(color: AppColors.neutral300)),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
        // ─ Right panel (form) ─
        Expanded(
          child: _buildForm(),
        ),
      ],
    );
  }

  Widget _buildMobile() => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: _buildForm(isMobile: true),
      );

  Widget _buildForm({bool isMobile = false}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 0 : 48),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isMobile) ...[
                  Row(children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.headset_mic_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text('SupportCRM',
                        style: AppTypography.h5
                            .copyWith(color: AppColors.primary)),
                  ]),
                  const SizedBox(height: 32),
                ],
                Text('Welcome back',
                    style: AppTypography.h3
                        .copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('Sign in to your workspace',
                    style: AppTypography.bodyMd
                        .copyWith(color: AppColors.textSecondary)),
                // Quick Demo Persona Switcher
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF2563EB)),
                          SizedBox(width: 4),
                          Text(
                            '1-CLICK DEMO PERSONAS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildPersonaChip('Lead Admin', 'akash@personalcrm.io', const Color(0xFF2563EB)),
                          _buildPersonaChip('Tier-2 Tech', 'marcus@personalcrm.io', const Color(0xFF0D9488)),
                          _buildPersonaChip('Billing Agent', 'maya@personalcrm.io', const Color(0xFF8B5CF6)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _label('Email address'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'you@company.com',
                    prefixIcon: Icon(Icons.email_outlined, size: 18),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _label('Password'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.forgotPassword),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4)),
                    child: Text('Forgot password?',
                        style: AppTypography.bodySmMedium
                            .copyWith(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Sign in'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                      child: Divider(color: AppColors.border)),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or',
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.textTertiary)),
                  ),
                  Expanded(
                      child: Divider(color: AppColors.border)),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.g_mobiledata_rounded,
                        size: 22, color: Colors.red),
                    label: const Text('Continue with Google Workspace'),
                    onPressed: () {
                      _emailCtrl.text = 'akash@personalcrm.io';
                      _passwordCtrl.text = 'admin123';
                      _login();
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Don't have an account? ",
                      style: AppTypography.bodySm
                          .copyWith(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.register),
                    child: Text('Sign up',
                        style: AppTypography.bodySmMedium
                            .copyWith(color: AppColors.primary)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonaChip(String label, String email, Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          _emailCtrl.text = email;
          _passwordCtrl.text = 'demo123456';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('👤 Logged in as $label ($email)'),
            backgroundColor: color,
            duration: const Duration(milliseconds: 1000),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: AppTypography.labelLg
          .copyWith(color: AppColors.textPrimary));
}
