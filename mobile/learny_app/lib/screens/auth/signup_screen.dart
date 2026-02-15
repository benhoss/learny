import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../shared/gradient_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final tokens = context.tokens;

    return GradientScaffold(
      gradient: LearnyGradients.hero,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(tokens.spaceLg),
          children: [
            // Header
            FadeInSlide(
              delay: const Duration(milliseconds: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.signupTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: LearnyColors.neutralDark,
                    ),
                  ),
                  SizedBox(height: tokens.spaceXs),
                  Text(
                    l.signupSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: LearnyColors.neutralMedium,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: tokens.spaceXl),
            
            // Form Fields
            FadeInSlide(
              delay: const Duration(milliseconds: 200),
              child: _buildTextField(
                controller: _nameController,
                label: l.signupFullNameLabel,
                icon: LucideIcons.user,
                textInputAction: TextInputAction.next,
              ),
            ),
            
            SizedBox(height: tokens.spaceMd),
            
            FadeInSlide(
              delay: const Duration(milliseconds: 300),
              child: _buildTextField(
                controller: _emailController,
                label: l.authEmailLabel,
                icon: LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
            ),
            
            SizedBox(height: tokens.spaceMd),
            
            FadeInSlide(
              delay: const Duration(milliseconds: 400),
              child: _buildTextField(
                controller: _passwordController,
                label: l.authPasswordLabel,
                icon: LucideIcons.lock,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: LearnyColors.neutralLight,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                textInputAction: TextInputAction.done,
              ),
            ),
            
            SizedBox(height: tokens.spaceLg),
            
            // Terms Note
            FadeInSlide(
              delay: const Duration(milliseconds: 500),
              child: Text(
                'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: LearnyColors.neutralMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: tokens.spaceLg),
            
            // Primary CTA
            FadeInSlide(
              delay: const Duration(milliseconds: 600),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LearnyGradients.cta,
                  borderRadius: tokens.radiusLg,
                  boxShadow: [
                    BoxShadow(
                      color: LearnyColors.skyPrimary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.verifyEmail),
                    borderRadius: tokens.radiusLg,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                      child: Center(
                        child: Text(
                          l.signupCreateAccount,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: tokens.spaceLg),
            
            // Divider
            FadeInSlide(
              delay: const Duration(milliseconds: 700),
              child: Row(
                children: [
                  Expanded(child: Divider(color: LearnyColors.neutralSoft)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spaceMd),
                    child: Text(
                      'or',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: LearnyColors.neutralLight,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: LearnyColors.neutralSoft)),
                ],
              ),
            ),
            
            SizedBox(height: tokens.spaceLg),
            
            // Social Login Buttons (placeholder)
            FadeInSlide(
              delay: const Duration(milliseconds: 800),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.mail, size: 20),
                      label: const Text('Google'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                        side: BorderSide(color: LearnyColors.neutralSoft, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: tokens.radiusLg,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: tokens.spaceMd),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.apple, size: 20),
                      label: const Text('Apple'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                        side: BorderSide(color: LearnyColors.neutralSoft, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: tokens.radiusLg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: tokens.spaceXl),
            
            // Login Link
            FadeInSlide(
              delay: const Duration(milliseconds: 900),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l.signupLoginPrompt.split(' ').first + ' ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: LearnyColors.neutralMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                    child: Text(
                      l.signupLoginPrompt.split(' ').last,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: LearnyColors.skyPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: LearnyColors.neutralLight, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: LearnyColors.neutralSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: LearnyColors.neutralSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: LearnyColors.skyPrimary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
