import { ChevronLeft } from 'lucide-react';
import { motion } from 'framer-motion';

interface BackButtonProps {
  onClick: () => void;
  label?: string;
}

export function BackButton({ onClick, label = 'Back' }: BackButtonProps) {
  return (
    <motion.button
      onClick={onClick}
      whileTap={{ scale: 0.95 }}
      className="flex items-center gap-1 text-neutral-medium hover:text-neutral-dark transition-colors"
    >
      <ChevronLeft className="w-5 h-5" />
      <span className="text-sm font-medium">{label}</span>
    </motion.button>
  );
}
