#!/bin/bash

# DEPRECATED: deploy is now handled by .github/workflows/deploy.yml,
# triggered automatically on every push to main. Keep this script as an
# emergency fallback only. Remove once CI has been verified to work end-to-end.

# Step 4: Build the Hugo site
echo "Building the Hugo site..."
if ! hugo; then
    echo "Hugo build failed."
    exit 1
fi

# Step 5: Add changes to Git
echo "Staging changes for Git..."
if git diff --quiet && git diff --cached --quiet; then
    echo "No changes to stage."
else
    git add .
fi

# Step 6: Commit changes with a dynamic message
commit_message="New Blog Post on $(date +'%Y-%m-%d %H:%M:%S')"
if git diff --cached --quiet; then
    echo "No changes to commit."
else
    echo "Committing changes..."
    git commit -m "$commit_message"
fi

# Step 7: Push all changes to the main branch
echo "Deploying to GitHub Main..."
if ! git push origin main; then
    echo "Failed to push to main branch."
    exit 1
fi

# Step 8: Push the public folder to the deploy branch using subtree split and force push
echo "Deploying to GitHub Deploy Branch..."
if git branch --list | grep -q 'personal-deploy'; then
    git branch -D personal-deploy
fi

if ! git subtree split --prefix public -b personal-deploy; then
    echo "Subtree split failed."
    exit 1
fi

if ! git push origin personal-deploy:deploy --force; then
    echo "Failed to push to deploy branch."
    git branch -D personal-deploy
    exit 1
fi

git branch -D personal-deploy

echo "All done! Site synced, processed, committed, built, and deployed."