#!/bin/bash
# Helper functions for outputting and communicating

# FUNCTIONS
define_font_colours() { # Define font colours for outputting errors (red), warnings(yellow), information (cyan) or confirmation (green)
  RED='\033[1;31m' # Error
  YELLOW='\033[1;33m' # Warning
  CYAN='\033[0;36m' # In progress
  GREEN='\033[1;32m' # Success
  NC='\033[0m' # No color
}

critical_error() { # Flag and log a critical error to syslog and exit script. Expect a descriptive message as first argument.
  echo "$0:$1" >&2
  logger -t $(basename "$0") -p user.err $1
  exit 1
}

ask_confirmation() { # Ask for user confirmation, no return or enter required
  if [[ -z "$1" ]]; then
    PROMPT="Confirm (y/n): ";
  else
    PROMPT="$1"$'\nConfirm (y/n): '
  fi
  read -p "$PROMPT" -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
    then
      printf "y";
    else
      printf "n";
  fi
}

recho() {
  echo -e "${RED}$1${NC}"
}

yecho() {
  echo -e "${YELLOW}$1${NC}"
}

gecho() {
  echo -e "${GREEN}$1${NC}"
}

run_and_log() { # Run a command and log its output and errors to a file. Accepts the command as an argument and an optional second argument for the log file name (default: [SCRIPT_NAME].log). The function will append the output and errors to the log file with timestamps.
  if [[ -z "$1" ]]; then
    echo "No command provided" >&2
    return 1
  fi
  local CMD="$1"
  calling_script=$(basename "$0")
  local LOG_FILE="${2:-${calling_script}.log}"
  echo "$(date +'%Y-%m-%d %H:%M:%S') - Running command: $CMD" | tee -a "$LOG_FILE"
  eval "$CMD" 2>&1 | tee -a "$LOG_FILE"
  if [[ $? -ne 0 ]]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Command failed: $CMD" | tee -a "$LOG_FILE"
    return 1
  fi
  return 0
}

welcome() {
  echo "-----------------------------------------------------"
  echo "|               Welcome to Uboontup !               |"
  echo "|                                                   |"
  echo "|      An easy way to get Ubuntu up and running     |"
  echo "|               for some serious work               |"
  echo "-----------------------------------------------------"
  echo ""
}