# Git Push Confirmation Rule

You must ALWAYS ask for explicit user confirmation before executing any `git push` command or any workflow/script that performs a push to a remote repository.

## Instructions
1. When a task requires pushing changes, perform all other steps (staging, committing, etc.).
2. Before running `git push`, stop and ask the user: "I am ready to push the changes to the remote repository. Do you want to proceed?"
3. Only execute the push command if the user provides a positive confirmation.
