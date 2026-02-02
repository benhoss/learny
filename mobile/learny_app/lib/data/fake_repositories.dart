import '../models/achievement.dart';
import '../models/child_profile.dart';
import '../models/daily_learning_time.dart';
import '../models/document_item.dart';
import '../models/learning_pack.dart';
import '../models/notification_item.dart';
import '../models/parent_profile.dart';
import '../models/plan_option.dart';
import '../models/quiz_question.dart';
import '../models/revision_prompt.dart';
import '../models/user_profile.dart';
import '../models/weak_area.dart';
import '../models/weekly_summary.dart';
import '../models/faq_item.dart';
import 'fake_data.dart';
import 'repositories.dart';

class FakeUserRepository implements UserRepository {
  @override
  UserProfile loadProfile() {
    return fakeUserProfile;
  }

  @override
  List<ChildProfile> loadChildren() {
    return fakeChildren;
  }

  @override
  WeeklySummary loadWeeklySummary() {
    return fakeWeeklySummary;
  }

  @override
  List<WeakArea> loadWeakAreas() {
    return fakeWeakAreas;
  }

  @override
  List<DailyLearningTime> loadLearningTimes() {
    return fakeLearningTimes;
  }
}

class FakePacksRepository implements PacksRepository {
  @override
  List<LearningPack> loadPacks() {
    return fakePacks;
  }

  @override
  List<QuizQuestion> loadQuestions(String packId) {
    return fakeQuestionsByPack[packId] ?? const [];
  }

  @override
  List<RevisionPrompt> loadRevisionPrompts(String packId) {
    return fakeRevisionPromptsByPack[packId] ?? const [];
  }
}

class FakeProgressRepository implements ProgressRepository {
  @override
  int loadStreakDays() {
    return 12;
  }

  @override
  int loadXpToday() {
    return 45;
  }

  @override
  int loadTotalXp() {
    return 1280;
  }

  @override
  Map<String, double> loadMastery() {
    return fakeMastery;
  }

  @override
  List<Achievement> loadAchievements() {
    return fakeAchievements;
  }
}

class FakeDocumentsRepository implements DocumentsRepository {
  @override
  List<DocumentItem> loadDocuments() {
    return fakeDocuments;
  }
}

class FakeNotificationsRepository implements NotificationsRepository {
  @override
  List<NotificationItem> loadNotifications() {
    return fakeNotifications;
  }
}

class FakeSupportRepository implements SupportRepository {
  @override
  List<FaqItem> loadFaqs() {
    return fakeFaqItems;
  }

  @override
  List<String> loadSupportTopics() {
    return fakeSupportTopics;
  }
}

class FakeBillingRepository implements BillingRepository {
  @override
  String loadCurrentPlan() {
    return fakeUserProfile.planName;
  }

  @override
  List<PlanOption> loadPlanOptions() {
    return fakePlanOptions;
  }
}

class FakeAccountRepository implements AccountRepository {
  @override
  ParentProfile loadParentProfile() {
    return fakeParentProfile;
  }
}

class FakeRepositories {
  FakeRepositories()
      : user = FakeUserRepository(),
        packs = FakePacksRepository(),
        progress = FakeProgressRepository(),
        documents = FakeDocumentsRepository(),
        notifications = FakeNotificationsRepository(),
        support = FakeSupportRepository(),
        billing = FakeBillingRepository(),
        account = FakeAccountRepository();

  final UserRepository user;
  final PacksRepository packs;
  final ProgressRepository progress;
  final DocumentsRepository documents;
  final NotificationsRepository notifications;
  final SupportRepository support;
  final BillingRepository billing;
  final AccountRepository account;
}
