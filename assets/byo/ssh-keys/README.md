# SSH Keys Directory

This directory is used to store private and public SSH keys required for authentication.

## Required Files
- `id_rsa`: The private SSH key.
- `id_rsa.pub`: The corresponding public SSH key.

## Instructions
1. Generate an SSH key pair using:
   ```sh
   ssh-keygen -t rsa -b 4096 -f id_rsa
   ```
2. Place `id_rsa` and `id_rsa.pub` in this directory.
3. Ensure `id_rsa` has the correct permissions:
   ```sh
   chmod 600 id_rsa
   ```
4. **Do not commit these files to Git.** They are ignored in `.gitignore` for security reasons.

## Security Notice
- **Never commit `id_rsa` or `id_rsa.pub` to the repository.** These files are ignored by Git to prevent accidental leaks.
- **Keep `id_rsa` private.** Do not share it or upload it to public repositories.
- **Consider using a secrets management tool** to store and manage SSH keys securely.
