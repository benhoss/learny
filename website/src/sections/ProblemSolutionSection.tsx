import { motion } from 'framer-motion';
import { X, Check, BookOpen, Brain, Clock, Zap } from 'lucide-react';
import { FadeInView } from '@/components/animations/FadeInView';

const problemPoints = [
  { icon: Clock, text: 'Cramming before tests' },
  { icon: BookOpen, text: 'Forgetting material quickly' },
  { icon: X, text: 'Passive reading, no engagement' },
  { icon: Brain, text: 'Anxiety around homework' },
];

const solutionPoints = [
  { icon: Clock, text: '15-minute focused sessions' },
  { icon: Brain, text: 'Long-term retention through games' },
  { icon: Zap, text: 'Interactive mini-challenges' },
  { icon: Check, text: 'Confidence building approach' },
];

export function ProblemSolutionSection() {
  return (
    <section className="py-20 lg:py-28 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <FadeInView className="text-center mb-16">
          <span className="section-label">THE CHALLENGE</span>
          <h2 className="font-poppins font-bold text-3xl sm:text-4xl lg:text-5xl text-slate-dark">
            Rote Memorization vs.{' '}
            <span className="gradient-text">Real Understanding</span>
          </h2>
        </FadeInView>

        {/* Comparison Cards */}
        <div className="grid md:grid-cols-2 gap-8 lg:gap-12">
          {/* Problem Card */}
          <FadeInView direction="left" delay={0}>
            <div className="relative bg-gradient-to-br from-red-50 to-orange-50 rounded-3xl p-8 lg:p-10 border border-red-100">
              <div className="absolute -top-6 left-8">
                <div className="w-12 h-12 bg-red-500 rounded-2xl flex items-center justify-center shadow-lg">
                  <X className="w-6 h-6 text-white" />
                </div>
              </div>
              
              <h3 className="font-poppins font-semibold text-2xl text-slate-dark mt-4 mb-6">
                Traditional Study Methods
              </h3>
              
              <ul className="space-y-4">
                {problemPoints.map((point, index) => (
                  <motion.li
                    key={point.text}
                    initial={{ opacity: 0, x: -20 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    viewport={{ once: true }}
                    transition={{ delay: index * 0.1 + 0.3 }}
                    className="flex items-center gap-4"
                  >
                    <div className="w-10 h-10 bg-red-100 rounded-xl flex items-center justify-center flex-shrink-0">
                      <point.icon className="w-5 h-5 text-red-500" />
                    </div>
                    <span className="text-slate-medium">{point.text}</span>
                  </motion.li>
                ))}
              </ul>
            </div>
          </FadeInView>

          {/* Solution Card */}
          <FadeInView direction="right" delay={0.2}>
            <div className="relative bg-gradient-to-br from-teal-50 to-green-50 rounded-3xl p-8 lg:p-10 border border-teal-100">
              <div className="absolute -top-6 left-8">
                <div className="w-12 h-12 bg-teal-500 rounded-2xl flex items-center justify-center shadow-lg">
                  <Check className="w-6 h-6 text-white" />
                </div>
              </div>
              
              <h3 className="font-poppins font-semibold text-2xl text-slate-dark mt-4 mb-6">
                AI-Assisted Active Learning
              </h3>
              
              <ul className="space-y-4">
                {solutionPoints.map((point, index) => (
                  <motion.li
                    key={point.text}
                    initial={{ opacity: 0, x: 20 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    viewport={{ once: true }}
                    transition={{ delay: index * 0.1 + 0.5 }}
                    className="flex items-center gap-4"
                  >
                    <div className="w-10 h-10 bg-teal-100 rounded-xl flex items-center justify-center flex-shrink-0">
                      <point.icon className="w-5 h-5 text-teal-600" />
                    </div>
                    <span className="text-slate-medium">{point.text}</span>
                  </motion.li>
                ))}
              </ul>
            </div>
          </FadeInView>
        </div>

        {/* VS Badge */}
        <FadeInView delay={0.4} className="flex justify-center -my-6 relative z-10">
          <div className="w-16 h-16 bg-white rounded-full shadow-xl flex items-center justify-center border-4 border-gray-50">
            <span className="font-poppins font-bold text-slate-light">VS</span>
          </div>
        </FadeInView>
      </div>
    </section>
  );
}
