#!/bin/bash

# Git Practice Session Script
# This script guides you through practicing Git commands with your repository

echo "🚀 Git Practice Session for GCP-Terraform Repository"
echo "Repository: https://github.com/surajkmr39-lang/GCP-Terraform"
echo "=================================================="

# Function to wait for user input
wait_for_user() {
    echo ""
    echo "Press Enter to continue..."
    read
}

# Function to show command and wait
show_command() {
    echo ""
    echo "📝 Next command to run:"
    echo "   $1"
    echo ""
    echo "Copy and paste this command, then press Enter to continue..."
    read
}

echo ""
echo "🎯 STEP 1: Initial Setup and Clone"
echo "=================================="

show_command "cd C:\Projects"
show_command "git clone https://github.com/surajkmr39-lang/GCP-Terraform.git"
show_command "cd GCP-Terraform"

echo ""
echo "🔍 Let's check the repository status:"
show_command "git status"
show_command "git branch"
show_command "git remote -v"
show_command "git log --oneline"

echo ""
echo "🎯 STEP 2: Configure Git (if not done already)"
echo "=============================================="

echo "Run these commands with YOUR information:"
show_command "git config --global user.name \"Your Name\""
show_command "git config --global user.email \"your.email@example.com\""
show_command "git config --list"

echo ""
echo "🎯 STEP 3: Create and Add Files"
echo "==============================="

show_command "echo \"# Git Practice Session - $(date)\" > git-practice-log.md"
show_command "git status"
show_command "git add git-practice-log.md"
show_command "git status"
show_command "git commit -m \"Add git practice log file\""

echo ""
echo "🎯 STEP 4: Working with Multiple Files"
echo "======================================"

show_command "echo \"Practice file 1\" > practice1.txt"
show_command "echo \"Practice file 2\" > practice2.txt"
show_command "mkdir practice-folder"
show_command "echo \"Nested practice file\" > practice-folder/nested.txt"

show_command "git status"
show_command "git add ."
show_command "git status"
show_command "git commit -m \"Add multiple practice files for Git workflow\""

echo ""
echo "🎯 STEP 5: Branch Creation and Management"
echo "========================================"

show_command "git branch"
show_command "git branch feature/dns-documentation"
show_command "git checkout feature/dns-documentation"
show_command "git branch"

echo ""
echo "🎯 STEP 6: Making Changes in Feature Branch"
echo "==========================================="

show_command "echo \"# DNS Configuration Improvements\" > dns-improvements.md"
show_command "echo \"## Private DNS Zone Enhancements\" >> dns-improvements.md"
show_command "echo \"- Improved TTL settings\" >> dns-improvements.md"
show_command "echo \"- Added health check integration\" >> dns-improvements.md"

show_command "git add dns-improvements.md"
show_command "git commit -m \"Add DNS improvements documentation\""
show_command "git log --oneline"

echo ""
echo "🎯 STEP 7: Switching Between Branches"
echo "====================================="

show_command "git checkout main"
show_command "ls dns-improvements.md"  # Should not exist
show_command "git checkout feature/dns-documentation"
show_command "ls dns-improvements.md"  # Should exist

echo ""
echo "🎯 STEP 8: Push Feature Branch to GitHub"
echo "========================================"

show_command "git push -u origin feature/dns-documentation"

echo ""
echo "🌐 STEP 9: Create Pull Request (GitHub Web Interface)"
echo "===================================================="

echo "Now go to your GitHub repository:"
echo "https://github.com/surajkmr39-lang/GCP-Terraform"
echo ""
echo "You should see a banner saying 'Compare & pull request'"
echo "Click it and fill in:"
echo ""
echo "Title: Add DNS improvements documentation"
echo ""
echo "Description:"
echo "- Added DNS improvements documentation"
echo "- Created practice files for Git workflow"
echo "- Enhanced repository with learning materials"
echo ""
echo "Then click 'Create pull request'"

wait_for_user

echo ""
echo "🎯 STEP 10: Create Another Feature Branch"
echo "========================================"

show_command "git checkout main"
show_command "git checkout -b feature/add-monitoring-docs"

show_command "echo \"# Monitoring and Observability\" > monitoring-guide.md"
show_command "echo \"## Cloud Ops Agent Configuration\" >> monitoring-guide.md"
show_command "echo \"## Custom Metrics Setup\" >> monitoring-guide.md"

show_command "git add monitoring-guide.md"
show_command "git commit -m \"Add monitoring and observability documentation\""
show_command "git push -u origin feature/add-monitoring-docs"

echo ""
echo "🎯 STEP 11: Merge First Pull Request"
echo "==================================="

echo "Go back to GitHub and merge your first pull request:"
echo "1. Go to the Pull Requests tab"
echo "2. Click on your 'Add DNS improvements documentation' PR"
echo "3. Click 'Merge pull request'"
echo "4. Click 'Confirm merge'"
echo "5. Optionally delete the feature branch"

wait_for_user

echo ""
echo "🎯 STEP 12: Update Local Main Branch"
echo "==================================="

show_command "git checkout main"
show_command "git pull origin main"
show_command "git log --oneline"
show_command "git branch -d feature/dns-documentation"  # Delete local branch

echo ""
echo "🎯 STEP 13: Practice Merge Conflicts (Advanced)"
echo "==============================================="

show_command "git checkout main"
show_command "echo \"Main branch change\" >> git-practice-log.md"
show_command "git add git-practice-log.md"
show_command "git commit -m \"Update practice log from main branch\""

show_command "git checkout feature/add-monitoring-docs"
show_command "echo \"Feature branch change\" >> git-practice-log.md"
show_command "git add git-practice-log.md"
show_command "git commit -m \"Update practice log from feature branch\""

echo ""
echo "Now let's try to merge and see what happens:"
show_command "git checkout main"
show_command "git merge feature/add-monitoring-docs"

echo ""
echo "If you get a merge conflict:"
echo "1. Open git-practice-log.md in your editor"
echo "2. Look for conflict markers: <<<<<<< ======= >>>>>>>"
echo "3. Edit the file to resolve conflicts"
echo "4. Save the file"
echo "5. Run: git add git-practice-log.md"
echo "6. Run: git commit -m \"Resolve merge conflicts\""

wait_for_user

echo ""
echo "🎯 STEP 14: Advanced Git Operations"
echo "==================================="

show_command "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
show_command "git status"
show_command "git branch -a"

echo ""
echo "🎯 STEP 15: Stashing Practice"
echo "============================"

show_command "echo \"Temporary work in progress\" >> temp-work.txt"
show_command "git status"
show_command "git stash"
show_command "git status"
show_command "git stash list"
show_command "git stash pop"
show_command "git status"

echo ""
echo "🎯 STEP 16: Final Cleanup and Push"
echo "=================================="

show_command "git add ."
show_command "git commit -m \"Complete Git practice session with all exercises\""
show_command "git push origin main"

echo ""
echo "🎉 CONGRATULATIONS!"
echo "==================="
echo ""
echo "You have successfully practiced:"
echo "✅ Repository cloning"
echo "✅ Basic Git operations (add, commit, push, pull)"
echo "✅ Branch creation and management"
echo "✅ Feature branch workflow"
echo "✅ Pull request creation and merging"
echo "✅ Merge conflict resolution"
echo "✅ Advanced Git operations"
echo "✅ Stashing and unstashing"
echo ""
echo "Your repository now contains:"
echo "- All the original GCP Terraform DNS Lab files"
echo "- Practice files and documentation"
echo "- Git workflow examples"
echo "- Professional architecture documentation"
echo ""
echo "Next steps:"
echo "1. Create more feature branches for different components"
echo "2. Practice collaborative workflows with others"
echo "3. Explore GitHub Actions for CI/CD"
echo "4. Set up branch protection rules"
echo ""
echo "Repository URL: https://github.com/surajkmr39-lang/GCP-Terraform"