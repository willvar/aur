# 贡献指南

[English Documentation](CONTRIBUTING.md)

欢迎！本仓库使用 [aurpublish](https://github.com/eli-schwartz/aurpublish) 管理多个 AUR 包，很高兴你能来。

## 如何贡献

根据参与程度，有以下几种方式：

### 🐛 报告问题

发现了 bug 或有建议？欢迎告诉我们：

- **提交 issue**：[GitHub Issues](https://github.com/willvar/aur/issues)
- **联系维护者**：0@willvar.tw
- 无需任何配置

### 🔀 提交 Pull Request

想贡献代码但还没有仓库直接访问权限？步骤如下：

1. **Fork 本仓库**
   - 访问 https://github.com/willvar/aur
   - 点击 "Fork" 按钮

2. **克隆你的 fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/aur.git
   cd aur
   ```

3. **添加 upstream 远程仓库**
   ```bash
   git remote add upstream https://github.com/willvar/aur.git
   ```

4. **创建分支并进行修改**
   ```bash
   git checkout -b my-package-update
   # 按照本指南进行修改
   ./test.sh package-name
   git add .
   git commit
   ```

5. **推送到你的 fork**
   ```bash
   git push origin my-package-update
   ```

6. **创建 Pull Request**
   - 访问你在 GitHub 上的 fork
   - 点击 "New Pull Request"
   - 描述你的修改
   - 等待维护者审查

7. **保持 fork 同步**
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   git push origin main
   ```

### 👥 成为协作者

对于希望获得仓库直接访问权限的贡献者：

1. **建立贡献历史**
   - 提交高质量的 Pull Request
   - 展示对代码规范的理解
   - 积极维护软件包

2. **申请访问权限**
   - 联系维护者：0@willvar.tw
   - 提供你的 GitHub 用户名
   - 说明你想维护的软件包

3. **被添加为协作者后**
   - 直接克隆仓库
   - 遵循本指南中的工作流程
   - 直接推送到 `main` 分支
   - 在 AUR 上维护你的软件包

**注意**：协作者拥有直接推送权限。推送前请确保所有测试都通过。

---

## 前置要求

### 1. 安装工具

```bash
# 安装 aurpublish
paru -S aurpublish
# 或
yay -S aurpublish
```

### 2. 配置环境

```bash
# 克隆仓库
git clone git@github.com:willvar/aur.git
cd aur

# 安装 Git hooks（必需）
aurpublish setup

# 配置 Git 用户信息（如果还未配置）
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### 3. 配置 SSH 密钥

#### AUR SSH 配置

```bash
# 生成 SSH 密钥（如果还没有）
ssh-keygen -t ed25519 -f ~/.ssh/aur

# 添加公钥到 AUR 账户
cat ~/.ssh/aur.pub
# 访问 https://aur.archlinux.org/account/ 添加公钥

# 配置 ~/.ssh/config
cat >> ~/.ssh/config <<EOF
Host aur.archlinux.org
    User aur
    IdentityFile ~/.ssh/aur
EOF

# 测试连接
ssh -T aur@aur.archlinux.org
```

#### GitHub SSH 配置

```bash
# 添加公钥到 GitHub
cat ~/.ssh/aur.pub  # 或使用其他密钥
# 访问 https://github.com/settings/keys 添加公钥

# 测试连接
ssh -T git@github.com
```

---

## 工作流程

### 新增软件包

```bash
# 1. 创建包目录和文件
mkdir package-name
cd package-name
# 创建 PKGBUILD、.SRCINFO、LICENSE 等文件

# 2. 回到仓库根目录
cd ..

# 3. 测试包
./test.sh package-name

# 4. 添加并提交
git add package-name/
git commit
# Git 会自动生成提交消息：Initial upload: package-name x.x.x-x
# 保存退出编辑器即可

# 5. 推送到 AUR
aurpublish package-name

# 6. 推送到 GitHub
git push origin main
```

### 更新现有软件包

```bash
# 1. 修改 PKGBUILD
vim package-name/PKGBUILD
# 更新 pkgver、pkgrel、sha256sums 等

# 2. 测试更改
./test.sh package-name

# 3. 提交更改
git add package-name/
git commit
# 自动生成消息：Updated: package-name x.x.x-x

# 4. 推送到 AUR
aurpublish package-name

# 5. 推送到 GitHub
git push origin main
```

### 从 AUR 导入现有包

```bash
# 导入包（会拉取完整的 AUR 提交历史）
aurpublish -p existing-package

# 推送到 GitHub
git push origin main
```

### 从 AUR 拉取更新

如果其他人在 AUR 上提交了更新：

```bash
# 拉取 AUR 的更新
aurpublish -p package-name

# 推送到 GitHub
git push origin main
```

### 删除/放弃软件包

```bash
# 1. 从本地仓库删除
git rm -r package-name/
git commit -m "Remove package-name (orphaned)"

# 2. 推送到 GitHub
git push origin main

# 3. 在 AUR 上放弃包
# 访问 https://aur.archlinux.org/packages/package-name
# 点击 "Disown Package" 或联系管理员删除
```

---

## 测试

提交更改之前，请务必使用测试工具测试你的 PKGBUILD。这能帮助及早发现错误。

### 快速开始

```bash
# 测试特定包（lint + 构建）
./test.sh package-name

# 测试所有包
./test.sh

# 仅 lint（快速，不构建）
./test.sh package-name --lint-only

# 仅构建（跳过 lint）
./test.sh package-name --build-only
```

### 推荐工作流程

```bash
# 1. 进行修改
vim package-name/PKGBUILD

# 2. 快速 lint 检查
./test.sh package-name --lint-only

# 3. 修复问题
# ... 编辑 PKGBUILD ...

# 4. 完整测试（lint + 构建）
./test.sh package-name

# 5. 测试通过后提交
git add package-name/
git commit
```

### 理解测试结果

**输出摘要：**
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

**状态类型：**
- ✅ **Passed**: 所有检查通过，可以提交
- ⚠️ **Warnings**: 非关键问题，建议修复
- ❌ **Errors**: 提交前必须修复

### 测试内容

**Lint 检查：**
- 变量命名（`makedepends` 而非 `makedepend`）
- 缩进（2 空格，不能用 tab）
- 变量引用（`"${var}"`）
- 数组引号（单引号）
- Source 文件唯一性
- SPDX license 格式
- Base 包依赖
- 以及 `namcap` 验证

**构建测试：**
- 使用 `makepkg` 完整构建软件包
- 实时构建输出
- 自动清理构建产物

### 常见问题及修复

| 问题 | 原因 | 修复方法 |
|------|------|----------|
| `ERROR: Tabs found on lines: X` | 混用 tab 和空格 | 将 tab 替换为 2 个空格 |
| `WARNING: Possible unquoted variables` | `cd $var` | 使用 `cd "${var}"` |
| `WARNING: Arrays should use single quotes` | `arch=("x86_64")` | 使用 `arch=('x86_64')` |
| `WARNING: License should use SPDX` | `license=('Apache 2.0')` | 使用 `license=('Apache-2.0')` |
| `WARNING: Base package in depends=()` | `depends=('glibc')` | 移除（base 包是隐式的） |
| `Build failed` | PKGBUILD 错误 | 检查构建输出，修复语法/逻辑错误 |

### CI/CD 集成

测试脚本返回退出码：
- `0` - 所有测试通过
- `1` - 发现错误（构建失败或 lint 错误）

---

## 代码规范

本仓库遵循统一的代码规范，以确保一致性和可维护性。

### 强制规范

以下规则必须遵守（测试工具会检查）：

#### 1. PKGBUILD 标准变量

必须使用正确的 PKGBUILD 标准变量名：
- ✅ `makedepends=()` 而不是 `makedepend=`
- ✅ `depends=()`、`provides=()`、`conflicts=()`
- ✅ 其他标准变量：`pkgname`、`pkgver`、`pkgrel`、`arch`、`license` 等

自定义变量必须以下划线开头：
- ✅ `_extname=`、`_pkgname=`、`_commit=`

**原因**：这是 PKGBUILD 规范要求。使用错误的变量名会导致包元数据不完整，可能引发依赖问题。

#### 2. 缩进

- ✅ 使用 **2 个空格**缩进
- ❌ **永远不要**使用 tab

```bash
# 正确
prepare() {
  cd "${srcdir}"
  ./configure
}

# 错误
prepare() {
	cd "${srcdir}"  # 使用了 tab
    ./configure     # 4 个空格
}
```

**原因**：统一的缩进提高可读性。

#### 3. 变量引用

- ✅ 总是给变量加引号：`"${var}"`
- ❌ 不要使用无引号形式：`$var`

```bash
# 正确
cd "${srcdir}/${pkgname}-${pkgver}"
install -Dm644 "${srcdir}/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"

# 错误
cd $srcdir/$pkgname-$pkgver
install -Dm644 $srcdir/LICENSE $pkgdir/usr/share/licenses/$pkgname/LICENSE
```

**原因**：防止文件名包含空格或特殊字符时出现问题。

#### 4. 数组引号

- ✅ 数组使用**单引号**：`arch=('x86_64')`
- ✅ 适用于：`arch`、`license`、`depends`、`makedepends` 等

```bash
# 正确
arch=('x86_64')
license=('MIT')
depends=('glibc' 'openssl')

# 错误
arch=("x86_64")
license=("MIT")
```

**原因**：与 Arch Linux 惯例保持一致。

#### 5. source 文件命名

- ✅ 所有 source 文件名**必须唯一**
- ✅ 使用 `${pkgname}-${pkgver}` 模式
- ✅ 使用 `::` 语法重命名通用文件

```bash
# 正确 - 唯一的名字防止冲突
source=(
  "${pkgname}-LICENSE::https://raw.githubusercontent.com/user/repo/master/LICENSE"
  "${pkgname}-${pkgver}.tar.gz::https://github.com/user/repo/archive/v${pkgver}.tar.gz"
)

# 错误 - 通用名称在共享 SRCDEST 时会冲突
source=(
  "https://raw.githubusercontent.com/user/repo/master/LICENSE"
  "https://github.com/user/repo/archive/v${pkgver}.tar.gz"  # 变成 v1.2.3.tar.gz
)
```

**原因**：防止共享 `SRCDEST` 时文件冲突（[ArchWiki](https://wiki.archlinux.org/title/PKGBUILD#source)）。

#### 6. License 格式

- ✅ 使用 **SPDX 标识符**：[SPDX License List](https://spdx.org/licenses/)
- ✅ 常用许可证：
  - MIT: `license=('MIT')`
  - Apache: `license=('Apache-2.0')`
  - BSD 3-Clause: `license=('BSD-3-Clause')`
  - GPL v3: `license=('GPL-3.0-or-later')`
  - LGPL v2.1: `license=('LGPL-2.1-or-later')`
  - PHP: `license=('PHP-3.01')`

**原因**：Arch Linux [RFC 0016](https://rfc.archlinux.page/0016-spdx-license-identifiers/) 要求使用 SPDX 格式。

#### 7. Base 依赖

- ❌ **不要**在 `depends=()` 中列出 base 包
- Base 包包括：`glibc`、`bash`、`coreutils` 等
- ✅ **要**列出明确的运行时依赖

**原因**：Base 包假定已安装（[Arch Guidelines](https://wiki.archlinux.org/title/Arch_package_guidelines)）。

---

### 推荐风格

以下不是强制性的，但有助于保持一致性：

#### 1. pkgdesc 引号

- 大多数包使用单引号：`pkgdesc='...'`
- 双引号 `pkgdesc="..."` 也可接受

#### 2. install 命令风格

推荐模式：
```bash
install -Dm755 file "${pkgdir}/path" \
&& install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
```

#### 3. 函数间空行

在函数之间添加空行以提高可读性：

```bash
prepare() {
  ...
}

build() {
  ...
}
```

#### 4. source 数组格式

使用多行格式，每个文件一行：

```bash
source=(
  "file1.tar.gz"
  "file2.patch"
)
```

---

## systemd 集成

对于提供系统服务或守护进程的包，我们使用现代 systemd 特性以获得更好的可靠性和可维护性。

### 系统用户和目录

**使用 `sysusers.d` 和 `tmpfiles.d` 替代 `.install` 脚本**来创建系统用户和运行时目录。

#### 为什么采用这种方式？

- ✅ **声明式且可靠**：systemd 自动处理边界情况
- ✅ **更安全**：原子操作，安装期间不会出现脚本错误
- ✅ **现代标准**：遵循 systemd 和 Arch Linux 最佳实践
- ✅ **更易维护**：简单的配置文件而非 bash 脚本

#### 实现步骤

**1. 创建 `pkgname.sysusers` 文件：**

```
u username - "Description" /home/dir /bin/false
```

来自 `proxysql-bin.sysusers` 的示例：
```
u proxysql - "ProxySQL Server" /var/lib/proxysql /bin/false
```

**2. 创建 `pkgname.tmpfiles` 文件：**

```
d /path/to/directory mode user group age
```

来自 `proxysql-bin.tmpfiles` 的示例：
```
d /var/lib/proxysql 0770 proxysql proxysql -
```

**3. 添加到 PKGBUILD 的 `source` 数组：**

```bash
source=("upstream-tarball.tar.gz"
        "${pkgname}.sysusers"
        "${pkgname}.tmpfiles")
sha256sums=('...'
            'SKIP'
            'SKIP')
```

**4. 在 `package()` 函数中安装：**

```bash
# 安装 sysusers 和 tmpfiles
install -Dm644 "${srcdir}/${pkgname}.sysusers" "${pkgdir}/usr/lib/sysusers.d/${pkgname}.conf"
install -Dm644 "${srcdir}/${pkgname}.tmpfiles" "${pkgdir}/usr/lib/tmpfiles.d/${pkgname}.conf"
```

**5. 简化 `.install` 脚本**（可选 - 仅用于用户消息）：

```bash
post_install() {
  # systemd-sysusers 和 systemd-tmpfiles 处理用户/目录创建

  # 只保留无法声明式完成的自定义设置
  chown root:username /etc/pkgname.conf
  chmod 640 /etc/pkgname.conf

  echo "==> 包已安装。"
  echo "==> 启动服务：systemctl start pkgname"
  echo "==> 开机自启：systemctl enable pkgname"
}
```

### Service 文件

**将 systemd service 文件安装到正确位置：**

```bash
# 正确位置
install -Dm644 pkgname.service "${pkgdir}/usr/lib/systemd/system/pkgname.service"
```

**安全加固检查清单：**

创建或修改 systemd service 文件时，包含适当的安全选项：

```ini
[Service]
# 基本安全
User=username
Group=groupname
NoNewPrivileges=true

# 文件系统保护
ProtectHome=yes
ProtectSystem=full
PrivateDevices=yes
PrivateTmp=yes

# 能力限制（根据需要调整）
CapabilityBoundingSet=CAP_SETGID CAP_SETUID CAP_SYS_RESOURCE

# 网络限制（如适用）
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX

# 资源限制（根据需要调整）
LimitNOFILE=102400
```

参见 `man systemd.exec` 了解所有可用选项。

### 配置文件备份

**始终在 `backup` 数组中声明配置文件：**

```bash
backup=('etc/pkgname.conf')
```

这确保用户修改在升级期间得以保留。

### 日志轮转

**对于生成日志的服务，提供 logrotate 配置：**

```bash
# 安装 logrotate 配置
install -Dm644 etc/logrotate.d/pkgname "${pkgdir}/etc/logrotate.d/pkgname"
```

### 完整示例

参见 `proxysql-bin` 包的完整工作示例：
- `proxysql-bin/proxysql-bin.sysusers`
- `proxysql-bin/proxysql-bin.tmpfiles`
- `proxysql-bin/PKGBUILD`
- `proxysql-bin/proxysql-bin.install`

---

## 重要说明

### Git Hooks

aurpublish 安装的 Git hooks 会自动：

- **pre-commit**：
  - 自动生成/更新 `.SRCINFO` 文件
  - 如果 PKGBUILD 有严重错误会导致提交失败

- **prepare-commit-msg**：
  - 自动生成规范的提交消息
  - 格式：`Initial upload:` / `Updated:` / `Deleted:` 等

### 最佳实践

**推荐做法**：
- 使用 `git commit`（不加 `-m`）让 hooks 自动生成消息
- 或使用 `git commit --no-edit` 直接使用自动生成的消息
- 每次修改后同时推送到 AUR 和 GitHub

**避免**：
- 不要使用 `git commit -m "..."`，会覆盖自动生成的消息
- 不要手动编辑 `.SRCINFO`，应该让 hooks 自动生成
- 不要忘记推送到 GitHub（只执行 aurpublish 不够）

### 两次推送的原因

- `aurpublish package-name` → 推送**子树**到 AUR 的独立仓库
- `git push origin main` → 推送**完整仓库**到 GitHub

AUR 为每个包维护独立的 Git 仓库，而 GitHub 是我们的主仓库。

---

## 常用命令速查

```bash
# 查看包的提交历史
aurpublish log package-name

# 加速推送（使用 --rejoin）
aurpublish -s package-name

# 查看仓库状态
git status

# 查看待推送的提交
git log origin/main..HEAD

# 查看所有包
ls -d */
```

---

## 故障排查

### Hooks 没有生效

```bash
# 重新安装 hooks
aurpublish setup
```

### .SRCINFO 未自动生成

```bash
# 手动生成
cd package-name
makepkg --printsrcinfo > .SRCINFO
```

### 推送到 AUR 失败

```bash
# 检查 SSH 连接
ssh -T aur@aur.archlinux.org

# 检查包名是否正确
ls -la package-name/
```

---

## 参考资源

- [AUR 官方文档](https://wiki.archlinux.org/title/AUR_submission_guidelines)
- [aurpublish GitHub](https://github.com/eli-schwartz/aurpublish)
- [PKGBUILD 编写指南](https://wiki.archlinux.org/title/PKGBUILD)
