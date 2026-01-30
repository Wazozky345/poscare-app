plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.poscare"
    compileSdk = 36  // <--- GANTI JADI 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.poscare"
        minSdk = flutter.minSdkVersion 
        targetSdk = 36 
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // Ini udah bener, jangan dihapus
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
