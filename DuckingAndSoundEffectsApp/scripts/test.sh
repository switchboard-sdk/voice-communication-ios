#!/bin/bash

set -eu

PROJECT_DIR="$(git rev-parse --show-toplevel)"
XCODE_PROJECT_PATH="${PROJECT_DIR}/DuckingAndSoundEffectsApp/DuckingAndSoundEffectsApp.xcodeproj"
SCHEME_NAME="DuckingAndSoundEffectsApp"
DESTINATION="platform=iOS Simulator,name=iPhone 15,OS=17.2"

xcodebuild test \
  -project "$XCODE_PROJECT_PATH" \
  -scheme "$SCHEME_NAME" \
  -destination "$DESTINATION"