import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../shared/gradient_scaffold.dart';

class StudentOnboardingScreen extends StatefulWidget {
  const StudentOnboardingScreen({super.key});

  @override
  State<StudentOnboardingScreen> createState() => _StudentOnboardingScreenState();
}

class _StudentOnboardingScreenState extends State<StudentOnboardingScreen> {
  String? _age;
  String? _country;
  String? _grade;
  String? _language = 'en'; // Default
  
  bool _gradeManuallyChanged = false;
  bool _configLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateScope.of(context);
    
    if (!_configLoaded) {
      _configLoaded = true;
      state.fetchOnboardingConfig();
    }

    if (_country == null && state.onboardingDetectedCountry != null) {
      setState(() {
        _country = state.onboardingDetectedCountry;
      });
    }
  }

  void _onAgeChanged(String? newAge) {
    setState(() {
      _age = newAge;
      if (!_gradeManuallyChanged && _country != null && newAge != null) {
        final state = AppStateScope.of(context);
        final suggestion = state.suggestGrade(int.parse(newAge), _country!);
        if (suggestion != null) {
          _grade = suggestion;
        }
      }
    });
  }

  void _onCountryChanged(String? newCountry) {
    setState(() {
      _country = newCountry;
      // Re-evaluate grade suggestion if age is set, or clear grade if invalid
      if (_age != null && newCountry != null) {
        final state = AppStateScope.of(context);
        final suggestion = state.suggestGrade(int.parse(_age!), newCountry);
        if (suggestion != null && !_gradeManuallyChanged) {
          _grade = suggestion;
        } else {
          // If the current grade isn't valid for the new country, clear it
          final grades = state.getAvailableGrades(newCountry);
          if (_grade != null && !grades.contains(_grade)) {
            _grade = null; 
            _gradeManuallyChanged = false; // Reset manual flag if forced to clear
          }
        }
      }
    });
  }

  Future<void> _continue() async {
    if (_age == null || _country == null || _grade == null) return;

    final state = AppStateScope.of(context);
    await state.saveOnboardingStep(
      step: 'child_profile_setup',
      checkpoint: {
        'age': _age,
        'country': _country,
        'grade': _grade,
        'language': _language,
        'market': _country, // Use country as market proxy
      },
      completedStep: 'student_details',
    );

    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.createProfile);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final tokens = context.tokens;
    final l10n = L10n.of(context);
    final canPop = Navigator.of(context).canPop();

    final availableGrades = _country != null 
        ? state.getAvailableGrades(_country!) 
        : <String>[];

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
          title: Text(l10n.createProfileSetupTitle),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(tokens.spaceLg),
            children: [
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell us about you',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: LearnyColors.neutralDark,
                      ),
                    ),
                    SizedBox(height: tokens.spaceXs),
                    Text(
                      'We customize the content based on your school system.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: LearnyColors.neutralMedium,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: tokens.spaceXl),

              // Country
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: DropdownButtonFormField<String>(
                  value: _country,
                  decoration: _inputDecoration(tokens, 'Country', LucideIcons.globe),
                  items: state.onboardingCountries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: _onCountryChanged,
                ),
              ),

              SizedBox(height: tokens.spaceMd),

              // Age
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: DropdownButtonFormField<String>(
                  value: _age,
                  decoration: _inputDecoration(tokens, 'Age', LucideIcons.calendar),
                  items: List.generate(16, (i) => (i + 4).toString())
                      .map((age) => DropdownMenuItem(value: age, child: Text('$age years old')))
                      .toList(),
                  onChanged: _onAgeChanged,
                ),
              ),

              SizedBox(height: tokens.spaceMd),

              // Grade
              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: DropdownButtonFormField<String>(
                  value: _grade,
                  decoration: _inputDecoration(tokens, 'Grade', LucideIcons.graduationCap),
                  items: availableGrades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _grade = value;
                      _gradeManuallyChanged = true;
                    });
                  },
                  hint: Text(_country == null ? 'Select country first' : 'Select grade'),
                ),
              ),

              SizedBox(height: tokens.spaceMd),

              // Language
              FadeInSlide(
                delay: const Duration(milliseconds: 500),
                child: DropdownButtonFormField<String>(
                  value: _language,
                  decoration: _inputDecoration(tokens, 'Language', LucideIcons.languages),
                  items: ['en', 'fr', 'nl']
                      .map((l) => DropdownMenuItem(value: l, child: Text(l.toUpperCase())))
                      .toList(),
                  onChanged: (value) => setState(() => _language = value),
                ),
              ),

              SizedBox(height: tokens.spaceXl),

              // Continue Button
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
                      onTap: (_age != null && _country != null && _grade != null) ? _continue : null,
                      borderRadius: tokens.radiusLg,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                        child: Center(
                          child: Text(
                            'Continue',
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
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(LearnyTokens tokens, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
