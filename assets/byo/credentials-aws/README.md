# Secrets Directory

This directory is used to store sensitive information required for authentication and configuration.

## Required Files
- `basedomain.env`: Contains the base domain.
- `accesskeyid.env`: Contains the AWS access key ID.
- `secretaccesskey.env`: Contains the AWS secret access key.
- `bundle.env`: Contains all the above values in a single file for convenience.

## Instructions
1. Run the provided script `setup-aws-creds.sh` to generate the required secret files.
2. Enter the requested values when prompted:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Base Domain
3. The script will check if the files already exist and prompt you to overwrite or skip each file individually.
4. Once completed, the secret files will be stored in this directory.

## Security Notice
- **Do not commit any of the secret files (`*.env`) to the repository.** These files should be ignored using `.gitignore` to prevent accidental commits.
- **Keep these files private.** Never share or expose them publicly.
- **Use a secure storage solution** such as a secrets manager (e.g., HashiCorp Vault, AWS Secrets Manager, or OpenShift Secrets) for better security.
- **Limit access permissions** to these files to prevent unauthorized access.
