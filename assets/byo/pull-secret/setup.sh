#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
PULL_SECRET_FILE="$SCRIPT_DIR/pull-secret.txt"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# Define file paths
BUNDLE_ENV="$SCRIPT_DIR/bundle.env"

# Define vars
PULL_SECRET_CONTENT=""

# Function to check and confirm overwriting a file
confirm_overwrite() {
    local file="$1"

    if [[ -f "$file" ]]; then

        show_msg "show-date" "WARNING" "File already exists" "Confirm to proceed..."
        show_msg "show-date" "INFO" "File" "$file"

        read -p "Do you want to overwrite $file? (y/n): " CONFIRM

        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            return 0  # Overwrite file
        else
            show_msg "show-date" "INFO" "Skipped" "Not modified"
            show_msg "show-date" "INFO" "File" "$file"
            return 1  # Skip file
        fi
    fi

    return 0  # File doesn't exist, create it
}

# Show opening message
show_msg "show-date" "INFO" "Setting up" "Credentials for AWS" "⏳"

# Ask the user to provide the pull-secret
show_msg "show-date" "INFO" "How would you like to provide the pull-secret?"
show_msg "show-date" "INFO" "1) Provide the file path"
show_msg "show-date" "INFO" "2) Manually enter the pull-secret"
read -p "Choose an option (1/2): " OPTION

if [[ "$OPTION" == "1" ]]; then
    read -p "Enter the full path to the pull-secret file: " SOURCE_FILE

    if [[ -f "$SOURCE_FILE" ]]; then
        PULL_SECRET_CONTENT=$(cat "$SOURCE_FILE")
    else
        show_msg "show-date" "CRITICAL" "File not found" "Specified file location does not exist"
        show_msg "show-date" "INFO" "File" "$SOURCE_FILE"
        exit 1
    fi

elif [[ "$OPTION" == "2" ]]; then
    read -p "Enter the pull-secret as a minified JSON object: " PULL_SECRET_CONTENT
else
    show_msg "show-date" "CRITICAL" "Invalid selection" "Please enter either 1 or 2."
    exit 1
fi

# Handle pull-secret file creation based on user confirmation
if confirm_overwrite "$PULL_SECRET_FILE"; then
    echo "$PULL_SECRET_CONTENT" > "$PULL_SECRET_FILE"
fi

# Show end message
show_msg "show-date" "INFO" "Setup completed" "✅"
