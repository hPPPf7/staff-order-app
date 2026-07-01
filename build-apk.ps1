$ErrorActionPreference = "Stop"

$projectRoot = $PSScriptRoot
$jdkHome = Join-Path $projectRoot ".tools\jdk17\jdk-17.0.19+10"
$androidHome = Join-Path $projectRoot ".tools\android-sdk"
$signingHome = Join-Path $projectRoot ".tools\signing"
$keystorePath = Join-Path $signingHome "release.jks"
$passwordPath = Join-Path $signingHome "password.txt"

if (-not (Test-Path -LiteralPath $jdkHome)) {
  throw "Java 17 was not found: $jdkHome"
}

if (-not (Test-Path -LiteralPath $androidHome)) {
  throw "Android SDK was not found: $androidHome"
}

if (-not (Test-Path -LiteralPath $keystorePath) -or -not (Test-Path -LiteralPath $passwordPath)) {
  throw "Release signing files were not found in $signingHome"
}

$env:JAVA_HOME = $jdkHome
$env:ANDROID_HOME = $androidHome
$env:ANDROID_SDK_ROOT = $androidHome
$env:ANDROID_KEYSTORE_PATH = $keystorePath
$env:ANDROID_KEYSTORE_PASSWORD = (Get-Content -LiteralPath $passwordPath -Raw).Trim()
$env:ANDROID_KEY_ALIAS = "staff-order"
$env:ANDROID_KEY_PASSWORD = $env:ANDROID_KEYSTORE_PASSWORD

Copy-Item -LiteralPath (Join-Path $projectRoot "index.html") `
  -Destination (Join-Path $projectRoot "www\index.html") -Force

Push-Location $projectRoot
try {
  & npx cap sync android
  if ($LASTEXITCODE -ne 0) {
    throw "Capacitor sync failed."
  }

  Push-Location (Join-Path $projectRoot "android")
  try {
    & .\gradlew.bat assembleRelease
    if ($LASTEXITCODE -ne 0) {
      throw "Android APK build failed."
    }
  }
  finally {
    Pop-Location
  }

  $sourceApk = Join-Path $projectRoot "android\app\build\outputs\apk\release\app-release.apk"
  $outputApk = Join-Path $projectRoot "staff-order-app.apk"
  Copy-Item -LiteralPath $sourceApk -Destination $outputApk -Force
  Write-Host "APK created: $outputApk"
}
finally {
  Pop-Location
}
