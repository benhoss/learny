import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../home/home_shell.dart';
import '../shared/gradient_scaffold.dart';

class ParentOnboardingScreen extends StatefulWidget {
  const ParentOnboardingScreen({super.key});

  @override
  State<ParentOnboardingScreen> createState() => _ParentOnboardingScreenState();
}

class _ParentOnboardingScreenState extends State<ParentOnboardingScreen> {
  final _nameController = TextEditingController(text: 'Parent');
  final _emailController = TextEditingController(text: 'parent@example.com');
  final _passwordController = TextEditingController(text: 'secret123');
  final _childNameController = TextEditingController(text: 'Alex');
  final _childGradeController = TextEditingController(text: '6th');

  bool _isLoginMode = true;
  bool _busy = false;
  String? _error;
  String? _selectedChildId;
  String? _latestCode;
  List<Map<String, dynamic>> _devices = const [];
  bool _dailySummary = true;
  bool _contentGuardrails = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _childNameController.dispose();
    _childGradeController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    final state = AppStateScope.of(context);
    final ok = await state.parentAuthenticateForOnboarding(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      loginMode: _isLoginMode,
    );

    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = ok ? null : 'Authentication failed. Check credentials.';
      _selectedChildId ??= state.children.isNotEmpty
          ? state.children.first.id
          : null;
    });
  }

  Future<void> _addChild() async {
    final state = AppStateScope.of(context);
    final created = await state.createChildForOnboarding(
      name: _childNameController.text.trim(),
      gradeLevel: _childGradeController.text.trim(),
      preferredLanguage: 'en',
    );

    if (!mounted) return;
    setState(() {
      _selectedChildId = created?.id ?? _selectedChildId;
      _childNameController.text = 'Child ${state.children.length + 1}';
    });
  }

  Future<void> _generateCode() async {
    if (_selectedChildId == null) return;
    final state = AppStateScope.of(context);
    final code = await state.generateParentLinkCode(_selectedChildId!);
    if (!mounted) return;
    setState(() => _latestCode = code);
  }

  Future<void> _loadDevices() async {
    if (_selectedChildId == null) return;
    final state = AppStateScope.of(context);
    final devices = await state.fetchLinkedDevices(_selectedChildId!);
    if (!mounted) return;
    setState(() => _devices = devices);
  }

  Future<void> _revokeDevice(String deviceId) async {
    if (_selectedChildId == null) return;
    final state = AppStateScope.of(context);
    await state.revokeLinkedDevice(_selectedChildId!, deviceId);
    await _loadDevices();
  }

  Future<void> _complete() async {
    final state = AppStateScope.of(context);
    final ok = await state.completeParentOnboarding(
      controls: {
        'daily_summary': _dailySummary,
        'content_guardrails': _contentGuardrails,
      },
    );
    if (!ok) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not complete onboarding. Please retry.';
      });
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
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
        gradient: LearnyGradients.trust,
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
          title: const Text('Parent Setup'),
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
                      'Parent Setup',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: LearnyColors.neutralDark,
                      ),
                    ),
                    SizedBox(height: tokens.spaceXs),
                    Text(
                      'Create your account, add children, link devices, and set baseline controls.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: LearnyColors.neutralMedium,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: tokens.spaceLg),
              
              // Auth Section
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: _SectionCard(
                  title: 'Account',
                  icon: LucideIcons.user,
                  children: [
                    // Login/Signup Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: LearnyColors.neutralCream,
                        borderRadius: tokens.radiusMd,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TabButton(
                              label: 'Login',
                              isSelected: _isLoginMode,
                              onTap: () => setState(() => _isLoginMode = true),
                            ),
                          ),
                          Expanded(
                            child: _TabButton(
                              label: 'Sign up',
                              isSelected: !_isLoginMode,
                              onTap: () => setState(() => _isLoginMode = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (!_isLoginMode) ...[
                      SizedBox(height: tokens.spaceMd),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full name',
                        icon: LucideIcons.user,
                      ),
                    ],
                    
                    SizedBox(height: tokens.spaceMd),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    
                    SizedBox(height: tokens.spaceMd),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
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
                    ),
                    
                    if (_error != null) ...[
                      SizedBox(height: tokens.spaceSm),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ],
                    
                    SizedBox(height: tokens.spaceMd),
                    _ActionButton(
                      label: _isLoginMode ? 'Login as parent' : 'Create account',
                      icon: _isLoginMode ? LucideIcons.logIn : LucideIcons.userPlus,
                      isLoading: _busy,
                      onPressed: _authenticate,
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: tokens.spaceLg),
              
              // Children Section
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: _SectionCard(
                  title: 'Children (${state.children.length})',
                  icon: LucideIcons.users,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _childNameController,
                            label: 'Child name',
                            icon: LucideIcons.user,
                          ),
                        ),
                        SizedBox(width: tokens.spaceMd),
                        Expanded(
                          child: _buildTextField(
                            controller: _childGradeController,
                            label: 'Grade',
                            icon: LucideIcons.graduationCap,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: tokens.spaceMd),
                    _ActionButton(
                      label: 'Add child profile',
                      icon: LucideIcons.plus,
                      onPressed: _addChild,
                    ),
                    
                    if (state.children.isNotEmpty) ...[
                      SizedBox(height: tokens.spaceMd),
                      DropdownButtonFormField<String>(
                        value: _selectedChildId ?? state.children.first.id,
                        decoration: InputDecoration(
                          labelText: 'Active child',
                          prefixIcon: Icon(LucideIcons.users, color: LearnyColors.neutralLight, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: state.children
                            .map(
                              (child) => DropdownMenuItem(
                                value: child.id,
                                child: Text('${child.name} (${child.gradeLabel})'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _selectedChildId = value),
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: tokens.spaceLg),
              
              // Device Linking Section
              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: _SectionCard(
                  title: 'Device Linking',
                  icon: LucideIcons.smartphone,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Link code',
                            icon: LucideIcons.qrCode,
                            onPressed: _selectedChildId == null ? null : _generateCode,
                          ),
                        ),
                        SizedBox(width: tokens.spaceMd),
                        Expanded(
                          child: _ActionButton(
                            label: 'Refresh',
                            icon: LucideIcons.refreshCw,
                            onPressed: _selectedChildId == null ? null : _loadDevices,
                            isPrimary: false,
                          ),
                        ),
                      ],
                    ),
                    
                    if (_latestCode != null) ...[
                      SizedBox(height: tokens.spaceMd),
                      Container(
                        padding: EdgeInsets.all(tokens.spaceMd),
                        decoration: BoxDecoration(
                          color: LearnyColors.highlight,
                          borderRadius: tokens.radiusMd,
                          border: Border.all(color: LearnyColors.sunshine),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Link Code',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: LearnyColors.neutralMedium,
                              ),
                            ),
                            SizedBox(height: tokens.spaceXs),
                            SelectableText(
                              _latestCode!,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 4,
                                color: LearnyColors.neutralDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    if (_devices.isNotEmpty) ...[
                      SizedBox(height: tokens.spaceMd),
                      ..._devices.map(
                        (device) => Container(
                          margin: EdgeInsets.only(bottom: tokens.spaceSm),
                          padding: EdgeInsets.all(tokens.spaceSm),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: tokens.radiusMd,
                            border: Border.all(color: LearnyColors.neutralSoft),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.smartphone, color: LearnyColors.neutralMedium, size: 20),
                              SizedBox(width: tokens.spaceSm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device['name']?.toString() ?? 'Unknown device',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      device['platform']?.toString() ?? 'unknown',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: LearnyColors.neutralMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _revokeDevice(device['id']?.toString() ?? ''),
                                icon: Icon(LucideIcons.unlink, color: Colors.red, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: tokens.spaceLg),
              
              // Controls Section
              FadeInSlide(
                delay: const Duration(milliseconds: 500),
                child: _SectionCard(
                  title: 'Baseline Controls',
                  icon: LucideIcons.shield,
                  children: [
                    _ControlToggle(
                      title: 'Daily parent summary',
                      subtitle: 'Receive daily updates about your child\'s learning progress',
                      icon: LucideIcons.mail,
                      value: _dailySummary,
                      onChanged: (value) => setState(() => _dailySummary = value),
                    ),
                    Divider(color: LearnyColors.neutralSoft),
                    _ControlToggle(
                      title: 'Content guardrails',
                      subtitle: 'Filter content appropriate for your child\'s age',
                      icon: LucideIcons.eyeOff,
                      value: _contentGuardrails,
                      onChanged: (value) => setState(() => _contentGuardrails = value),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: tokens.spaceLg),
              
              // Error message
              if (state.children.isEmpty)
                FadeInSlide(
                  delay: const Duration(milliseconds: 600),
                  child: Container(
                    padding: EdgeInsets.all(tokens.spaceMd),
                    decoration: BoxDecoration(
                      color: LearnyColors.coral.withValues(alpha: 0.1),
                      borderRadius: tokens.radiusMd,
                      border: Border.all(color: LearnyColors.coral.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.alertCircle, color: LearnyColors.coral, size: 20),
                        SizedBox(width: tokens.spaceSm),
                        Text(
                          'Add at least one child profile to continue.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: LearnyColors.coral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              SizedBox(height: tokens.spaceLg),
              
              // Primary CTA
              FadeInSlide(
                delay: const Duration(milliseconds: 700),
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
                      onTap: state.children.length < 1 ? null : _complete,
                      borderRadius: tokens.radiusLg,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                        child: Center(
                          child: Text(
                            'Complete parent onboarding',
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
              
              SizedBox(height: tokens.spaceMd),
              
              // Skip Link
              FadeInSlide(
                delay: const Duration(milliseconds: 800),
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
                      'Skip for now and go to Home',
                      style: TextStyle(
                        color: LearnyColors.neutralMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: tokens.spaceLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: LearnyColors.neutralLight, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LearnyColors.neutralSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LearnyColors.neutralSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LearnyColors.skyPrimary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return Container(
      padding: EdgeInsets.all(tokens.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: tokens.radiusLg,
        border: Border.all(color: LearnyColors.neutralSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(tokens.spaceSm),
                decoration: BoxDecoration(
                  color: LearnyColors.skyPrimary.withValues(alpha: 0.1),
                  borderRadius: tokens.radiusMd,
                ),
                child: Icon(icon, color: LearnyColors.skyPrimary, size: 20),
              ),
              SizedBox(width: tokens.spaceSm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LearnyColors.neutralDark,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceMd),
          ...children,
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? LearnyColors.skyPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : LearnyColors.neutralMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          gradient: LearnyGradients.cta,
          borderRadius: tokens.radiusMd,
          boxShadow: [
            BoxShadow(
              color: LearnyColors.skyPrimary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: tokens.radiusMd,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spaceSm + 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    Icon(icon, color: Colors.white, size: 18),
                  SizedBox(width: tokens.spaceSm),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: tokens.spaceSm + 2),
        side: BorderSide(color: LearnyColors.neutralSoft, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radiusMd,
        ),
      ),
    );
  }
}

class _ControlToggle extends StatelessWidget {
  const _ControlToggle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.spaceSm),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(tokens.spaceSm),
              decoration: BoxDecoration(
                color: value 
                    ? LearnyColors.mintPrimary.withValues(alpha: 0.15)
                    : LearnyColors.neutralCream,
                borderRadius: tokens.radiusMd,
              ),
              child: Icon(
                icon,
                color: value ? LearnyColors.mintPrimary : LearnyColors.neutralMedium,
                size: 20,
              ),
            ),
            SizedBox(width: tokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LearnyColors.neutralDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: LearnyColors.neutralMedium,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: LearnyColors.mintPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
