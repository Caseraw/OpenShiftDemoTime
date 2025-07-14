# `run_cmd` Script Documentation

## Overview

The `run_cmd` function executes a given command with retry logic and optional infinite retry mode. It provides configurable parameters for retry attempts, pause duration, silent execution, and timeout handling.

## Usage

```bash
run_cmd [--retries <COUNT>] [--pause <SECONDS>] [--infinite] [--infinite-timeout <SECONDS>] [--silent] -- <COMMAND>
```

## Parameters

| Parameter            | Short Option | Description |
|----------------------|-------------|-------------|
| `--retries <COUNT>` | `-r`        | Number of times to retry the command on failure (default: `0`). |
| `--pause <SECONDS>` | `-p`        | Pause duration between retries in seconds (default: `10`). |
| `--infinite`        | N/A         | Enables infinite retries until the `--infinite-timeout` is reached. |
| `--infinite-timeout <SECONDS>` | N/A | Maximum time in seconds for infinite retries (default: `1800`). |
| `--silent`          | N/A         | Suppresses failure messages, only returning exit codes. |
| `-- <COMMAND>`      | N/A         | The command to be executed. This must be the last argument. |

## Examples

### Run a command with 3 retries and a 5-second pause between attempts:
```bash
run_cmd --retries 3 --pause 5 -- echo "Hello, World!"
```

### Run a command with infinite retries, limited to 600 seconds:
```bash
run_cmd --infinite --infinite-timeout 600 -- my_script.sh
```

### Run a command in silent mode (no output on failure):
```bash
run_cmd --silent -- ls /nonexistent/path
```

## Behavior
- If the command succeeds (`exit code 0`), the script prints the output and exits immediately.
- If the command fails, it retries based on the configured options.
- If `--infinite` is enabled, the script retries indefinitely until the `--infinite-timeout` is reached.
- If `--silent` is enabled, failure messages are suppressed.

## Exit Codes
- `0`: Command executed successfully.
- `1`: Invalid usage or the command failed after all retries.

## Notes
- The script relies on a `show_msg` function (not included in this snippet) for logging messages.
- Ensure the script has execution permissions before running: `chmod +x script.sh`.

## License
This script is provided "as is" without warranty of any kind.
