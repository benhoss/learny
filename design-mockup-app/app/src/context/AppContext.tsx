import { createContext, useContext, useState, type ReactNode } from 'react';

type Screen = 'home' | 'upload' | 'session' | 'feedback' | 'revision';
type GameType = 'flashcard' | 'quiz' | 'matching' | 'timed';

interface AppState {
  currentScreen: Screen;
  userName: string;
  currentGame: GameType;
  sessionProgress: number;
  currentQuestion: number;
  totalQuestions: number;
  lastAnswerCorrect: boolean | null;
}

interface AppContextType extends AppState {
  navigate: (screen: Screen) => void;
  setGame: (game: GameType) => void;
  updateProgress: (progress: number) => void;
  nextQuestion: () => void;
  setAnswerResult: (correct: boolean) => void;
  resetSession: () => void;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export function AppProvider({ children }: { children: ReactNode }) {
  const [currentScreen, setCurrentScreen] = useState<Screen>('home');
  const [currentGame, setCurrentGame] = useState<GameType>('quiz');
  const [sessionProgress, setSessionProgress] = useState(0);
  const [currentQuestion, setCurrentQuestion] = useState(1);
  const [totalQuestions] = useState(5);
  const [lastAnswerCorrect, setLastAnswerCorrect] = useState<boolean | null>(null);

  const navigate = (screen: Screen) => {
    setCurrentScreen(screen);
    window.scrollTo(0, 0);
  };

  const setGame = (game: GameType) => {
    setCurrentGame(game);
  };

  const updateProgress = (progress: number) => {
    setSessionProgress(progress);
  };

  const nextQuestion = () => {
    if (currentQuestion < totalQuestions) {
      setCurrentQuestion(prev => prev + 1);
      setSessionProgress((currentQuestion / totalQuestions) * 100);
    }
  };

  const setAnswerResult = (correct: boolean) => {
    setLastAnswerCorrect(correct);
  };

  const resetSession = () => {
    setCurrentQuestion(1);
    setSessionProgress(0);
    setLastAnswerCorrect(null);
  };

  return (
    <AppContext.Provider
      value={{
        currentScreen,
        userName: 'Alex',
        currentGame,
        sessionProgress,
        currentQuestion,
        totalQuestions,
        lastAnswerCorrect,
        navigate,
        setGame,
        updateProgress,
        nextQuestion,
        setAnswerResult,
        resetSession,
      }}
    >
      {children}
    </AppContext.Provider>
  );
}

export function useApp() {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
}
