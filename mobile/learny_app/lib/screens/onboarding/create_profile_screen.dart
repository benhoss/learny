import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../home/home_shell.dart';
import '../shared/gradient_scaffold.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _nicknameController = TextEditingController(text: 'Alex');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _avatar = 'fox';
  bool _busy = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final l10n = L10n.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final state = AppStateScope.of(context);
    
    // Save avatar/nickname choice to checkpoints
    await state.saveOnboardingStep(
      step: 'child_signup',
      checkpoint: {
        'nickname': nickname,
        'avatar': _avatar,
      },
      completedStep: 'child_profile_setup',
    );

    // Register user and create child profile
    final success = await state.registerStudentForOnboarding(
      name: nickname,
      email: email,
      password: password,
    );

    if (!mounted) return;
    
    if (!success) {
      setState(() {
        _busy = false;
        _error = 'Could not create account. Email might be taken or password too weak.';
      });
      return;
    }

    setState(() => _busy = false);
    
    // Skip dummy quiz (ConsentScreen) and go to Home
    Navigator.pushNamedAndRemoveUntil(
      context, 
      AppRoutes.home, 
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final state = AppStateScope.of(context);
    final tokens = context.tokens;
    final canPop = Navigator.of(context).canPop();
    
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await state.resetOnboarding();
        if (context.mounted) {
          if (canPop) {
            Navigator.of(context).pop();
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.welcome);
          }
        }
      },
      child: GradientScaffold(
        gradient: LearnyGradients.hero,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () async {
              await state.resetOnboarding();
              if (!context.mounted) return;
              if (canPop) {
                Navigator.of(context).pop();
              } else {
                Navigator.pushReplacementNamed(context, AppRoutes.welcome);
              }
            },
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
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: LearnyColors.neutralDark,
                      ),
                    ),
                    SizedBox(height: tokens.spaceXs),
                    Text(
                      'Save your progress and access your study plans from anywhere.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: LearnyColors.neutralMedium,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: tokens.spaceXl),
              
              // Avatar Selection
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  l10n.createProfileAvatarLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: LearnyColors.neutralDark,
                  ),
                ),
              ),
              
              SizedBox(height: tokens.spaceMd),
              
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AvatarOption(
                      selected: _avatar == 'fox',
                      onTap: () => setState(() => _avatar = 'fox'),
                      image: AppImages.foxMascot,
                      label: l10n.createProfileAvatarFox,
                      color: LearnyColors.coral,
                    ),
                    _AvatarOption(
                      selected: _avatar == 'buddy',
                      onTap: () => setState(() => _avatar = 'buddy'),
                      image: AppImages.foxStudying,
                      label: l10n.createProfileAvatarFoxBuddy,
                      color: LearnyColors.mintPrimary,
                    ),
                    _AvatarOption(
                      selected: _avatar == 'robot',
                      onTap: () => setState(() => _avatar = 'robot'),
                      icon: LucideIcons.bot,
                      label: l10n.createProfileAvatarRobot,
                      color: LearnyColors.lavender,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: tokens.spaceXl),
              
              // Nickname Input
              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: TextField(
                  controller: _nicknameController,
                  decoration: _inputDecoration(
                    tokens,
                    l10n.createProfileNicknameLabel,
                    l10n.createProfileNicknameHint,
                    LucideIcons.user,
                  ),
                ),
              ),
              
              SizedBox(height: tokens.spaceMd),
              
              // Email Input
              FadeInSlide(
                delay: const Duration(milliseconds: 450),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    tokens,
                    'Email',
                    'your@email.com',
                    LucideIcons.mail,
                  ),
                ),
              ),
              
              SizedBox(height: tokens.spaceMd),
              
              // Password Input
              FadeInSlide(
                delay: const Duration(milliseconds: 500),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration(
                    tokens,
                    'Password',
                    'Min. 8 characters',
                    LucideIcons.lock,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                        color: LearnyColors.neutralLight,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
              ),
              
              if (_error != null) ...[
                SizedBox(height: tokens.spaceSm),
                FadeInSlide(
                  delay: const Duration(milliseconds: 550),
                  child: Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              
              SizedBox(height: tokens.spaceXl),
              
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
                      onTap: _busy ? null : _continue,
                      borderRadius: tokens.radiusLg,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                        child: Center(
                          child: _busy
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Create Account',
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
              
              // Skip Link
              FadeInSlide(
                delay: const Duration(milliseconds: 700),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const HomeShell(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(-1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                        (route) => false,
                      );
                    },
                    child: Text(
                      l10n.createProfileSkipToHome,
                      style: TextStyle(
                        color: LearnyColors.neutralMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(LearnyTokens tokens, String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: LearnyColors.neutralLight, size: 20),
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
    );
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.selected,
    required this.onTap,
    required this.label,
    required this.color,
    this.image,
    this.icon,
  });

  final bool selected;
  final VoidCallback onTap;
  final String label;
  final Color color;
  final String? image;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return InkWell(
      onTap: onTap,
      borderRadius: tokens.radiusLg,
      child: AnimatedContainer(
        duration: tokens.baseDuration,
        width: 100,
        padding: EdgeInsets.all(tokens.spaceSm + 4),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: tokens.radiusLg,
          border: Border.all(
            color: selected ? color : LearnyColors.neutralSoft,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: tokens.baseDuration,
              padding: EdgeInsets.all(tokens.spaceSm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: image != null
                  ? Image.asset(image!, width: 40, height: 40, errorBuilder: (_, __, ___) => Icon(icon, color: color, size: 28))
                  : Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : LearnyColors.neutralMedium,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
