# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Unity
-keep class com.unity3d.** { *; }
-keep class com.xraph.plugin.flutter_unity_widget.** { *; }
-keep class com.xraph.plugin.flutter_unity_widget_2.** { *; }

# Your native Android host / MethodChannel
-keep class com.example.ar_chemistry_visual.** { *; }
-keep class com.hoaianstudio.labedu.** { *; }

# Android DownloadManager / Broadcast / MethodChannel names
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Billing
-keep class com.android.billingclient.** { *; }
-keep class com.android.billingclient.api.** { *; }

# Kotlin metadata
-keep class kotlin.Metadata { *; }
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Gson / JSON reflection nếu project có dùng
-keep class com.google.gson.** { *; }
-keep class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Unity / native JNI methods
-keepclasseswithmembernames class * {
    native <methods>;
}