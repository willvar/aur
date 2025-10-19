#!/bin/bash
# PKGBUILD Testing Tool - Lint and build testing for AUR packages
# Usage: ./test.sh [package-name] [options]
#        ./test.sh                    # test all packages (lint + build)
#        ./test.sh php-event          # test specific package
#        ./test.sh --lint-only        # only run lint checks
#        ./test.sh php-event --build-only  # only build test

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
total_errors=0
total_warnings=0
total_packages=0
total_build_failures=0

# Test modes
RUN_LINT=true
RUN_BUILD=true
TARGET_PACKAGE=""

# Package results tracking
declare -a PASSED_PACKAGES
declare -a FAILED_PACKAGES

# Base packages that should not be in depends=()
# Reference: https://wiki.archlinux.org/title/PKGBUILD#depends
# Dynamically retrieved from system's 'base' meta-package
get_base_packages() {
  if command -v pacman &>/dev/null; then
    pacman -Qi base 2>/dev/null | grep "^Depends" | cut -d: -f2 | tr ' ' '\n' | grep -v "^$"
  fi
}

# Cache base packages list (empty if cannot retrieve)
BASE_PACKAGES=($(get_base_packages))

# Check if a package is a base package
is_base_package() {
  local pkg="$1"
  for base_pkg in "${BASE_PACKAGES[@]}"; do
    if [[ "$pkg" == "$base_pkg" ]]; then
      return 0
    fi
  done
  return 1
}

# Lint a single PKGBUILD
lint_pkgbuild() {
  local pkgdir="$1"
  local pkgname=$(basename "$pkgdir")
  local pkgbuild="$pkgdir/PKGBUILD"
  local errors=0
  local warnings=0

  if [[ ! -f "$pkgbuild" ]]; then
    echo -e "${RED}✗ PKGBUILD not found${NC}"
    return 1
  fi

  # 1. Check variable naming
  if grep -qE '^[[:space:]]*makedepend=' "$pkgbuild"; then
    echo -e "${RED}✗ ERROR: Use 'makedepends=' not 'makedepend='${NC}"
    ((errors++))
  fi

  if grep -qE '^[[:space:]]*depend=' "$pkgbuild"; then
    echo -e "${RED}✗ ERROR: Use 'depends=' not 'depend='${NC}"
    ((errors++))
  fi

  # Check indentation (tabs)
  if grep -qP '\t' "$pkgbuild"; then
    local tab_lines=$(grep -nP '\t' "$pkgbuild" | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')
    echo -e "${RED}✗ ERROR: Tabs found on lines: $tab_lines${NC}"
    echo -e "  Use 2 spaces for indentation"
    ((errors++))
  fi

  # 3. Check variable references
  # Look for unquoted variables (simplified check)
  if grep -E 'cd [^"]*\$' "$pkgbuild" 2>/dev/null | grep -qv '".*\$' 2>/dev/null || false; then
    echo -e "${YELLOW}⚠ WARNING: Possible unquoted variables in cd commands${NC}"
    grep -nE 'cd [^"]*\$' "$pkgbuild" 2>/dev/null | grep -v '".*\$' 2>/dev/null | sed 's/^/    /' || true
    ((warnings++))
  fi

  if grep -E 'install .*\$[a-zA-Z_]' "$pkgbuild" 2>/dev/null | grep -qvE '"\$\{[a-zA-Z_]' 2>/dev/null || false; then
    echo -e "${YELLOW}⚠ WARNING: Possible unquoted variables in install commands${NC}"
    ((warnings++))
  fi

  # 4. Check array quotes (double quotes in arch/license/depends)
  if grep -qE '^(arch|license|depends|makedepends)=\("' "$pkgbuild"; then
    echo -e "${YELLOW}⚠ WARNING: Arrays should use single quotes, not double quotes${NC}"
    grep -nE '^(arch|license|depends|makedepends)=\("' "$pkgbuild" | sed 's/^/    /'
    ((warnings++))
  fi

  # 5. Check source file naming
  if grep -qE 'source=\(' "$pkgbuild" 2>/dev/null; then
    # Check for common problematic patterns
    if grep -A20 'source=(' "$pkgbuild" 2>/dev/null | grep -E '(^|[[:space:]])"?https?://.*/(v[0-9]|[0-9])[^:]*\.(tar\.|zip)' 2>/dev/null | grep -qv '::' 2>/dev/null || false; then
      echo -e "${YELLOW}⚠ WARNING: Possible non-unique source filename (version-only)${NC}"
      echo -e "  Use '\${pkgname}-\${pkgver}.tar.gz::URL' syntax"
      ((warnings++))
    fi

    if grep -A20 'source=(' "$pkgbuild" 2>/dev/null | grep -E '"?https?://.*/LICENSE"?' 2>/dev/null | grep -qv '::' 2>/dev/null || false; then
      echo -e "${YELLOW}⚠ WARNING: LICENSE file should be renamed for uniqueness${NC}"
      echo -e "  Use '\${pkgname}-LICENSE::URL' syntax"
      ((warnings++))
    fi
  fi

  # Check license format (SPDX identifier should use hyphens, not spaces)
  # Reference: https://wiki.archlinux.org/title/PKGBUILD#license
  local license_line=$(grep -E "^license=" "$pkgbuild" | head -1)
  if [[ -n "$license_line" ]]; then
    # Check if license contains spaces (likely non-SPDX)
    if echo "$license_line" | grep -qE "license=\('[^']*[[:space:]][^']*'\)"; then
      echo -e "${YELLOW}⚠ WARNING: License should use SPDX identifiers (use hyphens, not spaces)${NC}"
      echo -e "  Found: $license_line"
      echo -e "  Examples: 'PHP-3.01', 'Apache-2.0', 'LGPL-2.1-or-later', 'BSD-3-Clause'"
      ((warnings++))
    fi
  fi

  # 8. Check base dependencies
  if grep -qE '^depends=\(' "$pkgbuild"; then
    local deps=$(grep -A10 'depends=(' "$pkgbuild" | grep -oE "'[^']+'" | tr -d "'")
    for dep in $deps; do
      # Remove version constraints
      local pkg_name=$(echo "$dep" | sed 's/[<>=].*$//')
      if is_base_package "$pkg_name"; then
        echo -e "${YELLOW}⚠ WARNING: Base package '$pkg_name' in depends=()${NC}"
        echo -e "  Base packages should not be listed"
        ((warnings++))
      fi
    done
  fi

  # Run namcap
  namcap_output=$(namcap "$pkgbuild" 2>&1)
  if echo "$namcap_output" | grep -qE '(E:|W:)'; then
    echo "$namcap_output"
    ((warnings++))
  fi

  total_errors=$((total_errors + errors))
  total_warnings=$((total_warnings + warnings))

  return $errors
}

# Build test a single package
test_build() {
  local pkgdir="$1"
  local pkgname=$(basename "$pkgdir")
  local pkgbuild="$pkgdir/PKGBUILD"

  if [[ ! -f "$pkgbuild" ]]; then
    echo -e "${RED}✗ PKGBUILD not found${NC}"
    return 1
  fi

  # Enter package directory
  cd "$pkgdir" || return 1

  # Cleanup any previous build artifacts before testing
  cleanup_build_artifacts

  # Run makepkg with real-time output
  makepkg -f --noconfirm
  local build_result=$?

  echo ""

  # Cleanup build artifacts
  cleanup_build_artifacts

  cd - > /dev/null

  if [[ $build_result -ne 0 ]]; then
    total_build_failures=$((total_build_failures + 1))
    total_errors=$((total_errors + 1))
  fi

  return $build_result
}

# Cleanup build artifacts
cleanup_build_artifacts() {
  # Remove build directories
  rm -rf src pkg

  # Parse source files from PKGBUILD and remove them
  if [[ -f PKGBUILD ]]; then
    # Extract source array from PKGBUILD
    local sources=$(bash -c "source PKGBUILD 2>/dev/null && printf '%s\n' \"\${source[@]}\" \"\${source_x86_64[@]}\" \"\${source_i686[@]}\"" 2>/dev/null)

    # Process each source entry
    while IFS= read -r src; do
      [[ -z "$src" ]] && continue

      # Extract filename from source
      # Handle format: "filename::URL" or just "URL"
      local filename
      if [[ "$src" =~ :: ]]; then
        # Format: filename::URL
        filename="${src%%::*}"
      else
        # Just URL, extract basename
        filename=$(basename "$src")
        # Remove URL query parameters
        filename="${filename%%\?*}"
      fi

      # Remove the file if it exists
      [[ -f "$filename" ]] && rm -f "$filename"
    done <<< "$sources"
  fi

  # Remove built package files
  rm -f *.pkg.tar*
}

# Test a single package (lint + build)
test_package() {
  local pkgdir="$1"
  local pkgname=$(basename "$pkgdir")
  local lint_result=0
  local build_result=0

  echo -e "${BLUE}==> Testing: ${pkgname}${NC}"
  echo ""

  # Run lint if enabled
  if [[ "$RUN_LINT" == true ]]; then
    lint_pkgbuild "$pkgdir"
    lint_result=$?
  fi

  # Run build test if enabled
  if [[ "$RUN_BUILD" == true ]]; then
    test_build "$pkgdir"
    build_result=$?
  fi

  total_packages=$((total_packages + 1))

  # Record package result
  if [[ $lint_result -eq 0 && $build_result -eq 0 ]]; then
    PASSED_PACKAGES+=("$pkgname")
  else
    FAILED_PACKAGES+=("$pkgname")
  fi

  return $((lint_result + build_result))
}

# Show usage
show_usage() {
  cat << EOF
PKGBUILD Testing Tool - Lint and build testing for AUR packages

Usage: $0 [package-name] [options]

Examples:
  $0                    # Test all packages (lint + build)
  $0 php-event          # Test specific package
  $0 --lint-only        # Only lint all packages
  $0 php-event --build-only  # Only build test specific package

Options:
  --lint-only           Only run lint checks, skip build testing
  --build-only          Only run build testing, skip lint checks
  --skip-lint           Skip lint checks (same as --build-only)
  --skip-build          Skip build testing (same as --lint-only)
  -h, --help            Show this help message

EOF
}

# Parse arguments
parse_arguments() {
  TARGET_PACKAGE=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --lint-only|--skip-build)
        RUN_BUILD=false
        shift
        ;;
      --build-only|--skip-lint)
        RUN_LINT=false
        shift
        ;;
      -h|--help)
        show_usage
        return 2  # Special return code for help
        ;;
      -*)
        echo -e "${RED}Error: Unknown option '$1'${NC}"
        show_usage
        return 1
        ;;
      *)
        if [[ -z "$TARGET_PACKAGE" ]]; then
          TARGET_PACKAGE="$1"
        else
          echo -e "${RED}Error: Multiple package names specified${NC}"
          show_usage
          return 1
        fi
        shift
        ;;
    esac
  done

  return 0
}

# Main
main() {
  parse_arguments "$@"
  local parse_result=$?

  # Handle help or error from argument parsing
  if [[ $parse_result -eq 2 ]]; then
    exit 0  # Help was shown
  elif [[ $parse_result -ne 0 ]]; then
    exit 1  # Error in arguments
  fi

  local target="$TARGET_PACKAGE"

  # Determine test mode display
  local mode_text="Lint + Build"
  if [[ "$RUN_LINT" == true && "$RUN_BUILD" == false ]]; then
    mode_text="Lint Only"
  elif [[ "$RUN_LINT" == false && "$RUN_BUILD" == true ]]; then
    mode_text="Build Only"
  fi

  echo -e "${BLUE}==> PKGBUILD Testing Tool for AUR Repo${NC}"
  echo -e "${BLUE}==> Mode: ${mode_text}${NC}"
  echo ""

  if [[ -n "$target" ]]; then
    # Test specific package
    if [[ -d "$target" ]]; then
      test_package "$target"
    else
      echo -e "${RED}Error: Directory '$target' not found${NC}"
      exit 1
    fi
  else
    # Test all packages
    for dir in */; do
      # Skip if not a package directory
      [[ ! -f "${dir}PKGBUILD" ]] && continue

      test_package "$dir"
    done
  fi

  # Final summary
  echo ""
  echo -e "${BLUE}==> Final Summary${NC}"
  echo ""

  # Show passed packages
  if [[ ${#PASSED_PACKAGES[@]} -gt 0 ]]; then
    echo -e "${GREEN}Passed (${#PASSED_PACKAGES[@]}):${NC}"
    for pkg in "${PASSED_PACKAGES[@]}"; do
      echo -e "  ${GREEN}✓${NC} $pkg"
    done
    echo ""
  fi

  # Show failed packages
  if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
    echo -e "${RED}Failed (${#FAILED_PACKAGES[@]}):${NC}"
    for pkg in "${FAILED_PACKAGES[@]}"; do
      echo -e "  ${RED}✗${NC} $pkg"
    done
    echo ""
  fi

  # Statistics
  echo -e "${BLUE}Statistics:${NC}"
  echo -e "  Total packages: $total_packages"
  [[ $total_errors -gt 0 ]] && echo -e "  ${RED}Total errors: $total_errors${NC}"
  [[ $total_warnings -gt 0 ]] && echo -e "  ${YELLOW}Total warnings: $total_warnings${NC}"
  [[ $total_build_failures -gt 0 ]] && echo -e "  ${RED}Build failures: $total_build_failures${NC}"

  echo ""
  if [[ ${#FAILED_PACKAGES[@]} -eq 0 ]]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  ✓✓✓ All packages passed! ✓✓✓${NC}"
    echo -e "${GREEN}========================================${NC}"
    exit 0
  else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}  ✗✗✗ Some packages failed! ✗✗✗${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
  fi
}

# Run main
cd "$(dirname "$0")"
main "$@"
