import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Zap, Check, X, ArrowRight, Home, Star } from 'lucide-react';
import { useApp } from '@/context/AppContext';
import { ScreenTransition } from '@/components/ui-custom/ScreenTransition';
import { BackButton } from '@/components/ui-custom/BackButton';
import { ProgressBar } from '@/components/ui-custom/ProgressBar';

// Sample revision questions
const revisionQuestions = [
  {
    question: "What is 7 × 8?",
    options: ["54", "56", "58", "52"],
    correctIndex: 1,
    explanation: "7 × 8 = 56. Remember: 7 × 7 = 49, so 7 × 8 is 7 more!"
  },
  {
    question: "Which planet is closest to the Sun?",
    options: ["Venus", "Earth", "Mercury", "Mars"],
    correctIndex: 2,
    explanation: "Mercury is the closest planet to the Sun, orbiting at about 58 million kilometers."
  },
  {
    question: "What is the capital of France?",
    options: ["London", "Berlin", "Madrid", "Paris"],
    correctIndex: 3,
    explanation: "Paris has been France's capital since 508 AD!"
  },
  {
    question: "How many continents are there?",
    options: ["5", "6", "7", "8"],
    correctIndex: 2,
    explanation: "There are 7 continents: Africa, Antarctica, Asia, Australia, Europe, North America, and South America."
  },
  {
    question: "What gas do plants absorb from the air?",
    options: ["Oxygen", "Carbon dioxide", "Nitrogen", "Hydrogen"],
    correctIndex: 1,
    explanation: "Plants absorb CO₂ (carbon dioxide) and release oxygen during photosynthesis."
  }
];

export function RevisionScreen() {
  const { navigate } = useApp();
  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);
  const [hasAnswered, setHasAnswered] = useState(false);
  const [isCorrect, setIsCorrect] = useState(false);
  const [isComplete, setIsComplete] = useState(false);
  const [correctCount, setCorrectCount] = useState(0);

  const currentQuestion = revisionQuestions[currentIndex];
  const progress = ((currentIndex + (hasAnswered ? 1 : 0)) / revisionQuestions.length) * 100;

  const handleSelect = (index: number) => {
    if (hasAnswered) return;
    setSelectedIndex(index);
  };

  const handleSubmit = () => {
    if (selectedIndex === null) return;
    
    const correct = selectedIndex === currentQuestion.correctIndex;
    setIsCorrect(correct);
    setHasAnswered(true);
    
    if (correct) {
      setCorrectCount(prev => prev + 1);
    }
  };

  const handleNext = () => {
    if (currentIndex < revisionQuestions.length - 1) {
      setCurrentIndex(prev => prev + 1);
      setSelectedIndex(null);
      setHasAnswered(false);
      setIsCorrect(false);
    } else {
      setIsComplete(true);
    }
  };

  if (isComplete) {
    return (
      <ScreenTransition>
        <div className="mobile-container bg-cream flex flex-col">
          <div className="flex-1 flex flex-col items-center justify-center px-6 py-12">
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ type: "spring", stiffness: 200, damping: 15 }}
              className="w-24 h-24 bg-gradient-to-br from-sunshine to-coral rounded-full flex items-center justify-center mb-8 shadow-lg"
            >
              <Star className="w-12 h-12 text-white" />
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className="text-center mb-8"
            >
              <h1 className="text-2xl font-bold text-neutral-dark mb-3">
                You're ready! 🌟
              </h1>
              <p className="text-neutral-medium leading-relaxed">
                Great job reviewing! You're well prepared for your day at school.
              </p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
              className="w-full bg-white rounded-2xl p-6 shadow-card mb-8"
            >
              <div className="text-center">
                <p className="text-4xl font-bold gradient-text mb-2">
                  {correctCount}/{revisionQuestions.length}
                </p>
                <p className="text-sm text-neutral-light">Correct answers</p>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4 }}
              className="w-full flex flex-col gap-3"
            >
              <button
                onClick={() => navigate('home')}
                className="btn-primary w-full"
              >
                <Home className="w-5 h-5" />
                Back to Home
              </button>
            </motion.div>
          </div>
        </div>
      </ScreenTransition>
    );
  }

  return (
    <ScreenTransition>
      <div className="mobile-container bg-cream">
        {/* Header */}
        <div className="screen-header">
          <div className="flex items-center justify-between">
            <BackButton onClick={() => navigate('home')} label="Exit" />
            <div className="flex items-center gap-2 bg-sunshine-light/50 px-3 py-1.5 rounded-full">
              <Zap className="w-4 h-4 text-sunshine-dark" />
              <span className="text-sm font-medium text-sunshine-dark">Express</span>
            </div>
          </div>
          
          {/* Progress */}
          <div className="mt-4">
            <ProgressBar progress={progress} />
          </div>
        </div>

        {/* Content */}
        <div className="screen-content flex flex-col gap-6">
          <AnimatePresence mode="wait">
            <motion.div
              key={currentIndex}
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.3 }}
              className="flex flex-col gap-6"
            >
              {/* Question */}
              <div className="bg-white rounded-2xl p-6 shadow-card">
                <p className="text-lg text-neutral-dark font-medium leading-relaxed">
                  {currentQuestion.question}
                </p>
              </div>

              {/* Options */}
              <div className="grid grid-cols-2 gap-3">
                {currentQuestion.options.map((option, index) => {
                  const selected = selectedIndex === index;
                  const showCorrect = hasAnswered && index === currentQuestion.correctIndex;
                  const showIncorrect = hasAnswered && selected && !isCorrect;

                  return (
                    <motion.button
                      key={index}
                      onClick={() => handleSelect(index)}
                      whileTap={!hasAnswered ? { scale: 0.95 } : undefined}
                      className={`
                        p-4 rounded-xl border-2 text-sm font-medium transition-all duration-200
                        ${showCorrect 
                          ? 'border-mint bg-mint-light text-neutral-dark' 
                          : showIncorrect
                            ? 'border-coral bg-coral-light/20 text-neutral-dark'
                            : selected
                              ? 'border-sky bg-sky-light text-neutral-dark'
                              : 'border-neutral-soft bg-white text-neutral-dark hover:border-sky'
                        }
                      `}
                      disabled={hasAnswered}
                    >
                      <div className="flex items-center justify-between">
                        <span>{option}</span>
                        {showCorrect && <Check className="w-4 h-4 text-mint-dark" />}
                        {showIncorrect && <X className="w-4 h-4 text-coral" />}
                      </div>
                    </motion.button>
                  );
                })}
              </div>

              {/* Submit or Explanation */}
              {!hasAnswered ? (
                <button
                  onClick={handleSubmit}
                  disabled={selectedIndex === null}
                  className={`
                    btn-primary w-full
                    ${selectedIndex === null ? 'opacity-50 cursor-not-allowed' : ''}
                  `}
                >
                  Check Answer
                </button>
              ) : (
                <motion.div
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="bg-sky-light/30 rounded-2xl p-5"
                >
                  <p className="text-sm font-semibold text-sky-dark mb-2">
                    {isCorrect ? '✨ Great job!' : '💡 Here\'s something to remember:'}
                  </p>
                  <p className="text-sm text-neutral-medium">
                    {currentQuestion.explanation}
                  </p>
                  <button
                    onClick={handleNext}
                    className="btn-primary w-full mt-4"
                  >
                    Next Question
                    <ArrowRight className="w-5 h-5" />
                  </button>
                </motion.div>
              )}
            </motion.div>
          </AnimatePresence>
        </div>

        {/* Bottom */}
        <div className="px-6 pb-8 text-center">
          <p className="text-xs text-neutral-light">
            Quick review before school! You've got this! 💪
          </p>
        </div>
      </div>
    </ScreenTransition>
  );
}
