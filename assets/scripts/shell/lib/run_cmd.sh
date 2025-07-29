#!/bin/env bash

# The actual main function of this file
run_cmd() {
  # Default values
  retry_count=0
  pause_duration=10
  infinite_retry=false
  infinite_timeout=1800  # Default timeout for infinite retries
  silent=false
  cmd=""
  usage_message="$(show_msg "INFO" "Usage" "run_cmd" "[--retries <COUNT>] [--pause <SECONDS>] [--infinite] [--infinite-timeout <SECONDS>] [--silent] -- <COMMAND>")"

  # Parse named parameters
  while [ $# -gt 0 ]; do
    case $1 in
      -r|--retries)
        retry_count="$2"
        shift 2
        ;;
      -p|--pause)
        pause_duration="$2"
        shift 2
        ;;
      --infinite)
        infinite_retry=true
        shift
        ;;
      --infinite-timeout)
        infinite_timeout="$2"
        shift 2
        ;;
      --silent)
        silent=true
        shift
        ;;
      --)
        shift
        cmd="$*"
        break
        ;;
      *)
        echo "Unknown parameter: $1"
        echo $usage_message
        return 1
        ;;
    esac
  done

  # Check if the command is provided
  if [ -z "$cmd" ]; then
    echo $usage_message
    return 1
  fi

  # Initialize attempt counter and start time for infinite timeout
  attempt=0
  start_time=$(date +%s)

  # Run the provided command, retrying as specified
  while [ $infinite_retry = true ] || [ $attempt -le $retry_count ]; do
    # Check for infinite timeout
    if [ $infinite_retry = true ]; then
      if [ $(($(date +%s) - start_time)) -ge $infinite_timeout ]; then
        show_msg "show-date" "CRITICAL" "Command failed" "Infinite retry timed out after $infinite_timeout seconds"
        return 1
      fi
    fi

    # Run the command and capture its output
    output=$(eval "$cmd")

    # Capture the return code of the command
    return_code=$?

    # If the command succeeds, print the output and exit the loop
    if [ $return_code -eq 0 ]; then
      echo "$output"
      return 0
    fi

    # Increment the attempt counter
    attempt=$((attempt + 1))

    # If not in silent mode, print messages and pause if specified
    if [ $silent = false ]; then
      if [ $infinite_retry = true ] || [ $attempt -le $retry_count ]; then
        if [ $infinite_retry = true ]; then
          show_msg "show-date" "WARNING" "Command failed" "Retrying" "Attempt $attempt, infinite retries, $pause_duration sec. interval, $(($(date +%s) - start_time))/$infinite_timeout sec. timeout..."
        else
          show_msg "show-date" "WARNING" "Command failed" "Retrying" "Attempt $attempt/$retry_count, $pause_duration sec. interval..."
        fi
        sleep $pause_duration
      fi
    fi
  done

  # If all attempts fail and not in silent mode, print an error message
  if [ $silent = false ]; then
    show_msg "show-date" "CRITICAL" "Command failed" "Return code: $return_code, total of $attempt attempt(s)"
  fi

  return $return_code
}
