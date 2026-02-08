import { useState } from 'react';
import { motion } from 'framer-motion';
import { Check } from 'lucide-react';

interface QuizProps {
  question: string;
  options: string[];
  correctIndex: number;
  onAnswer: (correct: boolean) => void;
}

export function Quiz({ question, options, correctIndex, onAnswer }: QuizProps) {
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);
  const [hasSubmitted, setHasSubmitted] = useState(false);

  const handleSelect = (index: number) => {
    if (hasSubmitted) return;
    setSelectedIndex(index);
  };

  const handleSubmit = () => {
    if (selectedIndex === null) return;
    setHasSubmitted(true);
    const isCorrect = selectedIndex === correctIndex;
    setTimeout(() => {
      onAnswer(isCorrect);
    }, 1500);
  };

  return (
    <div className="flex flex-col gap-6">
      {/* Question */}
      <div className="bg-white rounded-2xl p-6 shadow-card">
        <p className="text-lg text-neutral-dark font-medium leading-relaxed">
          {question}
        </p>
      </div>

      {/* Options */}
      <div className="flex flex-col gap-3">
        {options.map((option, index) => {
          const isSelected = selectedIndex === index;
          const isCorrect = index === correctIndex;
          const showCorrect = hasSubmitted && isCorrect;
          const showIncorrect = hasSubmitted && isSelected && !isCorrect;

          return (
            <motion.button
              key={index}
              onClick={() => handleSelect(index)}
              whileTap={!hasSubmitted ? { scale: 0.98 } : undefined}
              className={`
                quiz-option relative overflow-hidden
                ${isSelected && !hasSubmitted ? 'selected' : ''}
                ${showCorrect ? 'correct' : ''}
                ${showIncorrect ? 'border-coral bg-coral-light/20' : ''}
              `}
              disabled={hasSubmitted}
            >
              <div className="flex items-center justify-between">
                <span className="text-neutral-dark">{option}</span>
                {showCorrect && (
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    className="w-6 h-6 bg-success rounded-full flex items-center justify-center"
                  >
                    <Check className="w-4 h-4 text-white" />
                  </motion.div>
                )}
              </div>
            </motion.button>
          );
        })}
      </div>

      {/* Submit Button */}
      {!hasSubmitted && (
        <motion.button
          onClick={handleSubmit}
          whileTap={{ scale: 0.98 }}
          disabled={selectedIndex === null}
          className={`
            btn-primary w-full mt-2
            ${selectedIndex === null ? 'opacity-50 cursor-not-allowed' : ''}
          `}
        >
          Check Answer
        </motion.button>
      )}
    </div>
  );
}
