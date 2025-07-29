#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# Define secret file paths
BASEDOMAIN_ENV="$SCRIPT_DIR/basedomain.env"
ACCESSKEYID_ENV="$SCRIPT_DIR/accesskeyid.env"
SECRETACCESSKEY_ENV="$SCRIPT_DIR/secretaccesskey.env"
BUNDLE_ENV="$SCRIPT_DIR/bundle.env"
AWS_CLI_ENV="$SCRIPT_DIR/aws-cli.env"

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

# Prompt user for credentials
read -p "Enter AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -s -p "Enter AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo
read -p "Enter AWS Region: " AWS_REGION
read -p "Enter OCP cluster base domain: " BASE_DOMAIN
read -p "Enter OCP cluster GUID: " GUID_DOMAIN

# Handle bundle.env
if confirm_overwrite "$BUNDLE_ENV"; then
    cat <<EOF > "$BUNDLE_ENV"
baseDomain=$BASE_DOMAIN
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
EOF

fi

# Handle aws-cli.env
if confirm_overwrite "$AWS_CLI_ENV"; then
    cat <<EOF > "$AWS_CLI_ENV"
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION=$AWS_REGION
GUID_DOMAIN=$GUID_DOMAIN
EOF
    show_msg "show-date" "INFO" "Done" "AWS CLI file created/updated"
    show_msg "show-date" "INFO" "File" "$AWS_CLI_ENV"
fi

# Handle individual secret file creation based on user input
if confirm_overwrite "$BASEDOMAIN_ENV"; then
    echo "baseDomain=$BASE_DOMAIN" > "$BASEDOMAIN_ENV"
    show_msg "show-date" "INFO" "Done" "Base domain file created/updated"
    show_msg "show-date" "INFO" "File" "$BASEDOMAIN_ENV"
fi

if confirm_overwrite "$ACCESSKEYID_ENV"; then
    echo "aws_access_key_id=$AWS_ACCESS_KEY_ID" > "$ACCESSKEYID_ENV"
    show_msg "show-date" "INFO" "Done" "Access key ID file created/updated"
    show_msg "show-date" "INFO" "File" "$ACCESSKEYID_ENV"
fi

if confirm_overwrite "$SECRETACCESSKEY_ENV"; then
    echo "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" > "$SECRETACCESSKEY_ENV"
    show_msg "show-date" "INFO" "Done" "Secret access key file created/updated"
    show_msg "show-date" "INFO" "File" "$SECRETACCESSKEY_ENV"
fi

# Show end message
show_msg "show-date" "INFO" "Setup completed" "✅"
