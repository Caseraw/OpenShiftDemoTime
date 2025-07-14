# Example Script Documentation

## Overview

This script demonstrates how to use the `show_msg` and `run_cmd` functions from external libraries. It initializes necessary dependencies, logs messages, and runs commands while applying retry logic.

## Prerequisites
- Ensure the `show_msg.sh` and `run_cmd.sh` scripts are available in `../lib/` relative to this script.
- The script must have execution permissions: `chmod +x script.sh`.

## Usage
```bash
./example.sh
```

## Functionality
1. **Determines the script directory**: The script resolves its own directory dynamically.
2. **Loads required functions**:
   - `show_msg.sh` for structured logging ([show_msg.sh docs](../lib/show_msg.md)).
   - `run_cmd.sh` for executing commands with retry mechanisms ([run_cmd.sh docs](../lib/run_cmd.md)).
3. **Logs an example message using `show_msg`**:
   - Outputs an informational message with a timestamp.
3. **Runs the `date` command `run_cmd`**:
   - Outputs a date timestamp.

## Example Output
```bash
[21-02-2025 11:14:07] INFO - Title of the example message | Description of example message | Body of the example message
Fri Feb 21 11:14:07 UTC 2025
```

## Notes
- Modify the script to log other text messages using `show_msg`.
- Modify the script to execute specific commands using `run_cmd`.
- Ensure the script's dependencies are correctly sourced to avoid execution errors.

## Exit Codes
- `0`: Script executed successfully.
- `1`: Failed to source required scripts or incorrect usage.

## License
This script is provided "as is" without warranty of any kind.
