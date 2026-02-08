import { motion } from 'framer-motion';
import { Camera, FileText, Image } from 'lucide-react';
import { useApp } from '@/context/AppContext';
import { ScreenTransition } from '@/components/ui-custom/ScreenTransition';
import { BackButton } from '@/components/ui-custom/BackButton';

export function UploadScreen() {
  const { navigate } = useApp();

  const handleUpload = (_type: 'camera' | 'file') => {
    // In a real app, this would handle the actual upload
    // For now, we'll just navigate to the session
    navigate('session');
  };

  return (
    <ScreenTransition>
      <div className="mobile-container bg-cream">
        {/* Header */}
        <div className="screen-header">
          <BackButton onClick={() => navigate('home')} />
          <h1 className="text-2xl font-bold text-neutral-dark mt-4">Upload Your Lesson</h1>
          <p className="text-neutral-light mt-2">
            Take a photo or upload a PDF of your school material
          </p>
        </div>

        {/* Content */}
        <div className="screen-content flex flex-col gap-6">
          {/* Upload Options */}
          <div className="flex flex-col gap-4">
            {/* Camera Upload */}
            <motion.button
              onClick={() => handleUpload('camera')}
              whileTap={{ scale: 0.98 }}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 }}
              className="upload-btn"
            >
              <div className="w-16 h-16 bg-sky-light rounded-2xl flex items-center justify-center">
                <Camera className="w-8 h-8 text-sky-dark" />
              </div>
              <div className="text-center">
                <p className="text-lg font-semibold text-neutral-dark">Take a Photo</p>
                <p className="text-sm text-neutral-light">Snap your worksheet or textbook</p>
              </div>
            </motion.button>

            {/* File Upload */}
            <motion.button
              onClick={() => handleUpload('file')}
              whileTap={{ scale: 0.98 }}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className="upload-btn"
            >
              <div className="w-16 h-16 bg-mint-light rounded-2xl flex items-center justify-center">
                <FileText className="w-8 h-8 text-mint-dark" />
              </div>
              <div className="text-center">
                <p className="text-lg font-semibold text-neutral-dark">Upload File</p>
                <p className="text-sm text-neutral-light">Select a PDF from your device</p>
              </div>
            </motion.button>
          </div>

          {/* Supported Formats */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="bg-white rounded-2xl p-5"
          >
            <p className="text-sm font-semibold text-neutral-medium mb-3">Supported formats</p>
            <div className="flex gap-4">
              <div className="flex items-center gap-2">
                <Image className="w-4 h-4 text-sky" />
                <span className="text-sm text-neutral-light">JPG, PNG</span>
              </div>
              <div className="flex items-center gap-2">
                <FileText className="w-4 h-4 text-mint" />
                <span className="text-sm text-neutral-light">PDF</span>
              </div>
            </div>
          </motion.div>

          {/* Tips */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.4 }}
            className="bg-sky-light/30 rounded-2xl p-5"
          >
            <p className="text-sm font-semibold text-sky-dark mb-2">💡 Tips for best results</p>
            <ul className="text-sm text-neutral-medium space-y-2">
              <li>• Make sure the text is clearly visible</li>
              <li>• Good lighting helps the AI read better</li>
              <li>• One page at a time works best</li>
            </ul>
          </motion.div>

          {/* Example Preview */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.5 }}
          >
            <p className="text-sm font-semibold text-neutral-medium mb-3">Example</p>
            <div className="bg-white rounded-2xl p-4 shadow-card border-2 border-dashed border-neutral-soft">
              <div className="aspect-[3/4] bg-neutral-cream rounded-xl flex items-center justify-center">
                <div className="text-center">
                  <div className="w-20 h-24 bg-white rounded shadow-sm mx-auto mb-3 flex items-center justify-center">
                    <div className="text-center p-2">
                      <div className="h-2 w-16 bg-neutral-soft rounded mb-2" />
                      <div className="h-2 w-12 bg-neutral-soft rounded mb-2" />
                      <div className="h-2 w-14 bg-neutral-soft rounded" />
                    </div>
                  </div>
                  <p className="text-xs text-neutral-light">A clear photo of your worksheet</p>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </ScreenTransition>
  );
}
