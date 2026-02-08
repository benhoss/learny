import { motion } from 'framer-motion';
import { Sparkles, BookOpen, Home, RotateCcw } from 'lucide-react';
import { useApp } from '@/context/AppContext';
import { ScreenTransition } from '@/components/ui-custom/ScreenTransition';

export function FeedbackScreen() {
  const { navigate, resetSession } = useApp();

  const handleHome = () => {
    resetSession();
    navigate('home');
  };

  const handleAnotherSession = () => {
    resetSession();
    navigate('upload');
  };

  return (
    <ScreenTransition>
      <div className="mobile-container bg-cream flex flex-col">
        {/* Content */}
        <div className="flex-1 flex flex-col items-center justify-center px-6 py-12">
          {/* Success Animation */}
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ 
              type: "spring",
              stiffness: 200,
              damping: 15,
              delay: 0.2
            }}
            className="w-24 h-24 bg-gradient-to-br from-mint to-sky rounded-full flex items-center justify-center mb-8 shadow-lg"
          >
            <Sparkles className="w-12 h-12 text-white" />
          </motion.div>

          {/* Message */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="text-center mb-8"
          >
            <h1 className="text-2xl font-bold text-neutral-dark mb-3">
              Great work! 🎉
            </h1>
            <p className="text-neutral-medium leading-relaxed">
              You completed your learning session. You're building knowledge step by step!
            </p>
          </motion.div>

          {/* Stats */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5 }}
            className="w-full bg-white rounded-2xl p-6 shadow-card mb-8"
          >
            <h2 className="text-sm font-semibold text-neutral-medium mb-4">Session Summary</h2>
            <div className="grid grid-cols-2 gap-4">
              <div className="bg-sky-light/30 rounded-xl p-4 text-center">
                <p className="text-2xl font-bold text-sky-dark">5</p>
                <p className="text-xs text-neutral-light">Questions answered</p>
              </div>
              <div className="bg-mint-light/30 rounded-xl p-4 text-center">
                <p className="text-2xl font-bold text-mint-dark">12</p>
                <p className="text-xs text-neutral-light">Minutes spent</p>
              </div>
            </div>
          </motion.div>

          {/* Learning Tip */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.6 }}
            className="bg-sunshine-light/50 rounded-2xl p-5 mb-8"
          >
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 bg-sunshine rounded-lg flex items-center justify-center flex-shrink-0">
                <BookOpen className="w-4 h-4 text-white" />
              </div>
              <div>
                <p className="text-sm font-semibold text-neutral-dark mb-1">
                  Remember this:
                </p>
                <p className="text-sm text-neutral-medium">
                  Plants make their own food through photosynthesis using sunlight, water, and CO₂. This process releases oxygen that we breathe!
                </p>
              </div>
            </div>
          </motion.div>

          {/* Actions */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.7 }}
            className="w-full flex flex-col gap-3"
          >
            <button
              onClick={handleAnotherSession}
              className="btn-primary w-full"
            >
              <RotateCcw className="w-5 h-5" />
              Start Another Session
            </button>
            <button
              onClick={handleHome}
              className="btn-secondary w-full"
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
