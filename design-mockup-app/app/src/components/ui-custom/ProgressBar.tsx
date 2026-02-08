import { motion } from 'framer-motion';

interface ProgressBarProps {
  progress: number;
  showLabel?: boolean;
}

export function ProgressBar({ progress, showLabel = false }: ProgressBarProps) {
  return (
    <div className="w-full">
      <div className="progress-bar">
        <motion.div
          className="progress-fill"
          initial={{ width: 0 }}
          animate={{ width: `${progress}%` }}
          transition={{ duration: 0.5, ease: [0.4, 0, 0.2, 1] }}
        />
      </div>
      {showLabel && (
        <p className="text-xs text-neutral-light mt-2 text-center">
          {Math.round(progress)}% complete
        </p>
      )}
    </div>
  );
}
