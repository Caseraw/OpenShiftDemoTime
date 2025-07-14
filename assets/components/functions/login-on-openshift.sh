#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
KUSTOMIZE_BASE="$PROJECT_DIR/assets/kustomize/base/openshift-console-config"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# Show opening message
show_msg "show-date" "INFO" "Logging in on an OpenShift Cluster" "⏳"

# Check if already logged in
if oc whoami &> /dev/null; then
    CURRENT_USER=$(oc whoami)
    CURRENT_CLUSTER=$(oc whoami --show-server)
    show_msg "show-date" "INFO" "Already logged into OpenShift cluster."
    show_msg "show-date" "INFO" "User" "$CURRENT_USER"
    show_msg "show-date" "INFO" "Cluster" "$CURRENT_CLUSTER"

    # Ask if the user wants to re-login
    read -p "Do you want to log in again? (y/N): " RELOGIN
    if [[ ! "$RELOGIN" =~ ^[Yy]$ ]]; then
        show_msg "show-date" "INFO" "Keeping the existing session" "Continuing execution..."
    else
        # Prompt for OpenShift cluster details
        read -p "Enter OpenShift API URL (e.g., https://api.openshift.example.com:6443): " OC_API
        read -p "Enter OpenShift Username: " OC_USER
        read -s -p "Enter OpenShift Password: " OC_PASS
        echo

        # Attempt to log in
        show_msg "show-date" "INFO" "Logging into OpenShift cluster..."        
        if oc login "$OC_API" -u "$OC_USER" -p "$OC_PASS" --insecure-skip-tls-verify; then
            show_msg "show-date" "INFO" "Login successful!" "You are now logged into the OpenShift cluster."
        else
            show_msg "show-date" "CRITICAL" "Error" "Login failed" "Please check your credentials and API URL"
            exit 1
        fi
    fi
else
    # User is not logged in, prompt for credentials
    read -p "Enter OpenShift API URL (e.g., https://api.openshift.example.com:6443): " OC_API
    read -p "Enter OpenShift Username: " OC_USER
    read -s -p "Enter OpenShift Password: " OC_PASS
    echo

    # Attempt to log in
    show_msg "show-date" "INFO" "Logging into OpenShift cluster..."   
    if oc login "$OC_API" -u "$OC_USER" -p "$OC_PASS"; then
        show_msg "show-date" "INFO" "Login successful!" "You are now logged into the OpenShift cluster."
    else
        show_msg "show-date" "CRITICAL" "Error" "Login failed" "Please check your credentials and API URL"
        exit 1
    fi
fi

# Confirm current user and cluster
show_msg "show-date" "INFO" "Current user details"
oc whoami
show_msg "show-date" "INFO" "Current cluster"
oc whoami --show-server
oc whoami -c

# Show end message
show_msg "show-date" "INFO" "Logging in on an OpenShift Cluster" "Completed" "✅"
