$projectPath = "C:\Users\st155\MediGuideAI"
$studioPath  = "C:\Program Files\Android\Android Studio\bin\studio64.exe"
$iconSource  = "C:\Users\st155\MyIcons\ic_launcher_source.png"
$appPackage  = "com.example.myapp"
$keystorePath = "C:\Users\st155\keystore\my-release-key.jks"
$keystoreAlias = "myalias"
$keystorePass = "MyStorePassword"
$keyPass = "MyKeyPassword"
$releaseOutput = "C:\Users\st155\Releases"

# === Самопроверка окружения ===
if (-not $env:JAVA_HOME -or -not (Test-Path "$env:JAVA_HOME\bin\java.exe")) {
    $candidateJava = "C:\Program Files\Android\Android Studio\jbr"
    if (Test-Path "$candidateJava\bin\java.exe") {
        Write-Host "JAVA_HOME не задан. Устанавливаю: $candidateJava" -ForegroundColor Yellow
        $env:JAVA_HOME = $candidateJava
    } else {
        Write-Error "JAVA_HOME не задан и JDK не найден по пути: $candidateJava"
        exit 1
    }
}

if (-not $env:ANDROID_HOME -or -not (Test-Path "$env:ANDROID_HOME\emulator\emulator.exe")) {
    $candidateAndroid = "$env:LOCALAPPDATA\Android\Sdk"
    if (Test-Path "$candidateAndroid\emulator\emulator.exe") {
        Write-Host "ANDROID_HOME не задан. Устанавливаю: $candidateAndroid" -ForegroundColor Yellow
        $env:ANDROID_HOME = $candidateAndroid
    } else {
        Write-Error "ANDROID_HOME не задан и SDK не найден по пути: $candidateAndroid"
        exit 1
    }
}

# Проверка иконки
if (-not (Test-Path $iconSource)) { Write-Error "Нет исходной иконки: $iconSource"; exit 1 }

# === Автогенерация Gradle-конфигов ===
if (-not (Test-Path "$projectPath\settings.gradle")) {
    "include ':app'" | Set-Content -Encoding UTF8 "$projectPath\settings.gradle"
}
if (-not (Test-Path "$projectPath\build.gradle")) {
@"
buildscript {
    repositories { google(); mavenCentral() }
    dependencies { classpath "com.android.tools.build:gradle:8.2.2" }
}
allprojects { repositories { google(); mavenCentral() } }
"@ | Set-Content -Encoding UTF8 "$projectPath\build.gradle"
}
$appDir = "$projectPath\app"
if (-not (Test-Path $appDir)) { New-Item -ItemType Directory -Path $appDir | Out-Null }
if (-not (Test-Path "$appDir\build.gradle")) {
@"
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}
android {
    namespace "$appPackage"
    compileSdk 34
    defaultConfig {
        applicationId "$appPackage"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
dependencies {
    implementation "androidx.core:core-ktx:1.12.0"
    implementation "androidx.appcompat:appcompat:1.6.1"
    implementation "com.google.android.material:material:1.11.0"
}
"@ | Set-Content -Encoding UTF8 "$appDir\build.gradle"
}

# === Автогенерация заглушек ресурсов и кода ===
$valuesDir = "$appDir\src\main\res\values"
$layoutDir = "$appDir\src\main\res\layout"
$javaDir   = "$appDir\src\main\java\com\example\myapp"

foreach ($dir in @($valuesDir, $layoutDir, $javaDir)) {
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

if (-not (Test-Path "$valuesDir\strings.xml")) {
    "<resources>`n<string name=`"app_name`">MyApp</string>`n</resources>" | Set-Content -Encoding UTF8 "$valuesDir\strings.xml"
}
if (-not (Test-Path "$valuesDir\colors.xml")) {
    "<resources>`n<color name=`"white`">#FFFFFF</color>`n<color name=`"black`">#000000</color>`n</resources>" | Set-Content -Encoding UTF8 "$valuesDir\colors.xml"
}
if (-not (Test-Path "$layoutDir\activity_main.xml")) {
@"
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center"
    android:orientation="vertical">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello, St."
        android:textSize="20sp"/>
</LinearLayout>
"@ | Set-Content -Encoding UTF8 "$layoutDir\activity_main.xml"
}
if (-not (Test-Path "$javaDir\MainActivity.kt")) {
@"
package com.example.myapp

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }
}
"@ | Set-Content -Encoding UTF8 "$javaDir\MainActivity.kt"
}

# === Генерация иконок ===
$mipmapConfig = @{
    "mipmap-mdpi"=48;"mipmap-hdpi"=72;"mipmap-xhdpi"=96;"mipmap-xxhdpi"=144;"mipmap-xxxhdpi"=192;"mipmap-anydpi-v26"=432
}
Add-Type -AssemblyName System.Drawing
$srcImg = [System.Drawing.Image]::FromFile($iconSource)
foreach ($dir in $mipmapConfig.Keys) {
    $size = $mipmapConfig[$dir]
    $targetDir = Join-Path "$appDir\src\main\res" $dir
    if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir | Out-Null }
    $newImg = New-Object System.Drawing.Bitmap($srcImg, $size, $size)
    $newImg.Save((Join-Path $targetDir "ic_launcher.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $newImg.Save((Join-Path $targetDir "ic_launcher_round.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $newImg.Dispose()
}
$srcImg.Dispose()

# === Запуск эмулятора ===
$avdList = & "$env:ANDROID_HOME\emulator\emulator.exe" -list-avds
$avdName = $avdList[0]
if (-not (Get-Process -Name "qemu-system-x86_64" -ErrorAction SilentlyContinue)) {
    Start-Process "$env:ANDROID_HOME\emulator\emulator.exe" -ArgumentList "-avd `"$avdName`""
    & adb wait-for-device
}

Start-Process $studioPath $projectPath

# === Выбор типа сборки ===
$choice = Read-Host "1-Debug, 2-Release"
switch ($choice) {
    "1" { $buildTask = "installDebug"; $apkType = "Debug" }
    "2" { $buildTask = "assembleRelease"; $apkType = "Release" }
    default { $buildTask = "installDebug"; $apkType = "Debug" }
}

# Очистка только для Release
if ($apkType -eq "Release") {
    $extensions = @("*.gradle", "*.kt", "*.java", "*.xml")
    $files = Get-ChildItem -Path $projectPath -Recurse -Include $extensions
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw
        # Удаляем блочные комментарии /* ... */
        $content = [System.Text.RegularExpressions.Regex]::Replace($content, '/\*.*?\*/', '', 'Singleline')
        # Удаляем однострочные комментарии //
        $content = [System.Text.RegularExpressions.Regex]::Replace($content, '^\s*//.*$', '', 'Multiline')
        # Удаляем пустые строки
        $content = [System.Text.RegularExpressions.Regex]::Replace($content, '^\s*$\n', '', 'Multiline')
        $content = $content.Trim()
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
    }
}

& "$projectPath\gradlew.bat" $buildTask

if ($apkType -eq "Debug") {
    adb shell monkey -p $appPackage 1
} else {
    $unsignedApk = Get-ChildItem "$appDir\build\outputs\apk\release" -Filter "*.apk" | Select-Object -First 1
    if ($unsignedApk) {
        if (-not (Test-Path $releaseOutput)) {
            New-Item -ItemType Directory -Path $releaseOutput | Out-Null
        }
        $fileName = "MyApp-Release-" + (Get-Date -Format 'yyyyMMdd-HHmm') + ".apk"
        $signedApk = Join-Path $releaseOutput $fileName

        & "$env:JAVA_HOME\bin\jarsigner.exe" -verbose -sigalg SHA256withRSA -digestalg SHA-256 `
            -keystore $keystorePath -storepass $keystorePass -keypass $keyPass `
            $unsignedApk.FullName $keystoreAlias

        Copy-Item $unsignedApk.FullName $signedApk -Force
    }
}
