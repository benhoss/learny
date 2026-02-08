import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';

interface TimedChallengeProps {
  question: string;
  options: string[];
  correctIndex: number;
  timeLimit?: number;
  onAnswer: (correct: boolean, timeUp?: boolean) => void;
}

export function TimedChallenge({ 
  question, 
  options, 
  correctIndex, 
  timeLimit = 15,
  onAnswer 
}: TimedChallengeProps) {
  const [timeLeft, setTimeLeft] = useState(timeLimit);
  const [hasAnswered, setHasAnswered] = useState(false);
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);

  useEffect(() => {
    if (timeLeft > 0 && !hasAnswered) {
      const timer = setTimeout(() => {
        setTimeLeft(prev => prev - 1);
      }, 1000);
      return () => clearTimeout(timer);
    } else if (timeLeft === 0 && !hasAnswered) {
      setHasAnswered(true);
      onAnswer(false, true);
    }
  }, [timeLeft, hasAnswered, onAnswer]);

  const handleSelect = (index: number) => {
    if (hasAnswered) return;
    setSelectedIndex(index);
    setHasAnswered(true);
    const isCorrect = index === correctIndex;
    setTimeout(() => {
      onAnswer(isCorrect);
    }, 1000);
  };

  const progress = (timeLeft / timeLimit) * 100;
  const isLowTime = timeLeft <= 5;

  return (
    <div className="flex flex-col gap-6">
      {/* Timer */}
      <div className="flex items-center justify-center">
        <div className="relative w-20 h-20">
          {/* Background circle */}
          <svg className="w-full h-full -rotate-90">
            <circle
              cx="40"
              cy="40"
              r="36"
              fill="none"
              stroke="#E8EDF2"
              strokeWidth="6"
            />
            <motion.circle
              cx="40"
              cy="40"
              r="36"
              fill="none"
              stroke={isLowTime ? '#FF9A8B' : '#7DD3E8'}
              strokeWidth="6"
              strokeLinecap="round"
              strokeDasharray={`${2 * Math.PI * 36}`}
              strokeDashoffset={`${2 * Math.PI * 36 * (1 - progress / 100)}`}
              style={{ transition: 'stroke-dashoffset 1s linear' }}
            />
          </svg>
          {/* Time text */}
          <div className="absolute inset-0 flex items-center justify-center">
            <span className={`text-2xl font-bold ${isLowTime ? 'text-coral' : 'text-neutral-dark'}`}>
              {timeLeft}
            </span>
          </div>
        </div>
      </div>

      {/* Question */}
      <div className="bg-white rounded-2xl p-5 shadow-card">
        <p className="text-base text-neutral-dark font-medium leading-relaxed">
          {question}
        </p>
      </div>

      {/* Options */}
      <div className="grid grid-cols-2 gap-3">
        {options.map((option, index) => {
          const isSelected = selectedIndex === index;
          const isCorrect = index === correctIndex;
          const showResult = hasAnswered;

          return (
            <motion.button
              key={index}
              onClick={() => handleSelect(index)}
              whileTap={!hasAnswered ? { scale: 0.95 } : undefined}
              className={`
                p-4 rounded-xl border-2 text-sm font-medium transition-all duration-200
                ${showResult && isCorrect 
                  ? 'border-mint bg-mint-light text-neutral-dark' 
                  : showResult && isSelected && !isCorrect
                    ? 'border-coral bg-coral-light/20 text-neutral-dark'
                    : isSelected
                      ? 'border-sky bg-sky-light text-neutral-dark'
                      : 'border-neutral-soft bg-white text-neutral-dark hover:border-sky'
                }
              `}
              disabled={hasAnswered}
            >
              {option}
            </motion.button>
          );
        })}
      </div>
    </div>
  );
}
