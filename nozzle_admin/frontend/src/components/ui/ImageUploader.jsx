import React, { useState, useRef } from 'react';
import { Upload, X, AlertCircle, FileImage, Loader2, Info } from 'lucide-react';
import ImageUploadService from '../../services/imageUpload.service';

export default function ImageUploader({
  configKey,
  folder,
  value,
  onChange,
  multiple = false,
  maxFiles = 8,
  label,
  required = false,
}) {
  const config = ImageUploadService.configs[configKey];
  const [isDragging, setIsDragging] = useState(false);
  const [uploadingFiles, setUploadingFiles] = useState({}); // Track uploads by name: { name: progress }
  const [error, setError] = useState(null);
  const fileInputRef = useRef(null);

  // Safe checks for values
  const currentImages = multiple 
    ? (Array.isArray(value) ? value : (value ? [value] : []))
    : (typeof value === 'string' ? (value ? [value] : []) : []);

  if (!config) {
    return (
      <div className="p-4 bg-red-50 border border-red-200 text-red-700 rounded-xl text-sm">
        خطأ: إعداد الرفع "{configKey}" غير صالح أو غير معرّف.
      </div>
    );
  }

  // Get format names for display
  const displayFormats = config.allowedTypes
    .map(t => t.split('/')[1]?.toUpperCase() || t)
    .join(', ');

  const handleDragOver = (e) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleDrop = async (e) => {
    e.preventDefault();
    setIsDragging(false);
    setError(null);
    const files = Array.from(e.dataTransfer.files);
    if (files.length > 0) {
      await processFiles(files);
    }
  };

  const handleFileSelect = async (e) => {
    setError(null);
    const files = Array.from(e.target.files || []);
    if (files.length > 0) {
      await processFiles(files);
    }
  };

  const processFiles = async (files) => {
    // Filter out invalid count
    const targetFiles = multiple 
      ? files.slice(0, maxFiles - currentImages.length)
      : [files[0]];

    if (multiple && currentImages.length + files.length > maxFiles) {
      setError(`الحد الأقصى المسموح به هو ${maxFiles} صور فقط`);
    }

    for (const file of targetFiles) {
      // Validate
      const validationError = ImageUploadService.validateImage(file, config);
      if (validationError) {
        setError(validationError);
        continue;
      }

      // Add to uploading list
      setUploadingFiles(prev => ({ ...prev, [file.name]: 10 })); // starting progress
      
      try {
        // Upload single file
        // simulate upload progress updates
        const interval = setInterval(() => {
          setUploadingFiles(prev => {
            if (prev[file.name] < 90) {
              return { ...prev, [file.name]: prev[file.name] + 15 };
            }
            return prev;
          });
        }, 300);

        const result = await ImageUploadService.uploadSingle(file, configKey, folder);
        clearInterval(interval);
        
        // Remove from uploading list
        setUploadingFiles(prev => {
          const next = { ...prev };
          delete next[file.name];
          return next;
        });

        // Update parent
        if (multiple) {
          onChange([...currentImages, result.url]);
        } else {
          onChange(result.url);
        }
      } catch (err) {
        setUploadingFiles(prev => {
          const next = { ...prev };
          delete next[file.name];
          return next;
        });
        setError(err.message || 'فشل رفع الصورة');
      }
    }
  };

  const handleRemove = async (imageUrl, index) => {
    try {
      // Parse publicId from URL
      // example: /static/uploads/filename.jpg or cloudinary url
      let publicId = imageUrl;
      if (imageUrl.includes('/static/uploads/')) {
        publicId = imageUrl.split('/static/uploads/')[1];
      } else if (imageUrl.includes('res.cloudinary.com')) {
        // Cloudinary URL parses last part after folder name
        const parts = imageUrl.split('/');
        const fileWithExtension = parts[parts.length - 1];
        publicId = fileWithExtension.split('.')[0] || fileWithExtension;
        
        // prepend folder path if custom cloudinary setup
        const dashboardIdx = imageUrl.indexOf('dashboard/');
        if (dashboardIdx !== -1) {
          const cloudPath = imageUrl.substring(dashboardIdx);
          publicId = cloudPath.split('.')[0] || cloudPath;
        }
      }

      // Call delete endpoint
      await ImageUploadService.deleteImage(publicId);

      // Update parent value
      if (multiple) {
        const nextImages = currentImages.filter((_, idx) => idx !== index);
        onChange(nextImages);
      } else {
        onChange('');
      }
    } catch (err) {
      // Even if delete fails on server, update parent to clear reference in GUI
      if (multiple) {
        const nextImages = currentImages.filter((_, idx) => idx !== index);
        onChange(nextImages);
      } else {
        onChange('');
      }
      setError('تمت إزالة الصورة من النموذج ولكن قد تفشل إزالتها نهائياً من الخادم');
    }
  };

  const triggerSelect = () => {
    fileInputRef.current?.click();
  };

  return (
    <div className="w-full space-y-3 text-right" dir="rtl">
      {label && (
        <label className="block text-sm font-bold text-slate-700">
          {label} {required && <span className="text-red-500">*</span>}
        </label>
      )}

      {/* Specifications Card */}
      <div className="flex items-start gap-3 p-3 bg-amber-50 border border-amber-200 text-amber-900 rounded-xl text-xs leading-relaxed">
        <Info className="w-4.5 h-4.5 text-amber-600 shrink-0 mt-0.5" />
        <div className="space-y-0.5">
          <p className="font-bold">📐 قياسات الصورة المطلوبة</p>
          <div className="flex flex-wrap gap-x-4 gap-y-1 mt-1 text-amber-800">
            <span>• <b>الأبعاد:</b> {config.maxWidth} × {config.maxHeight} بكسل</span>
            <span>• <b>النسبة:</b> {config.aspectRatio}</span>
            <span>• <b>الحجم الأقصى:</b> {config.maxSizeMB}MB</span>
            <span>• <b>الصيغ:</b> {displayFormats}</span>
          </div>
        </div>
      </div>

      {/* Error Message */}
      {error && (
        <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 text-red-700 rounded-xl text-xs">
          <AlertCircle className="w-4 h-4 shrink-0" />
          <span className="font-semibold">{error}</span>
          <button onClick={() => setError(null)} className="mr-auto text-red-500 hover:text-red-700">
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* Drag & Drop Upload Zone */}
      {(multiple || currentImages.length === 0) && (
        <div
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
          onClick={triggerSelect}
          className={`relative group border-2 border-dashed rounded-2xl p-6 transition-all duration-300 cursor-pointer flex flex-col items-center justify-center gap-2 text-center select-none min-h-[140px] ${
            isDragging
              ? 'border-indigo-500 bg-indigo-50/50 scale-[0.99]'
              : 'border-slate-300 hover:border-indigo-400 bg-slate-50/50 hover:bg-slate-50'
          }`}
        >
          <input
            type="file"
            ref={fileInputRef}
            onChange={handleFileSelect}
            className="hidden"
            multiple={multiple}
            accept={config.allowedTypes.join(',')}
          />
          <div className={`p-3 rounded-full transition-all duration-300 ${
            isDragging ? 'bg-indigo-100 text-indigo-600' : 'bg-slate-100 text-slate-500 group-hover:bg-indigo-50 group-hover:text-indigo-500'
          }`}>
            <Upload className="w-6 h-6 animate-pulse" />
          </div>
          <div className="space-y-1">
            <p className="text-sm font-semibold text-slate-700 group-hover:text-indigo-600">
              اسحب الصورة هنا أو اضغط للاختيار
            </p>
            <p className="text-xs text-slate-400">
              {multiple ? `الحد الأقصى ${maxFiles} صور` : 'صورة واحدة فقط'}
            </p>
          </div>
        </div>
      )}

      {/* Progress Bars / Uploading files */}
      {Object.keys(uploadingFiles).length > 0 && (
        <div className="space-y-2 p-3 bg-slate-50 border border-slate-200 rounded-xl">
          {Object.entries(uploadingFiles).map(([name, progress]) => (
            <div key={name} className="space-y-1">
              <div className="flex justify-between items-center text-xs text-slate-600">
                <span className="font-semibold truncate max-w-[80%]">{name}</span>
                <span className="flex items-center gap-1">
                  <Loader2 className="w-3.5 h-3.5 animate-spin text-indigo-500" />
                  %{progress}
                </span>
              </div>
              <div className="w-full h-1.5 bg-slate-200 rounded-full overflow-hidden">
                <div
                  className="h-full bg-indigo-500 transition-all duration-300"
                  style={{ width: `${progress}%` }}
                />
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Images Preview Section */}
      {currentImages.length > 0 && (
        <div className="space-y-2">
          {multiple && (
            <div className="flex justify-between items-center text-xs font-bold text-slate-500 px-1">
              <span>الصور المرفوعة:</span>
              <span>{currentImages.length} / {maxFiles}</span>
            </div>
          )}
          
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            {currentImages.map((url, idx) => (
              <div
                key={url}
                className="relative group aspect-square rounded-2xl border border-slate-200 bg-slate-100 overflow-hidden shadow-sm hover:shadow-md transition-all duration-300"
              >
                <img
                  src={url}
                  alt={`معاينة ${idx + 1}`}
                  className="w-full h-full object-contain p-1"
                />
                
                {/* Delete Button overlay */}
                <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center">
                  <button
                    type="button"
                    onClick={(e) => {
                      e.stopPropagation();
                      handleRemove(url, idx);
                    }}
                    className="p-2 bg-red-600 hover:bg-red-700 text-white rounded-full hover:scale-110 shadow transition-all duration-300"
                  >
                    <X className="w-5 h-5" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
