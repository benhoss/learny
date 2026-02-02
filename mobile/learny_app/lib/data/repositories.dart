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

abstract class UserRepository {
  UserProfile loadProfile();
  List<ChildProfile> loadChildren();
  WeeklySummary loadWeeklySummary();
  List<WeakArea> loadWeakAreas();
  List<DailyLearningTime> loadLearningTimes();
}

abstract class PacksRepository {
  List<LearningPack> loadPacks();
  List<QuizQuestion> loadQuestions(String packId);
  List<RevisionPrompt> loadRevisionPrompts(String packId);
}

abstract class ProgressRepository {
  int loadStreakDays();
  int loadXpToday();
  int loadTotalXp();
  Map<String, double> loadMastery();
  List<Achievement> loadAchievements();
}

abstract class DocumentsRepository {
  List<DocumentItem> loadDocuments();
}

abstract class NotificationsRepository {
  List<NotificationItem> loadNotifications();
}

abstract class SupportRepository {
  List<FaqItem> loadFaqs();
  List<String> loadSupportTopics();
}

abstract class BillingRepository {
  String loadCurrentPlan();
  List<PlanOption> loadPlanOptions();
}

abstract class AccountRepository {
  ParentProfile loadParentProfile();
}
