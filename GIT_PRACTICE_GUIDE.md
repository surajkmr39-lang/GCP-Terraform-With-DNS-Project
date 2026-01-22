# 🚀 Git & GitHub Practice Guide

## 📋 Complete Git Workflow Practice

This guide will walk you through all essential Git commands using your repository: `https://github.com/surajkmr39-lang/GCP-Terraform`

---

## 🎯 Learning Objectives

By the end of this practice, you'll master:
- ✅ Repository cloning and setup
- ✅ Basic Git operations (add, commit, push, pull)
- ✅ Branch management (create, switch, merge)
- ✅ Pull requests and code reviews
- ✅ Collaboration workflows
- ✅ Conflict resolution

---

## 🛠️ Prerequisites

### **Install Git**
```bash
# Windows (using Chocolatey)
choco install git

# Or download from: https://git-scm.com/download/windows

# Verify installation
git --version
```

### **Configure Git (First Time Setup)**
```bash
# Set your identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Set default editor (optional)
git config --global core.editor "code --wait"  # For VS Code

# View your configuration
git config --list
```

---

## 📚 Step-by-Step Practice

### **Step 1: Clone Your Repository**

```bash
# Navigate to your desired directory
cd C:\Projects  # or wherever you want to store the project

# Clone your repository
git clone https://github.com/surajkmr39-lang/GCP-Terraform.git

# Navigate into the cloned repository
cd GCP-Terraform

# Check the repository status
git status

# View the repository structure
ls -la  # or 'dir' on Windows

# Check remote repositories
git remote -v
```

**Expected Output:**
```
origin  https://github.com/surajkmr39-lang/GCP-Terraform.git (fetch)
origin  https://github.com/surajkmr39-lang/GCP-Terraform.git (push)
```

### **Step 2: Understanding Repository State**

```bash
# Check current branch
git branch

# Check commit history
git log --oneline

# Check repository status
git status

# View differences (if any changes exist)
git diff
```

### **Step 3: Making Your First Changes**

```bash
# Create a new file for practice
echo "# Git Practice Session" > git-practice.md

# Check status (file is untracked)
git status

# Add the file to staging area
git add git-practice.md

# Check status again (file is staged)
git status

# Commit the changes
git commit -m "Add git practice file"

# Check status (working directory clean)
git status

# View commit history
git log --oneline
```

### **Step 4: More Advanced Add Operations**

```bash
# Create multiple files
echo "Feature 1 content" > feature1.txt
echo "Feature 2 content" > feature2.txt
mkdir test-folder
echo "Test file" > test-folder/test.txt

# Check status
git status

# Add specific file
git add feature1.txt

# Add all files in current directory
git add .

# Or add all files (alternative)
git add -A

# Check what's staged
git status

# Commit all staged changes
git commit -m "Add multiple practice files"
```

### **Step 5: Working with Branches**

```bash
# View all branches
git branch -a

# Create a new branch
git branch feature/dns-improvements

# Switch to the new branch
git checkout feature/dns-improvements

# Or create and switch in one command
git checkout -b feature/load-balancer-updates

# Check current branch
git branch

# Make changes in the new branch
echo "DNS improvements documentation" > dns-improvements.md
git add dns-improvements.md
git commit -m "Add DNS improvements documentation"

# Switch back to main branch
git checkout main

# Check that the file doesn't exist in main
ls dns-improvements.md  # Should not exist

# Switch back to feature branch
git checkout feature/load-balancer-updates

# Check that the file exists
ls dns-improvements.md  # Should exist
```

### **Step 6: Pushing Branches to GitHub**

```bash
# Push the feature branch to GitHub
git push origin feature/load-balancer-updates

# Set upstream for easier future pushes
git push -u origin feature/load-balancer-updates

# Now you can just use
git push  # for future pushes on this branch
```

### **Step 7: Working with Remote Changes (Pull)**

```bash
# Switch to main branch
git checkout main

# Fetch latest changes from remote
git fetch origin

# Pull latest changes (fetch + merge)
git pull origin main

# Or just
git pull  # if upstream is set
```

### **Step 8: Creating a Pull Request (GitHub Web Interface)**

1. **Go to your GitHub repository**: https://github.com/surajkmr39-lang/GCP-Terraform
2. **Click "Compare & pull request"** (appears after pushing a branch)
3. **Fill in the PR details**:
   ```
   Title: Add DNS improvements and practice files
   
   Description:
   - Added DNS improvements documentation
   - Created practice files for Git workflow
   - Updated repository structure
   
   ## Changes Made
   - [x] Added dns-improvements.md
   - [x] Added git-practice.md
   - [x] Added test files for practice
   
   ## Testing
   - [x] Verified all files are properly formatted
   - [x] Checked for any syntax errors
   ```
4. **Click "Create pull request"**

### **Step 9: Merging Pull Request**

**Option A: Merge via GitHub Web Interface**
1. Go to your pull request
2. Click "Merge pull request"
3. Choose merge type (Create a merge commit)
4. Click "Confirm merge"
5. Delete the feature branch (optional)

**Option B: Merge via Command Line**
```bash
# Switch to main branch
git checkout main

# Pull latest changes
git pull origin main

# Merge the feature branch
git merge feature/load-balancer-updates

# Push the merged changes
git push origin main

# Delete the feature branch (optional)
git branch -d feature/load-balancer-updates

# Delete remote branch (optional)
git push origin --delete feature/load-balancer-updates
```

### **Step 10: Advanced Git Operations**

```bash
# View detailed commit history
git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'

# View changes in a specific commit
git show <commit-hash>

# View file history
git log --follow git-practice.md

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes) - BE CAREFUL!
git reset --hard HEAD~1

# Stash changes temporarily
echo "Temporary work" >> git-practice.md
git stash

# Apply stashed changes
git stash pop

# View stash list
git stash list
```

---

## 🔄 Complete Workflow Practice

Let's practice a complete workflow:

### **Scenario: Adding the GCP Terraform DNS Lab to your repository**

```bash
# 1. Ensure you're on main branch and up to date
git checkout main
git pull origin main

# 2. Create a new feature branch
git checkout -b feature/add-dns-lab

# 3. Copy all the files we created (you'll do this manually or with commands)
# Since we have all the files in the current directory, let's add them

# 4. Add all the new files
git add .

# 5. Check what's being added
git status

# 6. Commit the changes
git commit -m "Add comprehensive GCP DNS Lab with Terraform

- Add complete multi-tier architecture
- Include professional documentation
- Add testing and troubleshooting guides
- Include network diagrams and architecture guides
- Add automated deployment with Makefile
- Include security best practices and monitoring"

# 7. Push the branch
git push -u origin feature/add-dns-lab

# 8. Create pull request via GitHub web interface

# 9. After review, merge the pull request

# 10. Clean up
git checkout main
git pull origin main
git branch -d feature/add-dns-lab
```

---

## 🚨 Common Git Scenarios & Solutions

### **Scenario 1: Merge Conflicts**

```bash
# When you encounter a merge conflict
git status  # Shows conflicted files

# Edit the conflicted files to resolve conflicts
# Look for markers like:
# <<<<<<< HEAD
# Your changes
# =======
# Other changes
# >>>>>>> branch-name

# After resolving conflicts
git add <resolved-file>
git commit -m "Resolve merge conflicts"
```

### **Scenario 2: Accidentally Committed to Wrong Branch**

```bash
# If you committed to main instead of a feature branch
git log --oneline  # Note the commit hash

# Create a new branch from current state
git branch feature/my-changes

# Reset main to previous state
git reset --hard HEAD~1

# Switch to the new branch
git checkout feature/my-changes
```

### **Scenario 3: Need to Update Branch with Latest Main**

```bash
# Switch to main and update
git checkout main
git pull origin main

# Switch back to your feature branch
git checkout feature/my-branch

# Merge main into your branch
git merge main

# Or rebase (cleaner history)
git rebase main
```

---

## 📝 Git Commands Cheat Sheet

### **Basic Commands**
```bash
git init                    # Initialize a new repository
git clone <url>            # Clone a repository
git status                 # Check repository status
git add <file>             # Stage a file
git add .                  # Stage all changes
git commit -m "message"    # Commit staged changes
git push                   # Push to remote repository
git pull                   # Pull from remote repository
```

### **Branch Commands**
```bash
git branch                 # List branches
git branch <name>          # Create new branch
git checkout <branch>      # Switch to branch
git checkout -b <branch>   # Create and switch to branch
git merge <branch>         # Merge branch into current
git branch -d <branch>     # Delete branch
```

### **Remote Commands**
```bash
git remote -v              # List remotes
git remote add <name> <url> # Add remote
git fetch <remote>         # Fetch from remote
git push <remote> <branch> # Push to remote
git pull <remote> <branch> # Pull from remote
```

### **History Commands**
```bash
git log                    # View commit history
git log --oneline          # Compact history
git show <commit>          # Show commit details
git diff                   # Show unstaged changes
git diff --staged          # Show staged changes
```

---

## 🎯 Practice Exercises

### **Exercise 1: Feature Development Workflow**
1. Create a branch called `feature/update-readme`
2. Update the README.md file with additional information
3. Commit your changes
4. Push the branch to GitHub
5. Create a pull request
6. Merge the pull request

### **Exercise 2: Bug Fix Workflow**
1. Create a branch called `bugfix/fix-typo`
2. Find and fix a typo in any documentation file
3. Commit the fix
4. Push and create a pull request
5. Merge the fix

### **Exercise 3: Collaboration Simulation**
1. Create two different feature branches
2. Make different changes in each branch
3. Merge one branch into main
4. Try to merge the second branch (may cause conflicts)
5. Resolve any conflicts that arise

---

## 🏆 Best Practices

### **Commit Messages**
```bash
# Good commit messages
git commit -m "Add user authentication feature"
git commit -m "Fix memory leak in data processing"
git commit -m "Update documentation for API endpoints"

# Bad commit messages
git commit -m "fix"
git commit -m "changes"
git commit -m "stuff"
```

### **Branch Naming**
```bash
# Good branch names
feature/user-authentication
bugfix/memory-leak-fix
hotfix/security-patch
docs/api-documentation

# Bad branch names
my-branch
test
fix
```

### **Workflow Tips**
- Always pull before starting new work
- Create feature branches for new work
- Keep commits small and focused
- Write descriptive commit messages
- Test before pushing
- Use pull requests for code review
- Delete merged branches to keep repository clean

---

## 🔧 Troubleshooting

### **Common Issues**

**Issue: "Permission denied (publickey)"**
```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"

# Add to SSH agent
ssh-add ~/.ssh/id_rsa

# Add public key to GitHub account
cat ~/.ssh/id_rsa.pub
```

**Issue: "Your branch is ahead of origin/main"**
```bash
# Push your commits
git push origin main
```

**Issue: "Your branch is behind origin/main"**
```bash
# Pull latest changes
git pull origin main
```

**Issue: "Merge conflict"**
```bash
# View conflicted files
git status

# Edit files to resolve conflicts
# Remove conflict markers and choose correct content

# Stage resolved files
git add <resolved-file>

# Complete the merge
git commit
```

---

This comprehensive guide covers all the Git commands and workflows you need to practice. Start with the basic commands and gradually work through the more advanced scenarios. Remember, the best way to learn Git is by practicing these commands regularly!