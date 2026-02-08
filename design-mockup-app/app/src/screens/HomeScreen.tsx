import { motion } from 'framer-motion';
import { BookOpen, Zap, Sparkles, ChevronRight } from 'lucide-react';
import { useApp } from '@/context/AppContext';
import { ScreenTransition } from '@/components/ui-custom/ScreenTransition';
import { ProgressBar } from '@/components/ui-custom/ProgressBar';

export function HomeScreen() {
  const { userName, navigate } = useApp();

  return (
    <ScreenTransition>
      <div className="mobile-container gradient-welcome">
        {/* Header */}
        <div className="screen-header">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-neutral-light text-sm">Good morning,</p>
              <h1 className="text-2xl font-bold text-neutral-dark">Hi {userName}! 👋</h1>
            </div>
            <div className="w-12 h-12 bg-gradient-to-br from-sky to-mint rounded-full flex items-center justify-center">
              <Sparkles className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="screen-content flex flex-col gap-6">
          {/* Welcome Message */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="bg-white/80 backdrop-blur-sm rounded-2xl p-5"
          >
            <p className="text-neutral-medium leading-relaxed">
              Ready to learn something new today? Let's turn your school lessons into fun games!
            </p>
          </motion.div>

          {/* Primary Actions */}
          <div className="flex flex-col gap-4">
            {/* Start Learning Session */}
            <motion.button
              onClick={() => navigate('upload')}
              whileTap={{ scale: 0.98 }}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className="card-interactive bg-gradient-to-br from-sky to-mint p-6 text-left"
            >
              <div className="flex items-start justify-between">
                <div>
                  <div className="w-12 h-12 bg-white/30 rounded-xl flex items-center justify-center mb-4">
                    <BookOpen className="w-6 h-6 text-white" />
                  </div>
                  <h2 className="text-xl font-bold text-white mb-1">Start Learning</h2>
                  <p className="text-white/80 text-sm">Upload your lesson and play</p>
                </div>
                <ChevronRight className="w-6 h-6 text-white/60" />
              </div>
            </motion.button>

            {/* Revision Express */}
            <motion.button
              onClick={() => navigate('revision')}
              whileTap={{ scale: 0.98 }}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
              className="card-interactive bg-white p-6 text-left border-2 border-sunshine"
            >
              <div className="flex items-start justify-between">
                <div>
                  <div className="w-12 h-12 bg-sunshine-light rounded-xl flex items-center justify-center mb-4">
                    <Zap className="w-6 h-6 text-sunshine-dark" />
                  </div>
                  <h2 className="text-xl font-bold text-neutral-dark mb-1">Revision Express</h2>
                  <p className="text-neutral-light text-sm">Quick 5-minute review</p>
                </div>
                <ChevronRight className="w-6 h-6 text-neutral-light" />
              </div>
            </motion.button>
          </div>

          {/* Weekly Progress */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="card"
          >
            <h3 className="text-sm font-semibold text-neutral-medium mb-3">This Week</h3>
            <ProgressBar progress={60} />
            <p className="text-sm text-neutral-light mt-3">
              You've completed 3 learning sessions. Great work!
            </p>
          </motion.div>

          {/* Recent Topics */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5 }}
          >
            <h3 className="text-sm font-semibold text-neutral-medium mb-3">Recent Topics</h3>
            <div className="flex gap-3 overflow-x-auto pb-2">
              {['Photosynthesis', 'Fractions', 'World War II'].map((topic) => (
                <div
                  key={topic}
                  className="flex-shrink-0 bg-white rounded-xl px-4 py-3 shadow-sm border border-neutral-soft"
                >
                  <p className="text-sm text-neutral-dark font-medium">{topic}</p>
                </div>
              ))}
            </div>
          </motion.div>
        </div>
      </div>
    </ScreenTransition>
  );
}
