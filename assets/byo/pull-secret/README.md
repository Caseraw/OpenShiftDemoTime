# Pull Secret Directory

This directory is used to store the pull secret required for accessing private container registries.

## Required File
- `pull-secret.txt`: This file should contain the pull secret.

## Instructions
1. Obtain the pull secret from the relevant provider (e.g., Red Hat, Docker Hub, etc.).
2. Run the `pull-secret.sh` script to generate the `pull-secret.txt` file.
3. You will be prompted to provide the pull secret in one of two ways:
   - **Option 1**: Provide a file path to an existing pull-secret file.
   - **Option 2**: Manually enter the pull-secret as a minified JSON object.
4. If `pull-secret.txt` already exists, you will be prompted whether to overwrite it or keep the existing file.
5. The script will create or update the `pull-secret.txt` file based on your input.
6. Alternatively, you can manually create the `pull-secret.txt` file by copying and pasting the pull-secret as a one-line minified JSON object.

## Security Notice
- **Do not commit `pull-secret.txt` to the repository.** This file is ignored in `.gitignore` to prevent accidental commits.
- **Keep this file private.** Never share or expose it publicly.
- **Use environment variables or secret management tools** for better security when using this secret in automation.
