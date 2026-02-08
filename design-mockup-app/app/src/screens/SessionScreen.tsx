import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useApp } from '@/context/AppContext';
import { ScreenTransition } from '@/components/ui-custom/ScreenTransition';
import { ProgressBar } from '@/components/ui-custom/ProgressBar';
import { BackButton } from '@/components/ui-custom/BackButton';
import { Flashcard } from '@/components/games/Flashcard';
import { Quiz } from '@/components/games/Quiz';
import { Matching } from '@/components/games/Matching';
import { TimedChallenge } from '@/components/games/TimedChallenge';

// Sample content for demo
const sampleContent = {
  flashcard: {
    front: "What is photosynthesis?",
    back: "The process by which plants use sunlight, water, and carbon dioxide to create their own food (glucose) and release oxygen."
  },
  quiz: {
    question: "Which gas do plants release during photosynthesis?",
    options: ["Carbon dioxide", "Oxygen", "Nitrogen", "Hydrogen"],
    correctIndex: 1
  },
  matching: [
    { id: '1a', text: 'Chlorophyll', pairId: 'p1' },
    { id: '1b', text: 'Green pigment in plants', pairId: 'p1' },
    { id: '2a', text: 'Glucose', pairId: 'p2' },
    { id: '2b', text: 'Sugar produced by plants', pairId: 'p2' },
    { id: '3a', text: 'Stomata', pairId: 'p3' },
    { id: '3b', text: 'Tiny openings on leaves', pairId: 'p3' },
    { id: '4a', text: 'Roots', pairId: 'p4' },
    { id: '4b', text: 'Absorb water from soil', pairId: 'p4' },
  ],
  timed: {
    question: "What does a plant need for photosynthesis?",
    options: ["Sunlight", "Oxygen", "Sugar", "Heat"],
    correctIndex: 0
  }
};

export function SessionScreen() {
  const { navigate, currentQuestion, totalQuestions, nextQuestion, setAnswerResult } = useApp();
  const [currentGame, setCurrentGame] = useState<'flashcard' | 'quiz' | 'matching' | 'timed'>('quiz');

  const handleGameComplete = () => {
    if (currentQuestion < totalQuestions) {
      nextQuestion();
      // Rotate through different game types for variety
      const games: typeof currentGame[] = ['quiz', 'flashcard', 'timed', 'matching'];
      const nextGameIndex = (games.indexOf(currentGame) + 1) % games.length;
      setCurrentGame(games[nextGameIndex]);
    } else {
      navigate('feedback');
    }
  };

  const handleAnswer = (correct: boolean) => {
    setAnswerResult(correct);
    setTimeout(() => {
      handleGameComplete();
    }, 1500);
  };

  return (
    <ScreenTransition>
      <div className="mobile-container bg-cream">
        {/* Header */}
        <div className="screen-header">
          <BackButton onClick={() => navigate('home')} label="Exit" />
          
          {/* Progress */}
          <div className="mt-4">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm text-neutral-light">
                Question {currentQuestion} of {totalQuestions}
              </span>
              <span className="text-sm font-medium text-sky">
                {Math.round((currentQuestion / totalQuestions) * 100)}%
              </span>
            </div>
            <ProgressBar progress={(currentQuestion / totalQuestions) * 100} />
          </div>
        </div>

        {/* Game Content */}
        <div className="screen-content flex flex-col">
          <AnimatePresence mode="wait">
            <motion.div
              key={currentQuestion + currentGame}
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.3 }}
              className="flex-1"
            >
              {currentGame === 'flashcard' && (
                <Flashcard
                  front={sampleContent.flashcard.front}
                  back={sampleContent.flashcard.back}
                  onNext={handleGameComplete}
                />
              )}
              
              {currentGame === 'quiz' && (
                <Quiz
                  question={sampleContent.quiz.question}
                  options={sampleContent.quiz.options}
                  correctIndex={sampleContent.quiz.correctIndex}
                  onAnswer={handleAnswer}
                />
              )}
              
              {currentGame === 'matching' && (
                <Matching
                  items={sampleContent.matching}
                  onComplete={handleGameComplete}
                />
              )}
              
              {currentGame === 'timed' && (
                <TimedChallenge
                  question={sampleContent.timed.question}
                  options={sampleContent.timed.options}
                  correctIndex={sampleContent.timed.correctIndex}
                  onAnswer={handleAnswer}
                />
              )}
            </motion.div>
          </AnimatePresence>
        </div>

        {/* Bottom Hint */}
        <div className="px-6 pb-8 text-center">
          <p className="text-xs text-neutral-light">
            Take your time. Learning is a journey! 🌱
          </p>
        </div>
      </div>
    </ScreenTransition>
  );
}
