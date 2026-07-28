#!/usr/bin/env bash
set -euo pipefail

echo "Starting Android emulator..."
"${EMULATOR_BIN}" & emulator_pid=$!

cleanup() {
  echo "Shutting down emulator..."
  trap - CHLD
  if ! adb emu kill; then
    kill -9 "$emulator_pid" 2>/dev/null || true
  else
    wait "$emulator_pid"
  fi
}
trap cleanup INT TERM EXIT

exit_on_error() {
  kill -0 "$emulator_pid" 2>/dev/null || exit 1
}
trap exit_on_error CHLD

echo "Waiting for adb server..."
adb wait-for-device

echo "Waiting for Android boot to complete..."
while [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
  sleep 2
done

echo "Android booted successfully."

adb shell settings put global window_animation_scale 0.0
adb shell settings put global transition_animation_scale 0.0
adb shell settings put global animator_duration_scale 0.0

adb shell 'rm -rf /data/local/tmp/n-o-d && mkdir /data/local/tmp/n-o-d'
git -C . archive --format=tar.gz --prefix n-o-d/ HEAD | adb shell 'cd /data/local/tmp/n-o-d && tar xzof - && mv n-o-d unpacked'
adb push "${BOOTSTRAP_ZIP}" /data/local/tmp/n-o-d/
cd tests/emulator
adb shell settings put secure enabled_accessibility_services com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService

echo "Executing test script ${TEST_SCRIPT}..."

droidctl run "${TEST_SCRIPT}.py"
