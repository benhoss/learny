import { AppProvider, useApp } from '@/context/AppContext';
import { HomeScreen } from '@/screens/HomeScreen';
import { UploadScreen } from '@/screens/UploadScreen';
import { SessionScreen } from '@/screens/SessionScreen';
import { FeedbackScreen } from '@/screens/FeedbackScreen';
import { RevisionScreen } from '@/screens/RevisionScreen';
import './index.css';

function AppContent() {
  const { currentScreen } = useApp();

  return (
    <div className="min-h-screen bg-neutral-cream flex items-center justify-center p-4">
      {/* Mobile Frame */}
      <div className="relative w-full max-w-md">
        {/* Phone Frame (visible on larger screens) */}
        <div className="hidden md:block absolute -inset-3 bg-neutral-dark rounded-[3rem] p-3 shadow-2xl">
          <div className="w-full h-full bg-neutral-medium rounded-[2.5rem] flex items-center justify-center">
            {/* Notch */}
            <div className="absolute top-6 left-1/2 -translate-x-1/2 w-24 h-6 bg-neutral-dark rounded-full" />
          </div>
        </div>
        
        {/* Screen Content */}
        <div className="relative md:mx-3 md:my-8 md:rounded-[2rem] overflow-hidden bg-cream shadow-xl min-h-[800px]">
          {currentScreen === 'home' && <HomeScreen />}
          {currentScreen === 'upload' && <UploadScreen />}
          {currentScreen === 'session' && <SessionScreen />}
          {currentScreen === 'feedback' && <FeedbackScreen />}
          {currentScreen === 'revision' && <RevisionScreen />}
        </div>
      </div>
    </div>
  );
}

function App() {
  return (
    <AppProvider>
      <AppContent />
    </AppProvider>
  );
}

export default App;
