// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class L10nNl extends L10n {
  L10nNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Learny';

  @override
  String get homeGreeting => 'Goedemorgen,';

  @override
  String get homeWelcomeMessage =>
      'Klaar om iets nieuws te leren vandaag? Laten we je schoollessen omzetten in leuke spelletjes!';

  @override
  String get homeStartLearningTitle => 'Begin met leren';

  @override
  String get homeStartLearningSubtitle => 'Upload je les en speel';

  @override
  String get homeRevisionExpressTitle => 'Herhaling Express';

  @override
  String get homeRevisionExpressSubtitle => 'Snelle herhaling van 5 minuten';

  @override
  String get homeSmartNextSteps => 'Slimme volgende stappen';

  @override
  String get homeNoRecommendations =>
      'Upload een document om AI-aanbevelingen te krijgen op basis van je studiegegevens.';

  @override
  String get homeContinueLearning => 'Verder leren';

  @override
  String get homeBasedOnActivity => 'Op basis van je recente activiteit';

  @override
  String get homeWhyThis => 'Waarom?';

  @override
  String get homeThisWeek => 'Deze week';

  @override
  String homeProgressMessage(int sessionsCompleted) {
    return 'Je hebt $sessionsCompleted leersessies voltooid. Goed gedaan!';
  }

  @override
  String homeReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count concepten te herhalen',
      one: '1 concept te herhalen',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewSubtitle => 'Herhaal nu om te blijven leren!';

  @override
  String get homeAchievements => 'Prestaties';

  @override
  String get homeProgress => 'Voortgang';

  @override
  String get homePackMastery => 'Pakketbeheersing';

  @override
  String get homeWhyRecommendation => 'Waarom deze aanbeveling?';

  @override
  String get homeRecommendation => 'Aanbeveling';

  @override
  String get homeNoExplainability =>
      'Geen extra uitleg beschikbaar voor deze suggestie.';

  @override
  String get homeClose => 'Sluiten';

  @override
  String get quizCorrectFeedback => 'Je bent goed bezig!';

  @override
  String get quizIncorrectFeedback => 'Bekijk de uitleg en ga verder.';

  @override
  String get quizNoQuizMessage => 'Er is nog geen quiz klaar voor dit pakket.';

  @override
  String get quizUploadDocument => 'Document uploaden';

  @override
  String get quizYourAnswer => 'Jouw antwoord';

  @override
  String get quizTypeAnswerHint => 'Typ je antwoord hier...';

  @override
  String get quizSelectAllThatApply => 'Selecteer alle juiste antwoorden';

  @override
  String get quizDragIntoOrder => 'Sleep de items in de juiste volgorde';

  @override
  String get quizLoadingQuestion => 'Vraag laden...';

  @override
  String get quizCheckAnswer => 'Controleren';

  @override
  String get quizFinish => 'Afronden';

  @override
  String quizProgress(int current, int total) {
    return 'Vraag $current van $total';
  }

  @override
  String get quizEmptyProgress => 'Vraag 0 / 0';

  @override
  String get gameTypeTrueFalse => 'Waar of Niet Waar';

  @override
  String get gameTypeMultiSelect => 'Kies alle juiste antwoorden';

  @override
  String get gameTypeFillBlank => 'Vul het gat in';

  @override
  String get gameTypeShortAnswer => 'Kort antwoord';

  @override
  String get gameTypeOrdering => 'Zet in de juiste volgorde';

  @override
  String get gameTypeMatching => 'Koppel de paren';

  @override
  String get gameTypeFlashcards => 'Geheugenkaarten';

  @override
  String get gameTypeQuiz => 'Snelle quiz';

  @override
  String get gameSubtitleTrueFalse => 'Snelle beoordelingen';

  @override
  String get gameSubtitleMultiSelect => 'Meerdere juiste antwoorden';

  @override
  String get gameSubtitleFillBlank => 'Maak de zin af';

  @override
  String get gameSubtitleShortAnswer => 'Schrijf een kort antwoord';

  @override
  String get gameSubtitleOrdering => 'Sleep in de juiste volgorde';

  @override
  String get gameSubtitleMatching => 'Koppel gerelateerde concepten';

  @override
  String get gameSubtitleFlashcards => 'Opwarmconcepten';

  @override
  String get gameSubtitleQuiz => 'Meerkeuzevragen';

  @override
  String get trueFalseTrue => 'Waar';

  @override
  String get trueFalseFalse => 'Niet waar';

  @override
  String get flashcardsDefaultTitle => 'Geheugenkaarten';

  @override
  String get flashcardsFront => 'Voorkant';

  @override
  String get flashcardsBack => 'Achterkant';

  @override
  String flashcardsProgress(int current, int total) {
    return 'Kaart $current van $total';
  }

  @override
  String get flashcardsEmptyProgress => 'Kaart 0 / 0';

  @override
  String get flashcardsFlipCard => 'Omdraaien';

  @override
  String get flashcardsFinish => 'Afronden';

  @override
  String get flashcardsGotItNext => 'Begrepen! Volgende';

  @override
  String get flashcardsQuestion => 'Vraag';

  @override
  String get flashcardsAnswer => 'Antwoord';

  @override
  String get flashcardsTapToFlip => 'Tik om te draaien';

  @override
  String get matchingDefaultTitle => 'Koppelspel';

  @override
  String get matchingSubtitle => 'Tik op twee bij elkaar horende items';

  @override
  String get matchingNoItems => 'Geen koppelparen beschikbaar.';

  @override
  String matchingProgress(int matched, int total) {
    return '$matched van $total paren gekoppeld';
  }

  @override
  String get matchingContinue => 'Doorgaan';

  @override
  String get matchingMismatch => 'Niet helemaal - probeer opnieuw!';

  @override
  String get resultsGreatJob => 'Goed gedaan!';

  @override
  String resultsSubtitle(int xp) {
    return 'Je hebt $xp XP verdiend in deze ronde en je reeks behouden.';
  }

  @override
  String get resultsSyncError =>
      'Synchronisatie is vertraagd. We proberen het automatisch opnieuw.';

  @override
  String get resultsFinishSession => 'Sessie afronden';

  @override
  String get resultsContinue => 'Doorgaan';

  @override
  String get resultsReviewMistakes => 'Fouten bekijken';

  @override
  String get resultsSeeProgress => 'Voortgang bekijken';

  @override
  String get resultsBackToHome => 'Terug naar start';

  @override
  String get resultsRetryMistakes => 'Fouten opnieuw proberen';

  @override
  String get processingReadyTitle => 'Klaar om te leren!';

  @override
  String get processingTitle => 'Je quiz wordt gemaakt';

  @override
  String get processingGoBack => 'Terug';

  @override
  String get processingTransfer => 'Overdracht';

  @override
  String get processingAI => 'AI-verwerking';

  @override
  String get processingSuccessTitle => 'Je quiz is klaar!';

  @override
  String get processingSuccessMessage => 'Spring erin terwijl het vers is.';

  @override
  String get processingSuccessDetail =>
      'Gepersonaliseerde spelletjes gemaakt van je document';

  @override
  String get processingErrorTitle => 'Er ging iets mis';

  @override
  String get processingErrorHint =>
      'Probeer een duidelijker beeld of een ander document te uploaden.';

  @override
  String get processingStartFlashcards => 'Start geheugenkaarten';

  @override
  String get processingStartMatching => 'Start koppelspel';

  @override
  String get processingStartTrueFalse => 'Start Waar/Niet waar';

  @override
  String get processingStartMultiSelect => 'Start meerkeuze';

  @override
  String get processingStartFillBlank => 'Start invuloefening';

  @override
  String get processingStartShortAnswer => 'Start kort antwoord';

  @override
  String get processingStartOrdering => 'Start sorteerspel';

  @override
  String get processingStartQuiz => 'Start de quiz';

  @override
  String get processingStartLearning => 'Begin met leren';

  @override
  String get statusQueued => 'In de wachtrij...';

  @override
  String get statusOcr => 'Je document lezen...';

  @override
  String get statusConceptQueueing => 'Concepten voorbereiden...';

  @override
  String get statusConceptExtraction => 'Kernconcepten extraheren...';

  @override
  String get statusPackQueueing => 'Leerpakket voorbereiden...';

  @override
  String get statusPackGeneration => 'Leerpakket samenstellen...';

  @override
  String get statusGameQueueing => 'Spelletjes voorbereiden...';

  @override
  String get statusGameGeneration => 'Spelletjes en quizzen genereren...';

  @override
  String get statusReady => 'Quiz klaar!';

  @override
  String get statusOcrFailed => 'Lezen mislukt. Probeer opnieuw.';

  @override
  String get statusConceptExtractionFailed =>
      'Extractie mislukt. Probeer opnieuw.';

  @override
  String get statusPackGenerationFailed =>
      'Pakketgeneratie mislukt. Probeer opnieuw.';

  @override
  String get statusGameGenerationFailed =>
      'Spelgeneratie mislukt. Probeer opnieuw.';

  @override
  String get statusProcessing => 'Document verwerken...';

  @override
  String get statusGenerating => 'Leerinhoud genereren...';

  @override
  String get statusFirstGameReady =>
      'Eerste spel klaar. Rest wordt afgemaakt...';

  @override
  String get statusUploadingDocument => 'Document uploaden...';

  @override
  String get statusProcessingAndGenerating => 'Verwerken en quiz genereren...';

  @override
  String get statusGenerationFailed => 'Generatie mislukt';

  @override
  String get statusCreatingGames => 'Spelletjes en quizzen maken...';

  @override
  String get statusGenerationTimedOut => 'Generatie verlopen. Probeer opnieuw.';

  @override
  String get stageFirstGameReady => 'Eerste spel klaar';

  @override
  String get stageQueued => 'Wachtrij';

  @override
  String get stageOcr => 'Lezen';

  @override
  String get stageConceptQueue => 'Conceptwachtrij';

  @override
  String get stageConceptExtraction => 'Extractie';

  @override
  String get stagePackQueue => 'Pakketwachtrij';

  @override
  String get stagePackGeneration => 'Pakketgeneratie';

  @override
  String get stageGameQueue => 'Spelwachtrij';

  @override
  String get stageGameGeneration => 'Spelgeneratie';

  @override
  String get stageReady => 'Klaar';

  @override
  String get stageOcrFailed => 'Lezen mislukt';

  @override
  String get stageConceptFailed => 'Extractie mislukt';

  @override
  String get stagePackFailed => 'Pakket mislukt';

  @override
  String get stageGameFailed => 'Spel mislukt';

  @override
  String get stageProcessing => 'Verwerking';

  @override
  String get stageProcessed => 'Verwerkt';

  @override
  String get docStatusQueued => 'Wachtrij';

  @override
  String get docStatusProcessing => 'Verwerking';

  @override
  String get docStatusProcessed => 'Verwerkt';

  @override
  String get docStatusReady => 'Klaar';

  @override
  String get docStatusFailed => 'Mislukt';

  @override
  String get docStatusUnknown => 'Onbekend';

  @override
  String get uploadTitle => 'Bestand uploaden';

  @override
  String get uploadSubtitle => 'PDF\'s en afbeeldingen ondersteund.';

  @override
  String get uploadDragOrBrowse => 'Sleep of blader';

  @override
  String get uploadSubjectLabel => 'Vak (optioneel)';

  @override
  String get uploadSubjectHint => 'bijv. Franse werkwoorden';

  @override
  String get uploadLanguageLabel => 'Taal (optioneel)';

  @override
  String get uploadLanguageHint => 'bijv. Frans';

  @override
  String get uploadGoalLabel => 'Leerdoel (optioneel)';

  @override
  String get uploadGoalHint => 'bijv. Vervoeging tegenwoordige tijd';

  @override
  String get uploadContextLabel => 'Extra context (optioneel)';

  @override
  String get uploadContextHint => 'Notities om de quizgeneratie te begeleiden';

  @override
  String get uploadAnalyzing => 'Analyseren...';

  @override
  String get uploadSuggestMetadata => 'Suggereren met AI';

  @override
  String get uploadSuggestionUnavailable => 'Suggestie nu niet beschikbaar.';

  @override
  String get uploadChooseFile => 'Bestand kiezen';

  @override
  String get createProfileTitle => 'Klaar om te beginnen!';

  @override
  String get createProfileSubtitle => 'Laten we samen leren.';

  @override
  String get createProfileNameLabel => 'Profielnaam';

  @override
  String get createProfileNameHint => 'Jouw naam';

  @override
  String get createProfileAvatarLabel => 'Kies je avatar';

  @override
  String get createProfileContinue => 'Doorgaan';

  @override
  String get createProfileLanguageLabel => 'Taal';

  @override
  String get feedbackCorrect => 'Correct!';

  @override
  String get feedbackIncorrect => 'Niet helemaal';

  @override
  String get feedbackContinue => 'Doorgaan';

  @override
  String resultSummaryAccuracy(int correct, int total) {
    return '$correct van $total correct';
  }

  @override
  String get resultSummaryStreak => 'Reeks';

  @override
  String resultSummaryStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen',
      one: '1 dag',
    );
    return '$_temp0';
  }

  @override
  String get resultSummaryMastery => 'Beheersing';

  @override
  String get reviewScreenTitle => 'Opname bekijken';

  @override
  String get reviewScreenSubtitle =>
      'Bijsnijden, draaien of opnieuw maken indien nodig.';

  @override
  String get reviewAddPage => 'Pagina toevoegen';

  @override
  String get reviewLooksGood => 'Ziet er goed uit';

  @override
  String get reviewRetake => 'Opnieuw maken';

  @override
  String get libraryTitle => 'Documentbibliotheek';

  @override
  String get librarySubtitle => 'Je geüploade werkbladen en PDF\'s.';

  @override
  String get libraryAddNew => 'Nieuw document';

  @override
  String get librarySyncButton => 'Synchroniseren';

  @override
  String get libraryRegenerateTooltip => 'Quiz opnieuw genereren';

  @override
  String get revisionSetupTitle => 'Herhaling Express';

  @override
  String get revisionSetupSubtitle =>
      'Snelle boost van 5 minuten voor een toets.';

  @override
  String get revisionSetupDuration => 'Duur';

  @override
  String get revisionSetupDurationValue => '5 minuten';

  @override
  String get revisionSetupSubjectFocus => 'Vak';

  @override
  String get revisionSetupPickPack => 'Kies een pakket';

  @override
  String get revisionSetupAdaptiveMix => 'Adaptieve mix';

  @override
  String get revisionSetupAdaptiveFull =>
      'Te herhalen concepten + recente fouten + laatste uploads';

  @override
  String get revisionSetupAdaptivePartial => 'Recente fouten + laatste uploads';

  @override
  String get revisionSetupStartButton => 'Sessie starten';

  @override
  String get revisionSetupNoItems =>
      'Nog geen herhalingsitems beschikbaar. Maak eerst een spel af.';

  @override
  String get revisionSessionTitle => 'Express sessie';

  @override
  String get revisionSessionNoSession =>
      'Nog geen sessie beschikbaar.\nUpload en maak een spel af om herhaling te ontgrendelen.';

  @override
  String get revisionSessionLoading => 'Laden...';

  @override
  String get revisionSessionFinish => 'Afronden';

  @override
  String get revisionSessionNext => 'Volgende';

  @override
  String get revisionResultsTitle => 'Herhaling voltooid!';

  @override
  String revisionResultsSubtitle(int correct) {
    return 'Je hebt $correct kernconcepten aangescherpt.';
  }

  @override
  String revisionResultsAccuracy(int correct, int total) {
    return 'Nauwkeurigheid: $correct/$total';
  }

  @override
  String revisionResultsTotalXp(int xp) {
    return 'Totaal XP: $xp';
  }

  @override
  String get revisionResultsBackHome => 'Terug naar start';

  @override
  String get revisionResultsSeeProgress => 'Voortgang bekijken';

  @override
  String get packDetailDefaultTitle => 'Leerpakket';

  @override
  String get packDetailNoPack => 'Nog geen pakket geselecteerd.';

  @override
  String get packDetailNoGamesTitle => 'Nog geen spelletjes';

  @override
  String get packDetailNoGamesMessage =>
      'Upload of genereer dit document opnieuw om spelletjes te maken.';

  @override
  String get packDetailStartSession => 'Sessie starten';

  @override
  String get packSessionDefaultTitle => 'Sessieschema';

  @override
  String packSessionSubtitle(int minutes) {
    return 'Begeleide sessie van $minutes minuten.';
  }

  @override
  String get packSessionNoGamesTitle => 'Geen klare spelletjes';

  @override
  String get packSessionNoGamesMessage =>
      'Maak de documentverwerking af en start dan de sessie.';

  @override
  String get packSessionStartNow => 'Nu starten';

  @override
  String get packSessionNoGamesSnackBar =>
      'Er zijn nog geen spelletjes klaar voor dit pakket.';

  @override
  String get packsListTitle => 'Leerpakketten';

  @override
  String get funFactBrainPowerTitle => 'Hersenkracht';

  @override
  String get funFactBrainPower =>
      'Je hersenen gebruiken ongeveer 20% van de energie van je lichaam, terwijl ze maar 2% van je gewicht zijn!';

  @override
  String get funFactOctopusTitle => 'Slimme octopus';

  @override
  String get funFactOctopus =>
      'Octopussen hebben 9 hersenen! Een centraal brein en een minibrein in elk van hun 8 armen.';

  @override
  String get funFactSchoolTitle => 'Schoolgeschiedenis';

  @override
  String get funFactSchool =>
      'De oudste school ter wereld is in Marokko - daar wordt al les gegeven sinds 859 na Christus!';

  @override
  String get funFactMemoryTitle => 'Geheugentip';

  @override
  String get funFactMemory =>
      'Je onthoudt dingen beter als je ze vlak voor het slapen leert. Mooie dromen = slimme dromen!';

  @override
  String get funFactGameTitle => 'Spelend leren';

  @override
  String get funFactGame =>
      'Educatieve spelletjes kunnen het geheugen met 30% verbeteren. Goed bezig!';

  @override
  String get funFactLanguageTitle => 'Taalfeit';

  @override
  String get funFactLanguage =>
      'Kinderen die meerdere vakken samen leren, onthouden 40% meer.';

  @override
  String get funFactSpaceTitle => 'Ruimtefeit';

  @override
  String get funFactSpace =>
      'Astronauten studeren jarenlang! NASA-training duurt ongeveer 2 jaar.';

  @override
  String get funFactMusicTitle => 'Muziek en wiskunde';

  @override
  String get funFactMusic =>
      'Muziek leren helpt bij wiskunde! Beide gebruiken patronen en tellen.';

  @override
  String get funFactAnimalTitle => 'Dierenleraren';

  @override
  String get funFactAnimal =>
      'Stokstaartjes leren hun baby\'s schorpioenen te eten door eerst dode te brengen!';

  @override
  String get funFactPencilTitle => 'Potloodkracht';

  @override
  String get funFactPencil =>
      'Een gemiddeld potlood kan ongeveer 45.000 woorden schrijven. Dat is veel huiswerk!';

  @override
  String get funFactColorTitle => 'Kleurgeheugen';

  @override
  String get funFactColor =>
      'Je onthoudt kleurrijke dingen beter! Daarom helpen markeerstiften bij het studeren.';

  @override
  String get funFactElephantTitle => 'Olifantengeheugen';

  @override
  String get funFactElephant =>
      'Olifanten hebben echt een geweldig geheugen - ze herinneren zich vrienden tientallen jaren!';

  @override
  String get funFactQuickTitle => 'Snel leren';

  @override
  String get funFactQuick =>
      'Je hersenen kunnen een beeld verwerken in slechts 13 milliseconden. Sneller dan een knipoog!';

  @override
  String get funFactDreamTitle => 'Dromend leren';

  @override
  String get funFactDream =>
      'Je hersenen spelen overdag geleerde dingen opnieuw af terwijl je droomt!';

  @override
  String get funFactPracticeTitle => 'Oefening baart kunst';

  @override
  String get funFactPractice =>
      'Het kost ongeveer 10.000 uur oefening om ergens expert in te worden.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get noChildProfile => 'Geen kindprofiel beschikbaar.';

  @override
  String get noImageSelected => 'Geen afbeelding geselecteerd.';

  @override
  String get missingDocumentId => 'Document-ID ontbreekt.';

  @override
  String get missingPackId => 'Pakket-ID ontbreekt voor opnieuw proberen.';

  @override
  String get documentProcessingFailed => 'Documentverwerking mislukt.';

  @override
  String get packMissingId => 'Pakket heeft geen ID.';

  @override
  String get resultSyncSkipped =>
      'Synchronisatie overgeslagen: childId/packId/gameId ontbreekt.';

  @override
  String get processingStepUploading => 'Uploaden';

  @override
  String get processingStepProcessing => 'Verwerken';

  @override
  String get processingStepGenerating => 'Genereren';

  @override
  String get processingStepCreatingGames => 'Spellen maken';

  @override
  String statusWithProgress(int progress, String message) {
    return '$progress% • $message';
  }
}
