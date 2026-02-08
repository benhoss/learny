# Learny Mobile App - Design System

---

## 1. Design Philosophy

**Core Values:**
- Calm & Reassuring - No stress, no pressure
- Encouraging & Positive - Build confidence
- Clean & Readable - Clear hierarchy
- Friendly but Not Childish - Respect the user's intelligence

**Emotional Goals:**
- Make children feel: safe, capable, curious, confident
- Learning as a calm daily habit, not homework

---

## 2. Color Palette

### Primary Colors
```
--primary-sky: #7DD3E8       // Calm, trustworthy blue
--primary-mint: #8FE5C2      // Fresh, positive green
--primary-lavender: #C5B9E8  // Soft, creative purple
--primary-cream: #FFF8F0     // Warm, welcoming background
```

### Secondary Colors
```
--secondary-coral: #FF9A8B   // Gentle accent (not aggressive)
--secondary-sunshine: #FFD97A // Warm yellow for highlights
--secondary-sage: #A8D5BA    // Natural, calming green
```

### Neutral Colors
```
--neutral-dark: #2D3748      // Primary text
--neutral-medium: #5A6C7D    // Secondary text
--neutral-light: #8B9CAD     // Placeholder text
--neutral-soft: #E8EDF2      // Borders, dividers
--neutral-cream: #F7F9FC     // Card backgrounds
--white: #FFFFFF
```

### Semantic Colors
```
--success: #7DD3C8           // Soft teal for correct
--info: #7DD3E8              // Sky blue for info
--highlight: #FFF4E1         // Warm highlight background
```

### Gradients
```
--gradient-welcome: linear-gradient(180deg, #E8F7FA 0%, #FFF8F0 100%)
--gradient-card: linear-gradient(135deg, #FFFFFF 0%, #F7F9FC 100%)
--gradient-accent: linear-gradient(135deg, #7DD3E8 0%, #8FE5C2 100%)
```

---

## 3. Typography System

### Font Family
```
--font-primary: 'Nunito', sans-serif  // Rounded, friendly, readable
--font-display: 'Poppins', sans-serif // For headings
```

### Type Scale (Mobile-First)

| Token | Size | Weight | Line Height | Use Case |
|-------|------|--------|-------------|----------|
| --text-hero | 28px | 700 | 1.2 | Welcome message |
| --text-h1 | 24px | 700 | 1.3 | Screen titles |
| --text-h2 | 20px | 600 | 1.4 | Section headers |
| --text-h3 | 18px | 600 | 1.4 | Card titles |
| --text-body | 16px | 400 | 1.6 | Primary content |
| --text-small | 14px | 400 | 1.5 | Secondary text |
| --text-caption | 12px | 500 | 1.4 | Labels, hints |
| --text-button | 16px | 600 | 1 | Button text |

---

## 4. Spacing System

### Base Unit: 4px

| Token | Value | Use Case |
|-------|-------|----------|
| --space-xs | 4px | Tight spacing |
| --space-sm | 8px | Icon gaps |
| --space-md | 16px | Default padding |
| --space-lg | 24px | Section gaps |
| --space-xl | 32px | Large sections |
| --space-2xl | 48px | Screen padding |

### Border Radius
```
--radius-sm: 8px    // Small elements
--radius-md: 12px   // Buttons, inputs
--radius-lg: 16px   // Cards
--radius-xl: 24px   // Large cards
--radius-full: 9999px // Pills, avatars
```

---

## 5. Component Library

### Buttons

**Primary Button**
- Background: --gradient-accent
- Text: white, 16px, 600 weight
- Padding: 16px 32px
- Border-radius: --radius-full
- Shadow: 0 4px 12px rgba(125, 211, 232, 0.3)
- Pressed: scale(0.98), shadow reduces

**Secondary Button**
- Background: white
- Border: 2px solid --primary-sky
- Text: --primary-sky, 16px, 600 weight
- Padding: 14px 30px
- Border-radius: --radius-full

**Ghost Button**
- Background: transparent
- Text: --neutral-medium
- Padding: 12px 24px
- Hover: background --neutral-cream

### Cards

**Session Card**
- Background: white
- Border-radius: --radius-xl
- Shadow: 0 4px 20px rgba(0, 0, 0, 0.06)
- Padding: 24px
- Border: 1px solid --neutral-soft

**Game Card**
- Background: --gradient-card
- Border-radius: --radius-lg
- Padding: 20px
- Interactive: scale on press

### Progress Indicators

**Session Progress Bar**
- Height: 8px
- Background: --neutral-soft
- Fill: --gradient-accent
- Border-radius: --radius-full
- No numbers, just visual

**Circular Progress**
- Size: 48px
- Stroke: --primary-mint
- Background stroke: --neutral-soft
- No percentage shown

### Input Elements

**Upload Button**
- Large tap area (min 120px)
- Icon + label
- Border: 2px dashed --primary-sky
- Border-radius: --radius-lg
- Hover: solid border, light background

**Choice Button (Quiz)**
- Background: white
- Border: 2px solid --neutral-soft
- Border-radius: --radius-md
- Padding: 16px 20px
- Selected: border --primary-sky, background --neutral-cream
- Correct: border --success, background rgba(125, 211, 200, 0.1)

---

## 6. Animation Guidelines

### Timing
- Default duration: 300ms
- Micro-interactions: 150ms
- Page transitions: 400ms
- Easing: cubic-bezier(0.4, 0, 0.2, 1)

### Interactions
- Button press: scale(0.98)
- Card hover: translateY(-2px)
- Progress fill: smooth width transition
- Success state: gentle pulse

### Reduced Motion
- Respect prefers-reduced-motion
- Disable animations for accessibility

---

## 7. Microcopy Guidelines

### Encouraging Messages
- "Nice try, let's review this together"
- "You're making progress"
- "Just a quick reminder before school"
- "Great thinking!"
- "You're getting the hang of this"

### Avoid
- "Wrong"
- "Failed"
- "Try harder"
- "Incorrect"
- Any negative language

### Positive Alternatives
- "Not quite" → "Let's look at this again"
- "Wrong answer" → "Here's another way to think about it"
- "Failed" → "Learning takes practice"

---

## 8. Screen Specifications

### Screen 1: Home / Dashboard
**Layout:**
- Safe area padding: 24px
- Welcome message at top
- Two primary action buttons (stacked)
- Progress section (subtle)
- Recent activity (optional)

**Elements:**
- Greeting: "Hi [Name]! Ready to learn?"
- Primary CTA: "Start Learning Session" (large)
- Secondary CTA: "Revision Express" (medium)
- Progress: "You've completed 3 sessions this week" (no numbers/streaks)

### Screen 2: Upload
**Layout:**
- Clear heading
- Two upload options (camera / file)
- Supported formats info
- Example/preview area

**Elements:**
- Title: "Upload Your School Lesson"
- Camera button: Large, with icon
- File button: Large, with icon
- Helper text: "We support photos and PDFs"

### Screen 3: Learning Session
**Layout:**
- Progress bar at top
- Game area (centered)
- Navigation at bottom

**Elements:**
- Progress bar (visual only)
- Current question number (optional)
- Game content
- Next/Skip button

### Screen 4: Mini-Games

**Flashcard:**
- Card centered
- Tap to flip
- Swipe for next
- Gentle animation

**Quiz:**
- Question at top
- 4 options (large tap targets)
- Clear selection state
- Submit button

**Matching:**
- Grid layout
- Drag or tap to match
- Visual connection lines
- Success animation

**Timed Challenge:**
- Gentle countdown (no stress)
- Progress circle
- Question + options
- Time up = "Let's take a breath and try again"

### Screen 5: Feedback
**Layout:**
- Centered content
- Positive icon/illustration
- Encouraging message
- Explanation (if needed)
- Continue button

**Elements:**
- Success: "Great job!" + explanation
- Learning moment: "Here's something to remember" + explanation
- Continue: "Next question" or "Continue"

### Screen 6: Revision Express
**Layout:**
- Minimal UI
- Large question
- Quick options
- Fast transitions

**End State:**
- "You're ready!"
- "Great work reviewing"
- Return to home

---

## 9. Accessibility Requirements

- Minimum touch target: 44x44px
- Color contrast: WCAG AA minimum
- Font size: Never below 12px
- Focus states: Visible outlines
- Screen reader: All elements labeled
- Reduced motion: Supported

---

## 10. Visual Examples

### Mood Keywords
- Calm
- Friendly
- Modern
- Clean
- Encouraging
- Soft
- Approachable

### Reference Feel
- Headspace (calm, mindful)
- Duolingo (playful but not childish)
- Apple Health (clean, trustworthy)
