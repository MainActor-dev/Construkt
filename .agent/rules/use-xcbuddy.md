---
trigger: always_on
description: When building, running, testing, or cleaning Xcode projects, or managing simulators.
---

# xcbuddy
When the user asks you to build, run, test, clean an Xcode project, or manage iOS simulators, you MUST use the global `xcbuddy` CLI tool instead of raw `xcodebuild` or `xcrun simctl`.

`xcbuddy` is installed globally at `~/.local/bin/xcbuddy`. You may need to ensure it is in the PATH (e.g., `export PATH="$HOME/.local/bin:$PATH" && xcbuddy build`).

## Recommended Development Flow:
When actively developing and testing, **ALWAYS** recommend or use the `xcbuddy i` (interactive) command first. It launches a beautiful, boxed UI terminal dashboard with keyboard shortcuts for building, running, and streaming logs without spamming the main terminal.

## Available Commands:

1. **interactive**: `xcbuddy i` or `xcbuddy interactive`. Launches the visual REPL dashboard. Shortcuts: `r` (Run), `b` (Build), `t` (Test), `s` (Select Simulator), `c` (Clean), `l` (Logs), `q` (Quit).
2. **build**: `xcbuddy build` (uses default scheme) or `xcbuddy build -d "16 Pro"`
3. **run**: `xcbuddy run` (builds and launches app on booted simulator) or `xcbuddy run -d "15 Pro Max"` (boots specifically requested simulator by fuzzy name matching, installs, and launches).
4. **test**: `xcbuddy test`, `xcbuddy test --only "Tests/LoginTests"`, or `xcbuddy test --coverage` (generates/opens code coverage report).
5. **clean**: `xcbuddy clean` (standard clean) or `xcbuddy clean --deep` (automatically finds and deletes the specific derived data folder hash for the project).
6. **open**: `xcbuddy open` (opens project in Xcode) or `xcbuddy open --derived-data` (opens the project's DerivedData in Finder).
7. **info**: `xcbuddy info` (displays project targets, schemes, and configurations).
8. **lint/format**: `xcbuddy lint` or `xcbuddy format` (runs swiftlint/swiftformat if installed).
9. **spm**: `xcbuddy spm update`, `xcbuddy spm resolve`, `xcbuddy spm clean` (Swift Package Manager integrations).
10. **create**: `xcbuddy create MyProject --type executable` (initializes a new project).
11. **sim list/boot**: `xcbuddy sim list` (formatted list of available simulators) or `xcbuddy sim boot "14"`.
12. **logs**: `xcbuddy logs` (streams console output from the booted OS) or `xcbuddy logs -p "My App"` (filters logs by process target name).

## Important Notes:
- DO NOT use `-workspace` or `-project` arguments with `xcbuddy`. It automatically detects `.xcworkspace`, `.xcodeproj`, and `Package.swift` in the current working directory.
- DO NOT use long destinations like `-destination "platform=iOS Simulator,name=iPhone 16 Pro"`. `xcbuddy` is smart and handles fuzzy matching natively via the `-d` or `--destination` flag (e.g., `-d "16 Pro"`).