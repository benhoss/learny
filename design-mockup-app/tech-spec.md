# Learny Marketing Website - Technical Specification

---

## Component Inventory

### shadcn/ui Components (Built-in)
- **Button** - CTAs, navigation actions
- **Card** - Feature cards, pricing cards
- **Accordion** - FAQ section
- **Badge** - Labels, tags
- **Switch** - Pricing toggle (monthly/annual)
- **Sheet** - Mobile navigation drawer
- **Separator** - Visual dividers
- **ScrollArea** - Smooth scroll containers

### Custom Components

**Layout Components:**
- `Navbar` - Fixed navigation with scroll detection
- `MobileNav` - Hamburger menu for mobile
- `Footer` - Site footer with links

**Section Components:**
- `HeroSection` - Main hero with CTA
- `ProblemSolutionSection` - Comparison cards
- `HowItWorksSection` - 3-step process
- `FeaturesSection` - Feature grid
- `TrustSafetySection` - Credentials and safety
- `PricingSection` - Pricing tiers
- `FAQSection` - Accordion FAQ

**Animation Components:**
- `FadeInView` - Scroll-triggered fade animation
- `FloatingElement` - Continuous float animation
- `StaggerContainer` - Staggered children animations
- `AnimatedCounter` - Number counting animation
- `DrawLine` - SVG line draw animation

**UI Components:**
- `FeatureCard` - Individual feature card
- `PricingCard` - Pricing tier card
- `StepCard` - How it works step
- `TrustBadge` - Certification badge
- `DownloadButton` - App store buttons

---

## Animation Implementation Table

| Animation | Library | Implementation Approach | Complexity |
|-----------|---------|------------------------|------------|
| Page load sequence | Framer Motion | AnimatePresence + stagger children | Medium |
| Navbar scroll effect | React hooks | useScroll + useTransform | Low |
| Hero text reveal | Framer Motion | motion.div with stagger delays | Medium |
| Hero phone float | Framer Motion | animate prop with repeat | Low |
| Fox mascot breathing | Framer Motion | animate scale with repeat | Low |
| Scroll-triggered reveals | Framer Motion | whileInView + viewport | Medium |
| Problem/Solution cards | Framer Motion | whileInView from left/right | Medium |
| How It Works path draw | Framer Motion | SVG pathLength animation | High |
| Step card stagger | Framer Motion | staggerChildren variant | Medium |
| Feature card hover | Framer Motion | whileHover + transition | Low |
| Feature grid reveal | Framer Motion | staggerChildren + whileInView | Medium |
| Pricing toggle | Framer Motion | AnimatePresence for price swap | Medium |
| FAQ accordion | Framer Motion | AnimatePresence + height auto | Medium |
| Trust badge bounce | Framer Motion | spring animation | Low |
| Floating decorations | CSS + Framer | Infinite float animation | Low |
| Button hover effects | CSS/Tailwind | Transform + shadow transitions | Low |
| Card hover lift | CSS/Tailwind | TranslateY + shadow | Low |

---

## Animation Library Choices

### Primary: Framer Motion
**Rationale:**
- React-native integration
- Declarative animation syntax
- Built-in scroll-triggered animations (whileInView)
- AnimatePresence for mount/unmount
- Excellent TypeScript support
- Gesture support (hover, tap)
- Spring physics for natural motion

### Secondary: CSS/Tailwind
**Rationale:**
- Simple hover transitions
- Performance-critical micro-interactions
- Reduced motion support
- No JS overhead for basic effects

---

## Project File Structure

```
/mnt/okcomputer/output/app/
├── public/
│   ├── images/
│   │   ├── hero-phone.png
│   │   ├── fox-mascot.png
│   │   ├── fox-studying.png
│   │   └── ...
│   └── favicon.ico
├── src/
│   ├── components/
│   │   ├── ui/              # shadcn components
│   │   ├── animations/      # Animation wrappers
│   │   │   ├── FadeInView.tsx
│   │   │   ├── FloatingElement.tsx
│   │   │   └── StaggerContainer.tsx
│   │   ├── layout/          # Layout components
│   │   │   ├── Navbar.tsx
│   │   │   ├── MobileNav.tsx
│   │   │   └── Footer.tsx
│   │   └── shared/          # Reusable UI components
│   │       ├── FeatureCard.tsx
│   │       ├── PricingCard.tsx
│   │       ├── StepCard.tsx
│   │       └── DownloadButton.tsx
│   ├── sections/            # Page sections
│   │   ├── HeroSection.tsx
│   │   ├── ProblemSolutionSection.tsx
│   │   ├── HowItWorksSection.tsx
│   │   ├── FeaturesSection.tsx
│   │   ├── TrustSafetySection.tsx
│   │   ├── PricingSection.tsx
│   │   └── FAQSection.tsx
│   ├── hooks/               # Custom hooks
│   │   ├── useScrollPosition.ts
│   │   └── useReducedMotion.ts
│   ├── lib/                 # Utilities
│   │   └── utils.ts
│   ├── App.tsx
│   ├── main.tsx
│   └── index.css
├── components.json
├── tailwind.config.js
├── vite.config.ts
└── package.json
```

---

## Dependencies

### Core (Auto-installed)
- React 18
- TypeScript
- Vite
- Tailwind CSS
- shadcn/ui components

### Animation
```bash
npm install framer-motion
```

### Icons
```bash
npm install lucide-react
```

### Fonts
- Google Fonts: Poppins, Inter, Nunito (loaded via CDN in index.css)

---

## Technical Implementation Notes

### Scroll-Triggered Animations
```tsx
// Using Framer Motion whileInView
<motion.div
  initial={{ opacity: 0, y: 30 }}
  whileInView={{ opacity: 1, y: 0 }}
  viewport={{ once: true, margin: "-20%" }}
  transition={{ duration: 0.6, ease: [0.4, 0, 0.2, 1] }}
>
  {children}
</motion.div>
```

### Stagger Animation Pattern
```tsx
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2
    }
  }
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { 
    opacity: 1, 
    y: 0,
    transition: { duration: 0.5, ease: [0.4, 0, 0.2, 1] }
  }
};
```

### Floating Animation
```tsx
<motion.div
  animate={{ y: [-10, 10, -10] }}
  transition={{ 
    duration: 4, 
    repeat: Infinity, 
    ease: "easeInOut" 
  }}
>
  {children}
</motion.div>
```

### Navbar Scroll Effect
```tsx
const [scrolled, setScrolled] = useState(false);

useEffect(() => {
  const handleScroll = () => {
    setScrolled(window.scrollY > 50);
  };
  window.addEventListener('scroll', handleScroll);
  return () => window.removeEventListener('scroll', handleScroll);
}, []);
```

### Reduced Motion Support
```tsx
const prefersReducedMotion = useReducedMotion();

const animationProps = prefersReducedMotion 
  ? {} 
  : { initial, animate, transition };
```

---

## Performance Considerations

1. **Image Optimization**
   - Use WebP format where possible
   - Lazy load below-fold images
   - Proper sizing for responsive images

2. **Animation Performance**
   - Use transform and opacity only
   - Apply will-change sparingly
   - Disable complex animations on mobile
   - Respect prefers-reduced-motion

3. **Code Splitting**
   - Lazy load sections if needed
   - Tree-shake unused components

4. **Font Loading**
   - Use font-display: swap
   - Preload critical fonts
   - System font fallbacks

---

## Responsive Strategy

**Breakpoints:**
- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px

**Mobile-First Approach:**
- Base styles for mobile
- Progressive enhancement for larger screens
- Simplified animations on mobile
- Touch-optimized interactions

---

## Build Configuration

**Vite Config:**
- Optimize deps for framer-motion
- CSS code splitting
- Asset optimization

**Tailwind Config:**
- Custom colors from design system
- Custom font families
- Extended spacing scale
- Animation utilities
