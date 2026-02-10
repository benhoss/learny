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

  /// Processing status: quick scan queued
  ///
  /// In en, this message translates to:
  /// **'Quick scan queued...'**
  String get statusQuickScanQueued;

  /// Processing status: quick scan running
  ///
  /// In en, this message translates to:
  /// **'Running quick scan...'**
  String get statusQuickScanProcessing;

  /// Processing status: waiting for user validation
  ///
  /// In en, this message translates to:
  /// **'Awaiting your validation...'**
  String get statusAwaitingValidation;

  /// Processing status: quick scan failed
  ///
  /// In en, this message translates to:
  /// **'Quick scan failed. Please retry.'**
  String get statusQuickScanFailed;

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

  /// Stage label: quick scan queued
  ///
  /// In en, this message translates to:
  /// **'Quick Scan Queue'**
  String get stageQuickScanQueue;

  /// Stage label: quick scan running
  ///
  /// In en, this message translates to:
  /// **'Quick Scan'**
  String get stageQuickScanProcessing;

  /// Stage label: awaiting validation
  ///
  /// In en, this message translates to:
  /// **'Awaiting Validation'**
  String get stageAwaitingValidation;

  /// Stage label: quick scan failed
  ///
  /// In en, this message translates to:
  /// **'Quick Scan Failed'**
  String get stageQuickScanFailed;

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

  /// Document status: quick scan queued
  ///
  /// In en, this message translates to:
  /// **'Quick scan queue'**
  String get docStatusQuickScanQueued;

  /// Document status: quick scan processing
  ///
  /// In en, this message translates to:
  /// **'Quick scan'**
  String get docStatusQuickScanProcessing;

  /// Document status: quick scan failed
  ///
  /// In en, this message translates to:
  /// **'Quick scan failed'**
  String get docStatusQuickScanFailed;

  /// Document status: awaiting validation
  ///
  /// In en, this message translates to:
  /// **'Awaiting validation'**
  String get docStatusAwaitingValidation;

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

  /// Title field label
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get uploadTitleLabel;

  /// Title field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Observation and interpretation'**
  String get uploadTitleHint;

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

  /// Feedback shown after metadata suggestion in upload flow
  ///
  /// In en, this message translates to:
  /// **'Suggested from current context (confidence {percent}%). Edit any field before continuing.'**
  String uploadSuggestionFeedback(int percent);

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

  /// Feedback shown after metadata suggestion in review flow
  ///
  /// In en, this message translates to:
  /// **'Suggested from capture context (confidence {percent}%). Edit any field before continuing.'**
  String reviewSuggestionFeedback(int percent);

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

  /// No description provided for @accountSettingsEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountSettingsEmailLabel;

  /// No description provided for @accountSettingsGradeRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred grade range'**
  String get accountSettingsGradeRangeLabel;

  /// No description provided for @accountSettingsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get accountSettingsNameLabel;

  /// No description provided for @accountSettingsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get accountSettingsSaveChanges;

  /// No description provided for @accountSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage parent profile and preferences.'**
  String get accountSettingsSubtitle;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettingsTitle;

  /// No description provided for @achievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Celebrate wins big and small.'**
  String get achievementsSubtitle;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @cameraCaptureChooseMultiplePages.
  ///
  /// In en, this message translates to:
  /// **'Choose Multiple Pages'**
  String get cameraCaptureChooseMultiplePages;

  /// No description provided for @cameraCaptureChooseSinglePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose Single Photo'**
  String get cameraCaptureChooseSinglePhoto;

  /// No description provided for @cameraCaptureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Frame the worksheet and snap a photo.'**
  String get cameraCaptureSubtitle;

  /// No description provided for @cameraCaptureTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get cameraCaptureTakePhoto;

  /// No description provided for @cameraCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Snap Homework'**
  String get cameraCaptureTitle;

  /// No description provided for @cameraCaptureUploadPdfInstead.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF Instead'**
  String get cameraCaptureUploadPdfInstead;

  /// No description provided for @childSelectorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between children.'**
  String get childSelectorSubtitle;

  /// No description provided for @childSelectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Child Profiles'**
  String get childSelectorTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// Auto-added localization for contactSupportFrom
  ///
  /// In en, this message translates to:
  /// **'From: {email}'**
  String contactSupportFrom(String email);

  /// No description provided for @contactSupportMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get contactSupportMessageLabel;

  /// No description provided for @contactSupportSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get contactSupportSendMessage;

  /// No description provided for @contactSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We usually respond within 24 hours.'**
  String get contactSupportSubtitle;

  /// No description provided for @contactSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupportTitle;

  /// No description provided for @contactSupportTopicLabel.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get contactSupportTopicLabel;

  /// No description provided for @createProfileAvatarDino.
  ///
  /// In en, this message translates to:
  /// **'Dino'**
  String get createProfileAvatarDino;

  /// No description provided for @createProfileAvatarFox.
  ///
  /// In en, this message translates to:
  /// **'Fox'**
  String get createProfileAvatarFox;

  /// No description provided for @createProfileAvatarFoxBuddy.
  ///
  /// In en, this message translates to:
  /// **'Fox Buddy'**
  String get createProfileAvatarFoxBuddy;

  /// No description provided for @createProfileAvatarOwl.
  ///
  /// In en, this message translates to:
  /// **'Owl'**
  String get createProfileAvatarOwl;

  /// No description provided for @createProfileAvatarPenguin.
  ///
  /// In en, this message translates to:
  /// **'Penguin'**
  String get createProfileAvatarPenguin;

  /// No description provided for @createProfileAvatarRobot.
  ///
  /// In en, this message translates to:
  /// **'Robot'**
  String get createProfileAvatarRobot;

  /// Auto-added localization for deleteAccountBody
  ///
  /// In en, this message translates to:
  /// **'Deleting {name}\'s account will remove all child profiles and documents. This cannot be undone.'**
  String deleteAccountBody(String name);

  /// No description provided for @deleteAccountConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get deleteAccountConfirmDelete;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent.'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @emptyStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a worksheet to get started.'**
  String get emptyStateSubtitle;

  /// No description provided for @emptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing Here Yet'**
  String get emptyStateTitle;

  /// No description provided for @errorStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We could not process the document.'**
  String get errorStateSubtitle;

  /// No description provided for @errorStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get errorStateTitle;

  /// No description provided for @errorStateTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get errorStateTryAgain;

  /// No description provided for @faqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answers to common questions.'**
  String get faqSubtitle;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqTitle;

  /// No description provided for @forgotPasswordEmailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get forgotPasswordEmailAddressLabel;

  /// No description provided for @forgotPasswordSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get forgotPasswordSendLink;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a reset link to your email.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// No description provided for @homeTabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTabHome;

  /// No description provided for @homeTabPacks.
  ///
  /// In en, this message translates to:
  /// **'Packs'**
  String get homeTabPacks;

  /// No description provided for @homeTabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get homeTabProgress;

  /// No description provided for @homeTabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeTabSettings;

  /// Auto-added localization for learningTimeMinutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String learningTimeMinutes(int minutes);

  /// No description provided for @learningTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Minutes per day'**
  String get learningTimeSubtitle;

  /// No description provided for @learningTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Time'**
  String get learningTimeTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @loginCreateAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get loginCreateAccountPrompt;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue your child\'s learning journey.'**
  String get loginSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @masteryDetailsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload and complete games to build concept mastery.'**
  String get masteryDetailsEmptySubtitle;

  /// No description provided for @masteryDetailsNoDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run at least one generated game to populate this view.'**
  String get masteryDetailsNoDataSubtitle;

  /// No description provided for @masteryDetailsNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No mastery data yet'**
  String get masteryDetailsNoDataTitle;

  /// No description provided for @masteryDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Concept-level breakdown from your uploaded study content.'**
  String get masteryDetailsSubtitle;

  /// No description provided for @masteryDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mastery Details'**
  String get masteryDetailsTitle;

  /// No description provided for @masteryStatusMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get masteryStatusMastered;

  /// No description provided for @masteryStatusNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get masteryStatusNeedsReview;

  /// No description provided for @masteryStatusPracticing.
  ///
  /// In en, this message translates to:
  /// **'Practicing'**
  String get masteryStatusPracticing;

  /// Auto-added localization for masteryStatusWithPercent
  ///
  /// In en, this message translates to:
  /// **'{label} • {percent}%'**
  String masteryStatusWithPercent(String label, int percent);

  /// No description provided for @notificationsMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get notificationsMarkRead;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Friendly nudges for parents and kids.'**
  String get notificationsSubtitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @offlineRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get offlineRetry;

  /// No description provided for @offlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your connection to sync progress.'**
  String get offlineSubtitle;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re Offline'**
  String get offlineTitle;

  /// No description provided for @onboardingConsentAgreeButton.
  ///
  /// In en, this message translates to:
  /// **'Agree & Continue'**
  String get onboardingConsentAgreeButton;

  /// No description provided for @onboardingConsentCoppaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Parent consent required before use.'**
  String get onboardingConsentCoppaSubtitle;

  /// No description provided for @onboardingConsentCoppaTitle.
  ///
  /// In en, this message translates to:
  /// **'COPPA-friendly'**
  String get onboardingConsentCoppaTitle;

  /// No description provided for @onboardingConsentEducatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Content aligns to school standards.'**
  String get onboardingConsentEducatorSubtitle;

  /// No description provided for @onboardingConsentEducatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Educator designed'**
  String get onboardingConsentEducatorTitle;

  /// No description provided for @onboardingConsentNoDataSellingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We never share or sell personal info.'**
  String get onboardingConsentNoDataSellingSubtitle;

  /// No description provided for @onboardingConsentNoDataSellingTitle.
  ///
  /// In en, this message translates to:
  /// **'No data selling'**
  String get onboardingConsentNoDataSellingTitle;

  /// No description provided for @onboardingConsentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We keep kids safe, private, and ad-free.'**
  String get onboardingConsentSubtitle;

  /// No description provided for @onboardingConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Consent'**
  String get onboardingConsentTitle;

  /// No description provided for @onboardingCreateProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Create a Profile'**
  String get onboardingCreateProfileButton;

  /// No description provided for @onboardingFoxBlurb.
  ///
  /// In en, this message translates to:
  /// **'Learny the fox keeps practice playful and focused.'**
  String get onboardingFoxBlurb;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingHowItWorksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From homework to mastery in 3 quick steps.'**
  String get onboardingHowItWorksSubtitle;

  /// No description provided for @onboardingHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get onboardingHowItWorksTitle;

  /// No description provided for @onboardingStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of any worksheet or page.'**
  String get onboardingStep1Subtitle;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Snap your homework'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Flashcards, quizzes, and matching in seconds.'**
  String get onboardingStep2Subtitle;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'AI creates learning games'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Short sessions with streaks and XP boosts.'**
  String get onboardingStep3Subtitle;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Learn & earn rewards'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your AI learning buddy for smart, playful study sessions.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Learny!'**
  String get onboardingWelcomeTitle;

  /// Auto-added localization for packsItemsMinutes
  ///
  /// In en, this message translates to:
  /// **'{itemCount} items • {minutes} min'**
  String packsItemsMinutes(int itemCount, int minutes);

  /// Auto-added localization for packsMasteryProgress
  ///
  /// In en, this message translates to:
  /// **'{percent}% mastery • {mastered}/{total} concepts'**
  String packsMasteryProgress(int percent, int mastered, int total);

  /// No description provided for @packsStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start a Session'**
  String get packsStartSession;

  /// No description provided for @packsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized packs based on homework.'**
  String get packsSubtitle;

  /// No description provided for @packsTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Packs'**
  String get packsTitle;

  /// No description provided for @packsViewLibrary.
  ///
  /// In en, this message translates to:
  /// **'View Document Library'**
  String get packsViewLibrary;

  /// No description provided for @parentDashboardActiveChild.
  ///
  /// In en, this message translates to:
  /// **'Active child'**
  String get parentDashboardActiveChild;

  /// No description provided for @parentDashboardChildSelector.
  ///
  /// In en, this message translates to:
  /// **'Child Selector'**
  String get parentDashboardChildSelector;

  /// No description provided for @parentDashboardLearningTime.
  ///
  /// In en, this message translates to:
  /// **'Learning Time'**
  String get parentDashboardLearningTime;

  /// No description provided for @parentDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track progress and guide next steps.'**
  String get parentDashboardSubtitle;

  /// No description provided for @parentDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Dashboard'**
  String get parentDashboardTitle;

  /// No description provided for @parentDashboardWeakAreas.
  ///
  /// In en, this message translates to:
  /// **'Weak Areas'**
  String get parentDashboardWeakAreas;

  /// No description provided for @parentDashboardWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get parentDashboardWeeklySummary;

  /// No description provided for @parentOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent only'**
  String get parentOnlyLabel;

  /// No description provided for @parentPinChangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new PIN for parent-only access.'**
  String get parentPinChangeSubtitle;

  /// No description provided for @parentPinChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get parentPinChangeTitle;

  /// No description provided for @parentPinCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'4-digit PIN'**
  String get parentPinCodeLabel;

  /// No description provided for @parentPinEnterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue.'**
  String get parentPinEnterSubtitle;

  /// No description provided for @parentPinSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save PIN'**
  String get parentPinSaveButton;

  /// No description provided for @parentPinUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock Parent Settings'**
  String get parentPinUnlockButton;

  /// No description provided for @parentSettingsChildProfiles.
  ///
  /// In en, this message translates to:
  /// **'Child profiles'**
  String get parentSettingsChildProfiles;

  /// No description provided for @parentSettingsParentProfile.
  ///
  /// In en, this message translates to:
  /// **'Parent profile'**
  String get parentSettingsParentProfile;

  /// Auto-added localization for parentSettingsProfilesCount
  ///
  /// In en, this message translates to:
  /// **'{count} profiles'**
  String parentSettingsProfilesCount(int count);

  /// No description provided for @parentSettingsProtectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect parent-only settings.'**
  String get parentSettingsProtectSubtitle;

  /// No description provided for @parentSettingsSetChangePin.
  ///
  /// In en, this message translates to:
  /// **'Set / Change PIN'**
  String get parentSettingsSetChangePin;

  /// No description provided for @parentSettingsSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get parentSettingsSubscription;

  /// No description provided for @parentSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription and family controls.'**
  String get parentSettingsSubtitle;

  /// No description provided for @parentSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Settings'**
  String get parentSettingsTitle;

  /// No description provided for @planAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get planAlreadyHaveAccount;

  /// No description provided for @planChooseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start free. Upgrade anytime.'**
  String get planChooseSubtitle;

  /// No description provided for @planChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get planChooseTitle;

  /// No description provided for @planFamilySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Up to 4 child profiles'**
  String get planFamilySubtitle;

  /// No description provided for @planFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get planFamilyTitle;

  /// No description provided for @planFreeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'3 packs per month'**
  String get planFreeSubtitle;

  /// No description provided for @planFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planFreeTitle;

  /// No description provided for @planProSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited packs + games'**
  String get planProSubtitle;

  /// No description provided for @planProTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get planProTitle;

  /// No description provided for @safetyPrivacyCoppaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Parental consent required'**
  String get safetyPrivacyCoppaSubtitle;

  /// No description provided for @safetyPrivacyCoppaTitle.
  ///
  /// In en, this message translates to:
  /// **'COPPA compliant'**
  String get safetyPrivacyCoppaTitle;

  /// No description provided for @safetyPrivacyEncryptedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Files are protected'**
  String get safetyPrivacyEncryptedSubtitle;

  /// No description provided for @safetyPrivacyEncryptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted storage'**
  String get safetyPrivacyEncryptedTitle;

  /// No description provided for @safetyPrivacyNoAdsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We do not monetize data'**
  String get safetyPrivacyNoAdsSubtitle;

  /// No description provided for @safetyPrivacyNoAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'No ads, no selling'**
  String get safetyPrivacyNoAdsTitle;

  /// No description provided for @safetyPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Built for kids, trusted by parents.'**
  String get safetyPrivacySubtitle;

  /// No description provided for @safetyPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety & Privacy'**
  String get safetyPrivacyTitle;

  /// No description provided for @settingsClearAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'This clears all learning memory signals. Continue?'**
  String get settingsClearAllConfirm;

  /// No description provided for @settingsClearAllLearningMemorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Events, revision, game results, mastery.'**
  String get settingsClearAllLearningMemorySubtitle;

  /// No description provided for @settingsClearAllLearningMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all learning memory'**
  String get settingsClearAllLearningMemoryTitle;

  /// No description provided for @settingsClearEventsOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keeps mastery and results.'**
  String get settingsClearEventsOnlySubtitle;

  /// No description provided for @settingsClearEventsOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear events only'**
  String get settingsClearEventsOnlyTitle;

  /// No description provided for @settingsClearMemoryScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Memory Scope'**
  String get settingsClearMemoryScopeTitle;

  /// No description provided for @settingsClearRevisionSessionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Removes quick revision history.'**
  String get settingsClearRevisionSessionsSubtitle;

  /// No description provided for @settingsClearRevisionSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear revision sessions'**
  String get settingsClearRevisionSessionsTitle;

  /// Auto-added localization for settingsClearScopeConfirm
  ///
  /// In en, this message translates to:
  /// **'Clear memory scope \"{scope}\"?'**
  String settingsClearScopeConfirm(String scope);

  /// No description provided for @settingsConfirmClearMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm clear memory'**
  String get settingsConfirmClearMemoryTitle;

  /// No description provided for @settingsDeleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is a destructive action.'**
  String get settingsDeleteAccountSubtitle;

  /// No description provided for @settingsDetailLevelBrief.
  ///
  /// In en, this message translates to:
  /// **'Brief'**
  String get settingsDetailLevelBrief;

  /// No description provided for @settingsDetailLevelDetailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get settingsDetailLevelDetailed;

  /// Auto-added localization for settingsLastReset
  ///
  /// In en, this message translates to:
  /// **'Last reset: {scope} at {time}'**
  String settingsLastReset(String scope, String time);

  /// No description provided for @settingsLearningMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Memory'**
  String get settingsLearningMemoryTitle;

  /// No description provided for @settingsNoRecentMemoryReset.
  ///
  /// In en, this message translates to:
  /// **'No recent memory reset.'**
  String get settingsNoRecentMemoryReset;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get updates about new packs and streaks.'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsTitle;

  /// No description provided for @settingsPersonalizedRecommendationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use activity history to adapt next steps.'**
  String get settingsPersonalizedRecommendationsSubtitle;

  /// No description provided for @settingsPersonalizedRecommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized Recommendations'**
  String get settingsPersonalizedRecommendationsTitle;

  /// No description provided for @settingsRationaleDetailLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Rationale Detail Level'**
  String get settingsRationaleDetailLevelTitle;

  /// No description provided for @settingsRecommendationRationaleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display \"why this suggestion\" explanations.'**
  String get settingsRecommendationRationaleSubtitle;

  /// No description provided for @settingsRecommendationRationaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Show Recommendation Rationale'**
  String get settingsRecommendationRationaleTitle;

  /// No description provided for @settingsSoundEffectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play sounds during games.'**
  String get settingsSoundEffectsSubtitle;

  /// No description provided for @settingsSoundEffectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get settingsSoundEffectsTitle;

  /// No description provided for @settingsStudyRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders for short sessions.'**
  String get settingsStudyRemindersSubtitle;

  /// No description provided for @settingsStudyRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Reminders'**
  String get settingsStudyRemindersTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsUnknownScope.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get settingsUnknownScope;

  /// No description provided for @signupCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupCreateAccount;

  /// No description provided for @signupFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get signupFullNameLabel;

  /// No description provided for @signupLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get signupLoginPrompt;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up a secure parent profile to manage learning.'**
  String get signupSubtitle;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Parent Account'**
  String get signupTitle;

  /// Auto-added localization for streaksRewardsBadges
  ///
  /// In en, this message translates to:
  /// **'{count} badges'**
  String streaksRewardsBadges(int count);

  /// No description provided for @streaksRewardsCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get streaksRewardsCurrentStreak;

  /// Auto-added localization for streaksRewardsDays
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String streaksRewardsDays(int count);

  /// No description provided for @streaksRewardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the momentum going!'**
  String get streaksRewardsSubtitle;

  /// No description provided for @streaksRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Streaks & Rewards'**
  String get streaksRewardsTitle;

  /// No description provided for @streaksRewardsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Rewards unlocked'**
  String get streaksRewardsUnlocked;

  /// Auto-added localization for subscriptionCurrentPlan
  ///
  /// In en, this message translates to:
  /// **'Current plan: {plan}'**
  String subscriptionCurrentPlan(String plan);

  /// No description provided for @subscriptionPlanIncluded.
  ///
  /// In en, this message translates to:
  /// **'Full access included with the free plan.'**
  String get subscriptionPlanIncluded;

  /// No description provided for @subscriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learny is free to use. Parents can upgrade anytime.'**
  String get subscriptionSubtitle;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionUpgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get subscriptionUpgradePlan;

  /// No description provided for @upgradePlanContinueToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Continue to Checkout'**
  String get upgradePlanContinueToCheckout;

  /// No description provided for @upgradePlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited packs and parent insights.'**
  String get upgradePlanSubtitle;

  /// No description provided for @upgradePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get upgradePlanTitle;

  /// No description provided for @verifyEmailCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verifyEmailCodeLabel;

  /// No description provided for @verifyEmailContinueToApp.
  ///
  /// In en, this message translates to:
  /// **'Continue to App'**
  String get verifyEmailContinueToApp;

  /// No description provided for @verifyEmailResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get verifyEmailResendCode;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit code to parent@example.com.'**
  String get verifyEmailSubtitle;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @weakAreasSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Focus zones to review next.'**
  String get weakAreasSubtitle;

  /// No description provided for @weakAreasTitle.
  ///
  /// In en, this message translates to:
  /// **'Weak Areas'**
  String get weakAreasTitle;

  /// No description provided for @weeklySummaryAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get weeklySummaryAchievements;

  /// Auto-added localization for weeklySummaryNewBadges
  ///
  /// In en, this message translates to:
  /// **'{count} new badges'**
  String weeklySummaryNewBadges(int count);

  /// No description provided for @weeklySummarySessionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sessions completed'**
  String get weeklySummarySessionsCompleted;

  /// Auto-added localization for weeklySummarySessionsValue
  ///
  /// In en, this message translates to:
  /// **'{count} sessions'**
  String weeklySummarySessionsValue(int count);

  /// No description provided for @weeklySummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Highlights from the past 7 days.'**
  String get weeklySummarySubtitle;

  /// No description provided for @weeklySummaryTimeSpent.
  ///
  /// In en, this message translates to:
  /// **'Time spent'**
  String get weeklySummaryTimeSpent;

  /// Auto-added localization for weeklySummaryTimeSpentValue
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String weeklySummaryTimeSpentValue(int hours, int minutes);

  /// No description provided for @weeklySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummaryTitle;

  /// No description provided for @weeklySummaryTopSubject.
  ///
  /// In en, this message translates to:
  /// **'Top subject'**
  String get weeklySummaryTopSubject;

  /// Auto-added localization for processingAlternativesLabel
  ///
  /// In en, this message translates to:
  /// **'Alternatives: {alternatives}'**
  String processingAlternativesLabel(String alternatives);

  /// Auto-added localization for processingConfidenceLabel
  ///
  /// In en, this message translates to:
  /// **'Confidence: {percent}%{modelSuffix}'**
  String processingConfidenceLabel(int percent, String modelSuffix);

  /// No description provided for @processingConfirmGenerate.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Generate'**
  String get processingConfirmGenerate;

  /// No description provided for @processingLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get processingLanguageLabel;

  /// No description provided for @processingNoAlternatives.
  ///
  /// In en, this message translates to:
  /// **'No alternatives suggested.'**
  String get processingNoAlternatives;

  /// No description provided for @processingRescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get processingRescan;

  /// No description provided for @processingStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get processingStarting;

  /// No description provided for @processingTopicLabel.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get processingTopicLabel;

  /// No description provided for @processingTopicLanguageRequired.
  ///
  /// In en, this message translates to:
  /// **'Topic and language are required to continue.'**
  String get processingTopicLanguageRequired;

  /// No description provided for @processingValidateScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm or edit the topic and language before deep generation starts.'**
  String get processingValidateScanSubtitle;

  /// No description provided for @processingValidateScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Validate AI scan'**
  String get processingValidateScanTitle;

  /// Auto-added localization for progressActivitySummary
  ///
  /// In en, this message translates to:
  /// **'{percent}% • {scoreLabel} • +{xp} XP'**
  String progressActivitySummary(int percent, String scoreLabel, int xp);

  /// No description provided for @progressCouldNotRegenerateDocument.
  ///
  /// In en, this message translates to:
  /// **'Could not regenerate document right now.'**
  String get progressCouldNotRegenerateDocument;

  /// Auto-added localization for progressCouldNotReopen
  ///
  /// In en, this message translates to:
  /// **'Could not reopen this subject: {error}'**
  String progressCouldNotReopen(String error);

  /// Auto-added localization for progressCouldNotStartRegenerationFor
  ///
  /// In en, this message translates to:
  /// **'Could not start regeneration for {gameType}.'**
  String progressCouldNotStartRegenerationFor(String gameType);

  /// No description provided for @progressDeltaNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get progressDeltaNew;

  /// No description provided for @progressDocumentRegenerationStarted.
  ///
  /// In en, this message translates to:
  /// **'Document regeneration started.'**
  String get progressDocumentRegenerationStarted;

  /// No description provided for @progressGenerateNewGameTypeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a type to regenerate from this document'**
  String get progressGenerateNewGameTypeSubtitle;

  /// No description provided for @progressGenerateNewGameTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate New Game Type'**
  String get progressGenerateNewGameTypeTitle;

  /// No description provided for @progressLatestCheerEmpty.
  ///
  /// In en, this message translates to:
  /// **'Upload a document and complete a game to start your momentum.'**
  String get progressLatestCheerEmpty;

  /// No description provided for @progressLoadOlderActivity.
  ///
  /// In en, this message translates to:
  /// **'Load older activity'**
  String get progressLoadOlderActivity;

  /// No description provided for @progressMetricAvgScore.
  ///
  /// In en, this message translates to:
  /// **'Avg score'**
  String get progressMetricAvgScore;

  /// No description provided for @progressMetricRecentXp.
  ///
  /// In en, this message translates to:
  /// **'Recent XP'**
  String get progressMetricRecentXp;

  /// No description provided for @progressMetricSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get progressMetricSessions;

  /// No description provided for @progressMetricStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get progressMetricStreak;

  /// Auto-added localization for progressMetricStreakValue
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String progressMetricStreakValue(int days);

  /// No description provided for @progressMomentumBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building momentum'**
  String get progressMomentumBuilding;

  /// No description provided for @progressMomentumExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent momentum'**
  String get progressMomentumExcellent;

  /// No description provided for @progressMomentumReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to start'**
  String get progressMomentumReady;

  /// No description provided for @progressMomentumSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady momentum'**
  String get progressMomentumSteady;

  /// No description provided for @progressNewGameType.
  ///
  /// In en, this message translates to:
  /// **'New Game Type'**
  String get progressNewGameType;

  /// No description provided for @progressNoActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play a generated game to see results and motivation here.'**
  String get progressNoActivitySubtitle;

  /// No description provided for @progressNoActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get progressNoActivityTitle;

  /// No description provided for @progressNoReadyGames.
  ///
  /// In en, this message translates to:
  /// **'No ready games found for this subject yet.'**
  String get progressNoReadyGames;

  /// No description provided for @progressOpenOverview.
  ///
  /// In en, this message translates to:
  /// **'Open Progress Overview'**
  String get progressOpenOverview;

  /// No description provided for @progressOverviewAreasToFocus.
  ///
  /// In en, this message translates to:
  /// **'Areas to Focus'**
  String get progressOverviewAreasToFocus;

  /// No description provided for @progressOverviewBadges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get progressOverviewBadges;

  /// No description provided for @progressOverviewDayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get progressOverviewDayStreak;

  /// Auto-added localization for progressOverviewLevelLearner
  ///
  /// In en, this message translates to:
  /// **'Level {level} Learner'**
  String progressOverviewLevelLearner(int level);

  /// No description provided for @progressOverviewMastery.
  ///
  /// In en, this message translates to:
  /// **'Mastery'**
  String get progressOverviewMastery;

  /// Auto-added localization for progressOverviewMinutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String progressOverviewMinutes(int minutes);

  /// No description provided for @progressOverviewSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get progressOverviewSessions;

  /// No description provided for @progressOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get progressOverviewTitle;

  /// No description provided for @progressOverviewTopSubject.
  ///
  /// In en, this message translates to:
  /// **'Top Subject'**
  String get progressOverviewTopSubject;

  /// No description provided for @progressOverviewTopicMastery.
  ///
  /// In en, this message translates to:
  /// **'Topic Mastery'**
  String get progressOverviewTopicMastery;

  /// No description provided for @progressOverviewTopicMasteryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete some lessons to see your mastery!'**
  String get progressOverviewTopicMasteryEmpty;

  /// Auto-added localization for progressOverviewTotalXp
  ///
  /// In en, this message translates to:
  /// **'{xp} XP total'**
  String progressOverviewTotalXp(int xp);

  /// Auto-added localization for progressOverviewXpToNextLevel
  ///
  /// In en, this message translates to:
  /// **'{xpToNext} XP to Level {nextLevel}'**
  String progressOverviewXpToNextLevel(int xpToNext, int nextLevel);

  /// No description provided for @progressOverviewXpToday.
  ///
  /// In en, this message translates to:
  /// **'XP Today'**
  String get progressOverviewXpToday;

  /// No description provided for @progressPastActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Past Activity'**
  String get progressPastActivityTitle;

  /// No description provided for @progressRedoDocument.
  ///
  /// In en, this message translates to:
  /// **'Redo Document'**
  String get progressRedoDocument;

  /// No description provided for @progressRedoSubject.
  ///
  /// In en, this message translates to:
  /// **'Redo Subject'**
  String get progressRedoSubject;

  /// No description provided for @progressRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get progressRefresh;

  /// Auto-added localization for progressRegenerationStartedFor
  ///
  /// In en, this message translates to:
  /// **'Regeneration started for {gameType}.'**
  String progressRegenerationStartedFor(String gameType);

  /// No description provided for @progressScoreBandImproving.
  ///
  /// In en, this message translates to:
  /// **'Improving'**
  String get progressScoreBandImproving;

  /// No description provided for @progressScoreBandKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep Going'**
  String get progressScoreBandKeepGoing;

  /// No description provided for @progressScoreBandStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get progressScoreBandStrong;

  /// Auto-added localization for progressScoreLabel
  ///
  /// In en, this message translates to:
  /// **'{correct}/{total} correct'**
  String progressScoreLabel(int correct, int total);

  /// No description provided for @progressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Past results, trends, and what to redo next.'**
  String get progressSubtitle;

  /// Auto-added localization for progressWeeklyMastery
  ///
  /// In en, this message translates to:
  /// **'{percent}% mastery across this week\'s packs'**
  String progressWeeklyMastery(int percent);

  /// No description provided for @progressWeeklyProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get progressWeeklyProgressTitle;
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
