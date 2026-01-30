---
description: Build and Launch the Demo app (Construkt) on iOS Simulator
---

1. Navigate to the project directory
```bash
cd Demo
```

2. Build the app for iOS Simulator
// turbo
```bash
xcodebuild build -scheme Construkt -project Construkt.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 16'
```

3. Boot the Simulator and Open it
// turbo
```bash
xcrun simctl boot "iPhone 16" || true
open -a Simulator
```

4. Install and Launch the App
// turbo
```bash
APP_PATH=$(xcodebuild -showBuildSettings -scheme Construkt -project Construkt.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 16' | grep " CONFIGURATION_BUILD_DIR =" | awk -F " = " '{print $2}')/Construkt.app
xcrun simctl install "iPhone 16" "$APP_PATH"
xcrun simctl launch "iPhone 16" com.koanba.Construkt
```
