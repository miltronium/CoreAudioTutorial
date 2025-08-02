#!/bin/bash

# Debug and Fix Remote Repository Push
# Check git status and ensure Day 3 work is properly pushed

set -e

echo "🔍 Debug Remote Repository Push"
echo "==============================="

# Function to log with timestamp
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
}

log_action "🎯 Starting remote repository debug"

# Check current directory
CURRENT_DIR=$(pwd)
log_action "📍 Current directory: $CURRENT_DIR"

# Check git status
log_action "📋 Checking git repository status"

if git rev-parse --git-dir > /dev/null 2>&1; then
    log_action "✅ Git repository confirmed"
    
    # Show current branch
    CURRENT_BRANCH=$(git branch --show-current)
    log_action "🌿 Current branch: $CURRENT_BRANCH"
    
    # Show recent commits
    log_action "📝 Recent commits:"
    git log --oneline -5
    
    # Check git status
    log_action "📊 Git status:"
    git status --porcelain
    
    # Check remotes
    log_action "🌐 Remote repositories:"
    if git remote -v; then
        log_action "✅ Remote repositories found"
        
        # Check if we're up to date with remote
        log_action "🔄 Checking remote sync status"
        
        # Fetch latest from remote
        log_action "⬇️  Fetching latest from remote"
        git fetch origin
        
        # Compare local vs remote
        LOCAL_COMMIT=$(git rev-parse HEAD)
        REMOTE_COMMIT=$(git rev-parse origin/$CURRENT_BRANCH 2>/dev/null || git rev-parse origin/main 2>/dev/null || git rev-parse origin/master 2>/dev/null || echo "unknown")
        
        log_action "🏠 Local commit:  $LOCAL_COMMIT"
        log_action "🌐 Remote commit: $REMOTE_COMMIT"
        
        if [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]; then
            log_action "✅ Local and remote are in sync"
        else
            log_action "⚠️  Local and remote are different"
            
            # Show what's different
            log_action "📊 Commits ahead of remote:"
            git log origin/$CURRENT_BRANCH..HEAD --oneline 2>/dev/null || git log origin/main..HEAD --oneline 2>/dev/null || git log origin/master..HEAD --oneline 2>/dev/null || echo "Cannot determine difference"
        fi
    else
        log_action "❌ No remote repositories configured"
    fi
    
else
    log_action "❌ Not a git repository"
    exit 1
fi

echo
echo "🔧 Diagnostic Information"
echo "========================"

# Check what files exist
log_action "📁 Key files and directories:"
for item in "daily-sessions" "scripts" "shared-frameworks" "activate-ca-env.sh" "daily-sessions/day03"; do
    if [[ -e "$item" ]]; then
        echo "  ✅ $item"
    else
        echo "  ❌ $item (missing)"
    fi
done

# Check Day 3 specific files
if [[ -d "daily-sessions/day03" ]]; then
    log_action "📋 Day 3 files:"
    ls -la daily-sessions/day03/
else
    log_action "❌ Day 3 directory not found"
fi

echo
echo "🚀 Recommended Actions"
echo "====================="

# Check if we need to push
if git log origin/$CURRENT_BRANCH..HEAD --oneline 2>/dev/null | grep -q .; then
    echo "📤 You have unpushed commits. Run:"
    echo "   git push origin $CURRENT_BRANCH"
elif git log origin/main..HEAD --oneline 2>/dev/null | grep -q .; then
    echo "📤 You have unpushed commits. Run:"
    echo "   git push origin main"
elif git log origin/master..HEAD --oneline 2>/dev/null | grep -q .; then
    echo "📤 You have unpushed commits. Run:"
    echo "   git push origin master"
else
    echo "🤔 Checking if remote branch exists..."
    if git ls-remote --heads origin $CURRENT_BRANCH | grep -q $CURRENT_BRANCH; then
        echo "✅ Remote branch exists and should be up to date"
        echo "🔍 Check your remote repository web interface"
        echo "   The commits might be there under branch: $CURRENT_BRANCH"
    else
        echo "📤 Remote branch doesn't exist. Create it with:"
        echo "   git push -u origin $CURRENT_BRANCH"
    fi
fi

echo
echo "📋 Quick Commands to Try"
echo "======================="
echo "1. Force push current branch:"
echo "   git push -u origin $CURRENT_BRANCH"
echo
echo "2. Check what's in the remote:"
echo "   git ls-remote origin"
echo
echo "3. See all branches:"
echo "   git branch -a"
echo
echo "4. Create and push to new branch:"
echo "   git checkout -b day03-complete"
echo "   git push -u origin day03-complete"

# Try to automatically fix the most common issue
echo
echo "🔧 Attempting Automatic Fix"
echo "=========================="

# Make sure we have all changes committed
if [[ -n "$(git status --porcelain)" ]]; then
    log_action "📦 Uncommitted changes found, adding them"
    git add .
    git commit -m "Day 3: Final cleanup and completion"
fi

# Try to push to the current branch
log_action "📤 Attempting to push to origin/$CURRENT_BRANCH"
if git push origin $CURRENT_BRANCH 2>/dev/null; then
    log_action "✅ Successfully pushed to origin/$CURRENT_BRANCH"
elif git push -u origin $CURRENT_BRANCH 2>/dev/null; then
    log_action "✅ Successfully pushed to origin/$CURRENT_BRANCH (with upstream set)"
else
    log_action "⚠️  Push failed. Manual intervention may be needed."
    echo
    echo "🔧 Manual push options:"
    echo "   git push -u origin $CURRENT_BRANCH  # Set upstream and push"
    echo "   git push --force origin $CURRENT_BRANCH  # Force push (use carefully)"
fi

echo
echo "🎯 Verification"
echo "=============="
log_action "📋 Final git status:"
git status

log_action "🌐 Remote URLs:"
git remote -v
