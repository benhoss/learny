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
  String get quizSaveAndExit => 'Save & Exit';

  @override
  String get quizSetupTitle => 'Build Your Quiz';

  @override
  String get quizSetupSubtitle => 'Choose how many questions you want today.';

  @override
  String quizSetupCountValue(int count) {
    return '$count questions';
  }

  @override
  String get quizSetupFunLineShort =>
      'Quick sprint mode. Fast focus, big wins.';

  @override
  String get quizSetupFunLineMedium =>
      'Balanced challenge unlocked. You got this.';

  @override
  String get quizSetupFunLineLong => 'Legend mode activated. Deep focus time.';

  @override
  String get quizSetupStartButton => 'Start My Quiz';

  @override
  String quizSetupResumeHint(int remaining) {
    return 'You have $remaining questions left in your saved quiz.';
  }

  @override
  String get quizSetupResumeButton => 'Resume Saved Quiz';

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
  String get statusQuickScanQueued => 'Quick scan queued...';

  @override
  String get statusQuickScanProcessing => 'Running quick scan...';

  @override
  String get statusAwaitingValidation => 'Awaiting your validation...';

  @override
  String get statusQuickScanFailed => 'Quick scan failed. Please retry.';

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
  String get stageQuickScanQueue => 'Quick Scan Queue';

  @override
  String get stageQuickScanProcessing => 'Quick Scan';

  @override
  String get stageAwaitingValidation => 'Awaiting Validation';

  @override
  String get stageQuickScanFailed => 'Quick Scan Failed';

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
  String get docStatusQuickScanQueued => 'Quick scan queue';

  @override
  String get docStatusQuickScanProcessing => 'Quick scan';

  @override
  String get docStatusQuickScanFailed => 'Quick scan failed';

  @override
  String get docStatusAwaitingValidation => 'Awaiting validation';

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
  String get uploadTitleLabel => 'Title (optional)';

  @override
  String get uploadTitleHint => 'e.g. Observation and interpretation';

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
  String uploadSuggestionFeedback(int percent) {
    return 'Suggested from current context (confidence $percent%). Edit any field before continuing.';
  }

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
  String reviewSuggestionFeedback(int percent) {
    return 'Suggested from capture context (confidence $percent%). Edit any field before continuing.';
  }

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
  String get librarySearchHint => 'Search documents and packs';

  @override
  String get libraryFilterSubject => 'Subject';

  @override
  String get libraryFilterTopic => 'Topic';

  @override
  String get libraryFilterGrade => 'Grade';

  @override
  String get libraryFilterLanguage => 'Language';

  @override
  String get libraryClearFilters => 'Clear filters';

  @override
  String get libraryDocumentsSection => 'Documents';

  @override
  String get libraryPacksSection => 'Learning Packs';

  @override
  String get libraryNoDocumentsMatch => 'No documents match your filters.';

  @override
  String get libraryNoPacksMatch => 'No packs match your filters.';

  @override
  String get librarySmartCategoriesTitle => 'Smart Categories';

  @override
  String get librarySmartCategoriesSubtitle =>
      'Auto-classified by subject and topic.';

  @override
  String get libraryCollectionsTitle => 'Collections';

  @override
  String get libraryCollectionsSubtitle => 'Your manual groupings per child.';

  @override
  String get libraryCollectionsEmpty =>
      'No collections yet. Add one when reviewing a document.';

  @override
  String get libraryRecentUploadsTitle => 'Recent uploads';

  @override
  String get libraryRecentUploadsSubtitle => 'Latest documents first.';

  @override
  String get libraryUnclassifiedTitle => 'Unclassified';

  @override
  String get libraryUnclassifiedSubtitle =>
      'Missing subject/topic/grade metadata.';

  @override
  String get libraryFilterClear => 'Clear';

  @override
  String get libraryFilterDone => 'Done';

  @override
  String get uploadTopicHint => 'e.g. Fractions, Grammar, World War II';

  @override
  String get uploadGradeLabel => 'Grade';

  @override
  String get uploadGradeHint => 'e.g. 5th Grade';

  @override
  String get uploadCollectionsLabel => 'Collections (comma separated)';

  @override
  String get uploadCollectionsHint => 'e.g. Emma Exam Week, Homework';

  @override
  String get uploadTagsLabel => 'Tags (comma separated)';

  @override
  String get uploadTagsHint => 'e.g. fractions, verbs';

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

  @override
  String get switchProfile => 'Switch Profile';

  @override
  String get switchProfileHint => 'Tap a profile to switch';

  @override
  String get accountSettingsEmailLabel => 'Email';

  @override
  String get accountSettingsGradeRangeLabel => 'Preferred grade range';

  @override
  String get accountSettingsNameLabel => 'Name';

  @override
  String get accountSettingsSaveChanges => 'Save Changes';

  @override
  String get accountSettingsSubtitle =>
      'Manage parent profile and preferences.';

  @override
  String get accountSettingsTitle => 'Account Settings';

  @override
  String get achievementsSubtitle => 'Celebrate wins big and small.';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get cameraCaptureChooseMultiplePages => 'Choose Multiple Pages';

  @override
  String get cameraCaptureChooseSinglePhoto => 'Choose Single Photo';

  @override
  String get cameraCaptureSubtitle => 'Frame the worksheet and snap a photo.';

  @override
  String get cameraCaptureTakePhoto => 'Take Photo';

  @override
  String get cameraCaptureTitle => 'Snap Homework';

  @override
  String get cameraCaptureUploadPdfInstead => 'Upload PDF Instead';

  @override
  String get childSelectorSubtitle => 'Switch between children.';

  @override
  String get childSelectorTitle => 'Child Profiles';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClear => 'Clear';

  @override
  String contactSupportFrom(String email) {
    return 'From: $email';
  }

  @override
  String get contactSupportMessageLabel => 'Message';

  @override
  String get contactSupportSendMessage => 'Send Message';

  @override
  String get contactSupportSubtitle => 'We usually respond within 24 hours.';

  @override
  String get contactSupportTitle => 'Contact Support';

  @override
  String get contactSupportTopicLabel => 'Topic';

  @override
  String get createProfileAvatarDino => 'Dino';

  @override
  String get createProfileAvatarFox => 'Fox';

  @override
  String get createProfileAvatarFoxBuddy => 'Fox Buddy';

  @override
  String get createProfileAvatarOwl => 'Owl';

  @override
  String get createProfileAvatarPenguin => 'Penguin';

  @override
  String get createProfileAvatarRobot => 'Robot';

  @override
  String deleteAccountBody(String name) {
    return 'Deleting $name\'s account will remove all child profiles and documents. This cannot be undone.';
  }

  @override
  String get deleteAccountConfirmDelete => 'Confirm Delete';

  @override
  String get deleteAccountSubtitle => 'This action is permanent.';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get emptyStateSubtitle => 'Upload a worksheet to get started.';

  @override
  String get emptyStateTitle => 'Nothing Here Yet';

  @override
  String get errorStateSubtitle => 'We could not process the document.';

  @override
  String get errorStateTitle => 'Something Went Wrong';

  @override
  String get errorStateTryAgain => 'Try Again';

  @override
  String get faqSubtitle => 'Answers to common questions.';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get forgotPasswordEmailAddressLabel => 'Email address';

  @override
  String get forgotPasswordSendLink => 'Send Link';

  @override
  String get forgotPasswordSubtitle =>
      'We\'ll send a reset link to your email.';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get homeTabHome => 'Home';

  @override
  String get homeTabPacks => 'Packs';

  @override
  String get homeTabProgress => 'Progress';

  @override
  String get homeTabSettings => 'Settings';

  @override
  String learningTimeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get learningTimeSubtitle => 'Minutes per day';

  @override
  String get learningTimeTitle => 'Learning Time';

  @override
  String get loginButton => 'Log In';

  @override
  String get loginCreateAccountPrompt => 'New here? Create an account';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginSubtitle =>
      'Log in to continue your child\'s learning journey.';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get masteryDetailsEmptySubtitle =>
      'Upload and complete games to build concept mastery.';

  @override
  String get masteryDetailsNoDataSubtitle =>
      'Run at least one generated game to populate this view.';

  @override
  String get masteryDetailsNoDataTitle => 'No mastery data yet';

  @override
  String get masteryDetailsSubtitle =>
      'Concept-level breakdown from your uploaded study content.';

  @override
  String get masteryDetailsTitle => 'Mastery Details';

  @override
  String get masteryStatusMastered => 'Mastered';

  @override
  String get masteryStatusNeedsReview => 'Needs review';

  @override
  String get masteryStatusPracticing => 'Practicing';

  @override
  String masteryStatusWithPercent(String label, int percent) {
    return '$label • $percent%';
  }

  @override
  String get notificationsMarkRead => 'Mark read';

  @override
  String get notificationsSubtitle => 'Friendly nudges for parents and kids.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get offlineRetry => 'Retry';

  @override
  String get offlineSubtitle => 'Check your connection to sync progress.';

  @override
  String get offlineTitle => 'You\'re Offline';

  @override
  String get onboardingConsentAgreeButton => 'Agree & Continue';

  @override
  String get onboardingConsentCoppaSubtitle =>
      'Parent consent required before use.';

  @override
  String get onboardingConsentCoppaTitle => 'COPPA-friendly';

  @override
  String get onboardingConsentEducatorSubtitle =>
      'Content aligns to school standards.';

  @override
  String get onboardingConsentEducatorTitle => 'Educator designed';

  @override
  String get onboardingConsentNoDataSellingSubtitle =>
      'We never share or sell personal info.';

  @override
  String get onboardingConsentNoDataSellingTitle => 'No data selling';

  @override
  String get onboardingConsentSubtitle =>
      'We keep kids safe, private, and ad-free.';

  @override
  String get onboardingConsentTitle => 'Parent Consent';

  @override
  String get onboardingCreateProfileButton => 'Create a Profile';

  @override
  String get onboardingFoxBlurb =>
      'Learny the fox keeps practice playful and focused.';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingHowItWorksSubtitle =>
      'From homework to mastery in 3 quick steps.';

  @override
  String get onboardingHowItWorksTitle => 'How It Works';

  @override
  String get onboardingStep1Subtitle =>
      'Take a photo of any worksheet or page.';

  @override
  String get onboardingStep1Title => 'Snap your homework';

  @override
  String get onboardingStep2Subtitle =>
      'Flashcards, quizzes, and matching in seconds.';

  @override
  String get onboardingStep2Title => 'AI creates learning games';

  @override
  String get onboardingStep3Subtitle =>
      'Short sessions with streaks and XP boosts.';

  @override
  String get onboardingStep3Title => 'Learn & earn rewards';

  @override
  String get onboardingWelcomeSubtitle =>
      'Your AI learning buddy for smart, playful study sessions.';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Learny!';

  @override
  String packsItemsMinutes(int itemCount, int minutes) {
    return '$itemCount items • $minutes min';
  }

  @override
  String packsMasteryProgress(int percent, int mastered, int total) {
    return '$percent% mastery • $mastered/$total concepts';
  }

  @override
  String get packsStartSession => 'Start a Session';

  @override
  String get packsSubtitle => 'Personalized packs based on homework.';

  @override
  String get packsTitle => 'Learning Packs';

  @override
  String get packsLibraryByTopicTitle => 'Library by Topic';

  @override
  String get packsLibraryByTopicSubtitle =>
      'Browse recent documents grouped by subject.';

  @override
  String get packsViewLibrary => 'View Document Library';

  @override
  String get parentDashboardActiveChild => 'Active child';

  @override
  String get parentDashboardChildSelector => 'Child Selector';

  @override
  String get parentDashboardLearningTime => 'Learning Time';

  @override
  String get parentDashboardSubtitle => 'Track progress and guide next steps.';

  @override
  String get parentDashboardTitle => 'Parent Dashboard';

  @override
  String get parentDashboardWeakAreas => 'Weak Areas';

  @override
  String get parentDashboardWeeklySummary => 'Weekly Summary';

  @override
  String get parentOnlyLabel => 'Parent only';

  @override
  String get parentPinChangeSubtitle => 'Set a new PIN for parent-only access.';

  @override
  String get parentPinChangeTitle => 'Change PIN';

  @override
  String get parentPinCodeLabel => '4-digit PIN';

  @override
  String get parentPinEnterSubtitle => 'Enter your PIN to continue.';

  @override
  String get parentPinSaveButton => 'Save PIN';

  @override
  String get parentPinUnlockButton => 'Unlock Parent Settings';

  @override
  String get parentSettingsChildProfiles => 'Child profiles';

  @override
  String get parentSettingsParentProfile => 'Parent profile';

  @override
  String parentSettingsProfilesCount(int count) {
    return '$count profiles';
  }

  @override
  String get parentSettingsProtectSubtitle => 'Protect parent-only settings.';

  @override
  String get parentSettingsSetChangePin => 'Set / Change PIN';

  @override
  String get parentSettingsSubscription => 'Subscription';

  @override
  String get parentSettingsSubtitle =>
      'Manage subscription and family controls.';

  @override
  String get parentSettingsTitle => 'Parent Settings';

  @override
  String get planAlreadyHaveAccount => 'Already have an account? Log in';

  @override
  String get planChooseSubtitle => 'Start free. Upgrade anytime.';

  @override
  String get planChooseTitle => 'Choose Your Plan';

  @override
  String get planFamilySubtitle => 'Up to 4 child profiles';

  @override
  String get planFamilyTitle => 'Family';

  @override
  String get planFreeSubtitle => '3 packs per month';

  @override
  String get planFreeTitle => 'Free';

  @override
  String get planProSubtitle => 'Unlimited packs + games';

  @override
  String get planProTitle => 'Pro';

  @override
  String get safetyPrivacyCoppaSubtitle => 'Parental consent required';

  @override
  String get safetyPrivacyCoppaTitle => 'COPPA compliant';

  @override
  String get safetyPrivacyEncryptedSubtitle => 'Files are protected';

  @override
  String get safetyPrivacyEncryptedTitle => 'Encrypted storage';

  @override
  String get safetyPrivacyNoAdsSubtitle => 'We do not monetize data';

  @override
  String get safetyPrivacyNoAdsTitle => 'No ads, no selling';

  @override
  String get safetyPrivacySubtitle => 'Built for kids, trusted by parents.';

  @override
  String get safetyPrivacyTitle => 'Safety & Privacy';

  @override
  String get settingsClearAllConfirm =>
      'This clears all learning memory signals. Continue?';

  @override
  String get settingsClearAllLearningMemorySubtitle =>
      'Events, revision, game results, mastery.';

  @override
  String get settingsClearAllLearningMemoryTitle => 'Clear all learning memory';

  @override
  String get settingsClearEventsOnlySubtitle => 'Keeps mastery and results.';

  @override
  String get settingsClearEventsOnlyTitle => 'Clear events only';

  @override
  String get settingsClearMemoryScopeTitle => 'Clear Memory Scope';

  @override
  String get settingsClearRevisionSessionsSubtitle =>
      'Removes quick revision history.';

  @override
  String get settingsClearRevisionSessionsTitle => 'Clear revision sessions';

  @override
  String settingsClearScopeConfirm(String scope) {
    return 'Clear memory scope \"$scope\"?';
  }

  @override
  String get settingsConfirmClearMemoryTitle => 'Confirm clear memory';

  @override
  String get settingsDeleteAccountSubtitle => 'This is a destructive action.';

  @override
  String get settingsDetailLevelBrief => 'Brief';

  @override
  String get settingsDetailLevelDetailed => 'Detailed';

  @override
  String settingsLastReset(String scope, String time) {
    return 'Last reset: $scope at $time';
  }

  @override
  String get settingsLearningMemoryTitle => 'Learning Memory';

  @override
  String get settingsNoRecentMemoryReset => 'No recent memory reset.';

  @override
  String get settingsNotificationsSubtitle =>
      'Get updates about new packs and streaks.';

  @override
  String get settingsNotificationsTitle => 'Notifications';

  @override
  String get settingsPersonalizedRecommendationsSubtitle =>
      'Use activity history to adapt next steps.';

  @override
  String get settingsPersonalizedRecommendationsTitle =>
      'Personalized Recommendations';

  @override
  String get settingsRationaleDetailLevelTitle => 'Rationale Detail Level';

  @override
  String get settingsRecommendationRationaleSubtitle =>
      'Display \"why this suggestion\" explanations.';

  @override
  String get settingsRecommendationRationaleTitle =>
      'Show Recommendation Rationale';

  @override
  String get settingsSoundEffectsSubtitle => 'Play sounds during games.';

  @override
  String get settingsSoundEffectsTitle => 'Sound Effects';

  @override
  String get settingsStudyRemindersSubtitle =>
      'Daily reminders for short sessions.';

  @override
  String get settingsStudyRemindersTitle => 'Study Reminders';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsUnknownScope => 'unknown';

  @override
  String get signupCreateAccount => 'Create Account';

  @override
  String get signupFullNameLabel => 'Full name';

  @override
  String get signupLoginPrompt => 'Already have an account? Log in';

  @override
  String get signupSubtitle =>
      'Set up a secure parent profile to manage learning.';

  @override
  String get signupTitle => 'Create Parent Account';

  @override
  String streaksRewardsBadges(int count) {
    return '$count badges';
  }

  @override
  String get streaksRewardsCurrentStreak => 'Current streak';

  @override
  String streaksRewardsDays(int count) {
    return '$count days';
  }

  @override
  String get streaksRewardsSubtitle => 'Keep the momentum going!';

  @override
  String get streaksRewardsTitle => 'Streaks & Rewards';

  @override
  String get streaksRewardsUnlocked => 'Rewards unlocked';

  @override
  String subscriptionCurrentPlan(String plan) {
    return 'Current plan: $plan';
  }

  @override
  String get subscriptionPlanIncluded =>
      'Full access included with the free plan.';

  @override
  String get subscriptionSubtitle =>
      'Learny is free to use. Parents can upgrade anytime.';

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String get subscriptionUpgradePlan => 'Upgrade Plan';

  @override
  String get upgradePlanContinueToCheckout => 'Continue to Checkout';

  @override
  String get upgradePlanSubtitle =>
      'Unlock unlimited packs and parent insights.';

  @override
  String get upgradePlanTitle => 'Upgrade Plan';

  @override
  String get verifyEmailCodeLabel => 'Verification code';

  @override
  String get verifyEmailContinueToApp => 'Continue to App';

  @override
  String get verifyEmailResendCode => 'Resend code';

  @override
  String get verifyEmailSubtitle =>
      'We\'ve sent a 6-digit code to parent@example.com.';

  @override
  String get verifyEmailTitle => 'Verify Your Email';

  @override
  String get weakAreasSubtitle => 'Focus zones to review next.';

  @override
  String get weakAreasTitle => 'Weak Areas';

  @override
  String get weeklySummaryAchievements => 'Achievements';

  @override
  String weeklySummaryNewBadges(int count) {
    return '$count new badges';
  }

  @override
  String get weeklySummarySessionsCompleted => 'Sessions completed';

  @override
  String weeklySummarySessionsValue(int count) {
    return '$count sessions';
  }

  @override
  String get weeklySummarySubtitle => 'Highlights from the past 7 days.';

  @override
  String get weeklySummaryTimeSpent => 'Time spent';

  @override
  String weeklySummaryTimeSpentValue(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get weeklySummaryTitle => 'Weekly Summary';

  @override
  String get weeklySummaryTopSubject => 'Top subject';

  @override
  String processingAlternativesLabel(String alternatives) {
    return 'Alternatives: $alternatives';
  }

  @override
  String processingConfidenceLabel(int percent, String modelSuffix) {
    return 'Confidence: $percent%$modelSuffix';
  }

  @override
  String get processingConfirmGenerate => 'Confirm & Generate';

  @override
  String get processingLanguageLabel => 'Language';

  @override
  String get processingNoAlternatives => 'No alternatives suggested.';

  @override
  String get processingRescan => 'Rescan';

  @override
  String get processingStarting => 'Starting...';

  @override
  String get processingTopicLabel => 'Topic';

  @override
  String get processingTopicLanguageRequired =>
      'Topic and language are required to continue.';

  @override
  String get processingValidateScanSubtitle =>
      'Confirm or edit the topic and language before deep generation starts.';

  @override
  String get processingValidateScanTitle => 'Validate AI scan';

  @override
  String progressActivitySummary(int percent, String scoreLabel, int xp) {
    return '$percent% • $scoreLabel • +$xp XP';
  }

  @override
  String get progressCouldNotRegenerateDocument =>
      'Could not regenerate document right now.';

  @override
  String progressCouldNotReopen(String error) {
    return 'Could not reopen this subject: $error';
  }

  @override
  String progressCouldNotStartRegenerationFor(String gameType) {
    return 'Could not start regeneration for $gameType.';
  }

  @override
  String get progressDeltaNew => 'New';

  @override
  String get progressDocumentRegenerationStarted =>
      'Document regeneration started.';

  @override
  String get progressGenerateNewGameTypeSubtitle =>
      'Choose a type to regenerate from this document';

  @override
  String get progressGenerateNewGameTypeTitle => 'Generate New Game Type';

  @override
  String get progressLatestCheerEmpty =>
      'Upload a document and complete a game to start your momentum.';

  @override
  String get progressLoadOlderActivity => 'Load older activity';

  @override
  String get progressMetricAvgScore => 'Avg score';

  @override
  String get progressMetricRecentXp => 'Recent XP';

  @override
  String get progressMetricSessions => 'Sessions';

  @override
  String get progressMetricStreak => 'Streak';

  @override
  String progressMetricStreakValue(int days) {
    return '${days}d';
  }

  @override
  String get progressMomentumBuilding => 'Building momentum';

  @override
  String get progressMomentumExcellent => 'Excellent momentum';

  @override
  String get progressMomentumReady => 'Ready to start';

  @override
  String get progressMomentumSteady => 'Steady momentum';

  @override
  String get progressNewGameType => 'New Game Type';

  @override
  String get progressNoActivitySubtitle =>
      'Play a generated game to see results and motivation here.';

  @override
  String get progressNoActivityTitle => 'No activity yet';

  @override
  String get progressNoReadyGames =>
      'No ready games found for this subject yet.';

  @override
  String get progressOpenOverview => 'Open Progress Overview';

  @override
  String get progressOverviewAreasToFocus => 'Areas to Focus';

  @override
  String get progressOverviewBadges => 'Badges';

  @override
  String get progressOverviewDayStreak => 'Day Streak';

  @override
  String progressOverviewLevelLearner(int level) {
    return 'Level $level Learner';
  }

  @override
  String get progressOverviewMastery => 'Mastery';

  @override
  String progressOverviewMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get progressOverviewSessions => 'Sessions';

  @override
  String get progressOverviewTitle => 'Your Progress';

  @override
  String get progressOverviewTopSubject => 'Top Subject';

  @override
  String get progressOverviewTopicMastery => 'Topic Mastery';

  @override
  String get progressOverviewTopicMasteryEmpty =>
      'Complete some lessons to see your mastery!';

  @override
  String progressOverviewTotalXp(int xp) {
    return '$xp XP total';
  }

  @override
  String progressOverviewXpToNextLevel(int xpToNext, int nextLevel) {
    return '$xpToNext XP to Level $nextLevel';
  }

  @override
  String get progressOverviewXpToday => 'XP Today';

  @override
  String get progressPastActivityTitle => 'Past Activity';

  @override
  String get progressRedoDocument => 'Redo Document';

  @override
  String get progressRedoSubject => 'Redo Subject';

  @override
  String get progressRefresh => 'Refresh';

  @override
  String progressRegenerationStartedFor(String gameType) {
    return 'Regeneration started for $gameType.';
  }

  @override
  String get progressScoreBandImproving => 'Improving';

  @override
  String get progressScoreBandKeepGoing => 'Keep Going';

  @override
  String get progressScoreBandStrong => 'Strong';

  @override
  String progressScoreLabel(int correct, int total) {
    return '$correct/$total correct';
  }

  @override
  String get progressSubtitle => 'Past results, trends, and what to redo next.';

  @override
  String progressWeeklyMastery(int percent) {
    return '$percent% mastery across this week\'s packs';
  }

  @override
  String get progressWeeklyProgressTitle => 'Weekly Progress';
}
