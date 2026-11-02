plugins {
  alias(libs.plugins.android.application)
  alias(libs.plugins.kotlin.serialization)
  alias(libs.plugins.compose.compiler)
}

if (gradle.startParameter.taskNames.any { it.contains("play", ignoreCase = true) }) {
  pluginManager.apply("com.google.gms.google-services")
}

android {
  namespace = "com.matthewblott.todos"
  flavorDimensions += "distribution" 
  buildFeatures {
    compose = true
    buildConfig = true
  }
  buildTypes {
    release {
      isMinifyEnabled = true
      isShrinkResources = true
      optimization {
        enable = false
      }
      proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "proguard-rules.pro"
      )
    }
  }
  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
  }
  compileSdk {
    version = release(37)
  }
  defaultConfig {
    applicationId = "com.matthewblott.todos"
    minSdk = 28
    targetSdk = 37
    versionCode = 1
    versionName = "1.0.0"
  }
  dependenciesInfo {
    includeInApk = false
    includeInBundle = false
  }
  productFlavors {
    create("fdroid") { dimension = "distribution" }
    create("play")   { dimension = "distribution" }
  } 
}

dependencies {
  implementation(libs.androidx.activity.ktx)
  implementation(libs.androidx.appcompat)
  implementation(libs.androidx.constraintlayout)
  implementation(libs.androidx.core.ktx)
  implementation(libs.material)
  implementation("dev.hotwire:core:1.3.1")
  implementation("dev.hotwire:navigation-fragments:1.3.1")
  implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.8.1")
  implementation(platform("androidx.compose:compose-bom:2026.06.00"))
  implementation("androidx.compose.material3:material3")
  implementation("androidx.compose.ui:ui")
  implementation("androidx.compose.ui:ui-tooling-preview")
  implementation("androidx.compose.runtime:runtime")
  "fdroidImplementation"("org.unifiedpush.android:connector:3.3.5")
  "fdroidImplementation"("org.unifiedpush.android:connector-ui:1.1.0")
  "playImplementation"(platform("com.google.firebase:firebase-bom:35.1.0"))
  "playImplementation"(libs.firebase.messaging)
}