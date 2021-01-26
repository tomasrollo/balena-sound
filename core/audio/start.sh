#!/bin/bash
set -e

# PulseAudio configuration files for balena-sound
CONFIG_TEMPLATE=/usr/src/balena-sound.pa
CONFIG_FILE=/etc/pulse/balena-sound.pa

# Set loopback module latency
function set_loopback_latency() {
  local LOOPBACK="$1"
  local LATENCY="$2"
  
  sed -i "s/%$LOOPBACK%/$LATENCY/" "$CONFIG_FILE"
}

# Route "balena-sound.input" to the appropriate sink
# Either "snapcast" fifo sink or "balena-sound.output"
function route_input_sink() {
  sed -i "s/%INPUT_SINK%/sink='balena-sound.output'/" "$CONFIG_FILE"
  echo "Routing 'balena-sound.input' to 'balena-sound.output'."
}

# Route "balena-sound.output" to the appropriate audio hardware
function route_output_sink() {
  local OUTPUT=""

  # Audio block outputs the default sink name to this file
  # If file doesn't exist, default to sink #0. This shouldn't happen though
  local SINK_FILE=/run/pulse/pulseaudio.sink
  if [[ -f "$SINK_FILE" ]]; then
    OUTPUT=$(cat "$SINK_FILE")
  fi
  OUTPUT="${OUTPUT:-0}"
  sed -i "s/%OUTPUT_SINK%/sink=\"$OUTPUT\"/" "$CONFIG_FILE"
  echo "Routing 'balena-sound.output' to '$OUTPUT'."
}

function reset_sound_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    rm "$CONFIG_FILE"
  fi 
  cp "$CONFIG_TEMPLATE" "$CONFIG_FILE"
}

# Get latency values
SOUND_INPUT_LATENCY=${SOUND_INPUT_LATENCY:-200}
SOUND_OUPUT_LATENCY=${SOUND_OUTPUT_LATENCY:-200}

# Audio routing: route intermediate balena-sound input/output sinks
echo "Setting audio routing rules. Note that this can be changed after startup."
reset_sound_config
route_input_sink
route_output_sink
set_loopback_latency "INPUT_LATENCY" "$SOUND_INPUT_LATENCY"
set_loopback_latency "OUTPUT_LATENCY" "$SOUND_OUPUT_LATENCY"

exec pulseaudio --file /etc/pulse/balena-sound.pa