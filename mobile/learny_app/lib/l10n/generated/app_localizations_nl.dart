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
  String get quizSaveAndExit => 'Opslaan en afsluiten';

  @override
  String get quizSetupTitle => 'Stel je quiz samen';

  @override
  String get quizSetupSubtitle => 'Kies hoeveel vragen je vandaag wilt.';

  @override
  String quizSetupCountValue(int count) {
    return '$count vragen';
  }

  @override
  String get quizSetupFunLineShort => 'Sprintmodus. Snel, scherp en klaar.';

  @override
  String get quizSetupFunLineMedium => 'Gebalanceerde uitdaging. Jij kunt dit.';

  @override
  String get quizSetupFunLineLong =>
      'Legendemodus actief. Tijd voor diepe focus.';

  @override
  String get quizSetupStartButton => 'Start mijn quiz';

  @override
  String quizSetupResumeHint(int remaining) {
    return 'Je hebt nog $remaining vragen in je opgeslagen quiz.';
  }

  @override
  String get quizSetupResumeButton => 'Hervat opgeslagen quiz';

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
  String get statusQuickScanQueued => 'Quick scan in de wachtrij...';

  @override
  String get statusQuickScanProcessing => 'Quick scan wordt uitgevoerd...';

  @override
  String get statusAwaitingValidation => 'In afwachting van uw validatie...';

  @override
  String get statusQuickScanFailed =>
      'Snelle scan mislukt. Probeer het opnieuw.';

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
  String get stageQuickScanQueue => 'Snelle scanwachtrij';

  @override
  String get stageQuickScanProcessing => 'Quick Scan';

  @override
  String get stageAwaitingValidation => 'In afwachting van bevestiging';

  @override
  String get stageQuickScanFailed => 'Snelle scan mislukt';

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
  String get docStatusQuickScanQueued => 'Quick scan queue';

  @override
  String get docStatusQuickScanProcessing => 'Quick Scan';

  @override
  String get docStatusAwaitingValidation => 'In afwachting van bevestiging';

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

  @override
  String get switchProfile => 'Wissel van profiel';

  @override
  String get switchProfileHint => 'Tik op een profiel om te wisselen';

  @override
  String get accountSettingsEmailLabel => 'E-mail';

  @override
  String get accountSettingsGradeRangeLabel => 'Voorkeursrangbereik';

  @override
  String get accountSettingsNameLabel => 'Naam';

  @override
  String get accountSettingsSaveChanges => 'Wijzigingen opslaan';

  @override
  String get accountSettingsSubtitle =>
      'Beheer bovenliggend profiel en voorkeuren.';

  @override
  String get accountSettingsTitle => 'Accountinstellingen';

  @override
  String get achievementsSubtitle => 'Celebrate wint groot en klein.';

  @override
  String get achievementsTitle => 'Prestaties';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authPasswordLabel => 'Wachtwoord';

  @override
  String get cameraCaptureChooseMultiplePages => 'Meerdere pagina\'s kiezen';

  @override
  String get cameraCaptureChooseSinglePhoto => 'Kies enkele foto';

  @override
  String get cameraCaptureSubtitle => 'Kader het werkblad in en maak een foto.';

  @override
  String get cameraCaptureTakePhoto => 'Foto maken';

  @override
  String get cameraCaptureTitle => 'Snap huiswerk';

  @override
  String get cameraCaptureUploadPdfInstead => 'Upload in plaats daarvan PDF';

  @override
  String get childSelectorSubtitle => 'Wissel tussen kinderen.';

  @override
  String get childSelectorTitle => 'Kindprofielen';

  @override
  String get commonCancel => 'Annuleren';

  @override
  String get commonClear => 'Wissen';

  @override
  String contactSupportFrom(String email) {
    return 'Vanaf: $email';
  }

  @override
  String get contactSupportMessageLabel => 'Bericht';

  @override
  String get contactSupportSendMessage => 'Stuur een bericht';

  @override
  String get contactSupportSubtitle => 'We komen binnen 24 uur bij je terug.';

  @override
  String get contactSupportTitle => 'Neem contact op met support';

  @override
  String get contactSupportTopicLabel => 'Onderwerp';

  @override
  String get createProfileAvatarDino => 'Dino';

  @override
  String get createProfileAvatarFox => 'Vos';

  @override
  String get createProfileAvatarFoxBuddy => 'Vriend Vos';

  @override
  String get createProfileAvatarOwl => 'Uil';

  @override
  String get createProfileAvatarPenguin => 'Pinguïn';

  @override
  String get createProfileAvatarRobot => 'Robot';

  @override
  String deleteAccountBody(String name) {
    return 'Als je het account van $name verwijdert, worden alle onderliggende profielen en documenten verwijderd. Dit kan niet ongedaan worden gemaakt.';
  }

  @override
  String get deleteAccountConfirmDelete => 'Bevestig de verwijdering';

  @override
  String get deleteAccountSubtitle => 'Deze actie is permanent.';

  @override
  String get deleteAccountTitle => 'Account verwijderen';

  @override
  String get emptyStateSubtitle =>
      'Upload een werkblad om aan de slag te gaan.';

  @override
  String get emptyStateTitle => 'Niks hier';

  @override
  String get errorStateSubtitle => 'Kon het document niet verwerken';

  @override
  String get errorStateTitle => 'Er is iets misgegaan';

  @override
  String get errorStateTryAgain => 'Probeer het opnieuw';

  @override
  String get faqSubtitle => 'Antwoorden op veelgestelde vragen.';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get forgotPasswordEmailAddressLabel => 'E-mailadres';

  @override
  String get forgotPasswordSendLink => 'Stuur een link';

  @override
  String get forgotPasswordSubtitle =>
      'We sturen een resetlink naar je e-mail.';

  @override
  String get forgotPasswordTitle => 'Wachtwoord opnieuw instellen';

  @override
  String get homeTabHome => 'Thuis';

  @override
  String get homeTabPacks => 'Pakketten';

  @override
  String get homeTabProgress => 'Voortgang';

  @override
  String get homeTabSettings => 'Settings';

  @override
  String learningTimeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get learningTimeSubtitle => '_____ minuten per dag';

  @override
  String get learningTimeTitle => 'leertijd';

  @override
  String get loginButton => 'Aanmelden';

  @override
  String get loginCreateAccountPrompt => 'Nieuw hier? Maak een account aan';

  @override
  String get loginForgotPassword => 'Wachtwoord vergeten?';

  @override
  String get loginSubtitle =>
      'Log in om de leerreis van uw kind voort te zetten.';

  @override
  String get loginTitle => 'Welkom terug';

  @override
  String get masteryDetailsEmptySubtitle =>
      'Upload en voltooi games om conceptmeesterschap op te bouwen.';

  @override
  String get masteryDetailsNoDataSubtitle =>
      'Voer ten minste één gegenereerd spel uit om deze weergave te vullen.';

  @override
  String get masteryDetailsNoDataTitle => 'Nog geen beheersingsgegevens';

  @override
  String get masteryDetailsSubtitle =>
      'Uitsplitsing op conceptniveau van uw geüploade studie-inhoud.';

  @override
  String get masteryDetailsTitle => 'Beheersingsdetails';

  @override
  String get masteryStatusMastered => 'Mastered';

  @override
  String get masteryStatusNeedsReview =>
      'Moet worden nagekeken@option:check trans-unit state';

  @override
  String get masteryStatusPracticing => 'Oefenen';

  @override
  String masteryStatusWithPercent(String label, int percent) {
    return '$label • $percent%';
  }

  @override
  String get notificationsMarkRead => 'Markeer gelezen';

  @override
  String get notificationsSubtitle =>
      'Vriendelijke duwtjes voor ouders en kinderen.';

  @override
  String get notificationsTitle => 'Meldingen';

  @override
  String get offlineRetry => 'Opnieuw proberen';

  @override
  String get offlineSubtitle =>
      'Controleer uw verbinding om de voortgang van de synchronisatie te controleren.';

  @override
  String get offlineTitle => 'U bent offline!';

  @override
  String get onboardingConsentAgreeButton => 'Ga akkoord &amp; Ga verder';

  @override
  String get onboardingConsentCoppaSubtitle =>
      'Toestemming van de ouder vereist voor gebruik.';

  @override
  String get onboardingConsentCoppaTitle => 'COPPA-vriendelijk';

  @override
  String get onboardingConsentEducatorSubtitle =>
      'De inhoud is afgestemd op de normen van de school.';

  @override
  String get onboardingConsentEducatorTitle => 'Opvoeder ontworpen';

  @override
  String get onboardingConsentNoDataSellingSubtitle =>
      'We delen of verkopen nooit persoonlijke informatie.';

  @override
  String get onboardingConsentNoDataSellingTitle => 'Geen gegevensverkoop';

  @override
  String get onboardingConsentSubtitle =>
      'We houden kinderen veilig, privé en reclamevrij.';

  @override
  String get onboardingConsentTitle => 'Toestemming van ouder';

  @override
  String get onboardingCreateProfileButton => 'Een profiel aanmaken';

  @override
  String get onboardingFoxBlurb =>
      'Leerling de vos houdt de praktijk speels en gefocust.';

  @override
  String get onboardingGetStarted => 'Aan de slag';

  @override
  String get onboardingHowItWorksSubtitle =>
      'Van huiswerk naar meesterschap in 3 snelle stappen.';

  @override
  String get onboardingHowItWorksTitle => 'Hoe werkt het';

  @override
  String get onboardingStep1Subtitle =>
      'Maak een foto van een werkblad of pagina.';

  @override
  String get onboardingStep1Title => 'Snap je huiswerk';

  @override
  String get onboardingStep2Subtitle =>
      'Flashcards, quizzen en matching in seconden.';

  @override
  String get onboardingStep2Title => 'AI creëert leerspellen';

  @override
  String get onboardingStep3Subtitle =>
      'Korte sessies met strepen en XP-boosts.';

  @override
  String get onboardingStep3Title => 'Beloningen leren en verdienen';

  @override
  String get onboardingWelcomeSubtitle =>
      'Jouw AI learning buddy voor slimme, speelse studiesessies.';

  @override
  String get onboardingWelcomeTitle => 'Welkom bij Learny!';

  @override
  String packsItemsMinutes(int itemCount, int minutes) {
    return '$itemCount items • $minutes min';
  }

  @override
  String packsMasteryProgress(int percent, int mastered, int total) {
    return '$percent% meesterschap • $mastered/$total concepten';
  }

  @override
  String get packsStartSession => 'Een sessie starten';

  @override
  String get packsSubtitle =>
      'Gepersonaliseerde pakketten op basis van huiswerk.';

  @override
  String get packsTitle => 'Leerpakketten';

  @override
  String get packsViewLibrary => 'Documentbibliotheek';

  @override
  String get parentDashboardActiveChild => 'Actief kind';

  @override
  String get parentDashboardChildSelector => 'Kinderselector';

  @override
  String get parentDashboardLearningTime => 'leertijd';

  @override
  String get parentDashboardSubtitle =>
      'Volg de voortgang en begeleid de volgende stappen.';

  @override
  String get parentDashboardTitle => 'Bovenliggend dashboard';

  @override
  String get parentDashboardWeakAreas => 'Zwakke gebieden';

  @override
  String get parentDashboardWeeklySummary => 'Wekelijks overzicht';

  @override
  String get parentOnlyLabel => 'Toon alleen oudercategorie';

  @override
  String get parentPinChangeSubtitle =>
      'Stel een nieuwe pincode in voor toegang alleen voor ouders.';

  @override
  String get parentPinChangeTitle => 'Pincode wijzigen';

  @override
  String get parentPinCodeLabel => '4-cijferige pincode';

  @override
  String get parentPinEnterSubtitle => 'Voer je PINCODE in om door te gaan.';

  @override
  String get parentPinSaveButton => 'Bewaar dealpin';

  @override
  String get parentPinUnlockButton => 'Bovenliggende instellingen ontgrendelen';

  @override
  String get parentSettingsChildProfiles => 'Kinderprofielen';

  @override
  String get parentSettingsParentProfile => 'Bovenliggend profiel';

  @override
  String parentSettingsProfilesCount(int count) {
    return '$count profielen';
  }

  @override
  String get parentSettingsProtectSubtitle =>
      'Bescherm instellingen voor alleen ouders.';

  @override
  String get parentSettingsSetChangePin => 'PINCODE instellen / wijzigen';

  @override
  String get parentSettingsSubscription => 'Subscription';

  @override
  String get parentSettingsSubtitle =>
      'Beheer abonnements- en gezinsbesturingselementen.';

  @override
  String get parentSettingsTitle => 'Bovenliggende instellingen';

  @override
  String get planAlreadyHaveAccount => 'Heeft u al een account? Log dan in';

  @override
  String get planChooseSubtitle =>
      'Begin gratis. Upgrade op elk gewenst moment.';

  @override
  String get planChooseTitle => 'Kies je abonnement';

  @override
  String get planFamilySubtitle => 'Maximaal 4 kinderprofielen';

  @override
  String get planFamilyTitle => 'Familie';

  @override
  String get planFreeSubtitle => '3 verpakkingen per maand';

  @override
  String get planFreeTitle => 'Gratis';

  @override
  String get planProSubtitle => 'Onbeperkte pakketten + games';

  @override
  String get planProTitle => 'Pro';

  @override
  String get safetyPrivacyCoppaSubtitle => 'Ouderlijke toestemming vereist';

  @override
  String get safetyPrivacyCoppaTitle => 'COPPA COMPLIANT';

  @override
  String get safetyPrivacyEncryptedSubtitle => 'Bestanden zijn beveiligd';

  @override
  String get safetyPrivacyEncryptedTitle => 'Versleutelde opslag';

  @override
  String get safetyPrivacyNoAdsSubtitle =>
      'We verdienen geen geld met gegevens';

  @override
  String get safetyPrivacyNoAdsTitle => 'Geen advertenties, geen verkoop';

  @override
  String get safetyPrivacySubtitle =>
      'Gemaakt voor kinderen, vertrouwd door ouders.';

  @override
  String get safetyPrivacyTitle => 'Veiligheid &amp; privacy';

  @override
  String get settingsClearAllConfirm =>
      'Hiermee worden alle signalen van het leergeheugen gewist. Doorgaan?';

  @override
  String get settingsClearAllLearningMemorySubtitle =>
      'Gebeurtenissen, revisie, spelresultaten, meesterschap.';

  @override
  String get settingsClearAllLearningMemoryTitle => 'Wis al het leergeheugen';

  @override
  String get settingsClearEventsOnlySubtitle =>
      'Behoudt meesterschap en resultaten.';

  @override
  String get settingsClearEventsOnlyTitle => 'Alleen gebeurtenissen wissen';

  @override
  String get settingsClearMemoryScopeTitle => 'Geheugenbereik wissen';

  @override
  String get settingsClearRevisionSessionsSubtitle =>
      'Verwijdert snelle revisiegeschiedenis.';

  @override
  String get settingsClearRevisionSessionsTitle => 'Revisiesessies wissen';

  @override
  String settingsClearScopeConfirm(String scope) {
    return 'Geheugenbereik \"$scope\" wissen?';
  }

  @override
  String get settingsConfirmClearMemoryTitle => 'Bevestig geheugen wissen';

  @override
  String get settingsDeleteAccountSubtitle => 'Dit is een destructieve actie.';

  @override
  String get settingsDetailLevelBrief => 'Samenvatting';

  @override
  String get settingsDetailLevelDetailed => 'Gedetaileerd';

  @override
  String settingsLastReset(String scope, String time) {
    return 'Laatste reset: $scope op $time';
  }

  @override
  String get settingsLearningMemoryTitle => 'Leren en geheugen';

  @override
  String get settingsNoRecentMemoryReset => 'Geen recente geheugenreset.';

  @override
  String get settingsNotificationsSubtitle =>
      'Ontvang updates over nieuwe pakketten en strepen.';

  @override
  String get settingsNotificationsTitle => 'Meldingen';

  @override
  String get settingsPersonalizedRecommendationsSubtitle =>
      'Gebruik activiteitsgeschiedenis om de volgende stappen aan te passen.';

  @override
  String get settingsPersonalizedRecommendationsTitle =>
      ' voor op je lijf geschreven aanbevelingen';

  @override
  String get settingsRationaleDetailLevelTitle => 'Rationale detailniveau';

  @override
  String get settingsRecommendationRationaleSubtitle =>
      'Geef uitleg over \"waarom deze suggestie\" weer.';

  @override
  String get settingsRecommendationRationaleTitle =>
      'Aanbevelingsreden weergeven';

  @override
  String get settingsSoundEffectsSubtitle => 'Geluiden afspelen tijdens games.';

  @override
  String get settingsSoundEffectsTitle => 'Geluidseffecten';

  @override
  String get settingsStudyRemindersSubtitle =>
      'Dagelijkse herinneringen voor korte sessies.';

  @override
  String get settingsStudyRemindersTitle => 'Onderzoeksherinneringen';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsUnknownScope => 'onbekend';

  @override
  String get signupCreateAccount => 'Account aanmaken';

  @override
  String get signupFullNameLabel => 'Volledige naam';

  @override
  String get signupLoginPrompt => 'Heeft u al een account? Log dan in';

  @override
  String get signupSubtitle =>
      'Stel een veilig ouderprofiel in om het leren te beheren.';

  @override
  String get signupTitle => 'Bovenliggend account aanmaken';

  @override
  String streaksRewardsBadges(int count) {
    return '$count badges';
  }

  @override
  String get streaksRewardsCurrentStreak => 'Huidig spel:NAME OF TRANSLATORS';

  @override
  String streaksRewardsDays(int count) {
    return '$count dagen';
  }

  @override
  String get streaksRewardsSubtitle => 'Houd het momentum gaande!';

  @override
  String get streaksRewardsTitle => 'Strepen en beloningen';

  @override
  String get streaksRewardsUnlocked => 'Beloningen ontgrendeld';

  @override
  String subscriptionCurrentPlan(String plan) {
    return 'Huidig abonnement: $plan';
  }

  @override
  String get subscriptionPlanIncluded =>
      'Volledige toegang inbegrepen bij het gratis abonnement.';

  @override
  String get subscriptionSubtitle =>
      'Learny is gratis te gebruiken. Ouders kunnen op elk moment upgraden.';

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String get subscriptionUpgradePlan => 'Lidmaatschap Upgraden';

  @override
  String get upgradePlanContinueToCheckout => 'Ga door naar betalen';

  @override
  String get upgradePlanSubtitle =>
      'Ontgrendel onbeperkte pakketten en bovenliggende inzichten.';

  @override
  String get upgradePlanTitle => 'Lidmaatschap Upgraden';

  @override
  String get verifyEmailCodeLabel => 'Verificatiecode';

  @override
  String get verifyEmailContinueToApp => 'Doorgaan naar';

  @override
  String get verifyEmailResendCode => 'Code opnieuw verzenden';

  @override
  String get verifyEmailSubtitle =>
      'We hebben een zescijferige code gestuurd naar parent@example.com.';

  @override
  String get verifyEmailTitle => 'Verifieer uw e-mail';

  @override
  String get weakAreasSubtitle => 'Focuszones om de volgende keer te bekijken.';

  @override
  String get weakAreasTitle => 'Zwakke gebieden';

  @override
  String get weeklySummaryAchievements => 'Prestaties';

  @override
  String weeklySummaryNewBadges(int count) {
    return '$count nieuwe badges';
  }

  @override
  String get weeklySummarySessionsCompleted => 'Afgeronde sessies';

  @override
  String weeklySummarySessionsValue(int count) {
    return '$count sessies';
  }

  @override
  String get weeklySummarySubtitle =>
      'Hoogtepunten van de afgelopen zeven dagen.';

  @override
  String get weeklySummaryTimeSpent => 'Bestede tijd';

  @override
  String weeklySummaryTimeSpentValue(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get weeklySummaryTitle => 'Wekelijks overzicht';

  @override
  String get weeklySummaryTopSubject => 'Toponderwerp';

  @override
  String processingAlternativesLabel(String alternatives) {
    return 'Alternatieven: $alternatives';
  }

  @override
  String processingConfidenceLabel(int percent, String modelSuffix) {
    return 'Vertrouwen: $percent%$modelSuffix';
  }

  @override
  String get processingConfirmGenerate => 'Bevestigen en genereren';

  @override
  String get processingLanguageLabel => 'Taal';

  @override
  String get processingNoAlternatives => 'Geen alternatieven voorgesteld.';

  @override
  String get processingRescan => 'Scan opnieuw';

  @override
  String get processingStarting => 'Start...';

  @override
  String get processingTopicLabel => 'Onderwerp';

  @override
  String get processingTopicLanguageRequired =>
      'Onderwerp en taal zijn vereist om door te gaan.';

  @override
  String get processingValidateScanSubtitle =>
      'Bevestig of bewerk het onderwerp en de taal voordat de diepe generatie begint.';

  @override
  String get processingValidateScanTitle => 'AI-scan valideren';

  @override
  String progressActivitySummary(int percent, String scoreLabel, int xp) {
    return '$percent% • $scoreLabel • +$xp XP';
  }

  @override
  String get progressCouldNotRegenerateDocument =>
      'Kan document nu niet opnieuw genereren.';

  @override
  String progressCouldNotReopen(String error) {
    return 'Kon dit onderwerp niet opnieuw openen: $error';
  }

  @override
  String progressCouldNotStartRegenerationFor(String gameType) {
    return 'Kon regeneratie voor $gameType niet starten.';
  }

  @override
  String get progressDeltaNew => 'Nieuwe';

  @override
  String get progressDocumentRegenerationStarted =>
      'Documentregeneratie gestart.';

  @override
  String get progressGenerateNewGameTypeSubtitle =>
      'Kies een type om te regenereren vanuit dit document';

  @override
  String get progressGenerateNewGameTypeTitle => 'Genereer nieuw speltype';

  @override
  String get progressLatestCheerEmpty =>
      'Upload een document en voltooi een spel om je momentum te starten.';

  @override
  String get progressLoadOlderActivity => 'Oudere activiteit laden';

  @override
  String get progressMetricAvgScore => 'nl-NL Avg Score';

  @override
  String get progressMetricRecentXp => 'Recente XP';

  @override
  String get progressMetricSessions => 'Sessies';

  @override
  String get progressMetricStreak => 'Streak';

  @override
  String progressMetricStreakValue(int days) {
    return '${days}d';
  }

  @override
  String get progressMomentumBuilding => 'Momentum opbouwen';

  @override
  String get progressMomentumExcellent => 'Uitstekend momentum.';

  @override
  String get progressMomentumReady => 'Klaar om te beginnen...';

  @override
  String get progressMomentumSteady => 'Stabiel momentum';

  @override
  String get progressNewGameType => 'Nieuw speltype';

  @override
  String get progressNoActivitySubtitle =>
      'Speel een gegenereerd spel om hier resultaten en motivatie te zien.';

  @override
  String get progressNoActivityTitle => 'Nog geen activiteit';

  @override
  String get progressNoReadyGames =>
      'Er zijn nog geen kant-en-klare spellen gevonden voor dit onderwerp.';

  @override
  String get progressOpenOverview => 'Voortgangsoverzicht';

  @override
  String get progressOverviewAreasToFocus => 'Vier aandachtsgebieden';

  @override
  String get progressOverviewBadges => 'Badges';

  @override
  String get progressOverviewDayStreak => 'Dagreeks';

  @override
  String progressOverviewLevelLearner(int level) {
    return 'Niveau $level Leerling';
  }

  @override
  String get progressOverviewMastery => 'Meesterschap';

  @override
  String progressOverviewMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get progressOverviewSessions => 'Sessies';

  @override
  String get progressOverviewTitle => 'Jouw voortgang';

  @override
  String get progressOverviewTopSubject => 'Toponderwerp';

  @override
  String get progressOverviewTopicMastery => 'Onderwerpmeesterschap';

  @override
  String get progressOverviewTopicMasteryEmpty =>
      'Voltooi enkele lessen om je meesterschap te zien!';

  @override
  String progressOverviewTotalXp(int xp) {
    return '$xp XP totaal';
  }

  @override
  String progressOverviewXpToNextLevel(int xpToNext, int nextLevel) {
    return '$xpToNext XP tot niveau $nextLevel';
  }

  @override
  String get progressOverviewXpToday => 'XP vandaag';

  @override
  String get progressPastActivityTitle => 'Eerdere activiteit';

  @override
  String get progressRedoDocument => 'Document opnieuw uitvoeren';

  @override
  String get progressRedoSubject => 'Onderwerp opnieuw uitvoeren';

  @override
  String get progressRefresh => 'Vernieuwen';

  @override
  String progressRegenerationStartedFor(String gameType) {
    return 'Regeneratie gestart voor $gameType.';
  }

  @override
  String get progressScoreBandImproving => 'Gegroeid';

  @override
  String get progressScoreBandKeepGoing => 'Doorgaan';

  @override
  String get progressScoreBandStrong => 'Sterk';

  @override
  String progressScoreLabel(int correct, int total) {
    return '$correct/$total correct';
  }

  @override
  String get progressSubtitle =>
      'Resultaten uit het verleden, trends en wat je vervolgens opnieuw moet doen.';

  @override
  String progressWeeklyMastery(int percent) {
    return '$percent% meesterschap over de pakketten van deze week';
  }

  @override
  String get progressWeeklyProgressTitle => 'Wekelijkse voortgang';
}
