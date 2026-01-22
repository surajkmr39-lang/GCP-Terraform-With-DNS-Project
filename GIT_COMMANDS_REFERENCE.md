# 📚 Git Commands Quick Reference

## 🚀 Essential Git Commands for Your Practice

### **Repository Setup**
```bash
# Clone your repository
git clone https://github.com/surajkmr39-lang/GCP-Terraform.git

# Navigate to repository
cd GCP-Terraform

# Check repository status
git status

# View commit history
git log --oneline
```

### **Basic Workflow**
```bash
# Check what's changed
git status

# Add specific file
git add filename.txt

# Add all changes
git add .

# Commit changes
git commit -m "Your commit message"

# Push to GitHub
git push origin main
```

### **Branch Operations**
```bash
# List all branches
git branch

# Create new branch
git branch feature/branch-name

# Switch to branch
git checkout feature/branch-name

# Create and switch in one command
git checkout -b feature/branch-name

# Delete branch (after merging)
git branch -d feature/branch-name
```

### **Remote Operations**
```bash
# Check remote repositories
git remote -v

# Fetch latest changes
git fetch origin

# Pull latest changes
git pull origin main

# Push branch to GitHub
git push origin feature/branch-name

# Set upstream for easier pushing
git push -u origin feature/branch-name
```

### **Merging**
```bash
# Switch to main branch
git checkout main

# Merge feature branch
git merge feature/branch-name

# Push merged changes
git push origin main
```

### **Useful Commands**
```bash
# View differences
git diff

# View staged differences
git diff --staged

# Show commit details
git show commit-hash

# Stash changes temporarily
git stash

# Apply stashed changes
git stash pop

# View stash list
git stash list
```

---

## 🎯 Practice Sequence for Your Repository

### **1. Initial Setup**
```bash
cd C:\Projects
git clone https://github.com/surajkmr39-lang/GCP-Terraform.git
cd GCP-Terraform
git status
```

### **2. Create Practice Files**
```bash
echo "# Git Practice" > practice.md
git add practice.md
git commit -m "Add practice file"
git push origin main
```

### **3. Feature Branch Workflow**
```bash
git checkout -b feature/dns-updates
echo "DNS improvements" > dns-updates.md
git add dns-updates.md
git commit -m "Add DNS updates"
git push -u origin feature/dns-updates
```

### **4. Create Pull Request**
- Go to GitHub repository
- Click "Compare & pull request"
- Fill in title and description
- Click "Create pull request"

### **5. Merge and Cleanup**
```bash
git checkout main
git pull origin main
git branch -d feature/dns-updates
```

---

## 🔧 Troubleshooting Commands

### **Fix Common Issues**
```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard local changes
git checkout -- filename.txt

# Update branch with latest main
git checkout main
git pull origin main
git checkout feature/branch-name
git merge main

# Resolve merge conflicts
# 1. Edit conflicted files
# 2. Remove conflict markers
# 3. git add resolved-file.txt
# 4. git commit -m "Resolve conflicts"
```

### **View Repository Information**
```bash
# Detailed commit history
git log --graph --oneline --all

# Show all branches (local and remote)
git branch -a

# Show remote repository URLs
git remote -v

# Show current branch
git branch --show-current
```

---

## 📝 Practice Checklist

### **Basic Operations**
- [ ] Clone repository
- [ ] Check status
- [ ] Add files
- [ ] Commit changes
- [ ] Push to GitHub

### **Branch Management**
- [ ] Create new branch
- [ ] Switch between branches
- [ ] Make changes in feature branch
- [ ] Push feature branch
- [ ] Merge branches

### **GitHub Integration**
- [ ] Create pull request
- [ ] Review pull request
- [ ] Merge pull request
- [ ] Delete merged branch

### **Advanced Operations**
- [ ] Resolve merge conflicts
- [ ] Use git stash
- [ ] View commit history
- [ ] Update branch with main

---

## 🎯 Your Practice Repository

**Repository URL:** https://github.com/surajkmr39-lang/GCP-Terraform

**Practice Branches to Create:**
- `feature/dns-improvements`
- `feature/security-updates`
- `feature/monitoring-setup`
- `bugfix/documentation-typos`
- `docs/architecture-updates`

**Files to Practice With:**
- README.md updates
- New documentation files
- Configuration improvements
- Architecture diagrams
- Practice logs

---

## 🏆 Pro Tips

1. **Always pull before starting new work**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Use descriptive commit messages**
   ```bash
   git commit -m "Add DNS zone configuration for internal services"
   ```

3. **Keep branches focused and small**
   - One feature per branch
   - Regular commits
   - Descriptive branch names

4. **Test before pushing**
   ```bash
   git status
   git diff --staged
   ```

5. **Clean up after merging**
   ```bash
   git branch -d merged-branch-name
   ```

Remember: The best way to learn Git is by practicing these commands regularly with real projects!