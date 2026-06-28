pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")

// ── workaround: patch workmanager_android build.gradle ──
// workmanager_android applies `kotlin-android` in its build.gradle, but
// Flutter's built-in Kotlin already provides it. Removing the redundant
// application silences the KGP warning. Runs before project evaluation.
val pubCache = providers.environmentVariable("PUB_CACHE")
    .orElse(providers.gradleProperty("PUB_CACHE"))
    .orElse(System.getProperty("user.home") + "/.pub-cache")
    .get()
val pubCacheDir = file(pubCache)
if (pubCacheDir.isDirectory) {
    pubCacheDir.walkTopDown().maxDepth(4).forEach { candidate ->
        if (candidate.name == "build.gradle"
            && candidate.parentFile?.name == "android"
            && candidate.parentFile?.parentFile?.name?.startsWith("workmanager_android") == true
        ) {
            val text = candidate.readText()
            val patched = text.replace(
                "apply plugin: 'kotlin-android'",
                "// apply plugin: 'kotlin-android'  // removed — Flutter's built-in Kotlin provides this"
            )
            if (text != patched) {
                candidate.writeText(patched)
                logger.lifecycle(":: patched KGP in ${candidate.absolutePath}")
            }
        }
    }
}
