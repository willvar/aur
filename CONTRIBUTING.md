# Contributing Guide

[中文文档](CONTRIBUTING.zh-CN.md)

Welcome! This repository uses [aurpublish](https://github.com/eli-schwartz/aurpublish) to manage multiple AUR packages. We're glad to have you here.

## How to Contribute

There are several ways to contribute, depending on how involved you want to be:

### 🐛 Report Issues

Found a bug or have a suggestion? Let us know:

- **Open an issue**: [GitHub Issues](https://github.com/willvar/aur/issues)
- **Contact maintainer**: 0@willvar.tw
- No setup needed

### 🔀 Submit Pull Requests

Want to contribute code without direct repository access? Here's how:

1. **Fork this repository**
   - Visit https://github.com/willvar/aur
   - Click the "Fork" button

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/aur.git
   cd aur
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/willvar/aur.git
   ```

4. **Create a branch and make changes**
   ```bash
   git checkout -b my-package-update
   # Make your changes following this guide
   ./test.sh package-name
   git add .
   git commit
   ```

5. **Push to your fork**
   ```bash
   git push origin my-package-update
   ```

6. **Create Pull Request**
   - Visit your fork on GitHub
   - Click "New Pull Request"
   - Describe your changes
   - Wait for maintainer review

7. **Keep your fork updated**
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   git push origin main
   ```

### 👥 Become a Collaborator

For trusted contributors who want direct repository access:

1. **Build contribution history**
   - Submit quality Pull Requests
   - Demonstrate understanding of coding standards
   - Actively maintain packages

2. **Request access**
   - Contact maintainer: 0@willvar.tw
   - Provide your GitHub username
   - Specify packages you want to maintain

3. **After being added**
   - Clone repository directly
   - Follow the workflows in this guide
   - Push directly to `main` branch
   - Maintain your packages on AUR

**Note**: Collaborators have direct push access. Please ensure all tests pass before pushing.

---

## Prerequisites

### 1. Install Tools

```bash
# Install aurpublish
paru -S aurpublish
# or
yay -S aurpublish
```

### 2. Setup Environment

```bash
# Clone the repository
git clone git@github.com:willvar/aur.git
cd aur

# Install Git hooks (required)
aurpublish setup

# Configure Git user info (if not already set)
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### 3. Configure SSH Keys

#### AUR SSH Setup

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -f ~/.ssh/aur

# Add public key to your AUR account
cat ~/.ssh/aur.pub
# Visit https://aur.archlinux.org/account/ to add the public key

# Configure ~/.ssh/config
cat >> ~/.ssh/config <<EOF
Host aur.archlinux.org
    User aur
    IdentityFile ~/.ssh/aur
EOF

# Test connection
ssh -T aur@aur.archlinux.org
```

#### GitHub SSH Setup

```bash
# Add public key to GitHub
cat ~/.ssh/aur.pub  # or use another key
# Visit https://github.com/settings/keys to add the public key

# Test connection
ssh -T git@github.com
```

---

## Workflows

### Adding a New Package

```bash
# 1. Create package directory and files
mkdir package-name
cd package-name
# Create PKGBUILD, .SRCINFO, LICENSE, etc.

# 2. Return to repository root
cd ..

# 3. Test the package
./test.sh package-name

# 4. Add and commit
git add package-name/
git commit
# Git will auto-generate commit message: "Initial upload: package-name x.x.x-x"
# Save and exit the editor

# 5. Push to AUR
aurpublish package-name

# 6. Push to GitHub
git push origin main
```

### Updating an Existing Package

```bash
# 1. Edit PKGBUILD
vim package-name/PKGBUILD
# Update pkgver, pkgrel, sha256sums, etc.

# 2. Test changes
./test.sh package-name

# 3. Commit changes
git add package-name/
git commit
# Auto-generated message: "Updated: package-name x.x.x-x"

# 4. Push to AUR
aurpublish package-name

# 5. Push to GitHub
git push origin main
```

### Importing an Existing Package from AUR

```bash
# Import package (pulls complete AUR commit history)
aurpublish -p existing-package

# Push to GitHub
git push origin main
```

### Pulling Updates from AUR

If someone else has submitted updates on AUR:

```bash
# Pull updates from AUR
aurpublish -p package-name

# Push to GitHub
git push origin main
```

### Removing/Orphaning a Package

```bash
# 1. Remove from local repository
git rm -r package-name/
git commit -m "Remove package-name (orphaned)"

# 2. Push to GitHub
git push origin main

# 3. Orphan package on AUR
# Visit https://aur.archlinux.org/packages/package-name
# Click "Disown Package" or contact admin to delete
```

---

## Testing

Before committing changes, always test your PKGBUILD using the provided testing tool. This helps catch errors early.

### Quick Start

```bash
# Test specific package (lint + build)
./test.sh package-name

# Test all packages
./test.sh

# Lint only (fast, no build)
./test.sh package-name --lint-only

# Build only (skip lint)
./test.sh package-name --build-only
```

### Recommended Workflow

```bash
# 1. Make changes
vim package-name/PKGBUILD

# 2. Quick lint check
./test.sh package-name --lint-only

# 3. Fix any issues
# ... edit PKGBUILD ...

# 4. Full test (lint + build)
./test.sh package-name

# 5. Commit when tests pass
git add package-name/
git commit
```

### Understanding Test Results

**Output Summary:**
```
==> Final Summary

Passed (1):
  ✓ package-name

Statistics:
  Total packages: 1

========================================
  ✓✓✓ All packages passed! ✓✓✓
========================================
```

**Status Types:**
- ✅ **Passed**: All checks passed, ready to commit
- ⚠️ **Warnings**: Non-critical issues, consider fixing
- ❌ **Errors**: Must fix before committing

### What Gets Tested

**Lint Checks:**
- Variable naming (`makedepends` not `makedepend`)
- Indentation (2 spaces, no tabs)
- Variable quoting (`"${var}"`)
- Array quotes (single quotes)
- Source file uniqueness
- SPDX license format
- Base package dependencies
- Plus `namcap` validation

**Build Testing:**
- Full package build with `makepkg`
- Real-time build output
- Automatic cleanup of build artifacts

### Common Issues and Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| `ERROR: Tabs found on lines: X` | Mixed tabs/spaces | Replace tabs with 2 spaces |
| `WARNING: Possible unquoted variables` | `cd $var` | Use `cd "${var}"` |
| `WARNING: Arrays should use single quotes` | `arch=("x86_64")` | Use `arch=('x86_64')` |
| `WARNING: License should use SPDX` | `license=('Apache 2.0')` | Use `license=('Apache-2.0')` |
| `WARNING: Base package in depends=()` | `depends=('glibc')` | Remove (base packages implicit) |
| `Build failed` | PKGBUILD errors | Check build output, fix syntax/logic |

### CI/CD Integration

The test script returns exit codes:
- `0` - All tests passed
- `1` - Errors found (build failures or lint errors)

---

## Coding Standards

We follow unified coding standards to ensure consistency and maintainability across all packages.

### Mandatory Standards

These rules must be followed (the test tool will check them):

#### 1. PKGBUILD Standard Variables

Must use correct PKGBUILD standard variable names:
- ✅ `makedepends=()` not `makedepend=`
- ✅ `depends=()`, `provides=()`, `conflicts=()`
- ✅ Other standard variables: `pkgname`, `pkgver`, `pkgrel`, `arch`, `license`, etc.

Custom variables must start with underscore:
- ✅ `_extname=`, `_pkgname=`, `_commit=`

**Why**: This is required by PKGBUILD specification. Incorrect variable names result in incomplete package metadata and may cause dependency issues.

#### 2. Indentation

- ✅ Use **2 spaces** for indentation
- ❌ **Never** use tabs

```bash
# Correct
prepare() {
  cd "${srcdir}"
  ./configure
}

# Wrong
prepare() {
	cd "${srcdir}"  # tab used
    ./configure     # 4 spaces
}
```

**Why**: Consistent indentation improves readability.

#### 3. Variable References

- ✅ Always quote variables: `"${var}"`
- ❌ Don't use unquoted: `$var`

```bash
# Correct
cd "${srcdir}/${pkgname}-${pkgver}"
install -Dm644 "${srcdir}/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"

# Wrong
cd $srcdir/$pkgname-$pkgver
install -Dm644 $srcdir/LICENSE $pkgdir/usr/share/licenses/$pkgname/LICENSE
```

**Why**: Prevents issues with filenames containing spaces or special characters.

#### 4. Array Quotes

- ✅ Use **single quotes** for arrays: `arch=('x86_64')`
- ✅ Applies to: `arch`, `license`, `depends`, `makedepends`, etc.

```bash
# Correct
arch=('x86_64')
license=('MIT')
depends=('glibc' 'openssl')

# Wrong
arch=("x86_64")
license=("MIT")
```

**Why**: Consistency with Arch Linux conventions.

#### 5. Source File Naming

- ✅ All source filenames **must be unique**
- ✅ Use `${pkgname}-${pkgver}` pattern
- ✅ Rename generic files with `::` syntax

```bash
# Correct - unique names prevent conflicts
source=(
  "${pkgname}-LICENSE::https://raw.githubusercontent.com/user/repo/master/LICENSE"
  "${pkgname}-${pkgver}.tar.gz::https://github.com/user/repo/archive/v${pkgver}.tar.gz"
)

# Wrong - generic names cause conflicts when SRCDEST is shared
source=(
  "https://raw.githubusercontent.com/user/repo/master/LICENSE"
  "https://github.com/user/repo/archive/v${pkgver}.tar.gz"  # becomes v1.2.3.tar.gz
)
```

**Why**: Prevents file conflicts when `SRCDEST` is shared ([ArchWiki](https://wiki.archlinux.org/title/PKGBUILD#source)).

#### 6. License Format

- ✅ Use **SPDX identifiers**: [SPDX License List](https://spdx.org/licenses/)
- ✅ Common licenses:
  - MIT: `license=('MIT')`
  - Apache: `license=('Apache-2.0')`
  - BSD 3-Clause: `license=('BSD-3-Clause')`
  - GPL v3: `license=('GPL-3.0-or-later')`
  - LGPL v2.1: `license=('LGPL-2.1-or-later')`
  - PHP: `license=('PHP-3.01')`

**Why**: Arch Linux [RFC 0016](https://rfc.archlinux.page/0016-spdx-license-identifiers/) mandates SPDX format.

#### 7. Base Dependencies

- ❌ **Don't** list base packages in `depends=()`
- Base packages include: `glibc`, `bash`, `coreutils`, etc.
- ✅ **Do** list explicit runtime dependencies

**Why**: Base packages are assumed to be installed ([Arch Guidelines](https://wiki.archlinux.org/title/Arch_package_guidelines)).

---

### Recommended Style

These aren't mandatory, but help maintain consistency:

#### 1. pkgdesc Quotes

- Most packages use single quotes: `pkgdesc='...'`
- Double quotes `pkgdesc="..."` are also acceptable

#### 2. install Command Style

Preferred pattern:
```bash
install -Dm755 file "${pkgdir}/path" \
&& install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
```

#### 3. Function Spacing

Add empty line between functions for readability:

```bash
prepare() {
  ...
}

build() {
  ...
}
```

#### 4. source Array Format

Use multi-line format with one file per line:

```bash
source=(
  "file1.tar.gz"
  "file2.patch"
)
```

---

## Important Notes

### Git Hooks

The Git hooks installed by aurpublish automatically:

- **pre-commit**:
  - Auto-generate/update `.SRCINFO` file
  - Commit will fail if PKGBUILD has critical errors

- **prepare-commit-msg**:
  - Auto-generate standardized commit messages
  - Format: `Initial upload:` / `Updated:` / `Deleted:`, etc.

### Best Practices

**Recommended**:
- Use `git commit` (without `-m`) to let hooks auto-generate messages
- Or use `git commit --no-edit` to directly use auto-generated messages
- Always push to both AUR and GitHub after modifications

**Avoid**:
- Don't use `git commit -m "..."`, it overrides auto-generated messages
- Don't manually edit `.SRCINFO`, let hooks generate it automatically
- Don't forget to push to GitHub (running aurpublish alone is not enough)

### Why Two Pushes?

- `aurpublish package-name` → Pushes **subtree** to AUR's independent repository
- `git push origin main` → Pushes **complete repository** to GitHub

AUR maintains independent Git repositories for each package, while GitHub is our main repository.

---

## Command Reference

```bash
# View package commit history
aurpublish log package-name

# Speed up push (using --rejoin)
aurpublish -s package-name

# Check repository status
git status

# View unpushed commits
git log origin/main..HEAD

# List all packages
ls -d */
```

---

## Troubleshooting

### Hooks Not Working

```bash
# Reinstall hooks
aurpublish setup
```

### .SRCINFO Not Auto-generated

```bash
# Manually generate
cd package-name
makepkg --printsrcinfo > .SRCINFO
```

### Failed to Push to AUR

```bash
# Check SSH connection
ssh -T aur@aur.archlinux.org

# Verify package name is correct
ls -la package-name/
```

---

## References

- [AUR Official Documentation](https://wiki.archlinux.org/title/AUR_submission_guidelines)
- [aurpublish GitHub](https://github.com/eli-schwartz/aurpublish)
- [PKGBUILD Writing Guide](https://wiki.archlinux.org/title/PKGBUILD)
