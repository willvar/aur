# AUR Packages Repository

[中文](README.zh-CN.md) | English

This repository maintains packages for the [Arch User Repository](https://aur.archlinux.org/) using [aurpublish](https://github.com/eli-schwartz/aurpublish).

## Packages

| Package | Description | AUR Link |
|---------|-------------|----------|
| [aurpick](aurpick/) | Easily install any version of AUR packages — current, historical, or newer | [AUR](https://aur.archlinux.org/packages/aurpick) |
| [nginx-mainline-mod-zstd-git](nginx-mainline-mod-zstd-git/) | Zstandard compression module for mainline nginx | [AUR](https://aur.archlinux.org/packages/nginx-mainline-mod-zstd-git) |
| [ossfs-bin](ossfs-bin/) | FUSE-based file system backed by Alibaba Cloud OSS | [AUR](https://aur.archlinux.org/packages/ossfs-bin) |
| [ossfs2-bin](ossfs2-bin/) | High Performance OSS POSIX Client for Alibaba Cloud | [AUR](https://aur.archlinux.org/packages/ossfs2-bin) |
| [ossutil](ossutil/) | Command-line tool to access AliCloud OSS (source) | [AUR](https://aur.archlinux.org/packages/ossutil) |
| [ossutil-bin](ossutil-bin/) | Command-line tool to access AliCloud OSS | [AUR](https://aur.archlinux.org/packages/ossutil-bin) |
| [php-event](php-event/) | PHP extension for event-driven I/O | [AUR](https://aur.archlinux.org/packages/php-event) |
| [php-jsonpath](php-jsonpath/) | PHP JSONPath implementation | [AUR](https://aur.archlinux.org/packages/php-jsonpath) |
| [php-msgpack](php-msgpack/) | PHP MessagePack serialization extension | [AUR](https://aur.archlinux.org/packages/php-msgpack) |
| [php-simdjson](php-simdjson/) | PHP SIMDJSON extension for fast JSON parsing | [AUR](https://aur.archlinux.org/packages/php-simdjson) |
| [php-uuid](php-uuid/) | PHP UUID extension | [AUR](https://aur.archlinux.org/packages/php-uuid) |
| [proxysql](proxysql/) | High-performance MySQL proxy with query routing, caching, and load balancing (built from source) | [AUR](https://aur.archlinux.org/packages/proxysql) |
| [proxysql-bin](proxysql-bin/) | High-performance MySQL proxy with query routing, caching, and load balancing | [AUR](https://aur.archlinux.org/packages/proxysql-bin) |

## Installation

Install any package using an AUR helper:

```bash
# Using paru
paru -S ossfs2-bin

# Using yay
yay -S ossfs2-bin
```

Or build manually:

```bash
git clone https://aur.archlinux.org/ossfs2-bin.git
cd ossfs2-bin
makepkg -si
```

## Contributing

Contributions are welcome! Please read the [Contributing Guide](CONTRIBUTING.md) ([中文版](CONTRIBUTING.zh-CN.md)) for details on how to:

- Add new packages
- Update existing packages
- Follow code standards and best practices
- Submit pull requests
- Report issues

### Development Tools

#### PKGBUILD Testing Tool

We provide a comprehensive testing tool to check coding standards and build packages:

```bash
# Test all packages (lint + build)
./test.sh

# Test specific package
./test.sh package-name

# Only run lint checks
./test.sh --lint-only

# Only run build test
./test.sh package-name --build-only
```

**Lint Checks:**
- ✅ Variable naming (`makedepends` not `makedepend`)
- ✅ Indentation (2 spaces, no tabs)
- ✅ Variable quoting (`"${var}"`)
- ✅ Array quotes (single quotes)
- ✅ Source file uniqueness
- ✅ SPDX license format
- ✅ .gitignore format
- ✅ Base package dependencies

**Build Testing:**
- ✅ Full package build with `makepkg`
- ✅ Complete build output display
- ✅ Automatic cleanup of build artifacts

## Maintainer

**William Varmus** - [@willvar](https://github.com/willvar)

- AUR: [willvar](https://aur.archlinux.org/account/willvar)
- Email: 0@willvar.tw

## License

Each package has its own license. Please refer to the LICENSE file in each package directory.

## Links

- [AUR Official Website](https://aur.archlinux.org/)
- [Arch Wiki - AUR](https://wiki.archlinux.org/title/Arch_User_Repository)
- [aurpublish](https://github.com/eli-schwartz/aurpublish)
