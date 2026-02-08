import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Check } from 'lucide-react';

interface MatchItem {
  id: string;
  text: string;
  pairId: string;
}

interface MatchingProps {
  items: MatchItem[];
  onComplete: () => void;
}

export function Matching({ items, onComplete }: MatchingProps) {
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [matchedPairs, setMatchedPairs] = useState<string[]>([]);
  const [shuffledItems, setShuffledItems] = useState<MatchItem[]>([]);

  useEffect(() => {
    // Shuffle items on mount
    setShuffledItems([...items].sort(() => Math.random() - 0.5));
  }, [items]);

  useEffect(() => {
    // Check if all pairs are matched
    const uniquePairs = new Set(items.map(item => item.pairId));
    if (matchedPairs.length === uniquePairs.size && matchedPairs.length > 0) {
      setTimeout(onComplete, 500);
    }
  }, [matchedPairs, items, onComplete]);

  const handleSelect = (id: string, pairId: string) => {
    if (matchedPairs.includes(pairId)) return;

    if (!selectedId) {
      setSelectedId(id);
    } else if (selectedId === id) {
      setSelectedId(null);
    } else {
      const selectedItem = shuffledItems.find(item => item.id === selectedId);
      if (selectedItem?.pairId === pairId) {
        // Match found!
        setMatchedPairs(prev => [...prev, pairId]);
        setSelectedId(null);
      } else {
        // No match
        setSelectedId(null);
      }
    }
  };

  const isMatched = (pairId: string) => matchedPairs.includes(pairId);
  const isSelected = (id: string) => selectedId === id;

  return (
    <div className="flex flex-col gap-6">
      <p className="text-center text-neutral-medium text-sm">
        Tap two matching items
      </p>

      <div className="grid grid-cols-2 gap-3">
        {shuffledItems.map((item) => {
          const matched = isMatched(item.pairId);
          const selected = isSelected(item.id);

          return (
            <motion.button
              key={item.id}
              onClick={() => handleSelect(item.id, item.pairId)}
              whileTap={!matched ? { scale: 0.95 } : undefined}
              animate={
                matched
                  ? { scale: [1, 1.05, 1], backgroundColor: '#B8F0D8' }
                  : selected
                  ? { backgroundColor: '#B8E8F5' }
                  : { backgroundColor: '#FFFFFF' }
              }
              className={`
                relative p-5 rounded-2xl border-2 transition-all duration-200
                ${matched 
                  ? 'border-mint bg-mint-light' 
                  : selected 
                    ? 'border-sky bg-sky-light' 
                    : 'border-neutral-soft bg-white'
                }
                ${matched ? 'cursor-default' : 'cursor-pointer'}
              `}
              disabled={matched}
            >
              <span className={`text-sm font-medium ${matched ? 'text-neutral-dark' : 'text-neutral-dark'}`}>
                {item.text}
              </span>
              
              {matched && (
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  className="absolute -top-2 -right-2 w-6 h-6 bg-mint rounded-full flex items-center justify-center"
                >
                  <Check className="w-4 h-4 text-white" />
                </motion.div>
              )}
            </motion.button>
          );
        })}
      </div>

      {/* Progress */}
      <div className="text-center">
        <p className="text-sm text-neutral-light">
          {matchedPairs.length} of {new Set(items.map(i => i.pairId)).size} pairs matched
        </p>
      </div>
    </div>
  );
}
