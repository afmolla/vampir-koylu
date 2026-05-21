import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreFile = rootProject.file("signing/release.keystore")
val hasReleaseKeystore = keystoreFile.isFile && keystoreFile.length() > 1000L

val signingProps = Properties().apply {
    rootProject.file("key.properties").takeIf { it.isFile }?.inputStream()?.use { load(it) }
}

android {
    namespace = "com.vampirkoylu.vampir_koylu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.vampirkoylu.vampir_koylu"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("releaseSigning") {
                storeFile = keystoreFile
                storePassword = signingProps.getProperty("storePassword")
                    ?: System.getenv("RELEASE_STORE_PASSWORD")
                    ?: "vampir_koylu_store"
                keyAlias = signingProps.getProperty("keyAlias")
                    ?: System.getenv("RELEASE_KEY_ALIAS")
                    ?: "vampir"
                keyPassword = signingProps.getProperty("keyPassword")
                    ?: System.getenv("RELEASE_KEY_PASSWORD")
                    ?: "vampir_koylu_key"
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("releaseSigning")
                ?: signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
