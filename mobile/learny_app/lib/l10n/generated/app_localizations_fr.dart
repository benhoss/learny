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
}
