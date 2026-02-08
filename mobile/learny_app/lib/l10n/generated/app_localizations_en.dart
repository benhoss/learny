// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Learny';

  @override
  String get homeGreeting => 'Good morning,';

  @override
  String get homeWelcomeMessage =>
      'Ready to learn something new today? Let\'s turn your school lessons into fun games!';

  @override
  String get homeStartLearningTitle => 'Start Learning';

  @override
  String get homeStartLearningSubtitle => 'Upload your lesson and play';

  @override
  String get homeRevisionExpressTitle => 'Revision Express';

  @override
  String get homeRevisionExpressSubtitle => 'Quick 5-minute review';

  @override
  String get homeSmartNextSteps => 'Smart Next Steps';

  @override
  String get homeNoRecommendations =>
      'Upload a document to get AI recommendations based on real study data.';

  @override
  String get homeContinueLearning => 'Continue learning';

  @override
  String get homeBasedOnActivity => 'Based on your recent activity';

  @override
  String get homeWhyThis => 'Why this?';

  @override
  String get homeThisWeek => 'This Week';

  @override
  String homeProgressMessage(int sessionsCompleted) {
    return 'You\'ve completed $sessionsCompleted learning sessions. Great work!';
  }

  @override
  String homeReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count concepts to review',
      one: '1 concept to review',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewSubtitle => 'Review now to keep learning!';

  @override
  String get homeAchievements => 'Achievements';

  @override
  String get homeProgress => 'Progress';

  @override
  String get homePackMastery => 'Pack Mastery';

  @override
  String get homeWhyRecommendation => 'Why this recommendation?';

  @override
  String get homeRecommendation => 'Recommendation';

  @override
  String get homeNoExplainability =>
      'No additional rationale available for this suggestion.';

  @override
  String get homeClose => 'Close';

  @override
  String get quizCorrectFeedback => 'You\'re on a roll!';

  @override
  String get quizIncorrectFeedback => 'Review the explanation and keep going.';

  @override
  String get quizNoQuizMessage =>
      'No generated quiz is ready for this pack yet.';

  @override
  String get quizUploadDocument => 'Upload Document';

  @override
  String get quizYourAnswer => 'Your answer';

  @override
  String get quizTypeAnswerHint => 'Type your answer here...';

  @override
  String get quizSelectAllThatApply => 'Select all that apply';

  @override
  String get quizDragIntoOrder => 'Drag items into the correct order';

  @override
  String get quizLoadingQuestion => 'Loading question...';

  @override
  String get quizCheckAnswer => 'Check Answer';

  @override
  String get quizFinish => 'Finish';

  @override
  String quizProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get quizEmptyProgress => 'Question 0 / 0';

  @override
  String get gameTypeTrueFalse => 'True or False';

  @override
  String get gameTypeMultiSelect => 'Choose All That Apply';

  @override
  String get gameTypeFillBlank => 'Fill in the Blank';

  @override
  String get gameTypeShortAnswer => 'Short Answer';

  @override
  String get gameTypeOrdering => 'Put in Order';

  @override
  String get gameTypeMatching => 'Matching Pairs';

  @override
  String get gameTypeFlashcards => 'Flashcards';

  @override
  String get gameTypeQuiz => 'Quick Quiz';

  @override
  String get gameSubtitleTrueFalse => 'Quick judgments';

  @override
  String get gameSubtitleMultiSelect => 'Multiple correct answers';

  @override
  String get gameSubtitleFillBlank => 'Complete the sentence';

  @override
  String get gameSubtitleShortAnswer => 'Write a quick response';

  @override
  String get gameSubtitleOrdering => 'Drag items into order';

  @override
  String get gameSubtitleMatching => 'Match linked concepts';

  @override
  String get gameSubtitleFlashcards => 'Warm-up concepts';

  @override
  String get gameSubtitleQuiz => 'Multiple choice questions';

  @override
  String get trueFalseTrue => 'True';

  @override
  String get trueFalseFalse => 'False';

  @override
  String get flashcardsDefaultTitle => 'Flashcards';

  @override
  String get flashcardsFront => 'Front';

  @override
  String get flashcardsBack => 'Back';

  @override
  String flashcardsProgress(int current, int total) {
    return 'Card $current of $total';
  }

  @override
  String get flashcardsEmptyProgress => 'Card 0 / 0';

  @override
  String get flashcardsFlipCard => 'Flip Card';

  @override
  String get flashcardsFinish => 'Finish';

  @override
  String get flashcardsGotItNext => 'Got it! Next';

  @override
  String get flashcardsQuestion => 'Question';

  @override
  String get flashcardsAnswer => 'Answer';

  @override
  String get flashcardsTapToFlip => 'Tap to flip';

  @override
  String get matchingDefaultTitle => 'Matching Game';

  @override
  String get matchingSubtitle => 'Tap two matching items';

  @override
  String get matchingNoItems => 'No matching pairs available.';

  @override
  String matchingProgress(int matched, int total) {
    return '$matched of $total pairs matched';
  }

  @override
  String get matchingContinue => 'Continue';

  @override
  String get matchingMismatch => 'Not quite - try again!';

  @override
  String get resultsGreatJob => 'Great Job!';

  @override
  String resultsSubtitle(int xp) {
    return 'You earned $xp XP in this round and kept your streak.';
  }

  @override
  String get resultsSyncError =>
      'Progress sync is delayed. We will retry automatically.';

  @override
  String get resultsFinishSession => 'Finish Session';

  @override
  String get resultsContinue => 'Continue';

  @override
  String get resultsReviewMistakes => 'Review Mistakes';

  @override
  String get resultsSeeProgress => 'See Progress';

  @override
  String get resultsBackToHome => 'Back to Home';

  @override
  String get resultsRetryMistakes => 'Retry Mistakes';

  @override
  String get processingReadyTitle => 'Ready to Learn!';

  @override
  String get processingTitle => 'Creating Your Quiz';

  @override
  String get processingGoBack => 'Go Back';

  @override
  String get processingTransfer => 'Transfer';

  @override
  String get processingAI => 'AI Processing';

  @override
  String get processingSuccessTitle => 'Your Quiz is Ready!';

  @override
  String get processingSuccessMessage => 'Jump in while the material is fresh.';

  @override
  String get processingSuccessDetail =>
      'Personalized games created from your document';

  @override
  String get processingErrorTitle => 'Something went wrong';

  @override
  String get processingErrorHint =>
      'Try uploading a clearer image or a different document.';

  @override
  String get processingStartFlashcards => 'Start Flashcards';

  @override
  String get processingStartMatching => 'Start Matching';

  @override
  String get processingStartTrueFalse => 'Start True/False';

  @override
  String get processingStartMultiSelect => 'Start Multi-Select';

  @override
  String get processingStartFillBlank => 'Start Fill-in-the-Blank';

  @override
  String get processingStartShortAnswer => 'Start Short Answer';

  @override
  String get processingStartOrdering => 'Start Ordering Game';

  @override
  String get processingStartQuiz => 'Start the Quiz';

  @override
  String get processingStartLearning => 'Start Learning';

  @override
  String get statusQueued => 'Waiting in queue...';

  @override
  String get statusOcr => 'Reading your document...';

  @override
  String get statusConceptQueueing => 'Preparing concepts...';

  @override
  String get statusConceptExtraction => 'Extracting key concepts...';

  @override
  String get statusPackQueueing => 'Preparing learning pack...';

  @override
  String get statusPackGeneration => 'Building learning pack...';

  @override
  String get statusGameQueueing => 'Preparing games...';

  @override
  String get statusGameGeneration => 'Generating games and quizzes...';

  @override
  String get statusReady => 'Quiz ready!';

  @override
  String get statusOcrFailed => 'OCR failed. Please retry.';

  @override
  String get statusConceptExtractionFailed =>
      'Concept extraction failed. Please retry.';

  @override
  String get statusPackGenerationFailed =>
      'Pack generation failed. Please retry.';

  @override
  String get statusGameGenerationFailed =>
      'Game generation failed. Please retry.';

  @override
  String get statusProcessing => 'Processing document...';

  @override
  String get statusGenerating => 'Generating learning content...';

  @override
  String get statusFirstGameReady =>
      'First game is ready. Finishing remaining games...';

  @override
  String get statusUploadingDocument => 'Uploading document...';

  @override
  String get statusProcessingAndGenerating =>
      'Processing and generating quiz...';

  @override
  String get statusGenerationFailed => 'Generation failed';

  @override
  String get statusCreatingGames => 'Creating games and quizzes...';

  @override
  String get statusGenerationTimedOut =>
      'Quiz generation timed out. Please try again.';

  @override
  String get stageFirstGameReady => 'First Game Ready';

  @override
  String get stageQueued => 'Queued';

  @override
  String get stageOcr => 'OCR';

  @override
  String get stageConceptQueue => 'Concept Queue';

  @override
  String get stageConceptExtraction => 'Concept Extraction';

  @override
  String get stagePackQueue => 'Pack Queue';

  @override
  String get stagePackGeneration => 'Pack Generation';

  @override
  String get stageGameQueue => 'Game Queue';

  @override
  String get stageGameGeneration => 'Game Generation';

  @override
  String get stageReady => 'Ready';

  @override
  String get stageOcrFailed => 'OCR Failed';

  @override
  String get stageConceptFailed => 'Concept Failed';

  @override
  String get stagePackFailed => 'Pack Failed';

  @override
  String get stageGameFailed => 'Game Failed';

  @override
  String get stageProcessing => 'Processing';

  @override
  String get stageProcessed => 'Processed';

  @override
  String get docStatusQueued => 'Queued';

  @override
  String get docStatusProcessing => 'Processing';

  @override
  String get docStatusProcessed => 'Processed';

  @override
  String get docStatusReady => 'Ready';

  @override
  String get docStatusFailed => 'Failed';

  @override
  String get docStatusUnknown => 'Unknown';

  @override
  String get uploadTitle => 'Upload a File';

  @override
  String get uploadSubtitle => 'PDFs and images supported.';

  @override
  String get uploadDragOrBrowse => 'Drag & drop or browse';

  @override
  String get uploadSubjectLabel => 'Subject (optional)';

  @override
  String get uploadSubjectHint => 'e.g. French verbs';

  @override
  String get uploadLanguageLabel => 'Language (optional)';

  @override
  String get uploadLanguageHint => 'e.g. French';

  @override
  String get uploadGoalLabel => 'Learning goal (optional)';

  @override
  String get uploadGoalHint => 'e.g. Present tense conjugation';

  @override
  String get uploadContextLabel => 'Extra context (optional)';

  @override
  String get uploadContextHint => 'Short notes to guide quiz generation';

  @override
  String get uploadAnalyzing => 'Analyzing...';

  @override
  String get uploadSuggestMetadata => 'Suggest Metadata with AI';

  @override
  String get uploadSuggestionUnavailable => 'Suggestion unavailable right now.';

  @override
  String get uploadChooseFile => 'Choose File';

  @override
  String get createProfileTitle => 'You\'re Ready!';

  @override
  String get createProfileSubtitle => 'Let\'s learn together.';

  @override
  String get createProfileNameLabel => 'Profile name';

  @override
  String get createProfileNameHint => 'Your name';

  @override
  String get createProfileAvatarLabel => 'Choose your avatar';

  @override
  String get createProfileContinue => 'Continue';

  @override
  String get createProfileLanguageLabel => 'Language';

  @override
  String get feedbackCorrect => 'Correct!';

  @override
  String get feedbackIncorrect => 'Not quite';

  @override
  String get feedbackContinue => 'Continue';

  @override
  String resultSummaryAccuracy(int correct, int total) {
    return '$correct of $total correct';
  }

  @override
  String get resultSummaryStreak => 'Streak';

  @override
  String resultSummaryStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get resultSummaryMastery => 'Mastery';

  @override
  String get reviewScreenTitle => 'Review Capture';

  @override
  String get reviewScreenSubtitle => 'Crop, rotate, or retake if needed.';

  @override
  String get reviewAddPage => 'Add Another Page';

  @override
  String get reviewLooksGood => 'Looks Good';

  @override
  String get reviewRetake => 'Retake';

  @override
  String get libraryTitle => 'Document Library';

  @override
  String get librarySubtitle => 'Your uploaded worksheets and PDFs.';

  @override
  String get libraryAddNew => 'Add New Document';

  @override
  String get librarySyncButton => 'Sync Library';

  @override
  String get libraryRegenerateTooltip => 'Re-generate quiz';

  @override
  String get revisionSetupTitle => 'Revision Express';

  @override
  String get revisionSetupSubtitle => 'Quick 5-minute boost before a test.';

  @override
  String get revisionSetupDuration => 'Duration';

  @override
  String get revisionSetupDurationValue => '5 minutes';

  @override
  String get revisionSetupSubjectFocus => 'Subject focus';

  @override
  String get revisionSetupPickPack => 'Pick a pack';

  @override
  String get revisionSetupAdaptiveMix => 'Adaptive mix';

  @override
  String get revisionSetupAdaptiveFull =>
      'Due concepts + recent mistakes + latest uploads';

  @override
  String get revisionSetupAdaptivePartial => 'Recent mistakes + latest uploads';

  @override
  String get revisionSetupStartButton => 'Start Express Session';

  @override
  String get revisionSetupNoItems =>
      'No revision items are ready yet. Complete a game first.';

  @override
  String get revisionSessionTitle => 'Express Session';

  @override
  String get revisionSessionNoSession =>
      'No revision session is ready yet.\nUpload and complete a game to unlock revision.';

  @override
  String get revisionSessionLoading => 'Loading prompt...';

  @override
  String get revisionSessionFinish => 'Finish';

  @override
  String get revisionSessionNext => 'Next';

  @override
  String get revisionResultsTitle => 'Express Complete!';

  @override
  String revisionResultsSubtitle(int correct) {
    return 'You sharpened $correct key concepts.';
  }

  @override
  String revisionResultsAccuracy(int correct, int total) {
    return 'Accuracy: $correct/$total';
  }

  @override
  String revisionResultsTotalXp(int xp) {
    return 'Total XP: $xp';
  }

  @override
  String get revisionResultsBackHome => 'Back to Home';

  @override
  String get revisionResultsSeeProgress => 'See Progress';

  @override
  String get packDetailDefaultTitle => 'Learning Pack';

  @override
  String get packDetailNoPack => 'No pack selected yet.';

  @override
  String get packDetailNoGamesTitle => 'No generated games yet';

  @override
  String get packDetailNoGamesMessage =>
      'Upload or regenerate this document to create games.';

  @override
  String get packDetailStartSession => 'Start Session';

  @override
  String get packSessionDefaultTitle => 'Session Roadmap';

  @override
  String packSessionSubtitle(int minutes) {
    return '$minutes minute guided flow.';
  }

  @override
  String get packSessionNoGamesTitle => 'No ready games';

  @override
  String get packSessionNoGamesMessage =>
      'Finish document processing, then start the session.';

  @override
  String get packSessionStartNow => 'Start Now';

  @override
  String get packSessionNoGamesSnackBar =>
      'No generated games are ready for this pack yet.';

  @override
  String get packsListTitle => 'Learning Packs';

  @override
  String get funFactBrainPowerTitle => 'Brain Power';

  @override
  String get funFactBrainPower =>
      'Your brain uses about 20% of your body\'s energy, even though it\'s only 2% of your weight!';

  @override
  String get funFactOctopusTitle => 'Octopus Smarts';

  @override
  String get funFactOctopus =>
      'Octopuses have 9 brains! One central brain and a mini-brain in each of their 8 arms.';

  @override
  String get funFactSchoolTitle => 'School History';

  @override
  String get funFactSchool =>
      'The world\'s oldest school is in Morocco - it\'s been teaching students since 859 AD!';

  @override
  String get funFactMemoryTitle => 'Memory Trick';

  @override
  String get funFactMemory =>
      'You remember things better when you learn them right before sleep. Sweet dreams = smart dreams!';

  @override
  String get funFactGameTitle => 'Game Learning';

  @override
  String get funFactGame =>
      'Playing educational games can improve memory by up to 30%. You\'re doing great!';

  @override
  String get funFactLanguageTitle => 'Language Fun';

  @override
  String get funFactLanguage =>
      'Kids who learn multiple subjects together remember 40% more than studying one at a time.';

  @override
  String get funFactSpaceTitle => 'Space Fact';

  @override
  String get funFactSpace =>
      'Astronauts study for years! NASA training takes about 2 years of intense learning.';

  @override
  String get funFactMusicTitle => 'Music & Math';

  @override
  String get funFactMusic =>
      'Learning music helps with math! Both use patterns and counting in similar ways.';

  @override
  String get funFactAnimalTitle => 'Animal Teachers';

  @override
  String get funFactAnimal =>
      'Meerkats teach their babies how to eat scorpions by bringing them dead ones first!';

  @override
  String get funFactPencilTitle => 'Pencil Power';

  @override
  String get funFactPencil =>
      'The average pencil can write about 45,000 words. That\'s a lot of homework!';

  @override
  String get funFactColorTitle => 'Color Memory';

  @override
  String get funFactColor =>
      'You remember colorful things better! That\'s why highlighters help you study.';

  @override
  String get funFactElephantTitle => 'Elephant Memory';

  @override
  String get funFactElephant =>
      'Elephants really do have great memories - they can remember friends for decades!';

  @override
  String get funFactQuickTitle => 'Quick Learner';

  @override
  String get funFactQuick =>
      'Your brain can process an image in just 13 milliseconds. Faster than a blink!';

  @override
  String get funFactDreamTitle => 'Dream Learning';

  @override
  String get funFactDream =>
      'Your brain replays what you learned during the day while you dream!';

  @override
  String get funFactPracticeTitle => 'Practice Perfect';

  @override
  String get funFactPractice =>
      'It takes about 10,000 hours of practice to become an expert at something.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get noChildProfile => 'No child profile available.';

  @override
  String get noImageSelected => 'No image selected.';

  @override
  String get missingDocumentId => 'Missing document ID.';

  @override
  String get missingPackId => 'Missing learning pack id for retry.';

  @override
  String get documentProcessingFailed => 'Document processing failed.';

  @override
  String get packMissingId => 'Pack missing id.';

  @override
  String get resultSyncSkipped =>
      'Game result sync skipped: missing childId/packId/gameId.';

  @override
  String get processingStepUploading => 'Uploading';

  @override
  String get processingStepProcessing => 'Processing';

  @override
  String get processingStepGenerating => 'Generating';

  @override
  String get processingStepCreatingGames => 'Creating games';

  @override
  String statusWithProgress(int progress, String message) {
    return '$progress% • $message';
  }
}
