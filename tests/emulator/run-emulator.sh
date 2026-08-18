#!/usr/bin/env bash

emu_ready=0
test_done=0

cleanup() {
  echo "Shutting down emulator..."
  trap - CHLD INT TERM EXIT
  if [ $emu_ready == 1 ] && ! adb emu kill; then
    kill -9 "$!" 2>/dev/null || true
  else
    wait "$!"
  fi
  if [ $test_done == 1 ]; then
    echo "Test completed successfully."
    exit 0
  else
    exit 1
  fi
}
trap cleanup INT TERM EXIT

exit_on_error() {
  if [ "$!" != "" ] && ! kill -0 "$!" 2>/dev/null; then
    echo "Emulator crashed, aborting..."
    trap - EXIT
    exit 1
  fi
}
trap exit_on_error CHLD

echo "Starting Android emulator..."
unset ANDROID_HOME
# shellcheck source=/dev/null
. "${EMULATOR_LAUNCH_SCRIPT}"
emu_ready=1

set -euo pipefail

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
eval "${BOOTSTRAP_ZIP_SCRIPT}" | adb shell "cat > /data/local/tmp/n-o-d/${BOOTSTRAP_ZIP_FILE}"
cd tests/emulator
adb shell settings put secure enabled_accessibility_services com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService

echo "Executing test script ${TEST_SCRIPT}..."

droidctl run "${TEST_SCRIPT}.py"

test_done=1
