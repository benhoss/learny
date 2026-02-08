import { motion } from 'framer-motion';
import { Camera, Sparkles, Trophy, ArrowRight } from 'lucide-react';
import { FadeInView } from '@/components/animations/FadeInView';
import { StaggerContainer, StaggerItem } from '@/components/animations/StaggerContainer';

const steps = [
  {
    icon: Camera,
    title: 'Snap Your Homework',
    description: 'Take a photo of any school worksheet, textbook page, or assignment. Our AI reads and understands the material.',
    color: 'from-orange-400 to-coral',
    bgColor: 'bg-orange-50',
  },
  {
    icon: Sparkles,
    title: 'AI Creates Learning Games',
    description: 'In seconds, Learny generates personalized flashcards, quizzes, and matching games based on the exact content.',
    color: 'from-teal-400 to-teal',
    bgColor: 'bg-teal-50',
  },
  {
    icon: Trophy,
    title: 'Learn & Earn Rewards',
    description: 'Your child plays through 15-minute sessions, earning XP and building streaks while mastering the material.',
    color: 'from-purple-400 to-purple',
    bgColor: 'bg-purple-50',
  },
];

export function HowItWorksSection() {
  return (
    <section id="how-it-works" className="py-20 lg:py-28 bg-gradient-to-b from-cream to-sky">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <FadeInView className="text-center mb-16">
          <span className="section-label">HOW IT WORKS</span>
          <h2 className="font-poppins font-bold text-3xl sm:text-4xl lg:text-5xl text-slate-dark mb-4">
            From Homework to Mastery in{' '}
            <span className="gradient-text">3 Steps</span>
          </h2>
          <p className="text-lg text-slate-medium max-w-2xl mx-auto">
            Getting started is easy. Transform any school material into engaging learning experiences in minutes.
          </p>
        </FadeInView>

        {/* Steps */}
        <StaggerContainer className="grid md:grid-cols-3 gap-8 lg:gap-12 relative">
          {/* Connection Line (Desktop) */}
          <div className="hidden md:block absolute top-24 left-[20%] right-[20%] h-0.5">
            <motion.div
              initial={{ scaleX: 0 }}
              whileInView={{ scaleX: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 1, delay: 0.5 }}
              className="h-full bg-gradient-to-r from-coral via-teal to-purple origin-left"
            />
          </div>

          {steps.map((step, index) => (
            <StaggerItem key={step.title}>
              <div className="relative">
                {/* Step Number */}
                <div className="flex justify-center mb-6">
                  <motion.div
                    initial={{ scale: 0 }}
                    whileInView={{ scale: 1 }}
                    viewport={{ once: true }}
                    transition={{ 
                      type: "spring",
                      stiffness: 200,
                      damping: 15,
                      delay: index * 0.2 + 0.3
                    }}
                    className={`w-16 h-16 rounded-2xl bg-gradient-to-br ${step.color} flex items-center justify-center shadow-lg relative z-10`}
                  >
                    <step.icon className="w-8 h-8 text-white" />
                  </motion.div>
                </div>

                {/* Card */}
                <div className={`${step.bgColor} rounded-3xl p-8 text-center h-full`}>
                  <div className="w-8 h-8 rounded-full bg-white shadow-md flex items-center justify-center mx-auto mb-4">
                    <span className="font-poppins font-bold text-slate-dark">{index + 1}</span>
                  </div>
                  
                  <h3 className="font-poppins font-semibold text-xl text-slate-dark mb-3">
                    {step.title}
                  </h3>
                  
                  <p className="text-slate-medium leading-relaxed">
                    {step.description}
                  </p>
                </div>

                {/* Arrow (Mobile) */}
                {index < steps.length - 1 && (
                  <div className="flex justify-center my-4 md:hidden">
                    <ArrowRight className="w-6 h-6 text-slate-light rotate-90" />
                  </div>
                )}
              </div>
            </StaggerItem>
          ))}
        </StaggerContainer>

        {/* CTA */}
        <FadeInView delay={0.6} className="text-center mt-12">
          <a href="#download" className="btn-primary inline-flex items-center gap-2">
            Try It Free
            <ArrowRight className="w-5 h-5" />
          </a>
        </FadeInView>
      </div>
    </section>
  );
}
