# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**

# Connectivity Plus
-keep class dev.connectivity_plus.** { *; }

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# WorkManager
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# Drift / SQLite
-keep class * extends com.github.drift.** { *; }
-dontwarn com.squareup.moshi.**
