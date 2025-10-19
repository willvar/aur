# AUR 软件包仓库

中文 | [English](README.md)

本仓库使用 [aurpublish](https://github.com/eli-schwartz/aurpublish) 在 [Arch 用户仓库](https://aur.archlinux.org/)维护软件包。

## 软件包列表

| 包名 | 描述 | AUR 链接 |
|------|------|----------|
| [ossfs2-bin](ossfs2-bin/) | 阿里云 OSS 高性能 POSIX 客户端 | [AUR](https://aur.archlinux.org/packages/ossfs2-bin) |
| [ossutil-bin](ossutil-bin/) | 阿里云 OSS 命令行工具 | [AUR](https://aur.archlinux.org/packages/ossutil-bin) |
| [ossutil](ossutil/) | 阿里云 OSS 命令行工具（源码版） | [AUR](https://aur.archlinux.org/packages/ossutil) |
| [php-event](php-event/) | PHP 事件驱动 I/O 扩展 | [AUR](https://aur.archlinux.org/packages/php-event) |
| [php-jsonpath](php-jsonpath/) | PHP JSONPath 实现 | [AUR](https://aur.archlinux.org/packages/php-jsonpath) |
| [php-msgpack](php-msgpack/) | PHP MessagePack 序列化扩展 | [AUR](https://aur.archlinux.org/packages/php-msgpack) |
| [php-simdjson](php-simdjson/) | PHP SIMDJSON 快速 JSON 解析扩展 | [AUR](https://aur.archlinux.org/packages/php-simdjson) |
| [php-uuid](php-uuid/) | PHP UUID 扩展 | [AUR](https://aur.archlinux.org/packages/php-uuid) |

## 安装方法

使用 AUR 助手安装任何软件包：

```bash
# 使用 paru
paru -S ossfs2-bin

# 使用 yay
yay -S ossfs2-bin
```

或手动构建：

```bash
git clone https://aur.archlinux.org/ossfs2-bin.git
cd ossfs2-bin
makepkg -si
```

## 参与贡献

欢迎贡献！请阅读[贡献指南](CONTRIBUTING.zh-CN.md)（[English](CONTRIBUTING.md)）了解如何：

- 添加新包
- 更新现有包
- 遵循代码规范和最佳实践
- 提交拉取请求
- 报告问题

### 开发工具

#### PKGBUILD 测试工具

我们提供了综合测试工具来检查代码规范和构建软件包：

```bash
# 测试所有包（lint + 构建）
./test.sh

# 测试特定包
./test.sh package-name

# 仅运行 lint 检查
./test.sh --lint-only

# 仅运行构建测试
./test.sh package-name --build-only
```

**Lint 检查项：**
- ✅ 变量命名（`makedepends` 而非 `makedepend`）
- ✅ 缩进（2 空格，无 tab）
- ✅ 变量引用（`"${var}"`）
- ✅ 数组引号（单引号）
- ✅ Source 文件唯一性
- ✅ SPDX license 格式
- ✅ .gitignore 格式
- ✅ Base 包依赖

**构建测试：**
- ✅ 使用 `makepkg` 完整构建软件包
- ✅ 完整显示构建输出
- ✅ 自动清理构建产物

## 维护者

**William Varmus** - [@willvar](https://github.com/willvar)

- AUR: [willvar](https://aur.archlinux.org/account/willvar)
- 邮箱: 0@willvar.tw

## 许可证

每个包都有自己的许可证。请参阅各包目录中的 LICENSE 文件。

## 相关链接

- [AUR 官方网站](https://aur.archlinux.org/)
- [Arch Wiki - AUR](https://wiki.archlinux.org/title/Arch_User_Repository)
- [aurpublish](https://github.com/eli-schwartz/aurpublish)
