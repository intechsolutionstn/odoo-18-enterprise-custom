# GitHub Setup Guide - Step by Step

## 🚀 Quick Setup (5 minutes)

### Step 1: Create GitHub Repository

1. **Go to GitHub**: https://github.com
2. **Click "New repository"** (green button)
3. **Repository name**: `odoo-18-enterprise-custom`
4. **Description**: `Odoo 18 Enterprise with subscription warning removed - One-command installation`
5. **Make it Public** ✅
6. **Don't check** "Add a README file" (we have one)
7. **Don't check** "Add .gitignore" (we have one)
8. **Don't check** "Choose a license" (we have one)
9. **Click "Create repository"**

### Step 2: Get Your Repository URL

After creating the repository, GitHub will show you commands. Copy the **HTTPS URL** that looks like:
```
https://github.com/YOUR_USERNAME/odoo-18-enterprise-custom.git
```

### Step 3: Open Command Prompt/Terminal

**On Windows:**
- Press `Win + R`
- Type `cmd` and press Enter
- Or use PowerShell

**On Mac/Linux:**
- Open Terminal

### Step 4: Navigate to Your Files

```bash
cd C:\odoo19installation\custom_addons
```

### Step 5: Initialize Git and Push

```bash
# Initialize git repository
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit: Odoo 18 Enterprise custom image with subscription fix"

# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/odoo-18-enterprise-custom.git

# Push to GitHub
git push -u origin main
```

## 🔧 Alternative: Using GitHub Desktop

If you prefer a GUI:

1. **Download GitHub Desktop**: https://desktop.github.com/
2. **Sign in** to your GitHub account
3. **Click "Create a new repository"**
4. **Name**: `odoo-18-enterprise-custom`
5. **Local path**: `C:\odoo19installation\custom_addons`
6. **Click "Create repository"**
7. **Commit all files** with message: "Initial commit: Odoo 18 Enterprise custom image"
8. **Publish repository** to GitHub

## 📝 After Pushing to GitHub

### Update URLs in Files

1. **Open `run.sh`** in a text editor
2. **Find this line** (around line 15):
   ```bash
   curl -s https://raw.githubusercontent.com/YOUR_USERNAME/odoo-18-enterprise-custom/master/run.sh | bash -s odoo18-project 10036 5432
   ```
3. **Replace `YOUR_USERNAME`** with your actual GitHub username
4. **Save the file**

5. **Open `README.md`** in a text editor
6. **Find all instances** of `YOUR_USERNAME` and replace with your actual username
7. **Save the file**

### Commit and Push Updates

```bash
git add .
git commit -m "Update URLs with actual GitHub username"
git push origin main
```

## 🧪 Test Your Repository

After everything is pushed, test it:

```bash
curl -s https://raw.githubusercontent.com/YOUR_ACTUAL_USERNAME/odoo-18-enterprise-custom/master/run.sh | bash -s test-odoo 10036 5432
```

## 📋 Files to Push

Make sure these files are in your repository:

- ✅ `run.sh` - Main installation script
- ✅ `README.md` - Documentation
- ✅ `.gitignore` - Git ignore rules
- ✅ `LICENSE` - MIT License
- ✅ `setup_github_repo.md` - Setup guide
- ✅ `github_setup_guide.md` - This guide

## 🎯 Repository Features

Your repository will have:

- **One-command installation** like the original
- **Custom Odoo 18 Enterprise image** with subscription fix
- **Multiple port support** for multiple instances
- **Management scripts** for easy operation
- **Professional documentation**
- **Docker-based** setup

## 🚨 Troubleshooting

### If you get "Permission denied":
```bash
# Make sure you're logged in to GitHub
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### If you get "Repository not found":
- Check the repository URL
- Make sure the repository is public
- Verify your GitHub username is correct

### If you get "Authentication failed":
- Use GitHub Personal Access Token instead of password
- Or use GitHub Desktop for easier authentication

## 🎉 Success!

Once everything is pushed, your repository will be available at:
```
https://github.com/YOUR_USERNAME/odoo-18-enterprise-custom
```

And users can install with:
```bash
curl -s https://raw.githubusercontent.com/YOUR_USERNAME/odoo-18-enterprise-custom/master/run.sh | bash
```

## 📞 Need Help?

If you encounter any issues:
1. Check the error message
2. Make sure all files are in the correct directory
3. Verify your GitHub username and repository name
4. Try using GitHub Desktop for easier setup

---

**Your Odoo 18 Enterprise custom repository will be ready! 🚀**
