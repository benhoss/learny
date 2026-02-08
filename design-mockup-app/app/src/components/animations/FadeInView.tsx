import { motion } from 'framer-motion';
import type { ReactNode } from 'react';

interface FadeInViewProps {
  children: ReactNode;
  delay?: number;
  duration?: number;
  direction?: 'up' | 'down' | 'left' | 'right';
  className?: string;
}

export function FadeInView({ 
  children, 
  delay = 0, 
  duration = 0.6,
  direction = 'up',
  className = ''
}: FadeInViewProps) {
  const directions = {
    up: { y: 30, x: 0 },
    down: { y: -30, x: 0 },
    left: { y: 0, x: 30 },
    right: { y: 0, x: -30 },
  };

  return (
    <motion.div
      initial={{ 
        opacity: 0, 
        ...directions[direction]
      }}
      whileInView={{ 
        opacity: 1, 
        y: 0,
        x: 0
      }}
      viewport={{ once: true, margin: "-10%" }}
      transition={{ 
        duration, 
        delay,
        ease: [0.4, 0, 0.2, 1]
      }}
      className={className}
    >
      {children}
    </motion.div>
  );
}
