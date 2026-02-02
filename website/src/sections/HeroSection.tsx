import { motion } from 'framer-motion';
import { Apple, Play, Shield, Lock, Award } from 'lucide-react';
import { FloatingElement } from '@/components/animations/FloatingElement';

const trustBadges = [
  { icon: Shield, label: 'COPPA Compliant' },
  { icon: Lock, label: 'No Data Selling' },
  { icon: Award, label: 'Educator Approved' },
];

export function HeroSection() {
  return (
    <section className="relative min-h-screen bg-gradient-hero overflow-hidden pt-20">
      {/* Decorative Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          animate={{ 
            rotate: 360,
            scale: [1, 1.1, 1]
          }}
          transition={{ 
            rotate: { duration: 20, repeat: Infinity, ease: "linear" },
            scale: { duration: 8, repeat: Infinity, ease: "easeInOut" }
          }}
          className="absolute -top-20 -right-20 w-96 h-96 bg-coral/10 rounded-full blur-3xl"
        />
        <motion.div
          animate={{ 
            rotate: -360,
            scale: [1, 1.2, 1]
          }}
          transition={{ 
            rotate: { duration: 25, repeat: Infinity, ease: "linear" },
            scale: { duration: 10, repeat: Infinity, ease: "easeInOut" }
          }}
          className="absolute -bottom-40 -left-40 w-[500px] h-[500px] bg-teal/10 rounded-full blur-3xl"
        />
        
        {/* Floating shapes */}
        <FloatingElement duration={5} distance={15} className="absolute top-1/4 left-[10%]">
          <div className="w-4 h-4 bg-coral/30 rounded-full" />
        </FloatingElement>
        <FloatingElement duration={6} distance={10} className="absolute top-1/3 right-[15%]">
          <div className="w-6 h-6 bg-teal/30 rounded-lg rotate-45" />
        </FloatingElement>
        <FloatingElement duration={4} distance={12} className="absolute bottom-1/4 left-[20%]">
          <div className="w-3 h-3 bg-purple/30 rounded-full" />
        </FloatingElement>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 lg:py-20">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          {/* Content */}
          <div className="relative z-10">
            {/* Badge */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              className="inline-flex items-center gap-2 bg-white/80 backdrop-blur-sm rounded-full px-4 py-2 mb-6 shadow-sm"
            >
              <span className="text-lg">🎓</span>
              <span className="text-sm font-medium text-slate-dark">
                Trusted by 10,000+ Parents
              </span>
            </motion.div>

            {/* Headline */}
            <motion.h1
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.4 }}
              className="font-poppins font-bold text-4xl sm:text-5xl lg:text-6xl text-slate-dark leading-tight mb-6"
            >
              Teach Your Child to Learn{' '}
              <span className="text-coral">WITH AI</span>, Not{' '}
              <span className="text-teal">FROM AI</span>
            </motion.h1>

            {/* Subheadline */}
            <motion.p
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.5 }}
              className="text-lg text-slate-medium leading-relaxed mb-8 max-w-xl"
            >
              Learny transforms school homework into engaging 15-minute learning sessions. 
              Build real understanding, not shortcuts.
            </motion.p>

            {/* CTA Buttons */}
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.6 }}
              className="flex flex-col sm:flex-row gap-4 mb-8"
            >
              <a href="#download" className="btn-primary">
                <Apple className="w-5 h-5 mr-2" />
                Download on App Store
              </a>
              <a href="#download" className="btn-secondary">
                <Play className="w-5 h-5 mr-2 fill-current" />
                Get it on Google Play
              </a>
            </motion.div>

            {/* Trust Badges */}
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.7 }}
              className="flex flex-wrap gap-4"
            >
              {trustBadges.map((badge) => (
                <div
                  key={badge.label}
                  className="flex items-center gap-2 text-sm text-slate-medium"
                >
                  <badge.icon className="w-4 h-4 text-coral" />
                  <span>{badge.label}</span>
                </div>
              ))}
            </motion.div>
          </div>

          {/* Hero Image */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.8, delay: 0.5 }}
            className="relative flex justify-center lg:justify-end"
          >
            <FloatingElement duration={4} distance={10}>
              <div className="relative">
                <img
                  src="/images/hero-phone.png"
                  alt="Learny App Dashboard"
                  className="w-full max-w-md lg:max-w-lg xl:max-w-xl drop-shadow-2xl"
                />
                
                {/* Floating fox mascot */}
                <motion.div
                  animate={{ 
                    scale: [1, 1.05, 1],
                    rotate: [-5, 5, -5]
                  }}
                  transition={{ 
                    duration: 4,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                  className="absolute -top-8 -left-8 w-24 h-24"
                >
                  <img
                    src="/images/fox-mascot.png"
                    alt="Learny Fox Mascot"
                    className="w-full h-full object-contain drop-shadow-lg"
                  />
                </motion.div>
              </div>
            </FloatingElement>
          </motion.div>
        </div>
      </div>

      {/* Bottom wave */}
      <div className="absolute bottom-0 left-0 right-0">
        <svg
          viewBox="0 0 1440 120"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="w-full"
        >
          <path
            d="M0 120L60 110C120 100 240 80 360 70C480 60 600 60 720 65C840 70 960 80 1080 85C1200 90 1320 90 1380 90L1440 90V120H1380C1320 120 1200 120 1080 120C960 120 840 120 720 120C600 120 480 120 360 120C240 120 120 120 60 120H0Z"
            fill="white"
          />
        </svg>
      </div>
    </section>
  );
}
