# GitHub Push Script for Odoo 18 Enterprise
# This script helps you push your project to GitHub

Write-Host "==========================================" -ForegroundColor Blue
Write-Host "GitHub Push Script for Odoo 18 Enterprise" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""

Write-Host "[INFO] This script will help you push your Odoo 18 Enterprise project to GitHub" -ForegroundColor Cyan
Write-Host ""

# Get GitHub username
$GITHUB_USERNAME = Read-Host "Enter your GitHub username"

if ([string]::IsNullOrEmpty($GITHUB_USERNAME)) {
    Write-Host "[ERROR] GitHub username is required!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "[INFO] GitHub username: $GITHUB_USERNAME" -ForegroundColor Green
Write-Host ""

# Check if git is installed
try {
    git --version | Out-Null
    Write-Host "[INFO] Git is installed." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Git is not installed. Please install Git first." -ForegroundColor Red
    Write-Host "Download from: https://git-scm.com/download/win" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Initialize git repository
Write-Host "[INFO] Initializing git repository..." -ForegroundColor Cyan
git init

# Add all files
Write-Host "[INFO] Adding files to git..." -ForegroundColor Cyan
git add .

# Create first commit
Write-Host "[INFO] Creating first commit..." -ForegroundColor Cyan
git commit -m "Initial commit: Odoo 18 Enterprise custom image with subscription fix"

# Add remote origin
Write-Host "[INFO] Adding GitHub remote..." -ForegroundColor Cyan
git remote add origin "https://github.com/$GITHUB_USERNAME/odoo-18-enterprise-custom.git"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "Ready to push to GitHub!" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""
Write-Host "[INFO] Repository URL: https://github.com/$GITHUB_USERNAME/odoo-18-enterprise-custom" -ForegroundColor Green
Write-Host ""
Write-Host "[WARNING] Make sure you have created the repository on GitHub first!" -ForegroundColor Yellow
Write-Host "[WARNING] Go to: https://github.com/new" -ForegroundColor Yellow
Write-Host "[WARNING] Repository name: odoo-18-enterprise-custom" -ForegroundColor Yellow
Write-Host "[WARNING] Make it PUBLIC" -ForegroundColor Yellow
Write-Host ""

$CONFIRM = Read-Host "Have you created the repository on GitHub? (y/N)"

if ($CONFIRM -ne "y" -and $CONFIRM -ne "Y") {
    Write-Host "[INFO] Please create the repository first, then run this script again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "[INFO] Pushing to GitHub..." -ForegroundColor Cyan
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "SUCCESS! Repository pushed to GitHub!" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "[SUCCESS] Your repository is now available at:" -ForegroundColor Green
    Write-Host "https://github.com/$GITHUB_USERNAME/odoo-18-enterprise-custom" -ForegroundColor Blue
    Write-Host ""
    Write-Host "[INFO] Users can now install with:" -ForegroundColor Cyan
    Write-Host "curl -s https://raw.githubusercontent.com/$GITHUB_USERNAME/odoo-18-enterprise-custom/master/run.sh | bash" -ForegroundColor Blue
    Write-Host ""
    Write-Host "[INFO] Next steps:" -ForegroundColor Cyan
    Write-Host "1. Update URLs in run.sh and README.md with your actual username" -ForegroundColor White
    Write-Host "2. Test the installation command" -ForegroundColor White
    Write-Host "3. Share your repository!" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "[ERROR] Failed to push to GitHub." -ForegroundColor Red
    Write-Host "[INFO] Common issues:" -ForegroundColor Yellow
    Write-Host "- Repository not created on GitHub" -ForegroundColor White
    Write-Host "- Authentication failed (use GitHub Desktop or Personal Access Token)" -ForegroundColor White
    Write-Host "- Network connection issues" -ForegroundColor White
    Write-Host ""
    Write-Host "[INFO] Try using GitHub Desktop for easier setup:" -ForegroundColor Cyan
    Write-Host "https://desktop.github.com/" -ForegroundColor Blue
}

Write-Host ""
Read-Host "Press Enter to exit"
