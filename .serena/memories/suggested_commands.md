# Suggested commands
## Package-level (framework)
- `swift build` — build the Swift package.
- `swift test` — run package tests in `Tests/ConstruktTests`.

## Demo app (Xcode workspace/project)
- Build demo app (example from logs):
  - `xcodebuild -workspace "Demo/Construkt.xcworkspace" -scheme "Construkt" -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' build`
- Run demo tests:
  - `xcodebuild -workspace "Demo/Construkt.xcworkspace" -scheme "Construkt" -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' test`

## Discovery/utility on Darwin
- `git status`, `git diff`, `git log --oneline -n 20`
- `ls`, `pwd`, `open .`
- `xcodebuild -list -workspace "Demo/Construkt.xcworkspace"`
- `xcrun simctl list devices`
- `swift package describe`

## Notes
- No lint/format config was found in repo (`.swiftlint.yml` / swiftformat config absent).
- Prefer project conventions and tests for validation.