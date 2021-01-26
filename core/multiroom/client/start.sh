#!/usr/bin/env bash
set -e


# --- ENV VARS ---
# SOUND_MULTIROOM_LATENCY: latency in milliseconds to compensate for speaker hardware sync issues
SNAPSERVER=${SOUND_SNAPSERVER}
LATENCY=${SOUND_MULTIROOM_LATENCY:+"--latency $SOUND_MULTIROOM_LATENCY"}

echo "Starting multi-room client..."
echo "Target snapcast server: $SNAPSERVER"

# Set the snapcast device name for https://github.com/balenalabs/balena-sound/issues/332
if [[ -z $SOUND_DEVICE_NAME ]]; then
    SNAPCAST_CLIENT_ID=$BALENA_DEVICE_UUID
else
    # The sed command replaces invalid host name characters with dash
    SNAPCAST_CLIENT_ID=$(echo $SOUND_DEVICE_NAME | sed -e 's/[^A-Za-z0-9.-]/-/g')
fi

# Start snapclient
# Start snapclient and filter out those pesky chunk logs
# grep filter can be removed when we get snapcast v0.20
# see: https://github.com/badaix/snapcast/issues/559#issuecomment-615874719
/usr/bin/snapclient --host $SNAPSERVER $LATENCY --hostID $SNAPCAST_CLIENT_ID --logfilter *:notice
