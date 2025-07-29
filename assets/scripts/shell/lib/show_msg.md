# `show_msg` Script Documentation

## Overview

The `show_msg` function is a logging utility that prints formatted messages with optional timestamps and color-coded log levels. It helps standardize message output for debugging, information logging, warnings, and critical errors.

## Usage

```bash
show_msg [show-date] <LEVEL> <TITLE> [DESCRIPTION] [BODY]
```

## Parameters

| Parameter       | Description |
|----------------|-------------|
| `show-date`    | (Optional) Includes a timestamp in the log message. |
| `<LEVEL>`      | The severity level of the message. Accepted values: `DEBUG`, `INFO`, `WARNING`, `CRITICAL`. |
| `<TITLE>`      | A short, descriptive title for the log entry. |
| `[DESCRIPTION]`| (Optional) A brief description providing additional details. |
| `[BODY]`       | (Optional) Extended message content. |

## Log Levels & Colors

| Level      | Color Code |
|-----------|------------|
| `DEBUG`   | Gray       |
| `INFO`    | Blue       |
| `WARNING` | Orange     |
| `CRITICAL`| Red        |

## Examples

### Basic log message:
```bash
show_msg INFO "Startup" "Application initialized"
```
**Output:**
```
 INFO - Startup | Application initialized
```

### Log message with a timestamp:
```bash
show_msg show-date WARNING "Low Disk Space" "Less than 10% remaining"
```
**Output:**
```
 [DD-MM-YYYY HH:MM:SS] WARNING - Low Disk Space | Less than 10% remaining
```

### Critical error with additional details:
```bash
show_msg show-date CRITICAL "Service Failure" "Database unreachable" "Restart required"
```
**Output:**
```
 [DD-MM-YYYY HH:MM:SS] CRITICAL - Service Failure | Database unreachable | Restart required
```

## Behavior
- If `show-date` is provided, the message includes a timestamp.
- If an invalid log level is used, an error message is displayed.
- Arguments are trimmed to remove leading and trailing spaces before output.
- Colors enhance readability in supported terminals.

## Exit Codes
- `0`: Message displayed successfully.
- `1`: Incorrect usage or invalid log level.

## Notes
- Ensure the script has execution permissions: `chmod +x script.sh`.
- This function is useful for logging in Bash scripts with structured, readable output.

## License
This script is provided "as is" without warranty of any kind.
