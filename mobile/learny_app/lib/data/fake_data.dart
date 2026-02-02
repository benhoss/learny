import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/child_profile.dart';
import '../models/daily_learning_time.dart';
import '../models/document_item.dart';
import '../models/faq_item.dart';
import '../models/learning_pack.dart';
import '../models/notification_item.dart';
import '../models/parent_profile.dart';
import '../models/plan_option.dart';
import '../models/quiz_question.dart';
import '../models/revision_prompt.dart';
import '../models/user_profile.dart';
import '../models/weak_area.dart';
import '../models/weekly_summary.dart';
import '../theme/app_assets.dart';
import '../theme/app_theme.dart';

const fakeUserProfile = UserProfile(
  id: 'child-1',
  name: 'Sarah',
  avatarAsset: AppImages.foxMascot,
  gradeLabel: 'Grade 6',
  planName: 'Learny Plus',
);

const fakeParentProfile = ParentProfile(
  name: 'Benoit Hossay',
  email: 'parent@example.com',
);

const fakePlanOptions = [
  PlanOption(
    id: 'pro',
    name: 'Pro',
    priceLabel: '\$9.99 / month',
    description: 'Unlimited packs + game modes',
    isHighlighted: true,
  ),
  PlanOption(
    id: 'family',
    name: 'Family',
    priceLabel: '\$14.99 / month',
    description: 'Up to 4 child profiles',
    isHighlighted: false,
  ),
];

const fakeFaqItems = [
  FaqItem(
    question: 'Is this cheating?',
    answer: 'No. It teaches by practice and feedback.',
  ),
  FaqItem(
    question: 'What ages is Learny for?',
    answer: 'Designed for grades 4–8.',
  ),
  FaqItem(
    question: 'Is there a free plan?',
    answer: 'Yes. Start for free and upgrade anytime.',
  ),
];

const fakeSupportTopics = [
  'Billing',
  'Account access',
  'Homework upload',
  'Gameplay issue',
];

const fakeChildren = [
  ChildProfile(id: 'child-1', name: 'Sarah', gradeLabel: 'Grade 6'),
  ChildProfile(id: 'child-2', name: 'Leo', gradeLabel: 'Grade 4'),
];

const fakeWeeklySummary = WeeklySummary(
  minutesSpent: 80,
  newBadges: 2,
  sessionsCompleted: 6,
  topSubject: 'Math',
);

const fakeWeakAreas = [
  WeakArea(title: 'Mixed numbers', note: 'Practice suggested'),
  WeakArea(title: 'Word problems', note: 'Needs reinforcement'),
  WeakArea(title: 'Decimals', note: 'Keep reviewing'),
];

const fakeLearningTimes = [
  DailyLearningTime(dayLabel: 'Mon', minutes: 15),
  DailyLearningTime(dayLabel: 'Tue', minutes: 10),
  DailyLearningTime(dayLabel: 'Wed', minutes: 20),
  DailyLearningTime(dayLabel: 'Thu', minutes: 8),
  DailyLearningTime(dayLabel: 'Fri', minutes: 12),
];

const fakePacks = [
  LearningPack(
    id: 'pack-math',
    title: 'Fractions Review',
    subject: 'Math',
    itemCount: 18,
    minutes: 12,
    icon: Icons.calculate_rounded,
    color: LearnyColors.coral,
    progress: 0.55,
  ),
  LearningPack(
    id: 'pack-science',
    title: 'Science: Cells & Systems',
    subject: 'Science',
    itemCount: 14,
    minutes: 10,
    icon: Icons.science_rounded,
    color: LearnyColors.teal,
    progress: 0.3,
  ),
  LearningPack(
    id: 'pack-geo',
    title: 'Geography Basics',
    subject: 'Geography',
    itemCount: 16,
    minutes: 11,
    icon: Icons.public_rounded,
    color: LearnyColors.purple,
    progress: 0.7,
  ),
];

final fakeQuestionsByPack = <String, List<QuizQuestion>>{
  'pack-math': const [
    QuizQuestion(
      id: 'math-1',
      prompt: 'What is 1/2 + 1/4?',
      options: ['1/6', '2/6', '3/4', '1/4'],
      correctIndex: 2,
      hint: 'Find a common denominator of 4.',
    ),
    QuizQuestion(
      id: 'math-2',
      prompt: 'Which fraction is equivalent to 0.25?',
      options: ['1/2', '1/3', '1/4', '2/3'],
      correctIndex: 2,
    ),
    QuizQuestion(
      id: 'math-3',
      prompt: 'Simplify 6/12.',
      options: ['1/3', '1/2', '2/3', '3/4'],
      correctIndex: 1,
      hint: 'Divide numerator and denominator by the same number.',
    ),
  ],
  'pack-science': const [
    QuizQuestion(
      id: 'sci-1',
      prompt: 'What part of the cell controls activities?',
      options: ['Nucleus', 'Cell wall', 'Chloroplast', 'Membrane'],
      correctIndex: 0,
      hint: 'Think of the cell\'s control center.',
    ),
    QuizQuestion(
      id: 'sci-2',
      prompt: 'Which organ system helps you breathe?',
      options: ['Digestive', 'Respiratory', 'Circulatory', 'Skeletal'],
      correctIndex: 1,
    ),
  ],
  'pack-geo': const [
    QuizQuestion(
      id: 'geo-1',
      prompt: 'What is the capital of France?',
      options: ['Paris', 'London', 'Berlin', 'Madrid'],
      correctIndex: 0,
      hint: 'It is called the City of Light.',
    ),
    QuizQuestion(
      id: 'geo-2',
      prompt: 'Which ocean is the largest?',
      options: ['Atlantic', 'Indian', 'Pacific', 'Arctic'],
      correctIndex: 2,
    ),
  ],
};

final fakeRevisionPromptsByPack = <String, List<RevisionPrompt>>{
  'pack-math': const [
    RevisionPrompt(
      id: 'rev-math-1',
      prompt: 'Which fraction is greater?',
      options: ['1/4', '3/4', '2/5', '1/3'],
      correctIndex: 1,
    ),
    RevisionPrompt(
      id: 'rev-math-2',
      prompt: 'Simplify 8/12',
      options: ['2/3', '3/4', '1/2', '4/5'],
      correctIndex: 0,
    ),
    RevisionPrompt(
      id: 'rev-math-3',
      prompt: '0.5 equals which fraction?',
      options: ['1/4', '1/2', '2/5', '3/5'],
      correctIndex: 1,
    ),
  ],
  'pack-science': const [
    RevisionPrompt(
      id: 'rev-sci-1',
      prompt: 'Cells get energy from which organelle?',
      options: ['Mitochondria', 'Nucleus', 'Cell wall', 'Chloroplast'],
      correctIndex: 0,
    ),
    RevisionPrompt(
      id: 'rev-sci-2',
      prompt: 'Which system carries oxygen?',
      options: ['Circulatory', 'Digestive', 'Skeletal', 'Nervous'],
      correctIndex: 0,
    ),
  ],
  'pack-geo': const [
    RevisionPrompt(
      id: 'rev-geo-1',
      prompt: 'Which continent is Australia in?',
      options: ['Africa', 'Europe', 'Australia', 'Asia'],
      correctIndex: 2,
    ),
    RevisionPrompt(
      id: 'rev-geo-2',
      prompt: 'Largest ocean?',
      options: ['Pacific', 'Atlantic', 'Indian', 'Arctic'],
      correctIndex: 0,
    ),
  ],
};

const fakeAchievements = [
  Achievement(
    id: 'ach-1',
    title: '7-Day Streak',
    description: 'Practice every day for a week.',
    icon: Icons.local_fire_department_rounded,
    isUnlocked: true,
  ),
  Achievement(
    id: 'ach-2',
    title: 'Quick Thinker',
    description: 'Answer 5 questions in a row correctly.',
    icon: Icons.bolt_rounded,
    isUnlocked: true,
  ),
  Achievement(
    id: 'ach-3',
    title: 'Homework Hero',
    description: 'Upload 3 homework sheets.',
    icon: Icons.camera_alt_rounded,
    isUnlocked: false,
  ),
  Achievement(
    id: 'ach-4',
    title: 'Explorer',
    description: 'Try all three game modes.',
    icon: Icons.explore_rounded,
    isUnlocked: false,
  ),
];

final fakeDocuments = [
  DocumentItem(
    id: 'doc-1',
    title: 'Fractions Worksheet',
    subject: 'Math',
    createdAt: DateTime(2026, 1, 22),
    statusLabel: 'Ready',
  ),
  DocumentItem(
    id: 'doc-2',
    title: 'Plant Cells Notes',
    subject: 'Science',
    createdAt: DateTime(2026, 1, 25),
    statusLabel: 'Processing',
  ),
  DocumentItem(
    id: 'doc-3',
    title: 'Map Skills Practice',
    subject: 'Geography',
    createdAt: DateTime(2026, 1, 27),
    statusLabel: 'Ready',
  ),
];

const fakeNotifications = [
  NotificationItem(
    id: 'note-1',
    title: 'New pack ready',
    message: 'Your Fractions Review pack is ready to play.',
    timeLabel: '2h ago',
    isRead: false,
  ),
  NotificationItem(
    id: 'note-2',
    title: 'Streak boost',
    message: 'Keep your 12-day streak alive with a 5-min quiz.',
    timeLabel: 'Yesterday',
    isRead: true,
  ),
  NotificationItem(
    id: 'note-3',
    title: 'Parent summary sent',
    message: 'Weekly summary shared with parents.',
    timeLabel: '2 days ago',
    isRead: true,
  ),
];

final fakeMastery = <String, double>{
  'Fractions': 0.72,
  'Decimals': 0.48,
  'Cells': 0.61,
  'Geography': 0.8,
};
