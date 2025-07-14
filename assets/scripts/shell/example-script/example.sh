#!/bin/env bash

# Set some file path variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load additional functions
source "$LIB_DIR/lib/show_msg.sh"
source "$LIB_DIR/lib/show_divider.sh"
source "$LIB_DIR/lib/run_cmd.sh"

# Show divider
show_divider

# Show message
show_msg "show-date" "INFO" "Title of the example message" "Description of example message" "Body of the example message"

# Run command
show_msg "show-date" "INFO" "Perform an invalid command" "See how it fails" "3 retires with 5 second delay"
run_cmd --retries 3 --pause 5 -- example_invalid_command

# Show divider
show_divider
