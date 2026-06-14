# Suppress warnings for missing optional ML Kit language modules
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep all ML Kit classes to prevent issues during R8 shrinking
-keep class com.google.mlkit.** { *; }
