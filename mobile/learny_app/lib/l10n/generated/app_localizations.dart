import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('nl'),
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Learny'**
  String get appTitle;

  /// Greeting on home screen
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get homeGreeting;

  /// Welcome message below greeting
  ///
  /// In en, this message translates to:
  /// **'Ready to learn something new today? Let\'s turn your school lessons into fun games!'**
  String get homeWelcomeMessage;

  /// Start learning card title
  ///
  /// In en, this message translates to:
  /// **'Start Learning'**
  String get homeStartLearningTitle;

  /// Start learning card subtitle
  ///
  /// In en, this message translates to:
  /// **'Upload your lesson and play'**
  String get homeStartLearningSubtitle;

  /// Revision express card title
  ///
  /// In en, this message translates to:
  /// **'Revision Express'**
  String get homeRevisionExpressTitle;

  /// Revision express card subtitle
  ///
  /// In en, this message translates to:
  /// **'Quick 5-minute review'**
  String get homeRevisionExpressSubtitle;

  /// Recommendations section title
  ///
  /// In en, this message translates to:
  /// **'Smart Next Steps'**
  String get homeSmartNextSteps;

  /// Message when no recommendations
  ///
  /// In en, this message translates to:
  /// **'Upload a document to get AI recommendations based on real study data.'**
  String get homeNoRecommendations;

  /// Default recommendation title
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get homeContinueLearning;

  /// Default recommendation subtitle
  ///
  /// In en, this message translates to:
  /// **'Based on your recent activity'**
  String get homeBasedOnActivity;

  /// Recommendation explainability tooltip
  ///
  /// In en, this message translates to:
  /// **'Why this?'**
  String get homeWhyThis;

  /// Weekly progress section title
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get homeThisWeek;

  /// Weekly progress message
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed {sessionsCompleted} learning sessions. Great work!'**
  String homeProgressMessage(int sessionsCompleted);

  /// Review card title with count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 concept to review} other{{count} concepts to review}}'**
  String homeReviewCount(int count);

  /// Review card subtitle
  ///
  /// In en, this message translates to:
  /// **'Review now to keep learning!'**
  String get homeReviewSubtitle;

  /// Achievements tab label
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get homeAchievements;

  /// Progress tab label
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get homeProgress;

  /// Pack mastery section title
  ///
  /// In en, this message translates to:
  /// **'Pack Mastery'**
  String get homePackMastery;

  /// Recommendation dialog title
  ///
  /// In en, this message translates to:
  /// **'Why this recommendation?'**
  String get homeWhyRecommendation;

  /// Recommendation dialog default title
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get homeRecommendation;

  /// Fallback explainability text
  ///
  /// In en, this message translates to:
  /// **'No additional rationale available for this suggestion.'**
  String get homeNoExplainability;

  /// Close button in recommendation dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get homeClose;

  /// Feedback when correct answer
  ///
  /// In en, this message translates to:
  /// **'You\'re on a roll!'**
  String get quizCorrectFeedback;

  /// Feedback when incorrect answer
  ///
  /// In en, this message translates to:
  /// **'Review the explanation and keep going.'**
  String get quizIncorrectFeedback;

  /// Empty state when no quiz available
  ///
  /// In en, this message translates to:
  /// **'No generated quiz is ready for this pack yet.'**
  String get quizNoQuizMessage;

  /// Button to upload document from quiz
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get quizUploadDocument;

  /// Text input label for typed answers
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get quizYourAnswer;

  /// Text input hint for typed answers
  ///
  /// In en, this message translates to:
  /// **'Type your answer here...'**
  String get quizTypeAnswerHint;

  /// Multi-select hint
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get quizSelectAllThatApply;

  /// Ordering hint
  ///
  /// In en, this message translates to:
  /// **'Drag items into the correct order'**
  String get quizDragIntoOrder;

  /// Loading state for question
  ///
  /// In en, this message translates to:
  /// **'Loading question...'**
  String get quizLoadingQuestion;

  /// Submit answer button
  ///
  /// In en, this message translates to:
  /// **'Check Answer'**
  String get quizCheckAnswer;

  /// Finish quiz button
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get quizFinish;

  /// Question progress indicator
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizProgress(int current, int total);

  /// Empty progress indicator
  ///
  /// In en, this message translates to:
  /// **'Question 0 / 0'**
  String get quizEmptyProgress;

  /// Button to save in-flight quiz and leave
  ///
  /// In en, this message translates to:
  /// **'Save & Exit'**
  String get quizSaveAndExit;

  /// Title for quiz setup screen
  ///
  /// In en, this message translates to:
  /// **'Build Your Quiz'**
  String get quizSetupTitle;

  /// Subtitle for quiz setup screen
  ///
  /// In en, this message translates to:
  /// **'Choose how many questions you want today.'**
  String get quizSetupSubtitle;

  /// Selected question count label
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String quizSetupCountValue(int count);

  /// Fun line for short quiz length
  ///
  /// In en, this message translates to:
  /// **'Quick sprint mode. Fast focus, big wins.'**
  String get quizSetupFunLineShort;

  /// Fun line for medium quiz length
  ///
  /// In en, this message translates to:
  /// **'Balanced challenge unlocked. You got this.'**
  String get quizSetupFunLineMedium;

  /// Fun line for long quiz length
  ///
  /// In en, this message translates to:
  /// **'Legend mode activated. Deep focus time.'**
  String get quizSetupFunLineLong;

  /// Start button on quiz setup screen
  ///
  /// In en, this message translates to:
  /// **'Start My Quiz'**
  String get quizSetupStartButton;

  /// Hint when a resumable quiz exists
  ///
  /// In en, this message translates to:
  /// **'You have {remaining} questions left in your saved quiz.'**
  String quizSetupResumeHint(int remaining);

  /// Resume quiz button on setup screen
  ///
  /// In en, this message translates to:
  /// **'Resume Saved Quiz'**
  String get quizSetupResumeButton;

  /// True/false game type title
  ///
  /// In en, this message translates to:
  /// **'True or False'**
  String get gameTypeTrueFalse;

  /// Multi-select game type title
  ///
  /// In en, this message translates to:
  /// **'Choose All That Apply'**
  String get gameTypeMultiSelect;

  /// Fill blank game type title
  ///
  /// In en, this message translates to:
  /// **'Fill in the Blank'**
  String get gameTypeFillBlank;

  /// Short answer game type title
  ///
  /// In en, this message translates to:
  /// **'Short Answer'**
  String get gameTypeShortAnswer;

  /// Ordering game type title
  ///
  /// In en, this message translates to:
  /// **'Put in Order'**
  String get gameTypeOrdering;

  /// Matching game type title
  ///
  /// In en, this message translates to:
  /// **'Matching Pairs'**
  String get gameTypeMatching;

  /// Flashcards game type title
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get gameTypeFlashcards;

  /// Quiz game type title
  ///
  /// In en, this message translates to:
  /// **'Quick Quiz'**
  String get gameTypeQuiz;

  /// True/false game type subtitle
  ///
  /// In en, this message translates to:
  /// **'Quick judgments'**
  String get gameSubtitleTrueFalse;

  /// Multi-select subtitle
  ///
  /// In en, this message translates to:
  /// **'Multiple correct answers'**
  String get gameSubtitleMultiSelect;

  /// Fill blank subtitle
  ///
  /// In en, this message translates to:
  /// **'Complete the sentence'**
  String get gameSubtitleFillBlank;

  /// Short answer subtitle
  ///
  /// In en, this message translates to:
  /// **'Write a quick response'**
  String get gameSubtitleShortAnswer;

  /// Ordering subtitle
  ///
  /// In en, this message translates to:
  /// **'Drag items into order'**
  String get gameSubtitleOrdering;

  /// Matching subtitle
  ///
  /// In en, this message translates to:
  /// **'Match linked concepts'**
  String get gameSubtitleMatching;

  /// Flashcards subtitle
  ///
  /// In en, this message translates to:
  /// **'Warm-up concepts'**
  String get gameSubtitleFlashcards;

  /// Quiz subtitle
  ///
  /// In en, this message translates to:
  /// **'Multiple choice questions'**
  String get gameSubtitleQuiz;

  /// True option in true/false games
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get trueFalseTrue;

  /// False option in true/false games
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get trueFalseFalse;

  /// Default flashcards screen title
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcardsDefaultTitle;

  /// Default card front label
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get flashcardsFront;

  /// Default card back label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get flashcardsBack;

  /// Flashcard progress
  ///
  /// In en, this message translates to:
  /// **'Card {current} of {total}'**
  String flashcardsProgress(int current, int total);

  /// Empty flashcard progress
  ///
  /// In en, this message translates to:
  /// **'Card 0 / 0'**
  String get flashcardsEmptyProgress;

  /// Flip card button
  ///
  /// In en, this message translates to:
  /// **'Flip Card'**
  String get flashcardsFlipCard;

  /// Finish button
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get flashcardsFinish;

  /// Next card button
  ///
  /// In en, this message translates to:
  /// **'Got it! Next'**
  String get flashcardsGotItNext;

  /// Question label on card
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get flashcardsQuestion;

  /// Answer label on card
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get flashcardsAnswer;

  /// Flip hint text
  ///
  /// In en, this message translates to:
  /// **'Tap to flip'**
  String get flashcardsTapToFlip;

  /// Default matching screen title
  ///
  /// In en, this message translates to:
  /// **'Matching Game'**
  String get matchingDefaultTitle;

  /// Matching game instruction
  ///
  /// In en, this message translates to:
  /// **'Tap two matching items'**
  String get matchingSubtitle;

  /// Empty state for matching
  ///
  /// In en, this message translates to:
  /// **'No matching pairs available.'**
  String get matchingNoItems;

  /// Matching progress
  ///
  /// In en, this message translates to:
  /// **'{matched} of {total} pairs matched'**
  String matchingProgress(int matched, int total);

  /// Continue button after matching
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get matchingContinue;

  /// Mismatch feedback
  ///
  /// In en, this message translates to:
  /// **'Not quite - try again!'**
  String get matchingMismatch;

  /// Results screen title
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get resultsGreatJob;

  /// Results screen subtitle
  ///
  /// In en, this message translates to:
  /// **'You earned {xp} XP in this round and kept your streak.'**
  String resultsSubtitle(int xp);

  /// Sync error banner
  ///
  /// In en, this message translates to:
  /// **'Progress sync is delayed. We will retry automatically.'**
  String get resultsSyncError;

  /// Finish session button
  ///
  /// In en, this message translates to:
  /// **'Finish Session'**
  String get resultsFinishSession;

  /// Continue to next game button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get resultsContinue;

  /// Review mistakes button
  ///
  /// In en, this message translates to:
  /// **'Review Mistakes'**
  String get resultsReviewMistakes;

  /// See progress button
  ///
  /// In en, this message translates to:
  /// **'See Progress'**
  String get resultsSeeProgress;

  /// Back to home button
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get resultsBackToHome;

  /// Retry mistakes game title
  ///
  /// In en, this message translates to:
  /// **'Retry Mistakes'**
  String get resultsRetryMistakes;

  /// Title when processing is done
  ///
  /// In en, this message translates to:
  /// **'Ready to Learn!'**
  String get processingReadyTitle;

  /// Title during processing
  ///
  /// In en, this message translates to:
  /// **'Creating Your Quiz'**
  String get processingTitle;

  /// Go back button
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get processingGoBack;

  /// Transfer progress label
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get processingTransfer;

  /// AI processing progress label
  ///
  /// In en, this message translates to:
  /// **'AI Processing'**
  String get processingAI;

  /// Success state title
  ///
  /// In en, this message translates to:
  /// **'Your Quiz is Ready!'**
  String get processingSuccessTitle;

  /// Success state message
  ///
  /// In en, this message translates to:
  /// **'Jump in while the material is fresh.'**
  String get processingSuccessMessage;

  /// Success detail message
  ///
  /// In en, this message translates to:
  /// **'Personalized games created from your document'**
  String get processingSuccessDetail;

  /// Error state title
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get processingErrorTitle;

  /// Error hint message
  ///
  /// In en, this message translates to:
  /// **'Try uploading a clearer image or a different document.'**
  String get processingErrorHint;

  /// Start flashcards button
  ///
  /// In en, this message translates to:
  /// **'Start Flashcards'**
  String get processingStartFlashcards;

  /// Start matching button
  ///
  /// In en, this message translates to:
  /// **'Start Matching'**
  String get processingStartMatching;

  /// Start true/false button
  ///
  /// In en, this message translates to:
  /// **'Start True/False'**
  String get processingStartTrueFalse;

  /// Start multi-select button
  ///
  /// In en, this message translates to:
  /// **'Start Multi-Select'**
  String get processingStartMultiSelect;

  /// Start fill blank button
  ///
  /// In en, this message translates to:
  /// **'Start Fill-in-the-Blank'**
  String get processingStartFillBlank;

  /// Start short answer button
  ///
  /// In en, this message translates to:
  /// **'Start Short Answer'**
  String get processingStartShortAnswer;

  /// Start ordering button
  ///
  /// In en, this message translates to:
  /// **'Start Ordering Game'**
  String get processingStartOrdering;

  /// Start quiz button
  ///
  /// In en, this message translates to:
  /// **'Start the Quiz'**
  String get processingStartQuiz;

  /// Generic start button
  ///
  /// In en, this message translates to:
  /// **'Start Learning'**
  String get processingStartLearning;

  /// Processing status: queued
  ///
  /// In en, this message translates to:
  /// **'Waiting in queue...'**
  String get statusQueued;

  /// Processing status: OCR
  ///
  /// In en, this message translates to:
  /// **'Reading your document...'**
  String get statusOcr;

  /// Processing status: concept queue
  ///
  /// In en, this message translates to:
  /// **'Preparing concepts...'**
  String get statusConceptQueueing;

  /// Processing status: concept extraction
  ///
  /// In en, this message translates to:
  /// **'Extracting key concepts...'**
  String get statusConceptExtraction;

  /// Processing status: pack queue
  ///
  /// In en, this message translates to:
  /// **'Preparing learning pack...'**
  String get statusPackQueueing;

  /// Processing status: pack generation
  ///
  /// In en, this message translates to:
  /// **'Building learning pack...'**
  String get statusPackGeneration;

  /// Processing status: game queue
  ///
  /// In en, this message translates to:
  /// **'Preparing games...'**
  String get statusGameQueueing;

  /// Processing status: game generation
  ///
  /// In en, this message translates to:
  /// **'Generating games and quizzes...'**
  String get statusGameGeneration;

  /// Processing status: ready
  ///
  /// In en, this message translates to:
  /// **'Quiz ready!'**
  String get statusReady;

  /// Processing status: OCR failed
  ///
  /// In en, this message translates to:
  /// **'OCR failed. Please retry.'**
  String get statusOcrFailed;

  /// Processing status: concept extraction failed
  ///
  /// In en, this message translates to:
  /// **'Concept extraction failed. Please retry.'**
  String get statusConceptExtractionFailed;

  /// Processing status: pack failed
  ///
  /// In en, this message translates to:
  /// **'Pack generation failed. Please retry.'**
  String get statusPackGenerationFailed;

  /// Processing status: game failed
  ///
  /// In en, this message translates to:
  /// **'Game generation failed. Please retry.'**
  String get statusGameGenerationFailed;

  /// Processing status: generic processing
  ///
  /// In en, this message translates to:
  /// **'Processing document...'**
  String get statusProcessing;

  /// Processing status: generating content
  ///
  /// In en, this message translates to:
  /// **'Generating learning content...'**
  String get statusGenerating;

  /// Processing status: first game ready
  ///
  /// In en, this message translates to:
  /// **'First game is ready. Finishing remaining games...'**
  String get statusFirstGameReady;

  /// Upload in progress
  ///
  /// In en, this message translates to:
  /// **'Uploading document...'**
  String get statusUploadingDocument;

  /// Processing and generating
  ///
  /// In en, this message translates to:
  /// **'Processing and generating quiz...'**
  String get statusProcessingAndGenerating;

  /// Generation failure
  ///
  /// In en, this message translates to:
  /// **'Generation failed'**
  String get statusGenerationFailed;

  /// Creating games status
  ///
  /// In en, this message translates to:
  /// **'Creating games and quizzes...'**
  String get statusCreatingGames;

  /// Timeout error
  ///
  /// In en, this message translates to:
  /// **'Quiz generation timed out. Please try again.'**
  String get statusGenerationTimedOut;

  /// Stage label: first game ready
  ///
  /// In en, this message translates to:
  /// **'First Game Ready'**
  String get stageFirstGameReady;

  /// Stage label: queued
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get stageQueued;

  /// Stage label: OCR
  ///
  /// In en, this message translates to:
  /// **'OCR'**
  String get stageOcr;

  /// Stage label: concept queue
  ///
  /// In en, this message translates to:
  /// **'Concept Queue'**
  String get stageConceptQueue;

  /// Stage label: concept extraction
  ///
  /// In en, this message translates to:
  /// **'Concept Extraction'**
  String get stageConceptExtraction;

  /// Stage label: pack queue
  ///
  /// In en, this message translates to:
  /// **'Pack Queue'**
  String get stagePackQueue;

  /// Stage label: pack generation
  ///
  /// In en, this message translates to:
  /// **'Pack Generation'**
  String get stagePackGeneration;

  /// Stage label: game queue
  ///
  /// In en, this message translates to:
  /// **'Game Queue'**
  String get stageGameQueue;

  /// Stage label: game generation
  ///
  /// In en, this message translates to:
  /// **'Game Generation'**
  String get stageGameGeneration;

  /// Stage label: ready
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get stageReady;

  /// Stage label: OCR failed
  ///
  /// In en, this message translates to:
  /// **'OCR Failed'**
  String get stageOcrFailed;

  /// Stage label: concept failed
  ///
  /// In en, this message translates to:
  /// **'Concept Failed'**
  String get stageConceptFailed;

  /// Stage label: pack failed
  ///
  /// In en, this message translates to:
  /// **'Pack Failed'**
  String get stagePackFailed;

  /// Stage label: game failed
  ///
  /// In en, this message translates to:
  /// **'Game Failed'**
  String get stageGameFailed;

  /// Stage label: processing
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get stageProcessing;

  /// Stage label: processed
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get stageProcessed;

  /// Document status: queued
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get docStatusQueued;

  /// Document status: processing
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get docStatusProcessing;

  /// Document status: processed
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get docStatusProcessed;

  /// Document status: ready
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get docStatusReady;

  /// Document status: failed
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get docStatusFailed;

  /// Document status: unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get docStatusUnknown;

  /// Upload screen title
  ///
  /// In en, this message translates to:
  /// **'Upload a File'**
  String get uploadTitle;

  /// Upload screen subtitle
  ///
  /// In en, this message translates to:
  /// **'PDFs and images supported.'**
  String get uploadSubtitle;

  /// Upload placeholder text
  ///
  /// In en, this message translates to:
  /// **'Drag & drop or browse'**
  String get uploadDragOrBrowse;

  /// Subject field label
  ///
  /// In en, this message translates to:
  /// **'Subject (optional)'**
  String get uploadSubjectLabel;

  /// Subject field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. French verbs'**
  String get uploadSubjectHint;

  /// Language field label
  ///
  /// In en, this message translates to:
  /// **'Language (optional)'**
  String get uploadLanguageLabel;

  /// Language field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. French'**
  String get uploadLanguageHint;

  /// Goal field label
  ///
  /// In en, this message translates to:
  /// **'Learning goal (optional)'**
  String get uploadGoalLabel;

  /// Goal field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Present tense conjugation'**
  String get uploadGoalHint;

  /// Context field label
  ///
  /// In en, this message translates to:
  /// **'Extra context (optional)'**
  String get uploadContextLabel;

  /// Context field hint
  ///
  /// In en, this message translates to:
  /// **'Short notes to guide quiz generation'**
  String get uploadContextHint;

  /// Analyzing button state
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get uploadAnalyzing;

  /// Suggest metadata button
  ///
  /// In en, this message translates to:
  /// **'Suggest Metadata with AI'**
  String get uploadSuggestMetadata;

  /// AI suggestion unavailable
  ///
  /// In en, this message translates to:
  /// **'Suggestion unavailable right now.'**
  String get uploadSuggestionUnavailable;

  /// Choose file button
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get uploadChooseFile;

  /// Create profile screen title
  ///
  /// In en, this message translates to:
  /// **'You\'re Ready!'**
  String get createProfileTitle;

  /// Create profile subtitle
  ///
  /// In en, this message translates to:
  /// **'Let\'s learn together.'**
  String get createProfileSubtitle;

  /// Profile name field label
  ///
  /// In en, this message translates to:
  /// **'Profile name'**
  String get createProfileNameLabel;

  /// Profile name hint
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get createProfileNameHint;

  /// Avatar picker label
  ///
  /// In en, this message translates to:
  /// **'Choose your avatar'**
  String get createProfileAvatarLabel;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get createProfileContinue;

  /// Language picker label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get createProfileLanguageLabel;

  /// Correct answer feedback
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get feedbackCorrect;

  /// Incorrect answer feedback
  ///
  /// In en, this message translates to:
  /// **'Not quite'**
  String get feedbackIncorrect;

  /// Continue button in feedback
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get feedbackContinue;

  /// Accuracy display
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct'**
  String resultSummaryAccuracy(int correct, int total);

  /// Streak label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get resultSummaryStreak;

  /// Streak days display
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String resultSummaryStreakDays(int count);

  /// Mastery label
  ///
  /// In en, this message translates to:
  /// **'Mastery'**
  String get resultSummaryMastery;

  /// Review screen title
  ///
  /// In en, this message translates to:
  /// **'Review Capture'**
  String get reviewScreenTitle;

  /// Review screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Crop, rotate, or retake if needed.'**
  String get reviewScreenSubtitle;

  /// Add page button
  ///
  /// In en, this message translates to:
  /// **'Add Another Page'**
  String get reviewAddPage;

  /// Confirm review button
  ///
  /// In en, this message translates to:
  /// **'Looks Good'**
  String get reviewLooksGood;

  /// Retake button
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get reviewRetake;

  /// Library screen title
  ///
  /// In en, this message translates to:
  /// **'Document Library'**
  String get libraryTitle;

  /// Library screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Your uploaded worksheets and PDFs.'**
  String get librarySubtitle;

  /// Add document button
  ///
  /// In en, this message translates to:
  /// **'Add New Document'**
  String get libraryAddNew;

  /// Sync button
  ///
  /// In en, this message translates to:
  /// **'Sync Library'**
  String get librarySyncButton;

  /// Regenerate tooltip
  ///
  /// In en, this message translates to:
  /// **'Re-generate quiz'**
  String get libraryRegenerateTooltip;

  /// Revision setup title
  ///
  /// In en, this message translates to:
  /// **'Revision Express'**
  String get revisionSetupTitle;

  /// Revision setup subtitle
  ///
  /// In en, this message translates to:
  /// **'Quick 5-minute boost before a test.'**
  String get revisionSetupSubtitle;

  /// Duration label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get revisionSetupDuration;

  /// Duration value
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get revisionSetupDurationValue;

  /// Subject focus label
  ///
  /// In en, this message translates to:
  /// **'Subject focus'**
  String get revisionSetupSubjectFocus;

  /// Pick a pack fallback
  ///
  /// In en, this message translates to:
  /// **'Pick a pack'**
  String get revisionSetupPickPack;

  /// Adaptive mix label
  ///
  /// In en, this message translates to:
  /// **'Adaptive mix'**
  String get revisionSetupAdaptiveMix;

  /// Adaptive mix full description
  ///
  /// In en, this message translates to:
  /// **'Due concepts + recent mistakes + latest uploads'**
  String get revisionSetupAdaptiveFull;

  /// Adaptive mix partial description
  ///
  /// In en, this message translates to:
  /// **'Recent mistakes + latest uploads'**
  String get revisionSetupAdaptivePartial;

  /// Start session button
  ///
  /// In en, this message translates to:
  /// **'Start Express Session'**
  String get revisionSetupStartButton;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No revision items are ready yet. Complete a game first.'**
  String get revisionSetupNoItems;

  /// Revision session app bar title
  ///
  /// In en, this message translates to:
  /// **'Express Session'**
  String get revisionSessionTitle;

  /// No session available message
  ///
  /// In en, this message translates to:
  /// **'No revision session is ready yet.\nUpload and complete a game to unlock revision.'**
  String get revisionSessionNoSession;

  /// Loading state
  ///
  /// In en, this message translates to:
  /// **'Loading prompt...'**
  String get revisionSessionLoading;

  /// Finish button
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get revisionSessionFinish;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get revisionSessionNext;

  /// Revision results title
  ///
  /// In en, this message translates to:
  /// **'Express Complete!'**
  String get revisionResultsTitle;

  /// Revision results subtitle
  ///
  /// In en, this message translates to:
  /// **'You sharpened {correct} key concepts.'**
  String revisionResultsSubtitle(int correct);

  /// Accuracy display
  ///
  /// In en, this message translates to:
  /// **'Accuracy: {correct}/{total}'**
  String revisionResultsAccuracy(int correct, int total);

  /// Total XP display
  ///
  /// In en, this message translates to:
  /// **'Total XP: {xp}'**
  String revisionResultsTotalXp(int xp);

  /// Back to home button
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get revisionResultsBackHome;

  /// See progress button
  ///
  /// In en, this message translates to:
  /// **'See Progress'**
  String get revisionResultsSeeProgress;

  /// Default pack detail title
  ///
  /// In en, this message translates to:
  /// **'Learning Pack'**
  String get packDetailDefaultTitle;

  /// No pack message
  ///
  /// In en, this message translates to:
  /// **'No pack selected yet.'**
  String get packDetailNoPack;

  /// No games title
  ///
  /// In en, this message translates to:
  /// **'No generated games yet'**
  String get packDetailNoGamesTitle;

  /// No games message
  ///
  /// In en, this message translates to:
  /// **'Upload or regenerate this document to create games.'**
  String get packDetailNoGamesMessage;

  /// Start session button
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get packDetailStartSession;

  /// Default pack session title
  ///
  /// In en, this message translates to:
  /// **'Session Roadmap'**
  String get packSessionDefaultTitle;

  /// Pack session subtitle
  ///
  /// In en, this message translates to:
  /// **'{minutes} minute guided flow.'**
  String packSessionSubtitle(int minutes);

  /// No games title
  ///
  /// In en, this message translates to:
  /// **'No ready games'**
  String get packSessionNoGamesTitle;

  /// No games message
  ///
  /// In en, this message translates to:
  /// **'Finish document processing, then start the session.'**
  String get packSessionNoGamesMessage;

  /// Start button
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get packSessionStartNow;

  /// No games snack bar
  ///
  /// In en, this message translates to:
  /// **'No generated games are ready for this pack yet.'**
  String get packSessionNoGamesSnackBar;

  /// Packs list app bar title
  ///
  /// In en, this message translates to:
  /// **'Learning Packs'**
  String get packsListTitle;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Brain Power'**
  String get funFactBrainPowerTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'Your brain uses about 20% of your body\'s energy, even though it\'s only 2% of your weight!'**
  String get funFactBrainPower;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Octopus Smarts'**
  String get funFactOctopusTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'Octopuses have 9 brains! One central brain and a mini-brain in each of their 8 arms.'**
  String get funFactOctopus;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'School History'**
  String get funFactSchoolTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'The world\'s oldest school is in Morocco - it\'s been teaching students since 859 AD!'**
  String get funFactSchool;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Memory Trick'**
  String get funFactMemoryTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'You remember things better when you learn them right before sleep. Sweet dreams = smart dreams!'**
  String get funFactMemory;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Game Learning'**
  String get funFactGameTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'Playing educational games can improve memory by up to 30%. You\'re doing great!'**
  String get funFactGame;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Language Fun'**
  String get funFactLanguageTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'Kids who learn multiple subjects together remember 40% more than studying one at a time.'**
  String get funFactLanguage;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Space Fact'**
  String get funFactSpaceTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'Astronauts study for years! NASA training takes about 2 years of intense learning.'**
  String get funFactSpace;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Music & Math'**
  String get funFactMusicTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'Learning music helps with math! Both use patterns and counting in similar ways.'**
  String get funFactMusic;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Animal Teachers'**
  String get funFactAnimalTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'Meerkats teach their babies how to eat scorpions by bringing them dead ones first!'**
  String get funFactAnimal;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Pencil Power'**
  String get funFactPencilTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'The average pencil can write about 45,000 words. That\'s a lot of homework!'**
  String get funFactPencil;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Color Memory'**
  String get funFactColorTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'You remember colorful things better! That\'s why highlighters help you study.'**
  String get funFactColor;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Elephant Memory'**
  String get funFactElephantTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'Elephants really do have great memories - they can remember friends for decades!'**
  String get funFactElephant;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Quick Learner'**
  String get funFactQuickTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'Your brain can process an image in just 13 milliseconds. Faster than a blink!'**
  String get funFactQuick;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Dream Learning'**
  String get funFactDreamTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'Your brain replays what you learned during the day while you dream!'**
  String get funFactDream;

  /// Fun fact title
  ///
  /// In en, this message translates to:
  /// **'Practice Perfect'**
  String get funFactPracticeTitle;

  /// Fun fact text
  ///
  /// In en, this message translates to:
  /// **'It takes about 10,000 hours of practice to become an expert at something.'**
  String get funFactPractice;

  /// English language label
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// French language label
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// Dutch language label
  ///
  /// In en, this message translates to:
  /// **'Nederlands'**
  String get languageDutch;

  /// Error when no child profile
  ///
  /// In en, this message translates to:
  /// **'No child profile available.'**
  String get noChildProfile;

  /// Error when no image
  ///
  /// In en, this message translates to:
  /// **'No image selected.'**
  String get noImageSelected;

  /// Error when missing doc ID
  ///
  /// In en, this message translates to:
  /// **'Missing document ID.'**
  String get missingDocumentId;

  /// Error when missing pack ID
  ///
  /// In en, this message translates to:
  /// **'Missing learning pack id for retry.'**
  String get missingPackId;

  /// Document processing failure
  ///
  /// In en, this message translates to:
  /// **'Document processing failed.'**
  String get documentProcessingFailed;

  /// Error when pack has no id
  ///
  /// In en, this message translates to:
  /// **'Pack missing id.'**
  String get packMissingId;

  /// Result sync skip message
  ///
  /// In en, this message translates to:
  /// **'Game result sync skipped: missing childId/packId/gameId.'**
  String get resultSyncSkipped;

  /// Processing step: uploading
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get processingStepUploading;

  /// Processing step: processing
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processingStepProcessing;

  /// Processing step: generating
  ///
  /// In en, this message translates to:
  /// **'Generating'**
  String get processingStepGenerating;

  /// Processing step: creating games
  ///
  /// In en, this message translates to:
  /// **'Creating games'**
  String get processingStepCreatingGames;

  /// Status message with progress prefix
  ///
  /// In en, this message translates to:
  /// **'{progress}% • {message}'**
  String statusWithProgress(int progress, String message);

  /// Child switcher bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Switch Profile'**
  String get switchProfile;

  /// Child switcher bottom sheet hint
  ///
  /// In en, this message translates to:
  /// **'Tap a profile to switch'**
  String get switchProfileHint;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'fr':
      return L10nFr();
    case 'nl':
      return L10nNl();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
