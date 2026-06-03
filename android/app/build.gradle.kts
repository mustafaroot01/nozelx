plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
namespace = "com.autolube.nozzle"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ✅ تفعيل desugaring لدعم ميزات Java 8+ على الأجهزة القديمة
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // ✅ توحيد إصدار JVM مع Java
        jvmTarget = "17"
    }

    defaultConfig {
applicationId = "com.autolube.nozzle"

        // ✅ minSdk 21 ممتاز للتطبيقات الحديثة
        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // ✅ تفعيل Multidex إذا احتجت
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // ✅ توقيع debug للتجربة على الموبايل
            signingConfig = signingConfigs.getByName("debug")
            
            // ✅ تحسينات Release
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isDebuggable = true
        }
    }
    
    // ✅ تحسينات الترجمة
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

flutter {
    source = "../.."
}

// ✅ التبعيات المطلوبة
dependencies {
    // ✅ Core Library Desugaring لمزام الميزات الجديدة على الأجهزة القديمة
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    
    // ✅ Kotlin Standard Library
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.0.21")
    
    // ✅ AndroidX Support
    implementation("androidx.core:core-ktx:1.15.0")
    implementation("androidx.multidex:multidex:2.0.1")
    
    // ✅ Google Play Core - مطلوب لـ Flutter Embedding
    implementation("com.google.android.play:core:1.10.3")
}
