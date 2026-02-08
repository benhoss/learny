import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Check, Sparkles } from 'lucide-react';
import { FadeInView } from '@/components/animations/FadeInView';
import { Switch } from '@/components/ui/switch';

const plans = [
  {
    name: 'Free',
    description: 'Perfect for trying out',
    monthlyPrice: 0,
    yearlyPrice: 0,
    features: [
      '3 learning packs per month',
      'Basic mini-games',
      '7-day streak tracking',
      'Email support',
    ],
    cta: 'Get Started Free',
    highlighted: false,
  },
  {
    name: 'Pro',
    description: 'Most popular choice',
    monthlyPrice: 9.99,
    yearlyPrice: 95.88,
    features: [
      'Unlimited learning packs',
      'All mini-game types',
      'Unlimited streak tracking',
      'Parent dashboard',
      'Revision Express mode',
      'Priority support',
    ],
    cta: 'Start Pro Trial',
    highlighted: true,
    badge: 'Most Popular',
  },
  {
    name: 'Family',
    description: 'For multiple children',
    monthlyPrice: 14.99,
    yearlyPrice: 143.88,
    features: [
      'Everything in Pro',
      'Up to 4 child profiles',
      'Family progress reports',
      'Custom learning paths',
      'Dedicated support',
    ],
    cta: 'Choose Family',
    highlighted: false,
  },
];

export function PricingSection() {
  const [isYearly, setIsYearly] = useState(false);

  return (
    <section id="pricing" className="py-20 lg:py-28 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <FadeInView className="text-center mb-12">
          <span className="section-label">PRICING</span>
          <h2 className="font-poppins font-bold text-3xl sm:text-4xl lg:text-5xl text-slate-dark mb-4">
            Start Free, Upgrade When{' '}
            <span className="gradient-text">Ready</span>
          </h2>
          <p className="text-lg text-slate-medium max-w-2xl mx-auto">
            Choose the plan that works best for your family. No hidden fees, cancel anytime.
          </p>
        </FadeInView>

        {/* Toggle */}
        <FadeInView delay={0.1} className="flex items-center justify-center gap-4 mb-12">
          <span className={`font-medium ${!isYearly ? 'text-slate-dark' : 'text-slate-light'}`}>
            Monthly
          </span>
          <Switch
            checked={isYearly}
            onCheckedChange={setIsYearly}
          />
          <span className={`font-medium ${isYearly ? 'text-slate-dark' : 'text-slate-light'}`}>
            Annual
          </span>
          <span className="bg-coral/10 text-coral text-xs font-semibold px-2 py-1 rounded-full">
            Save 20%
          </span>
        </FadeInView>

        {/* Pricing Cards */}
        <div className="grid md:grid-cols-3 gap-8 lg:gap-6">
          {plans.map((plan, index) => (
            <FadeInView key={plan.name} delay={index * 0.1 + 0.2}>
              <motion.div
                whileHover={{ y: -8 }}
                transition={{ duration: 0.4, ease: [0.4, 0, 0.2, 1] }}
                className={`relative rounded-3xl p-8 h-full flex flex-col ${
                  plan.highlighted
                    ? 'bg-gradient-to-br from-slate-dark to-slate-800 text-white shadow-2xl scale-105'
                    : 'bg-white border-2 border-gray-100'
                }`}
              >
                {/* Badge */}
                {plan.badge && (
                  <div className="absolute -top-4 left-1/2 -translate-x-1/2">
                    <div className="bg-gradient-to-r from-coral to-purple text-white text-xs font-bold px-4 py-1.5 rounded-full flex items-center gap-1">
                      <Sparkles className="w-3 h-3" />
                      {plan.badge}
                    </div>
                  </div>
                )}

                {/* Plan Header */}
                <div className="text-center mb-6">
                  <h3 className={`font-poppins font-semibold text-xl mb-2 ${
                    plan.highlighted ? 'text-white' : 'text-slate-dark'
                  }`}>
                    {plan.name}
                  </h3>
                  <p className={`text-sm ${plan.highlighted ? 'text-gray-300' : 'text-slate-light'}`}>
                    {plan.description}
                  </p>
                </div>

                {/* Price */}
                <div className="text-center mb-8">
                  <AnimatePresence mode="wait">
                    <motion.div
                      key={isYearly ? 'yearly' : 'monthly'}
                      initial={{ opacity: 0, y: -10 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: 10 }}
                      transition={{ duration: 0.2 }}
                    >
                      <span className={`font-poppins font-bold text-4xl ${
                        plan.highlighted ? 'text-white' : 'text-slate-dark'
                      }`}>
                        ${isYearly ? (plan.yearlyPrice / 12).toFixed(2) : plan.monthlyPrice}
                      </span>
                      <span className={`text-sm ${plan.highlighted ? 'text-gray-300' : 'text-slate-light'}`}>
                        /month
                      </span>
                    </motion.div>
                  </AnimatePresence>
                  {isYearly && plan.yearlyPrice > 0 && (
                    <p className={`text-xs mt-1 ${plan.highlighted ? 'text-gray-400' : 'text-slate-light'}`}>
                      Billed annually (${plan.yearlyPrice}/year)
                    </p>
                  )}
                </div>

                {/* Features */}
                <ul className="space-y-4 mb-8 flex-grow">
                  {plan.features.map((feature) => (
                    <li key={feature} className="flex items-start gap-3">
                      <div className={`w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 ${
                        plan.highlighted ? 'bg-coral' : 'bg-teal/20'
                      }`}>
                        <Check className={`w-3 h-3 ${plan.highlighted ? 'text-white' : 'text-teal'}`} />
                      </div>
                      <span className={`text-sm ${plan.highlighted ? 'text-gray-200' : 'text-slate-medium'}`}>
                        {feature}
                      </span>
                    </li>
                  ))}
                </ul>

                {/* CTA */}
                <a
                  href="#download"
                  className={`w-full py-4 rounded-full font-semibold text-center transition-all duration-300 ${
                    plan.highlighted
                      ? 'bg-gradient-to-r from-coral to-purple text-white hover:shadow-lg hover:scale-[1.02]'
                      : 'bg-gray-100 text-slate-dark hover:bg-gray-200'
                  }`}
                >
                  {plan.cta}
                </a>
              </motion.div>
            </FadeInView>
          ))}
        </div>

        {/* Trial Note */}
        <FadeInView delay={0.5} className="text-center mt-8">
          <p className="text-slate-light text-sm">
            All paid plans include a 7-day free trial. No credit card required to start.
          </p>
        </FadeInView>
      </div>
    </section>
  );
}
