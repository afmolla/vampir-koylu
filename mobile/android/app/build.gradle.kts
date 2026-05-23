import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseKeystore = keystorePropertiesFile.exists().also { exists ->
    if (exists) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }
}

fun resolveStoreFile(): java.io.File? {
    if (!hasReleaseKeystore) return null
    val rel = keystoreProperties.getProperty("storeFile") ?: return null
    val primary = rootProject.file(rel)
    if (primary.exists()) return primary
    val pfx = rootProject.file("signing/release.pfx")
    if (pfx.exists()) return pfx
    return null
}

android {
    namespace = "com.vampirkoylu.vampir_koylu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
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
            create("release") {
                val store = resolveStoreFile()
                    ?: error("Imza dosyasi yok: signing/release.keystore veya release.pfx")
                storeFile = store
                storePassword = keystoreProperties.getProperty("storePassword")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                val alias = keystoreProperties.getProperty("keyAlias") ?: "vampir"
                keyAlias = alias
                val type = keystoreProperties.getProperty("storeType")
                    ?: if (store.extension.equals("pfx", ignoreCase = true)) "PKCS12" else "PKCS12"
                storeType = type
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
