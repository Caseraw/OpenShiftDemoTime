#!/bin/env bash

# Color Code Constants
GRAY="\033[37m"
BLUE="\033[34m"
ORANGE="\033[33m"
RED="\033[91m"
DARK_GRAY="\033[90m"
RESET="\033[0m"

# The actual main function of this file
show_msg() {
  formatted_date=""

  # Determine if the date should be shown and shift arguments if necessary
  if [ "$1" = "show-date" ]; then
    formatted_date=" $DARK_GRAY[$(date +"%d-%m-%Y %H:%M:%S")]$RESET"
    shift
  fi

  # Validate mandatory fields
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: display_message [show-date] <LEVEL> <TITLE> [DESCRIPTION] [BODY]"
    return 1
  fi

  # Format log level
  case "$1" in
    "DEBUG")    formatted_level="$GRAY$1$RESET" ;;
    "INFO")     formatted_level="$BLUE$1$RESET" ;;
    "WARNING")  formatted_level="$ORANGE$1$RESET" ;;
    "CRITICAL") formatted_level="$RED$1$RESET" ;;
    *)          echo "Error: Invalid log level: $1"; return 1 ;;
  esac

  # Construct the formatted message
  formatted_message="$formatted_date $formatted_level - $2"
  [ -n "$3" ] && formatted_message="$formatted_message | $3"
  [ -n "$4" ] && formatted_message="$formatted_message | $4"

  # Print the formatted message, trimming leading and trailing spaces
  echo -e "${formatted_message# }"
}
