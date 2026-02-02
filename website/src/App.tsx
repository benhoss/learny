import { Navbar } from '@/components/layout/Navbar';
import { Footer } from '@/components/layout/Footer';
import { HeroSection } from '@/sections/HeroSection';
import { ProblemSolutionSection } from '@/sections/ProblemSolutionSection';
import { HowItWorksSection } from '@/sections/HowItWorksSection';
import { FeaturesSection } from '@/sections/FeaturesSection';
import { TrustSafetySection } from '@/sections/TrustSafetySection';
import { PricingSection } from '@/sections/PricingSection';
import { FAQSection } from '@/sections/FAQSection';
import './index.css';

function App() {
  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main>
        <HeroSection />
        <ProblemSolutionSection />
        <HowItWorksSection />
        <FeaturesSection />
        <TrustSafetySection />
        <PricingSection />
        <FAQSection />
      </main>
      <Footer />
    </div>
  );
}

export default App;
