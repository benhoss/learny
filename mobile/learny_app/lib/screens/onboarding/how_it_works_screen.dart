import 'dart:ui';

import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../home/home_shell.dart';
import '../shared/placeholder_screen.dart';

class HowItWorksScreen extends StatefulWidget {
  const HowItWorksScreen({super.key});

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  static const _ageBrackets = ['10-11', '12-13', '14+'];
  static const _languages = ['en', 'fr', 'nl'];

  // Map device locales to country codes
  static const _localeToCountry = {
    'en_US': 'US',
    'en_GB': 'GB',
    'fr_FR': 'FR',
    'fr_BE': 'BE',
    'de_DE': 'DE',
    'de_CH': 'CH',
    'de_AT': 'AT',
    'nl_NL': 'NL',
    'nl_BE': 'BE',
    'es_ES': 'ES',
    'it_IT': 'IT',
    'pt_PT': 'PT',
    'pl_PL': 'PL',
    'ja_JP': 'JP',
    'en_CA': 'CA',
    'en_AU': 'AU',
  };

  String _ageBracket = _ageBrackets.first;
  String? _selectedGrade;
  String _language = _languages.first;
  
  String? _detectedCountry;
  List<String> _availableGrades = [];
  bool _countrySupported = false;
  bool _isLoadingGrades = false;
  String? _errorMessage;

  // Default fallback grades (US system)
  static const _defaultGrades = ['5th', '6th', '7th', '8th'];

  @override
  void initState() {
    super.initState();
    _initializeCountryAndGrades();
  }

  String? _getCountryFromDeviceLocale() {
    final locale = PlatformDispatcher.instance.locale;
    final localeString = '${locale.languageCode}_${locale.countryCode}';
    
    // Try exact match first
    if (_localeToCountry.containsKey(localeString)) {
      return _localeToCountry[localeString];
    }
    
    // Try language code only match
    final langCode = locale.languageCode;
    for (final entry in _localeToCountry.entries) {
      if (entry.key.startsWith('${langCode}_')) {
        return entry.value;
      }
    }
    
    return null;
  }

  Future<void> _initializeCountryAndGrades() async {
    final state = AppStateScope.of(context);
    
    // First, try to detect country from device locale
    String? detectedFromLocale = _getCountryFromDeviceLocale();
    
    try {
      // Try backend IP detection as fallback
      final countriesData = await state.backend.listOnboardingCountries();
      final backendDetected = countriesData['detected_country'] as String?;
      
      // Prefer device locale over IP detection (more accurate for mobile)
      _detectedCountry = detectedFromLocale ?? backendDetected;
      
      if (mounted) setState(() {});
      
      // Fetch grade suggestions based on detected country
      await _fetchGradeSuggestions();
    } catch (e) {
      // Fallback to device locale only
      _detectedCountry = detectedFromLocale;
      
      if (_detectedCountry != null) {
        await _fetchGradeSuggestions();
      } else {
        // Use default grades if nothing detected
        _availableGrades = List.from(_defaultGrades);
        _selectedGrade = _defaultGrades[1];
        if (mounted) {
          setState(() {
            _errorMessage = 'Using default grades';
          });
        }
      }
    }
  }

  int _ageFromBracket(String bracket) {
    switch (bracket) {
      case '10-11':
        return 10;
      case '12-13':
        return 12;
      case '14+':
        return 14;
      default:
        return 10;
    }
  }

  Future<void> _fetchGradeSuggestions() async {
    final state = AppStateScope.of(context);
    
    setState(() {
      _isLoadingGrades = true;
      _errorMessage = null;
    });

    try {
      final age = _ageFromBracket(_ageBracket);
      final suggestionsData = await state.backend.getGradeSuggestions(
        country: _detectedCountry,
        age: age,
      );

      final countrySupported = suggestionsData['country_supported'] as bool? ?? false;
      final suggestedGrade = suggestionsData['suggested_grade'] as String?;
      final availableGrades = (suggestionsData['available_grades'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [];

      if (mounted) {
        setState(() {
          _countrySupported = countrySupported;
          _availableGrades = availableGrades.isNotEmpty 
              ? availableGrades 
              : List.from(_defaultGrades);
          _selectedGrade = suggestedGrade ?? 
              (_availableGrades.isNotEmpty ? _availableGrades[0] : null);
          _isLoadingGrades = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableGrades = List.from(_defaultGrades);
          _selectedGrade = _defaultGrades[1];
          _isLoadingGrades = false;
          _errorMessage = 'Could not load grade suggestions';
        });
      }
    }
  }

  Future<void> _onAgeBracketChanged(String? newBracket) async {
    if (newBracket != null && newBracket != _ageBracket) {
      setState(() {
        _ageBracket = newBracket;
      });
      await _fetchGradeSuggestions();
    }
  }

  Future<void> _continueWithDemoQuiz() async {
    final state = AppStateScope.of(context);
    await state.saveOnboardingStep(
      step: 'child_avatar',
      checkpoint: {
        'age_bracket': _ageBracket,
        'grade': _selectedGrade ?? '',
        'language': _language,
        'market': _detectedCountry ?? 'US',
        'country_supported': _countrySupported,
      },
      completedStep: 'child_profile',
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.createProfile);
  }

  Future<void> _startScanNow() async {
    final state = AppStateScope.of(context);
    await state.startScanFirstOnboarding();
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.upload);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final state = AppStateScope.of(context);
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
      child: PlaceholderScreen(
        title: l10n.howItWorksTitle,
        subtitle: l10n.howItWorksSubtitle,
        gradient: LearnyGradients.trust,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
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
        body: Column(
        children: [
          // Country indicator
          if (_detectedCountry != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _countrySupported 
                    ? Colors.green.withValues(alpha: 0.1) 
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _countrySupported ? Icons.check_circle : Icons.info_outline,
                    size: 16,
                    color: _countrySupported ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _countrySupported 
                        ? 'Country detected: $_detectedCountry'
                        : 'Country not recognized - select grade manually',
                    style: TextStyle(
                      fontSize: 12,
                      color: _countrySupported ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          DropdownButtonFormField<String>(
            value: _ageBracket,
            decoration: InputDecoration(labelText: l10n.howItWorksAgeBracketLabel),
            items: _ageBrackets
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: _onAgeBracketChanged,
          ),
          const SizedBox(height: 12),
          _isLoadingGrades
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  decoration: InputDecoration(
                    labelText: l10n.howItWorksGradeLabel,
                    helperText: _countrySupported 
                        ? 'Grade suggested based on your country and age' 
                        : 'Select your grade level',
                  ),
                  items: _availableGrades
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedGrade = value),
                ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _language,
            decoration: InputDecoration(labelText: l10n.howItWorksLanguageLabel),
            items: _languages
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => _language = value ?? _language),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
          const SizedBox(height: 24),
          Center(
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
              child: Text(l10n.howItWorksSkipToHome),
            ),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: _continueWithDemoQuiz,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
        child: const Text('Continue'),
      ),
      secondaryAction: OutlinedButton(
        onPressed: _startScanNow,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
        child: Text(l10n.howItWorksScanNow),
      ),
    ));
  }
}
