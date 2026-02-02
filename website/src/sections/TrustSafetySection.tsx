import { motion } from 'framer-motion';
import { Shield, Lock, Award, Check, User, BookOpen, GraduationCap } from 'lucide-react';
import { FadeInView } from '@/components/animations/FadeInView';
import { FloatingElement } from '@/components/animations/FloatingElement';

const certifications = [
  { icon: Shield, label: 'COPPA Certified' },
  { icon: Lock, label: 'GDPR Compliant' },
  { icon: Award, label: 'Educator Designed' },
];

const advisors = [
  { name: 'Dr. Sarah Chen, PhD', role: 'Child Development', icon: User },
  { name: 'Mark Johnson, M.Ed.', role: 'Curriculum Design', icon: BookOpen },
  { name: 'Lisa Park', role: 'EdTech Specialist', icon: GraduationCap },
];

const safetyFeatures = [
  'No personal data collection',
  'No third-party advertising',
  'Encrypted cloud storage',
  'Parental consent required',
  'Content moderation on all AI outputs',
  'Regular security audits',
];

export function TrustSafetySection() {
  return (
    <section className="py-20 lg:py-28 bg-gradient-trust relative overflow-hidden">
      {/* Decorative Elements */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-20 right-20 w-64 h-64 bg-coral/5 rounded-full blur-3xl" />
        <div className="absolute bottom-20 left-20 w-80 h-80 bg-teal/5 rounded-full blur-3xl" />
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        {/* Section Header */}
        <FadeInView className="text-center mb-16">
          <span className="section-label">TRUST & SAFETY</span>
          <h2 className="font-poppins font-bold text-3xl sm:text-4xl lg:text-5xl text-slate-dark mb-4">
            Built by Educators,{' '}
            <span className="gradient-text">Loved by Parents</span>
          </h2>
          <p className="text-lg text-slate-medium max-w-2xl mx-auto">
            Your child's safety and privacy are our top priorities. We're committed to ethical AI and transparent practices.
          </p>
        </FadeInView>

        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          {/* Left Column */}
          <div className="space-y-8">
            {/* Certifications */}
            <FadeInView delay={0.1}>
              <div className="glass-card p-8">
                <h3 className="font-poppins font-semibold text-xl text-slate-dark mb-6">
                  Certified & Compliant
                </h3>
                <div className="flex flex-wrap gap-4">
                  {certifications.map((cert, index) => (
                    <motion.div
                      key={cert.label}
                      initial={{ scale: 0 }}
                      whileInView={{ scale: 1 }}
                      viewport={{ once: true }}
                      transition={{ 
                        type: "spring",
                        stiffness: 200,
                        damping: 15,
                        delay: index * 0.1 + 0.3
                      }}
                      className="flex items-center gap-3 bg-white rounded-xl px-4 py-3 shadow-sm"
                    >
                      <div className="w-10 h-10 bg-gradient-to-br from-coral to-purple rounded-lg flex items-center justify-center">
                        <cert.icon className="w-5 h-5 text-white" />
                      </div>
                      <span className="font-medium text-slate-dark">{cert.label}</span>
                    </motion.div>
                  ))}
                </div>
              </div>
            </FadeInView>

            {/* Educational Advisors */}
            <FadeInView delay={0.2}>
              <div className="glass-card p-8">
                <h3 className="font-poppins font-semibold text-xl text-slate-dark mb-6">
                  Educational Advisors
                </h3>
                <div className="space-y-4">
                  {advisors.map((advisor, index) => (
                    <motion.div
                      key={advisor.name}
                      initial={{ opacity: 0, x: -20 }}
                      whileInView={{ opacity: 1, x: 0 }}
                      viewport={{ once: true }}
                      transition={{ delay: index * 0.1 + 0.4 }}
                      className="flex items-center gap-4"
                    >
                      <div className="w-12 h-12 bg-gradient-to-br from-teal to-blue-400 rounded-full flex items-center justify-center">
                        <advisor.icon className="w-6 h-6 text-white" />
                      </div>
                      <div>
                        <div className="font-medium text-slate-dark">{advisor.name}</div>
                        <div className="text-sm text-slate-light">{advisor.role}</div>
                      </div>
                    </motion.div>
                  ))}
                </div>
              </div>
            </FadeInView>
          </div>

          {/* Right Column */}
          <div className="space-y-8">
            {/* Fox Illustration */}
            <FadeInView delay={0.3} className="flex justify-center">
              <FloatingElement duration={5} distance={8}>
                <img
                  src="/images/fox-studying.png"
                  alt="Fox studying with books"
                  className="w-64 h-64 lg:w-80 lg:h-80 object-contain"
                />
              </FloatingElement>
            </FadeInView>

            {/* Safety Features */}
            <FadeInView delay={0.4}>
              <div className="glass-card p-8">
                <h3 className="font-poppins font-semibold text-xl text-slate-dark mb-6">
                  Safety Features
                </h3>
                <div className="grid sm:grid-cols-2 gap-4">
                  {safetyFeatures.map((feature, index) => (
                    <motion.div
                      key={feature}
                      initial={{ opacity: 0, y: 10 }}
                      whileInView={{ opacity: 1, y: 0 }}
                      viewport={{ once: true }}
                      transition={{ delay: index * 0.1 + 0.5 }}
                      className="flex items-center gap-3"
                    >
                      <div className="w-6 h-6 bg-teal/20 rounded-full flex items-center justify-center flex-shrink-0">
                        <Check className="w-4 h-4 text-teal" />
                      </div>
                      <span className="text-sm text-slate-medium">{feature}</span>
                    </motion.div>
                  ))}
                </div>
              </div>
            </FadeInView>
          </div>
        </div>
      </div>
    </section>
  );
}
