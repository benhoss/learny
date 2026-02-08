import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { RotateCw } from 'lucide-react';

interface FlashcardProps {
  front: string;
  back: string;
  onNext: () => void;
}

export function Flashcard({ front, back, onNext }: FlashcardProps) {
  const [isFlipped, setIsFlipped] = useState(false);

  const handleFlip = () => {
    setIsFlipped(!isFlipped);
  };

  const handleNext = () => {
    setIsFlipped(false);
    setTimeout(onNext, 200);
  };

  return (
    <div className="flex flex-col items-center gap-6">
      {/* Flashcard */}
      <div 
        className="relative w-full aspect-[4/3] cursor-pointer perspective-1000"
        onClick={handleFlip}
      >
        <AnimatePresence mode="wait">
          {!isFlipped ? (
            <motion.div
              key="front"
              initial={{ rotateY: 90, opacity: 0 }}
              animate={{ rotateY: 0, opacity: 1 }}
              exit={{ rotateY: -90, opacity: 0 }}
              transition={{ duration: 0.3 }}
              className="absolute inset-0 bg-white rounded-3xl shadow-card p-8 flex flex-col items-center justify-center border-2 border-neutral-soft"
            >
              <p className="text-lg text-neutral-dark text-center font-medium leading-relaxed">
                {front}
              </p>
              <div className="absolute bottom-4 flex items-center gap-2 text-neutral-light text-sm">
                <RotateCw className="w-4 h-4" />
                <span>Tap to flip</span>
              </div>
            </motion.div>
          ) : (
            <motion.div
              key="back"
              initial={{ rotateY: -90, opacity: 0 }}
              animate={{ rotateY: 0, opacity: 1 }}
              exit={{ rotateY: 90, opacity: 0 }}
              transition={{ duration: 0.3 }}
              className="absolute inset-0 bg-gradient-to-br from-mint-light to-sky-light rounded-3xl shadow-card p-8 flex flex-col items-center justify-center border-2 border-mint"
            >
              <p className="text-lg text-neutral-dark text-center font-medium leading-relaxed">
                {back}
              </p>
              <div className="absolute bottom-4 flex items-center gap-2 text-neutral-medium text-sm">
                <RotateCw className="w-4 h-4" />
                <span>Tap to flip back</span>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Next Button */}
      <motion.button
        onClick={handleNext}
        whileTap={{ scale: 0.98 }}
        className="btn-primary w-full"
      >
        Got it! Next card
      </motion.button>
    </div>
  );
}
