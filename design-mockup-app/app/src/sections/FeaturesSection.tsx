import { motion } from 'framer-motion';
import { Camera, Package, Gamepad2, Zap, BarChart3, Shield } from 'lucide-react';
import { FadeInView } from '@/components/animations/FadeInView';
import { StaggerContainer, StaggerItem } from '@/components/animations/StaggerContainer';

const features = [
  {
    icon: Camera,
    title: 'Photo & PDF Upload',
    description: 'Snap a picture of any homework or upload PDFs. Works with textbooks, worksheets, and handwritten notes.',
    color: 'bg-gradient-to-br from-orange-400 to-coral',
    iconBg: 'bg-orange-100',
  },
  {
    icon: Package,
    title: 'Smart Learning Packs',
    description: 'AI organizes content into bite-sized learning modules, perfectly aligned with school curriculum.',
    color: 'bg-gradient-to-br from-teal-400 to-teal',
    iconBg: 'bg-teal-100',
  },
  {
    icon: Gamepad2,
    title: 'Fun Mini-Games',
    description: 'Flashcards, quizzes, matching games, and puzzles that make learning feel like playtime.',
    color: 'bg-gradient-to-br from-yellow-400 to-amber',
    iconBg: 'bg-yellow-100',
  },
  {
    icon: Zap,
    title: 'Revision Express',
    description: 'Quick 5-minute review sessions before tests. Perfect for last-minute confidence building.',
    color: 'bg-gradient-to-br from-coral to-red-400',
    iconBg: 'bg-red-100',
  },
  {
    icon: BarChart3,
    title: 'Parent Dashboard',
    description: 'Track progress, see time spent learning, and monitor which topics need more attention.',
    color: 'bg-gradient-to-br from-purple-400 to-purple',
    iconBg: 'bg-purple-100',
  },
  {
    icon: Shield,
    title: '100% Safe & Private',
    description: 'COPPA compliant, no data selling, no ads. Your child\'s information stays protected.',
    color: 'bg-gradient-to-br from-blue-400 to-teal',
    iconBg: 'bg-blue-100',
  },
];

export function FeaturesSection() {
  return (
    <section id="features" className="py-20 lg:py-28 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <FadeInView className="text-center mb-16">
          <span className="section-label">FEATURES</span>
          <h2 className="font-poppins font-bold text-3xl sm:text-4xl lg:text-5xl text-slate-dark mb-4">
            Everything Your Child Needs to{' '}
            <span className="gradient-text">Succeed</span>
          </h2>
          <p className="text-lg text-slate-medium max-w-2xl mx-auto">
            A complete learning toolkit designed to make studying engaging, effective, and fun.
          </p>
        </FadeInView>

        {/* Features Grid */}
        <StaggerContainer className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8">
          {features.map((feature) => (
            <StaggerItem key={feature.title}>
              <motion.div
                whileHover={{ y: -8 }}
                transition={{ duration: 0.4, ease: [0.4, 0, 0.2, 1] }}
                className="feature-card group cursor-pointer h-full"
              >
                {/* Icon */}
                <motion.div
                  whileHover={{ scale: 1.1 }}
                  transition={{ duration: 0.3 }}
                  className={`w-16 h-16 rounded-2xl ${feature.color} flex items-center justify-center mb-6 shadow-lg`}
                >
                  <feature.icon className="w-8 h-8 text-white" />
                </motion.div>

                {/* Content */}
                <h3 className="font-poppins font-semibold text-xl text-slate-dark mb-3 group-hover:text-coral transition-colors">
                  {feature.title}
                </h3>
                
                <p className="text-slate-medium leading-relaxed">
                  {feature.description}
                </p>
              </motion.div>
            </StaggerItem>
          ))}
        </StaggerContainer>
      </div>
    </section>
  );
}
