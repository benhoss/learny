import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/documents/camera_capture_screen.dart';
import '../screens/documents/library_screen.dart';
import '../screens/documents/processing_screen.dart';
import '../screens/documents/review_screen.dart';
import '../screens/documents/upload_screen.dart';
import '../screens/games/flashcards_screen.dart';
import '../screens/games/matching_screen.dart';
import '../screens/games/quiz_screen.dart';
import '../screens/games/results_screen.dart';
import '../screens/home/home_shell.dart';
import '../screens/home/notifications_screen.dart';
import '../screens/onboarding/consent_screen.dart';
import '../screens/onboarding/create_profile_screen.dart';
import '../screens/onboarding/how_it_works_screen.dart';
import '../screens/onboarding/plan_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/packs/pack_detail_screen.dart';
import '../screens/packs/pack_session_screen.dart';
import '../screens/packs/packs_list_screen.dart';
import '../screens/parent/child_selector_screen.dart';
import '../screens/parent/learning_time_screen.dart';
import '../screens/parent/parent_dashboard_screen.dart';
import '../screens/parent/parent_pin_screen.dart';
import '../screens/parent/parent_settings_screen.dart';
import '../screens/parent/weak_areas_screen.dart';
import '../screens/parent/weekly_summary_screen.dart';
import '../screens/progress/achievements_screen.dart';
import '../screens/progress/mastery_detail_screen.dart';
import '../screens/progress/progress_overview_screen.dart';
import '../screens/progress/streaks_rewards_screen.dart';
import '../screens/revision/revision_results_screen.dart';
import '../screens/revision/revision_session_screen.dart';
import '../screens/revision/revision_setup_screen.dart';
import '../screens/support/contact_support_screen.dart';
import '../screens/support/faq_screen.dart';
import '../screens/support/safety_privacy_screen.dart';
import '../screens/account/account_settings_screen.dart';
import '../screens/account/delete_account_screen.dart';
import '../screens/account/subscription_screen.dart';
import '../screens/account/upgrade_plan_screen.dart';
import '../screens/system/empty_state_screen.dart';
import '../screens/system/error_state_screen.dart';
import '../screens/system/offline_screen.dart';
import '../app/backend_config.dart';
import '../state/app_state.dart';
import '../state/app_state_scope.dart';

class LearnyApp extends StatelessWidget {
  const LearnyApp({super.key});

  static const List<String> _onboardingRoutes = [
    AppRoutes.welcome,
    AppRoutes.howItWorks,
    AppRoutes.createProfile,
    AppRoutes.consent,
    AppRoutes.plan,
    AppRoutes.signup,
    AppRoutes.login,
    AppRoutes.forgotPassword,
    AppRoutes.verifyEmail,
  ];

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: AppState(),
      child: Builder(
        builder: (context) {
          final state = AppStateScope.of(context);
          return MaterialApp(
        title: 'Learny',
        theme: LearnyTheme.light(),
        locale: state.locale,
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        initialRoute: BackendConfig.disableOnboarding ? AppRoutes.home : AppRoutes.welcome,
        onGenerateRoute: (settings) {
          if (BackendConfig.disableOnboarding &&
              _onboardingRoutes.contains(settings.name)) {
            return MaterialPageRoute(
              settings: const RouteSettings(name: AppRoutes.home),
              builder: (_) => const HomeShell(),
            );
          }
          return null;
        },
        routes: {
          AppRoutes.welcome: (_) => const WelcomeScreen(),
          AppRoutes.howItWorks: (_) => const HowItWorksScreen(),
          AppRoutes.createProfile: (_) => const CreateProfileScreen(),
          AppRoutes.consent: (_) => const ConsentScreen(),
          AppRoutes.plan: (_) => const PlanScreen(),
          AppRoutes.signup: (_) => const SignupScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
          AppRoutes.verifyEmail: (_) => const VerifyEmailScreen(),
          AppRoutes.home: (_) => const HomeShell(),
          AppRoutes.notifications: (_) => const NotificationsScreen(),
          AppRoutes.cameraCapture: (_) => const CameraCaptureScreen(),
          AppRoutes.upload: (_) => const UploadScreen(),
          AppRoutes.review: (_) => const ReviewScreen(),
          AppRoutes.processing: (_) => const ProcessingScreen(),
          AppRoutes.library: (_) => const LibraryScreen(),
          AppRoutes.packsList: (_) => const PacksListScreen(),
          AppRoutes.packDetail: (_) => const PackDetailScreen(),
          AppRoutes.packSession: (_) => const PackSessionScreen(),
          AppRoutes.quiz: (_) => const QuizScreen(),
          AppRoutes.flashcards: (_) => const FlashcardsScreen(),
          AppRoutes.matching: (_) => const MatchingScreen(),
          AppRoutes.results: (_) => const ResultsScreen(),
          AppRoutes.revisionSetup: (_) => const RevisionSetupScreen(),
          AppRoutes.revisionSession: (_) => const RevisionSessionScreen(),
          AppRoutes.revisionResults: (_) => const RevisionResultsScreen(),
          AppRoutes.progressOverview: (_) => const ProgressOverviewScreen(),
          AppRoutes.masteryDetail: (_) => const MasteryDetailScreen(),
          AppRoutes.streaksRewards: (_) => const StreaksRewardsScreen(),
          AppRoutes.achievements: (_) => const AchievementsScreen(),
        AppRoutes.parentDashboard: (_) => const ParentDashboardScreen(),
        AppRoutes.childSelector: (_) => const ChildSelectorScreen(),
        AppRoutes.weeklySummary: (_) => const WeeklySummaryScreen(),
        AppRoutes.weakAreas: (_) => const WeakAreasScreen(),
        AppRoutes.learningTime: (_) => const LearningTimeScreen(),
        AppRoutes.parentPin: (_) => const ParentPinScreen(),
        AppRoutes.parentSettings: (_) => const ParentSettingsScreen(),
          AppRoutes.safetyPrivacy: (_) => const SafetyPrivacyScreen(),
          AppRoutes.faq: (_) => const FaqScreen(),
          AppRoutes.contactSupport: (_) => const ContactSupportScreen(),
          AppRoutes.subscription: (_) => const SubscriptionScreen(),
          AppRoutes.upgradePlan: (_) => const UpgradePlanScreen(),
          AppRoutes.accountSettings: (_) => const AccountSettingsScreen(),
          AppRoutes.deleteAccount: (_) => const DeleteAccountScreen(),
          AppRoutes.emptyState: (_) => const EmptyStateScreen(),
          AppRoutes.errorState: (_) => const ErrorStateScreen(),
          AppRoutes.offline: (_) => const OfflineScreen(),
        },
          );
        },
      ),
    );
  }
}
