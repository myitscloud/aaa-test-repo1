# GitHub Setup Steps for Beginners

A comprehensive guide to getting started with Git and GitHub on Debian-based systems.

---

## 1. Create a GitHub Account

1. Go to [https://github.com](https://github.com)
2. Click **Sign up** in the top-right corner
3. Enter your email address and click **Continue**
4. Create a password (at least 15 characters, or 8 characters with a number and lowercase letter)
5. Choose a username (this will be visible publicly)
6. Complete the email verification by entering the code sent to your email
7. Optionally, personalize your experience or skip to the dashboard

---

## 2. Install Git on Debian

Open a terminal and run the following commands:

```bash
# Update package list
sudo apt update

# Install Git
sudo apt install git -y

# Verify installation
git --version
```

You should see output like `git version 2.x.x`.

---

## 3. Configure Git Locally

Set your identity (this information appears in your commits):

```bash
# Set your name
git config --global user.name "Your Name"

# Set your email (use the same email as your GitHub account)
git config --global user.email "your.email@example.com"

# Verify your settings
git config --list
```

Optional but recommended settings:

```bash
# Set default branch name to 'main'
git config --global init.defaultBranch main

# Set default editor (e.g., nano, vim, code)
git config --global core.editor nano

# Enable colored output
git config --global color.ui auto
```

---

## 4. Create a GitHub Repository

1. Log in to [GitHub](https://github.com)
2. Click the **+** icon in the top-right corner
3. Select **New repository**
4. Fill in the repository details:
   - **Repository name**: Choose a descriptive name (e.g., `my-project`)
   - **Description**: Optional but helpful
   - **Visibility**: Choose **Public** or **Private**
   - **Initialize with**: Optionally check "Add a README file"
5. Click **Create repository**
6. You'll be taken to your new repository page with setup instructions

---

## 5. Clone a Repository

Copy the repository URL from GitHub (click the green **Code** button), then:

```bash
# Clone using HTTPS
git clone https://github.com/username/repository-name.git

# Navigate into the cloned folder
cd repository-name

# Verify you're in the right place
pwd
ls -la
```

---

## 6. SSH Key Setup (Recommended)

SSH keys allow you to authenticate with GitHub without entering your password each time.

### Generate an SSH Key

```bash
# Generate a new SSH key (use your GitHub email)
ssh-keygen -t ed25519 -C "your.email@example.com"

# When prompted for file location, press Enter for default
# When prompted for passphrase, enter one (recommended) or press Enter for none
```

### Start the SSH Agent and Add Your Key

```bash
# Start the SSH agent
eval "$(ssh-agent -s)"

# Add your SSH key to the agent
ssh-add ~/.ssh/id_ed25519
```

### Add the SSH Key to GitHub

```bash
# Copy the public key to clipboard (or display it to copy manually)
cat ~/.ssh/id_ed25519.pub
```

1. Go to GitHub → **Settings** → **SSH and GPG keys**
2. Click **New SSH key**
3. Give it a **Title** (e.g., "My Debian Laptop")
4. Paste your public key into the **Key** field
5. Click **Add SSH key**

### Test the Connection

```bash
ssh -T git@github.com
```

You should see: "Hi username! You've successfully authenticated..."

### Clone Using SSH (Instead of HTTPS)

```bash
git clone git@github.com:username/repository-name.git
```

---

## 7. Basic Git Workflow

The typical workflow for making changes:

### Check Status

```bash
# See what files have changed
git status
```

### Stage Changes

```bash
# Stage a specific file
git add filename.txt

# Stage all changed files
git add .

# Stage all files of a specific type
git add *.py
```

### Commit Changes

```bash
# Commit with a message
git commit -m "Describe what you changed"

# Write a longer commit message in your editor
git commit
```

### Push to GitHub

```bash
# Push to the remote repository
git push

# If it's your first push on a new branch
git push -u origin branch-name
```

### Pull Latest Changes

```bash
# Get and merge the latest changes from GitHub
git pull
```

### Complete Example

```bash
# 1. Make sure you have the latest changes
git pull

# 2. Make your changes to files...

# 3. Check what changed
git status

# 4. Stage your changes
git add .

# 5. Commit with a descriptive message
git commit -m "Add new feature X"

# 6. Push to GitHub
git push
```

---

## 8. Common Git Commands Reference

| Command | Description |
|---------|-------------|
| `git init` | Initialize a new Git repository |
| `git clone <url>` | Clone a repository from GitHub |
| `git status` | Show the working directory status |
| `git add <file>` | Stage a file for commit |
| `git add .` | Stage all changes |
| `git commit -m "msg"` | Commit staged changes with a message |
| `git push` | Push commits to remote repository |
| `git pull` | Fetch and merge remote changes |
| `git fetch` | Fetch remote changes without merging |
| `git branch` | List local branches |
| `git branch <name>` | Create a new branch |
| `git checkout <branch>` | Switch to a branch |
| `git checkout -b <name>` | Create and switch to a new branch |
| `git merge <branch>` | Merge a branch into current branch |
| `git log` | Show commit history |
| `git log --oneline` | Show compact commit history |
| `git diff` | Show unstaged changes |
| `git diff --staged` | Show staged changes |
| `git reset <file>` | Unstage a file |
| `git stash` | Temporarily save uncommitted changes |
| `git stash pop` | Restore stashed changes |
| `git remote -v` | Show remote repositories |

---

## 9. Troubleshooting Common Issues

### "Permission denied (publickey)"
- Ensure your SSH key is added to GitHub
- Run `ssh-add ~/.ssh/id_ed25519` to add your key to the agent

### "fatal: not a git repository"
- Make sure you're inside a Git repository folder
- Run `git init` if you need to create a new repository

### "Your branch is behind"
- Run `git pull` to fetch and merge the latest changes

### "Merge conflict"
- Open the conflicting files and look for `<<<<<<<`, `=======`, `>>>>>>>` markers
- Edit the file to resolve the conflict
- Run `git add <file>` and `git commit` to complete the merge

### "fatal: refusing to merge unrelated histories"
- Run `git pull origin main --allow-unrelated-histories`

---

## Next Steps

Once you're comfortable with the basics:

- Learn about [branching strategies](https://docs.github.com/en/get-started/quickstart/github-flow)
- Explore [pull requests](https://docs.github.com/en/pull-requests)
- Set up [.gitignore files](https://git-scm.com/docs/gitignore)
- Learn about [Git tags and releases](https://docs.github.com/en/repositories/releasing-projects-on-github)

---

*Last updated: January 2026*
