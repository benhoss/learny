import { motion } from 'framer-motion';
import { MessageCircle, ArrowRight } from 'lucide-react';
import { FadeInView } from '@/components/animations/FadeInView';
import { FloatingElement } from '@/components/animations/FloatingElement';
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@/components/ui/accordion';

const faqs = [
  {
    question: 'Is this just a way for kids to cheat on homework?',
    answer: 'Absolutely not. Learny doesn\'t give answers—it creates practice materials based on school content. Your child learns by doing, not by copying. Our AI generates similar problems, flashcards, and quizzes that reinforce the exact concepts they\'re studying.',
  },
  {
    question: 'How do I know my child\'s data is safe?',
    answer: 'We\'re COPPA compliant and GDPR certified. We never sell data, show ads, or share information with third parties. All data is encrypted, and parents must provide consent before any account is created.',
  },
  {
    question: 'What age is Learny appropriate for?',
    answer: 'Learny is designed for children ages 10-14 (grades 5-8). The content adapts to your child\'s grade level and becomes more challenging as they progress.',
  },
  {
    question: 'Can I track my child\'s progress?',
    answer: 'Yes! The Parent Dashboard shows time spent learning, topics mastered, streak counts, and areas where your child might need extra help. You\'ll get weekly progress emails too.',
  },
  {
    question: 'What subjects does Learny support?',
    answer: 'Learny works with any subject: Math, Science, History, Geography, Language Arts, and more. If it\'s in a textbook or worksheet, our AI can create learning games from it.',
  },
  {
    question: 'Is there a free trial?',
    answer: 'Yes! Start with our Free plan—no credit card required. When you\'re ready, try Pro free for 7 days. Cancel anytime.',
  },
];

export function FAQSection() {
  return (
    <section id="faq" className="py-20 lg:py-28 bg-cream">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-5 gap-12 lg:gap-16">
          {/* Left Column - Header & CTA */}
          <div className="lg:col-span-2">
            <FadeInView>
              <span className="section-label">FAQ</span>
              <h2 className="font-poppins font-bold text-3xl sm:text-4xl lg:text-5xl text-slate-dark mb-4">
                Questions Parents{' '}
                <span className="gradient-text">Ask</span>
              </h2>
              <p className="text-lg text-slate-medium mb-8">
                Everything you need to know about Learny and how it helps your child learn.
              </p>
            </FadeInView>

            {/* Contact CTA */}
            <FadeInView delay={0.2}>
              <div className="glass-card p-6 text-center">
                <FloatingElement duration={4} distance={5}>
                  <div className="w-16 h-16 bg-gradient-to-br from-coral to-purple rounded-2xl flex items-center justify-center mx-auto mb-4">
                    <MessageCircle className="w-8 h-8 text-white" />
                  </div>
                </FloatingElement>
                <h3 className="font-poppins font-semibold text-xl text-slate-dark mb-2">
                  Still have questions?
                </h3>
                <p className="text-slate-medium text-sm mb-4">
                  Our team is here to help you get started.
                </p>
                <a
                  href="#"
                  className="inline-flex items-center gap-2 text-coral font-semibold hover:gap-3 transition-all"
                >
                  Contact Us
                  <ArrowRight className="w-4 h-4" />
                </a>
              </div>
            </FadeInView>
          </div>

          {/* Right Column - Accordion */}
          <div className="lg:col-span-3">
            <FadeInView delay={0.1}>
              <Accordion type="single" collapsible className="space-y-4">
                {faqs.map((faq, index) => (
                  <motion.div
                    key={index}
                    initial={{ opacity: 0, y: 20 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    transition={{ delay: index * 0.1 + 0.2 }}
                  >
                    <AccordionItem 
                      value={`item-${index}`}
                      className="bg-white rounded-2xl border-none shadow-sm px-6 data-[state=open]:shadow-md transition-shadow"
                    >
                      <AccordionTrigger className="text-left font-poppins font-medium text-slate-dark hover:text-coral py-5 [&[data-state=open]>svg]:rotate-45">
                        {faq.question}
                      </AccordionTrigger>
                      <AccordionContent className="text-slate-medium pb-5 leading-relaxed">
                        {faq.answer}
                      </AccordionContent>
                    </AccordionItem>
                  </motion.div>
                ))}
              </Accordion>
            </FadeInView>
          </div>
        </div>
      </div>
    </section>
  );
}
