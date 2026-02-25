#!/bin/bash
set -e

# Switch to a protected branch to avoid deleting the current branch if it's not protected
if git show-ref --quiet refs/heads/main; then
    echo "Switching to main..."
    git checkout main
elif git show-ref --quiet refs/heads/develop; then
    echo "Switching to develop..."
    git checkout develop
fi

# Update remote information
git fetch -p

# --- DELETE LOCAL BRANCHES ---
echo "--- Cleaning Local Branches ---"
# Get list of local branches excluding main and develop
local_branches=$(git branch | grep -vEi "main|develop" | sed 's/^[ *]*//')

if [ -n "$local_branches" ]; then
    echo "Deleting local branches:"
    echo "$local_branches"
    
    # Delete branches
    echo "$local_branches" | xargs git branch -D
    echo "Successfully deleted local branches."
else
    echo "No local branches to delete (except main and develop)."
fi

# --- DELETE REMOTE BRANCHES ---
echo "--- Cleaning Remote Branches ---"
# Get list of remote branches excluding main, develop, and HEAD
# We use 'sed' to clean up 'origin/' prefix and whitespace
remote_branches=$(git branch -r | grep -vEi "main|develop|HEAD" | sed 's/origin\///' | sed 's/^[ *]*//')

if [ -n "$remote_branches" ]; then
    echo "Identified the following remote branches to delete (excluding main and develop):"
    echo "$remote_branches"
    
    echo "Deleting remote branches..."
    # Iterate and delete each remote branch
    for branch in $remote_branches; do
         echo "Deleting remote branch: $branch"
         git push origin --delete "$branch"
    done
    echo "Remote cleanup complete."
else
    echo "No remote branches to delete (except main and develop)."
fi
