#!/bin/bash

# GitHub Push Script for Odoo 18 Enterprise
# This script helps you push your project to GitHub using Git Bash

echo "=========================================="
echo "GitHub Push Script for Odoo 18 Enterprise"
echo "=========================================="
echo ""

echo "[INFO] This script will help you push your Odoo 18 Enterprise project to GitHub"
echo ""

# Get GitHub username
read -p "Enter your GitHub username: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "[ERROR] GitHub username is required!"
    read -p "Press Enter to exit"
    exit 1
fi

echo ""
echo "[INFO] GitHub username: $GITHUB_USERNAME"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "[ERROR] Git is not installed. Please install Git first."
    echo "Download from: https://git-scm.com/download/win"
    read -p "Press Enter to exit"
    exit 1
fi

echo "[INFO] Git is installed."
echo ""

# Initialize git repository
echo "[INFO] Initializing git repository..."
git init

# Add all files
echo "[INFO] Adding files to git..."
git add .

# Create first commit
echo "[INFO] Creating first commit..."
git commit -m "Initial commit: Odoo 18 Enterprise custom image with subscription fix"

# Add remote origin
echo "[INFO] Adding GitHub remote..."
git remote add origin "https://github.com/$GITHUB_USERNAME/odoo-18-enterprise-custom.git"

echo ""
echo "=========================================="
echo "Ready to push to GitHub!"
echo "=========================================="
echo ""
echo "[INFO] Repository URL: https://github.com/$GITHUB_USERNAME/odoo-18-enterprise-custom"
echo ""
echo "[WARNING] Make sure you have created the repository on GitHub first!"
echo "[WARNING] Go to: https://github.com/new"
echo "[WARNING] Repository name: odoo-18-enterprise-custom"
echo "[WARNING] Make it PUBLIC"
echo ""
read -p "Have you created the repository on GitHub? (y/N): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "[INFO] Please create the repository first, then run this script again."
    read -p "Press Enter to exit"
    exit 1
fi

echo ""
echo "[INFO] Pushing to GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "SUCCESS! Repository pushed to GitHub!"
    echo "=========================================="
    echo ""
    echo "[SUCCESS] Your repository is now available at:"
    echo "https://github.com/$GITHUB_USERNAME/odoo-18-enterprise-custom"
    echo ""
    echo "[INFO] Users can now install with:"
    echo "curl -s https://raw.githubusercontent.com/$GITHUB_USERNAME/odoo-18-enterprise-custom/master/run.sh | bash"
    echo ""
    echo "[INFO] Next steps:"
    echo "1. Update URLs in run.sh and README.md with your actual username"
    echo "2. Test the installation command"
    echo "3. Share your repository!"
else
    echo ""
    echo "[ERROR] Failed to push to GitHub."
    echo "[INFO] Common issues:"
    echo "- Repository not created on GitHub"
    echo "- Authentication failed (use GitHub Desktop or Personal Access Token)"
    echo "- Network connection issues"
    echo ""
    echo "[INFO] Try using GitHub Desktop for easier setup:"
    echo "https://desktop.github.com/"
fi

echo ""
read -p "Press Enter to exit"
