import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeystore = rootProject.file("signing/release.keystore")
val releaseSigning = run {
    if (!releaseKeystore.exists()) return@run null
    val props = Properties()
    rootProject.file("key.properties").takeIf { it.exists() }?.inputStream()?.use {
        props.load(it)
    }
    mapOf(
        "storeFile" to releaseKeystore,
        "storePassword" to (props.getProperty("storePassword")
            ?: System.getenv("RELEASE_STORE_PASSWORD")
            ?: "vampir_koylu_store"),
        "keyAlias" to (props.getProperty("keyAlias")
            ?: System.getenv("RELEASE_KEY_ALIAS")
            ?: "vampir"),
        "keyPassword" to (props.getProperty("keyPassword")
            ?: System.getenv("RELEASE_KEY_PASSWORD")
            ?: "vampir_koylu_key"),
    )
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.vampirkoylu.vampir_koylu"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigning != null) {
            create("releaseSigning") {
                storeFile = releaseSigning["storeFile"] as java.io.File
                storePassword = releaseSigning["storePassword"] as String
                keyAlias = releaseSigning["keyAlias"] as String
                keyPassword = releaseSigning["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (releaseSigning != null) {
                signingConfigs.getByName("releaseSigning")
            } else {
                signingConfigs.getByName("debug")
            }
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
