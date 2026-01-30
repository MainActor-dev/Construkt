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
xcodebuild build -scheme Construkt -project Construkt.xcodeproj -destination 'generic/platform=iOS Simulator'
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
xcrun simctl install booted $(xcodebuild -showBuildSettings -scheme Construkt -project Construkt.xcodeproj -destination 'generic/platform=iOS Simulator' | grep " BUILT_PRODUCTS_DIR =" | awk -F " = " '{print $2}')/Builder.app
xcrun simctl launch booted $(xcodebuild -showBuildSettings -scheme Construkt -project Construkt.xcodeproj -destination 'generic/platform=iOS Simulator' | grep " PRODUCT_BUNDLE_IDENTIFIER =" | awk -F " = " '{print $2}')
```
