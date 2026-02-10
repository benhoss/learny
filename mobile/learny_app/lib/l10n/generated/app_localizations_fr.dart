// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class L10nFr extends L10n {
  L10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Learny';

  @override
  String get homeGreeting => 'Bonjour,';

  @override
  String get homeWelcomeMessage =>
      'Prêt à apprendre quelque chose de nouveau aujourd\'hui ? Transformons tes leçons en jeux amusants !';

  @override
  String get homeStartLearningTitle => 'Commencer';

  @override
  String get homeStartLearningSubtitle => 'Importe ta leçon et joue';

  @override
  String get homeRevisionExpressTitle => 'Révision Express';

  @override
  String get homeRevisionExpressSubtitle => 'Révision rapide de 5 minutes';

  @override
  String get homeSmartNextSteps => 'Prochaines étapes';

  @override
  String get homeNoRecommendations =>
      'Importe un document pour obtenir des recommandations basées sur tes données d\'étude.';

  @override
  String get homeContinueLearning => 'Continuer à apprendre';

  @override
  String get homeBasedOnActivity => 'Basé sur ton activité récente';

  @override
  String get homeWhyThis => 'Pourquoi ?';

  @override
  String get homeThisWeek => 'Cette semaine';

  @override
  String homeProgressMessage(int sessionsCompleted) {
    return 'Tu as complété $sessionsCompleted sessions d\'apprentissage. Bravo !';
  }

  @override
  String homeReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count concepts à revoir',
      one: '1 concept à revoir',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewSubtitle =>
      'Révise maintenant pour continuer à progresser !';

  @override
  String get homeAchievements => 'Succès';

  @override
  String get homeProgress => 'Progrès';

  @override
  String get homePackMastery => 'Maîtrise des packs';

  @override
  String get homeWhyRecommendation => 'Pourquoi cette recommandation ?';

  @override
  String get homeRecommendation => 'Recommandation';

  @override
  String get homeNoExplainability =>
      'Pas d\'explication supplémentaire disponible pour cette suggestion.';

  @override
  String get homeClose => 'Fermer';

  @override
  String get quizCorrectFeedback => 'Tu es en forme !';

  @override
  String get quizIncorrectFeedback => 'Revois l\'explication et continue.';

  @override
  String get quizNoQuizMessage => 'Aucun quiz n\'est encore prêt pour ce pack.';

  @override
  String get quizUploadDocument => 'Importer un document';

  @override
  String get quizYourAnswer => 'Ta réponse';

  @override
  String get quizTypeAnswerHint => 'Tape ta réponse ici...';

  @override
  String get quizSelectAllThatApply => 'Sélectionne toutes les bonnes réponses';

  @override
  String get quizDragIntoOrder => 'Glisse les éléments dans le bon ordre';

  @override
  String get quizLoadingQuestion => 'Chargement de la question...';

  @override
  String get quizCheckAnswer => 'Vérifier';

  @override
  String get quizFinish => 'Terminer';

  @override
  String quizProgress(int current, int total) {
    return 'Question $current sur $total';
  }

  @override
  String get quizEmptyProgress => 'Question 0 / 0';

  @override
  String get quizSaveAndExit => 'Sauvegarder et quitter';

  @override
  String get quizSetupTitle => 'Compose ton quiz';

  @override
  String get quizSetupSubtitle =>
      'Choisis le nombre de questions pour aujourd\'hui.';

  @override
  String quizSetupCountValue(int count) {
    return '$count questions';
  }

  @override
  String get quizSetupFunLineShort => 'Mode sprint. Rapide, fun, efficace.';

  @override
  String get quizSetupFunLineMedium => 'Défi équilibré activé. Tu gères.';

  @override
  String get quizSetupFunLineLong => 'Mode légende activé. Focus maximal.';

  @override
  String get quizSetupStartButton => 'Lancer mon quiz';

  @override
  String quizSetupResumeHint(int remaining) {
    return 'Il te reste $remaining questions dans ton quiz sauvegardé.';
  }

  @override
  String get quizSetupResumeButton => 'Reprendre le quiz sauvegardé';

  @override
  String get gameTypeTrueFalse => 'Vrai ou Faux';

  @override
  String get gameTypeMultiSelect => 'Choisis toutes les bonnes réponses';

  @override
  String get gameTypeFillBlank => 'Complète la phrase';

  @override
  String get gameTypeShortAnswer => 'Réponse courte';

  @override
  String get gameTypeOrdering => 'Remets dans l\'ordre';

  @override
  String get gameTypeMatching => 'Associer les paires';

  @override
  String get gameTypeFlashcards => 'Cartes mémoire';

  @override
  String get gameTypeQuiz => 'Quiz rapide';

  @override
  String get gameSubtitleTrueFalse => 'Jugements rapides';

  @override
  String get gameSubtitleMultiSelect => 'Plusieurs bonnes réponses';

  @override
  String get gameSubtitleFillBlank => 'Complète la phrase';

  @override
  String get gameSubtitleShortAnswer => 'Écris une réponse courte';

  @override
  String get gameSubtitleOrdering => 'Glisse dans le bon ordre';

  @override
  String get gameSubtitleMatching => 'Associe les concepts liés';

  @override
  String get gameSubtitleFlashcards => 'Révise les concepts';

  @override
  String get gameSubtitleQuiz => 'Questions à choix multiples';

  @override
  String get trueFalseTrue => 'Vrai';

  @override
  String get trueFalseFalse => 'Faux';

  @override
  String get flashcardsDefaultTitle => 'Cartes mémoire';

  @override
  String get flashcardsFront => 'Recto';

  @override
  String get flashcardsBack => 'Verso';

  @override
  String flashcardsProgress(int current, int total) {
    return 'Carte $current sur $total';
  }

  @override
  String get flashcardsEmptyProgress => 'Carte 0 / 0';

  @override
  String get flashcardsFlipCard => 'Retourner';

  @override
  String get flashcardsFinish => 'Terminer';

  @override
  String get flashcardsGotItNext => 'Compris ! Suivant';

  @override
  String get flashcardsQuestion => 'Question';

  @override
  String get flashcardsAnswer => 'Réponse';

  @override
  String get flashcardsTapToFlip => 'Appuie pour retourner';

  @override
  String get matchingDefaultTitle => 'Jeu d\'association';

  @override
  String get matchingSubtitle => 'Touche deux éléments correspondants';

  @override
  String get matchingNoItems => 'Aucune paire disponible.';

  @override
  String matchingProgress(int matched, int total) {
    return '$matched paires sur $total trouvées';
  }

  @override
  String get matchingContinue => 'Continuer';

  @override
  String get matchingMismatch => 'Pas tout à fait - réessaie !';

  @override
  String get resultsGreatJob => 'Bravo !';

  @override
  String resultsSubtitle(int xp) {
    return 'Tu as gagné $xp XP dans cette manche et maintenu ta série.';
  }

  @override
  String get resultsSyncError =>
      'La synchronisation est retardée. Nous réessaierons automatiquement.';

  @override
  String get resultsFinishSession => 'Terminer la session';

  @override
  String get resultsContinue => 'Continuer';

  @override
  String get resultsReviewMistakes => 'Revoir les erreurs';

  @override
  String get resultsSeeProgress => 'Voir les progrès';

  @override
  String get resultsBackToHome => 'Retour à l\'accueil';

  @override
  String get resultsRetryMistakes => 'Réessayer les erreurs';

  @override
  String get processingReadyTitle => 'Prêt à apprendre !';

  @override
  String get processingTitle => 'Création de ton quiz';

  @override
  String get processingGoBack => 'Retour';

  @override
  String get processingTransfer => 'Transfert';

  @override
  String get processingAI => 'Traitement IA';

  @override
  String get processingSuccessTitle => 'Ton quiz est prêt !';

  @override
  String get processingSuccessMessage => 'Lance-toi pendant que c\'est frais.';

  @override
  String get processingSuccessDetail =>
      'Jeux personnalisés créés à partir de ton document';

  @override
  String get processingErrorTitle => 'Quelque chose n\'a pas fonctionné';

  @override
  String get processingErrorHint =>
      'Essaie d\'importer une image plus claire ou un autre document.';

  @override
  String get processingStartFlashcards => 'Commencer les cartes';

  @override
  String get processingStartMatching => 'Commencer l\'association';

  @override
  String get processingStartTrueFalse => 'Commencer Vrai/Faux';

  @override
  String get processingStartMultiSelect => 'Commencer Multi-choix';

  @override
  String get processingStartFillBlank => 'Commencer Texte à trous';

  @override
  String get processingStartShortAnswer => 'Commencer Réponse courte';

  @override
  String get processingStartOrdering => 'Commencer le tri';

  @override
  String get processingStartQuiz => 'Commencer le quiz';

  @override
  String get processingStartLearning => 'Commencer';

  @override
  String get statusQueued => 'En attente...';

  @override
  String get statusOcr => 'Lecture de ton document...';

  @override
  String get statusConceptQueueing => 'Préparation des concepts...';

  @override
  String get statusConceptExtraction => 'Extraction des concepts clés...';

  @override
  String get statusPackQueueing => 'Préparation du pack...';

  @override
  String get statusPackGeneration => 'Construction du pack...';

  @override
  String get statusGameQueueing => 'Préparation des jeux...';

  @override
  String get statusGameGeneration => 'Génération des jeux et quiz...';

  @override
  String get statusQuickScanQueued => 'Analyse rapide en file d\'attente...';

  @override
  String get statusQuickScanProcessing => 'Exécution de l\'analyse rapide...';

  @override
  String get statusAwaitingValidation => 'En attente de votre validation...';

  @override
  String get statusQuickScanFailed =>
      'Échec de l\'analyse rapide. Veuillez réessayer.';

  @override
  String get statusReady => 'Quiz prêt !';

  @override
  String get statusOcrFailed => 'La lecture a échoué. Réessaie.';

  @override
  String get statusConceptExtractionFailed =>
      'L\'extraction a échoué. Réessaie.';

  @override
  String get statusPackGenerationFailed =>
      'La génération du pack a échoué. Réessaie.';

  @override
  String get statusGameGenerationFailed =>
      'La génération des jeux a échoué. Réessaie.';

  @override
  String get statusProcessing => 'Traitement du document...';

  @override
  String get statusGenerating => 'Génération du contenu...';

  @override
  String get statusFirstGameReady =>
      'Premier jeu prêt. Finalisation des autres jeux...';

  @override
  String get statusUploadingDocument => 'Import du document...';

  @override
  String get statusProcessingAndGenerating =>
      'Traitement et génération du quiz...';

  @override
  String get statusGenerationFailed => 'La génération a échoué';

  @override
  String get statusCreatingGames => 'Création des jeux et quiz...';

  @override
  String get statusGenerationTimedOut => 'La génération a expiré. Réessaie.';

  @override
  String get stageFirstGameReady => 'Premier jeu prêt';

  @override
  String get stageQuickScanQueue => 'File d\'attente d\'analyse rapide';

  @override
  String get stageQuickScanProcessing => 'Scan rapide';

  @override
  String get stageAwaitingValidation => 'En attente de validation';

  @override
  String get stageQuickScanFailed => 'Échec de l\'analyse rapide';

  @override
  String get stageQueued => 'En attente';

  @override
  String get stageOcr => 'Lecture';

  @override
  String get stageConceptQueue => 'File concepts';

  @override
  String get stageConceptExtraction => 'Extraction';

  @override
  String get stagePackQueue => 'File pack';

  @override
  String get stagePackGeneration => 'Génération pack';

  @override
  String get stageGameQueue => 'File jeux';

  @override
  String get stageGameGeneration => 'Génération jeux';

  @override
  String get stageReady => 'Prêt';

  @override
  String get stageOcrFailed => 'Lecture échouée';

  @override
  String get stageConceptFailed => 'Extraction échouée';

  @override
  String get stagePackFailed => 'Pack échoué';

  @override
  String get stageGameFailed => 'Jeux échoués';

  @override
  String get stageProcessing => 'Traitement';

  @override
  String get stageProcessed => 'Traité';

  @override
  String get docStatusQueued => 'En attente';

  @override
  String get docStatusQuickScanQueued => 'File d\'attente d\'analyse rapide';

  @override
  String get docStatusQuickScanProcessing => 'anayse rapide';

  @override
  String get docStatusQuickScanFailed => 'Échec de l\'analyse rapide';

  @override
  String get docStatusAwaitingValidation => 'En attente de validation';

  @override
  String get docStatusProcessing => 'Traitement';

  @override
  String get docStatusProcessed => 'Traité';

  @override
  String get docStatusReady => 'Prêt';

  @override
  String get docStatusFailed => 'Échoué';

  @override
  String get docStatusUnknown => 'Inconnu';

  @override
  String get uploadTitle => 'Importer un fichier';

  @override
  String get uploadSubtitle => 'PDF et images acceptés.';

  @override
  String get uploadDragOrBrowse => 'Glisse ou parcours';

  @override
  String get uploadTitleLabel => 'Titre (optionnel)';

  @override
  String get uploadTitleHint => 'ex. Observation et interprétation';

  @override
  String get uploadSubjectLabel => 'Matière (optionnel)';

  @override
  String get uploadSubjectHint => 'ex. Verbes français';

  @override
  String get uploadLanguageLabel => 'Langue (optionnel)';

  @override
  String get uploadLanguageHint => 'ex. Français';

  @override
  String get uploadGoalLabel => 'Objectif (optionnel)';

  @override
  String get uploadGoalHint => 'ex. Conjugaison au présent';

  @override
  String get uploadContextLabel => 'Contexte supplémentaire (optionnel)';

  @override
  String get uploadContextHint => 'Notes pour guider la génération du quiz';

  @override
  String get uploadAnalyzing => 'Analyse...';

  @override
  String uploadSuggestionFeedback(int percent) {
    return 'Suggestion basée sur le contexte actuel (confiance $percent%). Modifie les champs avant de continuer.';
  }

  @override
  String get uploadSuggestMetadata => 'Suggérer avec l\'IA';

  @override
  String get uploadSuggestionUnavailable =>
      'Suggestion indisponible pour le moment.';

  @override
  String get uploadChooseFile => 'Choisir un fichier';

  @override
  String get createProfileTitle => 'C\'est parti !';

  @override
  String get createProfileSubtitle => 'Apprenons ensemble.';

  @override
  String get createProfileNameLabel => 'Nom du profil';

  @override
  String get createProfileNameHint => 'Ton prénom';

  @override
  String get createProfileAvatarLabel => 'Choisis ton avatar';

  @override
  String get createProfileContinue => 'Continuer';

  @override
  String get createProfileLanguageLabel => 'Langue';

  @override
  String get feedbackCorrect => 'Correct !';

  @override
  String get feedbackIncorrect => 'Pas tout à fait';

  @override
  String get feedbackContinue => 'Continuer';

  @override
  String resultSummaryAccuracy(int correct, int total) {
    return '$correct sur $total correct';
  }

  @override
  String get resultSummaryStreak => 'Série';

  @override
  String resultSummaryStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get resultSummaryMastery => 'Maîtrise';

  @override
  String get reviewScreenTitle => 'Vérifier la capture';

  @override
  String get reviewScreenSubtitle =>
      'Recadre, tourne ou reprends si nécessaire.';

  @override
  String get reviewAddPage => 'Ajouter une page';

  @override
  String get reviewLooksGood => 'C\'est bon';

  @override
  String reviewSuggestionFeedback(int percent) {
    return 'Suggestion basée sur la capture (confiance $percent%). Modifie les champs avant de continuer.';
  }

  @override
  String get reviewRetake => 'Reprendre';

  @override
  String get libraryTitle => 'Bibliothèque';

  @override
  String get librarySubtitle => 'Tes documents importés.';

  @override
  String get libraryAddNew => 'Nouveau document';

  @override
  String get librarySyncButton => 'Synchroniser';

  @override
  String get libraryRegenerateTooltip => 'Re-générer le quiz';

  @override
  String get revisionSetupTitle => 'Révision Express';

  @override
  String get revisionSetupSubtitle =>
      'Boost rapide de 5 minutes avant un contrôle.';

  @override
  String get revisionSetupDuration => 'Durée';

  @override
  String get revisionSetupDurationValue => '5 minutes';

  @override
  String get revisionSetupSubjectFocus => 'Matière';

  @override
  String get revisionSetupPickPack => 'Choisis un pack';

  @override
  String get revisionSetupAdaptiveMix => 'Mix adaptatif';

  @override
  String get revisionSetupAdaptiveFull =>
      'Concepts à revoir + erreurs récentes + derniers imports';

  @override
  String get revisionSetupAdaptivePartial =>
      'Erreurs récentes + derniers imports';

  @override
  String get revisionSetupStartButton => 'Commencer la session';

  @override
  String get revisionSetupNoItems =>
      'Pas encore de révision disponible. Termine d\'abord un jeu.';

  @override
  String get revisionSessionTitle => 'Session Express';

  @override
  String get revisionSessionNoSession =>
      'Pas encore de session disponible.\nImporte et termine un jeu pour débloquer la révision.';

  @override
  String get revisionSessionLoading => 'Chargement...';

  @override
  String get revisionSessionFinish => 'Terminer';

  @override
  String get revisionSessionNext => 'Suivant';

  @override
  String get revisionResultsTitle => 'Révision terminée !';

  @override
  String revisionResultsSubtitle(int correct) {
    return 'Tu as révisé $correct concepts clés.';
  }

  @override
  String revisionResultsAccuracy(int correct, int total) {
    return 'Précision : $correct/$total';
  }

  @override
  String revisionResultsTotalXp(int xp) {
    return 'XP total : $xp';
  }

  @override
  String get revisionResultsBackHome => 'Retour à l\'accueil';

  @override
  String get revisionResultsSeeProgress => 'Voir les progrès';

  @override
  String get packDetailDefaultTitle => 'Pack d\'apprentissage';

  @override
  String get packDetailNoPack => 'Aucun pack sélectionné.';

  @override
  String get packDetailNoGamesTitle => 'Pas encore de jeux';

  @override
  String get packDetailNoGamesMessage =>
      'Importe ou regénère ce document pour créer des jeux.';

  @override
  String get packDetailStartSession => 'Commencer la session';

  @override
  String get packSessionDefaultTitle => 'Plan de session';

  @override
  String packSessionSubtitle(int minutes) {
    return 'Session guidée de $minutes minutes.';
  }

  @override
  String get packSessionNoGamesTitle => 'Pas de jeux prêts';

  @override
  String get packSessionNoGamesMessage =>
      'Termine le traitement du document, puis lance la session.';

  @override
  String get packSessionStartNow => 'Commencer';

  @override
  String get packSessionNoGamesSnackBar =>
      'Aucun jeu n\'est encore prêt pour ce pack.';

  @override
  String get packsListTitle => 'Packs d\'apprentissage';

  @override
  String get funFactBrainPowerTitle => 'Puissance cérébrale';

  @override
  String get funFactBrainPower =>
      'Ton cerveau utilise environ 20 % de l\'énergie de ton corps, alors qu\'il ne représente que 2 % de ton poids !';

  @override
  String get funFactOctopusTitle => 'Pieuvre intelligente';

  @override
  String get funFactOctopus =>
      'Les pieuvres ont 9 cerveaux ! Un cerveau central et un mini-cerveau dans chacun de leurs 8 bras.';

  @override
  String get funFactSchoolTitle => 'Histoire de l\'école';

  @override
  String get funFactSchool =>
      'La plus ancienne école du monde est au Maroc - elle enseigne depuis 859 après J.-C. !';

  @override
  String get funFactMemoryTitle => 'Astuce mémoire';

  @override
  String get funFactMemory =>
      'Tu retiens mieux quand tu apprends juste avant de dormir. Beaux rêves = rêves intelligents !';

  @override
  String get funFactGameTitle => 'Apprendre en jouant';

  @override
  String get funFactGame =>
      'Les jeux éducatifs peuvent améliorer la mémoire de 30 %. Tu fais du super boulot !';

  @override
  String get funFactLanguageTitle => 'Fun linguistique';

  @override
  String get funFactLanguage =>
      'Les enfants qui étudient plusieurs matières ensemble retiennent 40 % de plus.';

  @override
  String get funFactSpaceTitle => 'Fait spatial';

  @override
  String get funFactSpace =>
      'Les astronautes étudient pendant des années ! La formation NASA dure environ 2 ans.';

  @override
  String get funFactMusicTitle => 'Musique et maths';

  @override
  String get funFactMusic =>
      'La musique aide en maths ! Les deux utilisent des motifs et du comptage.';

  @override
  String get funFactAnimalTitle => 'Profs animaux';

  @override
  String get funFactAnimal =>
      'Les suricates apprennent à leurs petits à manger des scorpions en leur apportant des morts !';

  @override
  String get funFactPencilTitle => 'Pouvoir du crayon';

  @override
  String get funFactPencil =>
      'Un crayon peut écrire environ 45 000 mots. Ça fait beaucoup de devoirs !';

  @override
  String get funFactColorTitle => 'Mémoire colorée';

  @override
  String get funFactColor =>
      'Tu retiens mieux les choses colorées ! C\'est pour ça que les surligneurs aident à étudier.';

  @override
  String get funFactElephantTitle => 'Mémoire d\'éléphant';

  @override
  String get funFactElephant =>
      'Les éléphants ont vraiment une super mémoire - ils se souviennent de leurs amis pendant des décennies !';

  @override
  String get funFactQuickTitle => 'Apprentissage rapide';

  @override
  String get funFactQuick =>
      'Ton cerveau peut traiter une image en seulement 13 millisecondes. Plus rapide qu\'un clin d\'œil !';

  @override
  String get funFactDreamTitle => 'Apprendre en rêvant';

  @override
  String get funFactDream =>
      'Ton cerveau rejoue ce que tu as appris pendant la journée quand tu rêves !';

  @override
  String get funFactPracticeTitle => 'La pratique rend parfait';

  @override
  String get funFactPractice =>
      'Il faut environ 10 000 heures de pratique pour devenir expert en quelque chose.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get noChildProfile => 'Aucun profil enfant disponible.';

  @override
  String get noImageSelected => 'Aucune image sélectionnée.';

  @override
  String get missingDocumentId => 'ID du document manquant.';

  @override
  String get missingPackId => 'ID du pack manquant pour réessayer.';

  @override
  String get documentProcessingFailed => 'Le traitement du document a échoué.';

  @override
  String get packMissingId => 'Le pack n\'a pas d\'identifiant.';

  @override
  String get resultSyncSkipped =>
      'Synchronisation ignorée : childId/packId/gameId manquant.';

  @override
  String get processingStepUploading => 'Envoi';

  @override
  String get processingStepProcessing => 'Traitement';

  @override
  String get processingStepGenerating => 'Génération';

  @override
  String get processingStepCreatingGames => 'Création des jeux';

  @override
  String statusWithProgress(int progress, String message) {
    return '$progress % • $message';
  }

  @override
  String get switchProfile => 'Changer de profil';

  @override
  String get switchProfileHint => 'Appuie sur un profil pour changer';

  @override
  String get accountSettingsEmailLabel => 'E-mail';

  @override
  String get accountSettingsGradeRangeLabel => 'Plage de notes préférée';

  @override
  String get accountSettingsNameLabel => 'Nom';

  @override
  String get accountSettingsSaveChanges => 'Enregistrer les modifications';

  @override
  String get accountSettingsSubtitle =>
      'Gérer le profil et les préférences des parents.';

  @override
  String get accountSettingsTitle => 'Paramètres du compte';

  @override
  String get achievementsSubtitle =>
      'Je célèbre les victoires, qu’elles soient grandes ou petites.';

  @override
  String get achievementsTitle => 'Réussites';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get cameraCaptureChooseMultiplePages => 'Choisir plusieurs pages';

  @override
  String get cameraCaptureChooseSinglePhoto => 'Choisir une seule photo';

  @override
  String get cameraCaptureSubtitle =>
      'Encadrez la feuille de calcul et prenez une photo.';

  @override
  String get cameraCaptureTakePhoto => 'Prendre une photo';

  @override
  String get cameraCaptureTitle => 'Snap Homework';

  @override
  String get cameraCaptureUploadPdfInstead => 'Télécharger le PDF à la place';

  @override
  String get childSelectorSubtitle => 'Basculer entre les enfants.';

  @override
  String get childSelectorTitle => 'Profils enfants';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonClear => 'Vide';

  @override
  String contactSupportFrom(String email) {
    return 'De : $email';
  }

  @override
  String get contactSupportMessageLabel => 'Message';

  @override
  String get contactSupportSendMessage => 'Envoyer un message';

  @override
  String get contactSupportSubtitle =>
      'NOUS VOUS RÉPONDRONS DANS LES 24 HEURES';

  @override
  String get contactSupportTitle => 'Contacter le support';

  @override
  String get contactSupportTopicLabel => 'Thème';

  @override
  String get createProfileAvatarDino => 'Dino';

  @override
  String get createProfileAvatarFox => 'Renard';

  @override
  String get createProfileAvatarFoxBuddy => 'Ami Renard';

  @override
  String get createProfileAvatarOwl => 'Hibou';

  @override
  String get createProfileAvatarPenguin => 'Pingouin';

  @override
  String get createProfileAvatarRobot => 'Robot';

  @override
  String deleteAccountBody(String name) {
    return 'La suppression du compte de $name supprimera tous les profils et documents enfants. Cela ne peut pas être annulé.';
  }

  @override
  String get deleteAccountConfirmDelete => 'Confirmer la suppression';

  @override
  String get deleteAccountSubtitle => 'Cette action est permanente.';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get emptyStateSubtitle =>
      'Téléchargez une feuille de calcul pour commencer.';

  @override
  String get emptyStateTitle => 'Rien ici pour l\'instant.';

  @override
  String get errorStateSubtitle => 'Nous n\'avons pas pu traiter le document.';

  @override
  String get errorStateTitle => 'Quelque chose a mal tournée';

  @override
  String get errorStateTryAgain => 'Réessayez';

  @override
  String get faqSubtitle => '• des réponses à des questions courantes';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get forgotPasswordEmailAddressLabel => 'Adresse e-mail';

  @override
  String get forgotPasswordSendLink => 'Ajouter un lien';

  @override
  String get forgotPasswordSubtitle =>
      'Nous enverrons un lien de réinitialisation à votre adresse e-mail.';

  @override
  String get forgotPasswordTitle => 'Réinit mot de passe';

  @override
  String get homeTabHome => 'Accueil';

  @override
  String get homeTabPacks => 'Packs';

  @override
  String get homeTabProgress => 'Avancement';

  @override
  String get homeTabSettings => 'Réglages';

  @override
  String learningTimeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get learningTimeSubtitle =>
      'Une comparaison des données canadiennes et néerlandaises sur l&apos;emploi du temps montre que les adolescents néerlandais consacrent 20 minutes par jour de plus que les adolescents canadiens à l&apos;école et aux travaux scolaires, mais environ 20 minutes de moins au travail rémunéré et 10 minutes de moins aux tâches domestiques.';

  @override
  String get learningTimeTitle => 'Durée du cours';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginCreateAccountPrompt =>
      'Vous êtes nouveau ici ? Créez un compte.';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginSubtitle =>
      'Connectez-vous pour poursuivre le parcours d\'apprentissage de votre enfant.';

  @override
  String get loginTitle => 'Bienvenu à nouveau';

  @override
  String get masteryDetailsEmptySubtitle =>
      'Téléchargez et terminez des jeux pour développer la maîtrise du concept.';

  @override
  String get masteryDetailsNoDataSubtitle =>
      'Exécutez au moins un jeu généré pour remplir cette vue.';

  @override
  String get masteryDetailsNoDataTitle => 'Pas encore de données de maîtrise';

  @override
  String get masteryDetailsSubtitle =>
      'Répartition au niveau du concept à partir du contenu de votre étude téléchargé.';

  @override
  String get masteryDetailsTitle => 'Maîtrise du détail';

  @override
  String get masteryStatusMastered => 'Maitrise';

  @override
  String get masteryStatusNeedsReview =>
      'Nécessite une révision@option: check trans-unit state';

  @override
  String get masteryStatusPracticing => 'Entraînement';

  @override
  String masteryStatusWithPercent(String label, int percent) {
    return '$label • $percent%';
  }

  @override
  String get notificationsMarkRead => 'Marquer comme lu';

  @override
  String get notificationsSubtitle =>
      'Nudges amicaux pour les parents et les enfants.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get offlineRetry => 'Réessayer';

  @override
  String get offlineSubtitle =>
      'Vérifiez votre connexion pour synchroniser la progression.';

  @override
  String get offlineTitle => 'Vous êtes déconnecté(e)';

  @override
  String get onboardingConsentAgreeButton => 'accepter et poursuivre';

  @override
  String get onboardingConsentCoppaSubtitle =>
      'Consentement des parents requis avant utilisation.';

  @override
  String get onboardingConsentCoppaTitle => 'COPPA-friendly';

  @override
  String get onboardingConsentEducatorSubtitle =>
      'Le contenu est conforme aux normes de l\'école.';

  @override
  String get onboardingConsentEducatorTitle => 'Conçu par un éducateur';

  @override
  String get onboardingConsentNoDataSellingSubtitle =>
      'Nous ne partageons ni ne vendons jamais d\'informations personnelles.';

  @override
  String get onboardingConsentNoDataSellingTitle => 'Aucune vente de données';

  @override
  String get onboardingConsentSubtitle =>
      'Nous gardons les enfants en sécurité, privés et sans publicité.';

  @override
  String get onboardingConsentTitle => 'Formulaire de consentement des parents';

  @override
  String get onboardingCreateProfileButton => 'Créez un profil';

  @override
  String get onboardingFoxBlurb =>
      'Apprendre le renard permet de pratiquer de manière ludique et concentrée.';

  @override
  String get onboardingGetStarted => 'Démarrez';

  @override
  String get onboardingHowItWorksSubtitle =>
      'Des devoirs à la maîtrise en 3 étapes rapides.';

  @override
  String get onboardingHowItWorksTitle => 'Comment ça marche';

  @override
  String get onboardingStep1Subtitle =>
      'Prenez une photo de n\'importe quelle feuille de calcul ou page.';

  @override
  String get onboardingStep1Title => 'Vos devoirs';

  @override
  String get onboardingStep2Subtitle =>
      'Cartes-éclair, quiz et correspondance en quelques secondes.';

  @override
  String get onboardingStep2Title => 'L\'IA crée des jeux d\'apprentissage';

  @override
  String get onboardingStep3Subtitle =>
      'Sessions courtes avec des stries et des boosters d\'XP.';

  @override
  String get onboardingStep3Title => 'Apprendre et gagner des récompenses';

  @override
  String get onboardingWelcomeSubtitle =>
      'Votre compagnon d\'apprentissage IA pour des sessions d\'étude intelligentes et ludiques.';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue dans Learny !';

  @override
  String packsItemsMinutes(int itemCount, int minutes) {
    return '$itemCount articles • $minutes min';
  }

  @override
  String packsMasteryProgress(int percent, int mastered, int total) {
    return '$percent% Maîtrise • Concepts $mastered/$total';
  }

  @override
  String get packsStartSession => 'Débuter une séance';

  @override
  String get packsSubtitle => 'Packs personnalisés basés sur les devoirs.';

  @override
  String get packsTitle => 'Packs d\'apprentissage';

  @override
  String get packsViewLibrary => 'Bibliothèque de documents';

  @override
  String get parentDashboardActiveChild => 'Enfant actif';

  @override
  String get parentDashboardChildSelector => 'Sélecteur enfant';

  @override
  String get parentDashboardLearningTime => 'Durée du cours';

  @override
  String get parentDashboardSubtitle =>
      'Suivez les progrès et guidez les prochaines étapes.';

  @override
  String get parentDashboardTitle => 'Tableau de bord parent';

  @override
  String get parentDashboardWeakAreas => 'Points faibles';

  @override
  String get parentDashboardWeeklySummary => 'Résumé hebdomadaire';

  @override
  String get parentOnlyLabel => 'Parent seulement';

  @override
  String get parentPinChangeSubtitle =>
      'Définissez un nouveau code PIN pour l\'accès réservé aux parents.';

  @override
  String get parentPinChangeTitle => 'Modifier le code NIP';

  @override
  String get parentPinCodeLabel => 'Code à 4 chiffres';

  @override
  String get parentPinEnterSubtitle =>
      'Saisissez votre code PIN de travail pour continuer.';

  @override
  String get parentPinSaveButton => 'Enregistrer le CODE PIN';

  @override
  String get parentPinUnlockButton => 'Déverrouiller les paramètres parents';

  @override
  String get parentSettingsChildProfiles => 'Profils enfants';

  @override
  String get parentSettingsParentProfile => 'Profil parent';

  @override
  String parentSettingsProfilesCount(int count) {
    return 'Profils $count';
  }

  @override
  String get parentSettingsProtectSubtitle =>
      'Protéger les paramètres réservés aux parents.';

  @override
  String get parentSettingsSetChangePin => 'Définir / Changer le CODE PIN';

  @override
  String get parentSettingsSubscription => 'Inscription';

  @override
  String get parentSettingsSubtitle =>
      'Gérez les contrôles d\'abonnement et de famille.';

  @override
  String get parentSettingsTitle => 'paramètres parentaux';

  @override
  String get planAlreadyHaveAccount =>
      'Vous avez déjà un compte? Connectez vous';

  @override
  String get planChooseSubtitle =>
      'Commencez gratuitement. Mettez à niveau à tout moment.';

  @override
  String get planChooseTitle => 'Choisissez votre abonnement';

  @override
  String get planFamilySubtitle => 'Jusqu\'à 4 profils enfants';

  @override
  String get planFamilyTitle => 'Famille';

  @override
  String get planFreeSubtitle => '3 paquets par mois';

  @override
  String get planFreeTitle => 'Libre';

  @override
  String get planProSubtitle => 'Packs illimités + jeux';

  @override
  String get planProTitle => 'Pro';

  @override
  String get safetyPrivacyCoppaSubtitle => 'Il faut un consentement parental.';

  @override
  String get safetyPrivacyCoppaTitle => 'Conforme COPPA';

  @override
  String get safetyPrivacyEncryptedSubtitle => 'Les fichiers sont protégés';

  @override
  String get safetyPrivacyEncryptedTitle => 'Stockage chiffré';

  @override
  String get safetyPrivacyNoAdsSubtitle => 'Nous ne monétisons pas les données';

  @override
  String get safetyPrivacyNoAdsTitle => 'Aucune publicité, aucune vente';

  @override
  String get safetyPrivacySubtitle =>
      'Construit pour les enfants, approuvé par les parents.';

  @override
  String get safetyPrivacyTitle => 'Sécurité / confidentialité';

  @override
  String get settingsClearAllConfirm =>
      'Cela efface tous les signaux de mémoire d\'apprentissage. Continuer ?';

  @override
  String get settingsClearAllLearningMemorySubtitle =>
      'Événements, révision, résultats du jeu, maîtrise.';

  @override
  String get settingsClearAllLearningMemoryTitle =>
      'Effacer toute la mémoire d\'apprentissage';

  @override
  String get settingsClearEventsOnlySubtitle =>
      'Maintient la maîtrise et les résultats.';

  @override
  String get settingsClearEventsOnlyTitle => 'Supprimer les événements';

  @override
  String get settingsClearMemoryScopeTitle => 'Effacer la portée de la mémoire';

  @override
  String get settingsClearRevisionSessionsSubtitle =>
      'Supprime l\'historique des révisions rapides.';

  @override
  String get settingsClearRevisionSessionsTitle =>
      'Séances de révision claires';

  @override
  String settingsClearScopeConfirm(String scope) {
    return 'Effacer l\'étendue de mémoire « $scope » ?';
  }

  @override
  String get settingsConfirmClearMemoryTitle => 'Confirmer la mémoire claire';

  @override
  String get settingsDeleteAccountSubtitle => 'C\'est une action destructrice.';

  @override
  String get settingsDetailLevelBrief => 'Résumé';

  @override
  String get settingsDetailLevelDetailed => 'Détaillé';

  @override
  String settingsLastReset(String scope, String time) {
    return 'Dernière réinitialisation : $scope à $time';
  }

  @override
  String get settingsLearningMemoryTitle => 'Apprentissage/mémoire';

  @override
  String get settingsNoRecentMemoryReset =>
      'Aucune réinitialisation récente de la mémoire.';

  @override
  String get settingsNotificationsSubtitle =>
      'Obtenez des mises à jour sur les nouveaux packs et les nouvelles séries.';

  @override
  String get settingsNotificationsTitle => 'Notifications';

  @override
  String get settingsPersonalizedRecommendationsSubtitle =>
      'Utilisez l\'historique des activités pour adapter les prochaines étapes.';

  @override
  String get settingsPersonalizedRecommendationsTitle =>
      'Personalized Recommendations:';

  @override
  String get settingsRationaleDetailLevelTitle =>
      'Niveau de détail de la justification';

  @override
  String get settingsRecommendationRationaleSubtitle =>
      'Afficher les explications « pourquoi cette suggestion ».';

  @override
  String get settingsRecommendationRationaleTitle =>
      '<g id=\"1\">Recommandation/Justification </g>';

  @override
  String get settingsSoundEffectsSubtitle => 'Jouer des sons pendant les jeux.';

  @override
  String get settingsSoundEffectsTitle => 'Effets Sonores';

  @override
  String get settingsStudyRemindersSubtitle =>
      'Rappels quotidiens pour les courtes sessions.';

  @override
  String get settingsStudyRemindersTitle => 'Rappels de l\'étude';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsUnknownScope => 'inconnu';

  @override
  String get signupCreateAccount => 'Créer compte';

  @override
  String get signupFullNameLabel => 'Nom complet';

  @override
  String get signupLoginPrompt => 'Vous avez déjà un compte? Connectez vous';

  @override
  String get signupSubtitle =>
      'Configurez un profil parent sécurisé pour gérer l\'apprentissage.';

  @override
  String get signupTitle => 'Créez votre compte parent';

  @override
  String streaksRewardsBadges(int count) {
    return 'Badges $count';
  }

  @override
  String get streaksRewardsCurrentStreak => 'Série actuelle';

  @override
  String streaksRewardsDays(int count) {
    return '$count jours';
  }

  @override
  String get streaksRewardsSubtitle => 'Continuez sur votre lancée. ';

  @override
  String get streaksRewardsTitle => 'Streaks et récompenses';

  @override
  String get streaksRewardsUnlocked => 'Récompenses débloquées';

  @override
  String subscriptionCurrentPlan(String plan) {
    return 'Formule actuelle : $plan';
  }

  @override
  String get subscriptionPlanIncluded =>
      'Accès complet inclus avec le plan gratuit.';

  @override
  String get subscriptionSubtitle =>
      'Learny est gratuit à utiliser. Les parents peuvent mettre à niveau à tout moment.';

  @override
  String get subscriptionTitle => 'Inscription';

  @override
  String get subscriptionUpgradePlan => 'Mettre à niveau l\'abonnement';

  @override
  String get upgradePlanContinueToCheckout => 'Continuer à la caisse';

  @override
  String get upgradePlanSubtitle =>
      'Débloquez des packs illimités et des informations sur les parents.';

  @override
  String get upgradePlanTitle => 'Mettre à niveau l\'abonnement';

  @override
  String get verifyEmailCodeLabel => 'Code de vérification';

  @override
  String get verifyEmailContinueToApp => 'Continuer vers l\'application';

  @override
  String get verifyEmailResendCode => 'Renvoyer le code';

  @override
  String get verifyEmailSubtitle =>
      'Nous avons envoyé un code à 6 chiffres à parent@example.com.';

  @override
  String get verifyEmailTitle => 'Vérifier votre courriel';

  @override
  String get weakAreasSubtitle => 'Zones de concentration à examiner ensuite.';

  @override
  String get weakAreasTitle => 'Points faibles';

  @override
  String get weeklySummaryAchievements => 'Réussites';

  @override
  String weeklySummaryNewBadges(int count) {
    return '$count nouveaux badges';
  }

  @override
  String get weeklySummarySessionsCompleted => 'Sessions terminées :';

  @override
  String weeklySummarySessionsValue(int count) {
    return '$count sessions';
  }

  @override
  String get weeklySummarySubtitle => 'Faits marquants des 7 derniers jours.';

  @override
  String get weeklySummaryTimeSpent => 'Temps utilisé';

  @override
  String weeklySummaryTimeSpentValue(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get weeklySummaryTitle => 'Résumé hebdomadaire';

  @override
  String get weeklySummaryTopSubject => 'Sujet principal';

  @override
  String processingAlternativesLabel(String alternatives) {
    return 'Alternatives : $alternatives';
  }

  @override
  String processingConfidenceLabel(int percent, String modelSuffix) {
    return 'Confiance : $percent%$modelSuffix';
  }

  @override
  String get processingConfirmGenerate => 'Confirmer et générer';

  @override
  String get processingLanguageLabel => 'Langue';

  @override
  String get processingNoAlternatives => 'Aucune alternative suggérée.';

  @override
  String get processingRescan => 'Balayer à nouveau';

  @override
  String get processingStarting => 'Démarrage...';

  @override
  String get processingTopicLabel => 'Thème';

  @override
  String get processingTopicLanguageRequired =>
      'Le sujet et la langue sont requis pour continuer.';

  @override
  String get processingValidateScanSubtitle =>
      'Confirmez ou modifiez le sujet et la langue avant le début de la génération approfondie.';

  @override
  String get processingValidateScanTitle => 'Valider l\'analyse de l\'IA';

  @override
  String progressActivitySummary(int percent, String scoreLabel, int xp) {
    return '$percent% • $scoreLabel • +$xp XP';
  }

  @override
  String get progressCouldNotRegenerateDocument =>
      'Impossible de régénérer le document pour le moment.';

  @override
  String progressCouldNotReopen(String error) {
    return 'Impossible de rouvrir ce sujet : $error';
  }

  @override
  String progressCouldNotStartRegenerationFor(String gameType) {
    return 'Impossible de démarrer la régénération pour $gameType.';
  }

  @override
  String get progressDeltaNew => 'Nouveau';

  @override
  String get progressDocumentRegenerationStarted =>
      'La régénération du document a commencé.';

  @override
  String get progressGenerateNewGameTypeSubtitle =>
      'Choisissez un type à régénérer à partir de ce document';

  @override
  String get progressGenerateNewGameTypeTitle =>
      'Générer un nouveau type de jeu';

  @override
  String get progressLatestCheerEmpty =>
      'Téléchargez un document et terminez un jeu pour démarrer votre dynamique.';

  @override
  String get progressLoadOlderActivity => 'Charger une activité plus ancienne';

  @override
  String get progressMetricAvgScore => 'Score moy.';

  @override
  String get progressMetricRecentXp => 'XP récente';

  @override
  String get progressMetricSessions => 'Sessions';

  @override
  String get progressMetricStreak => 'Série';

  @override
  String progressMetricStreakValue(int days) {
    return '${days}d';
  }

  @override
  String get progressMomentumBuilding => 'Avancer plus vite et mieux';

  @override
  String get progressMomentumExcellent => 'Excellente dynamique';

  @override
  String get progressMomentumReady => 'Prêtes au démarrage';

  @override
  String get progressMomentumSteady => 'Un élan constant';

  @override
  String get progressNewGameType => 'Nouveau type de jeu';

  @override
  String get progressNoActivitySubtitle =>
      'Jouez à un jeu généré pour voir les résultats et la motivation ici.';

  @override
  String get progressNoActivityTitle => 'Aucune activité pour l\'instant';

  @override
  String get progressNoReadyGames =>
      'Aucun jeu prêt trouvé pour ce sujet pour le moment.';

  @override
  String get progressOpenOverview => 'Aperçu de la progression';

  @override
  String get progressOverviewAreasToFocus => 'Domaines prioritaires';

  @override
  String get progressOverviewBadges => 'Badges';

  @override
  String get progressOverviewDayStreak => 'Day Streak';

  @override
  String progressOverviewLevelLearner(int level) {
    return 'Niveau $level Étudiant';
  }

  @override
  String get progressOverviewMastery => 'Maîtrise';

  @override
  String progressOverviewMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get progressOverviewSessions => 'Sessions';

  @override
  String get progressOverviewTitle => 'Votre progression';

  @override
  String get progressOverviewTopSubject => 'Sujet principal';

  @override
  String get progressOverviewTopicMastery => 'Maîtrise du sujet';

  @override
  String get progressOverviewTopicMasteryEmpty =>
      'Complétez quelques leçons pour voir votre maîtrise !';

  @override
  String progressOverviewTotalXp(int xp) {
    return '$xp XP total';
  }

  @override
  String progressOverviewXpToNextLevel(int xpToNext, int nextLevel) {
    return '$xpToNext XP au niveau $nextLevel';
  }

  @override
  String get progressOverviewXpToday => 'XP aujourd\'hui';

  @override
  String get progressPastActivityTitle => 'Activité passée';

  @override
  String get progressRedoDocument => 'Refaire le document';

  @override
  String get progressRedoSubject => 'Refaire le sujet';

  @override
  String get progressRefresh => 'Actualiser';

  @override
  String progressRegenerationStartedFor(String gameType) {
    return 'La régénération a commencé pour $gameType.';
  }

  @override
  String get progressScoreBandImproving => 'En amélioration';

  @override
  String get progressScoreBandKeepGoing => 'Continue';

  @override
  String get progressScoreBandStrong => 'Fort';

  @override
  String progressScoreLabel(int correct, int total) {
    return '$correct/$total correct';
  }

  @override
  String get progressSubtitle =>
      'Résultats passés, tendances et quoi refaire ensuite.';

  @override
  String progressWeeklyMastery(int percent) {
    return '$percent% maîtrise des packs de cette semaine';
  }

  @override
  String get progressWeeklyProgressTitle => 'Progrès hebdomadaire';
}
