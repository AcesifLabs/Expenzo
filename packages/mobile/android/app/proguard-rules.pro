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

# Play Core: the Flutter engine references the deferred-components classes
# (com.google.android.play.core.splitinstall/splitcompat/tasks), which this app
# never uses. The old all-in-one com.google.android.play:core is deprecated and
# clashes with in_app_review's com.google.android.play:review, so don't add it
# back; let R8 skip the unused references instead.
-dontwarn com.google.android.play.core.**
