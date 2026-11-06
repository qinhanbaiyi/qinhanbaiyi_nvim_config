# Qinhanbaiyi 的 Neovim 配置

面向 WSL 和 Linux 的 Neovim 0.12 配置。使用 One Dark、Telescope、Neo-tree、Blink、LuaSnip 和 Conform。

## 安装

- Neovim 0.12 或更新版本。
- Git、`curl`、`tar`、`unzip`、C 编译器和 `make`。Tree-sitter 解析器需要 `tree-sitter` CLI 0.26.1 或更新版本。
- `rg` 用于 Telescope 全文搜索，`fd` 用于文件搜索。Bash、Vimscript 和 JSON 语言服务器需要 Node.js 与 npm。
- Markdown 浮窗预览使用 PATH 中的 `glow`。格式化工具见下表。

新环境可以把配置克隆到 Neovim 的配置目录。

```sh
git clone https://github.com/qinhanbaiyi/qinhanbaiyi_nvim_config.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim
```

已有配置时，先备份现有目录。已有插件缓存时，在 Neovim 中运行 `:Lazy restore` 以对齐 `lazy-lock.json`。首次启动等插件和解析器安装完成后，运行 `:checkhealth`。用 `:Mason` 查看语言服务器，用 `:ConformInfo` 查看当前文件的格式化器。插件锁文件记录的是 Git 提交，Mason 工具和系统可执行文件需要单独安装。

如果首次启动无法克隆插件，先在同一个 WSL shell 中检查 Git 能否访问 GitHub。较旧的 Linux 发行版可能需要本地编译 Tree-sitter CLI 才能匹配系统的 glibc。

## 常用操作

`<leader>` 是空格，`<localleader>` 是反斜杠。

| 键位 | 行为 |
| --- | --- |
| `<leader>ff` / `<leader>sg` | 查找文件 / 全文搜索 |
| `<leader>e` | 打开或关闭 Neo-tree |
| `<leader>cs` / `<leader>vs` | Aerial 符号导航 / 代码大纲 |
| `gd` / `gD` | 预览定义 / 跳转定义 |
| `gr` / `gI` / `gy` | 查找引用 / 实现 / 类型定义 |
| `gh` / `gH` | 悬浮文档 / 函数签名 |
| `<leader>cr` / `<leader>ca` | 重命名 / 代码操作 |
| `[d` / `]d` | 上一条 / 下一条诊断 |
| `<leader>co` / `<leader>cl` | Lspsaga 大纲 / LSP 健康检查 |
| `<leader>xs` / `<leader>xl` | Trouble 的符号 / LSP 视图 |
| `<leader>mp` | Markdown 浮窗预览 |
| `<leader><leader>s` | 重新加载当前配置的 LuaSnip 片段 |
| `\` | 用 SnipRun 执行当前语句或选区 |
| `<leader>f` | 手动格式化，也可用 `:Format` |
| `<leader>cf` | 仅调用 LSP 格式化 |

补全列表里用 `Tab` 和 `Shift-Tab` 浏览补全，回车确认已选候选。LuaSnip 用 `Ctrl-K` 展开或向前跳，`Ctrl-J` 向后跳，`Ctrl-L` 切换片段选项。

## 格式化

| 文件类型 | 工具 |
| --- | --- |
| Lua | `stylua` |
| Python | `black` |
| Rust | `rustfmt`，缺失时回退到 LSP |
| JavaScript | `prettierd` 或 `prettier` |
| Snakemake | `snakefmt` |
| YAML | `yamlfmt` |
| Shell | `shfmt -i 2`，手动格式化 |

`:Format` 使用 Conform。Shell 继续保持手动格式化，原有的保存格式化规则覆盖其余已配置的文件类型。

可用 `:Prettier` 手动格式化支持的文件，例如 Markdown。Lua、YAML 和 JavaScript 需要在 PATH 或项目内提供上表对应的工具。用 uv 安装 Python 工具时，可以运行 `uv tool install black==26.10.1` 和 `uv tool install --python 3.11 snakefmt==0.11.5`。

## 配置结构

```text
init.lua                       # leader 与启动顺序
lua/
  config/
    options.lua                # Neovim 基础选项
    keymaps.lua                # 编辑、窗口、Quickfix 等原生快捷键
    autocmds.lua               # 通用事件与文件类型
    lazy.lua                   # 插件管理器引导和唯一插件入口
    lsp.lua                    # 服务器、诊断、原生 LSP 键位
    lsp_compat.lua             # Lspsaga 公开方法的局部兼容修复
    plugin_patches.lua         # 固定源码校验与内存补丁加载
    compat/                    # ToggleTerm / Diffview 的版本专用补丁清单
    ai.lua                     # 旧 AI 按键、命令与认证字段的兼容
    markdown.lua               # 原生浮窗调用 Glow CLI
    which.lua                  # Which-key 菜单分组
  plugins/                     # 扁平、小写；只放 Lazy 插件声明
    lsp.lua                    # LSP 插件、版本、Lspsaga 键位
    completion.lua             # Blink 补全与候选列表
    snippets.lua               # LuaSnip 插件与跳转键
    formatting.lua             # Conform、保存格式化、手动命令
    editor.lua                 # 编辑工具、Neo-tree、mini.pairs/surround
    ai.lua                     # NeoCodeium 插件版本与启用策略
    ui.lua                     # 主题、状态栏、标签栏、缩进线
    which-key.lua              # Which-key 加载与分组显示
    ...                        # Telescope、Git、Tree-sitter 等领域文件
  snippets/
    init.lua                   # 注册语言、加载和重载
    definitions/               # 每个文件对应一种语言的片段
    helpers/                   # 仅供片段使用的 AST 和字符串辅助函数
scripts/check.sh               # 格式、加载、锁版本和键位回归
scripts/check-all.sh            # 完整 LSP、Git、编辑和 AI 本地回归
tests/                         # 启动、片段和真实按键测试
.editorconfig
.stylua.toml
lazy-lock.json
```

`lua/plugins/` 中每个模块返回插件声明。与插件相关的选项、依赖、命令和快捷键放在同一处；通用编辑操作放在 `config/keymaps.lua`，Which-key 只负责显示菜单分组。使用多个事件的模块创建有名称的 augroup，避免重载后叠加事件。

原来的 `plugins/LSP`、`plugins/UI`、`plugins/Snippets` 目录已归入上述结构。原 `utils` 中实际使用的代码收归片段 helpers，无引用的工具已移除。

### 如何扩展

- **新增插件**：在对应领域的 `lua/plugins/*.lua` 中添加声明，或新建一个返回声明的文件，Lazy 会自动发现。带键位的插件如需启动加载，显式写 `lazy = false`；搬迁映射时保留原来的模式、`silent` 和 `nowait`。
- **新增语言服务器**：在 `config/lsp.lua` 的 `ensure_installed` 中登记服务器，用 `vim.lsp.config("服务器名", {...})` 添加覆盖配置。Mason 负责安装及启用，保留 Tombi 手动启用。
- **新增格式化器**：修改 `plugins/formatting.lua` 的 `formatters_by_ft`，并安装对应可执行文件。Shell 保持仅手动格式化。
- **新增片段**：在 `snippets/definitions/<filetype>.lua` 返回片段表，并把文件类型加入 `snippets/init.lua` 的列表。共用辅助函数放在 `snippets/helpers/`。按 `<leader><leader>s` 会刷新定义与 helpers，稳定的注册 key 避免重复候选。
- **更新插件**：兼容性敏感的插件声明使用固定版本或提交。修改目标版本后更新对应锁项，测试通过再提交 `lazy-lock.json`；其他机器用 `:Lazy restore` 对齐。

### Lua 与 LSP

使用 Neovim 0.12 原生的 `vim.lsp.config` 和客户端方法调用。Lspsaga 使用维护中的 [nvimdev 仓库](https://github.com/nvimdev/lspsaga.nvim)，保留定义预览里的 `Ctrl-C` 组合键以及原有导航键。

[Lazydev](https://github.com/folke/lazydev.nvim) 代替 neodev，根据当前 Lua 文件引用的模块补充 LuaLS 类型。Blink 的 Lazydev 来源仅对 Lua 启用，其他语言继续使用原有补全来源。自动函数签名提示继续由 lsp_signature 提供。

旧的大纲插件已迁移到 [outline.nvim](https://github.com/hedyhli/outline.nvim)，保留 `:SymbolsOutline`、`:SymbolsOutlineOpen` 和 `:SymbolsOutlineClose`，继续使用右侧大纲窗口。日常的 Aerial 和 Lspsaga 大纲键位保持不变。

`config/lsp_compat.lua` 对锁定版本 Lspsaga 的重命名引用高亮、类型层级请求与布局校验作局部修复，处理客户端方法、字符编码、过期异步响应和新版 validate 签名，不修改 Neovim 全局 API，也不屏蔽警告。后续升级该插件时应核对上游是否已修复，再删除对应兼容代码。

## 检查与维护

先完成插件和语言服务器安装，然后在当前启用的配置目录运行。

```sh
cd ~/.config/nvim
bash scripts/check.sh
bash scripts/check-all.sh
```

第一条需要 PATH 中的 `nvim` 和 `stylua`，检查格式、插件锁版本、常用快捷键、主题，以及 44 个片段的展开、跳转、历史和重载。完整检查还需要 `uv`、Git、Glow 和 Mason 已安装的 `lua_ls`，使用 `pynvim==0.6.0` 运行以下场景。

| 测试 | 覆盖 |
| --- | --- |
| `tests/lsp.py` | 真实 LuaLS、Lazydev 补全、Saga 窗口、重命名、签名和大纲 |
| `tests/git.py` | 临时 Git 仓库中的导航、暂存、撤销、还原、blame、diff 与缩进线 |
| `tests/deferred.py` | 按需打开终端、状态栏刷新、仓库差异与文件历史 |
| `tests/tooling.lua` | 调试依赖导入、异步任务与调试参数校验，不启动调试会话 |
| `tests/editor.py` | 自动括号、包围符、原生注释、Glow 内容与关闭竞态、Saga 布局 |
| `tests/ai.py` | 本地合成候选的接受、循环、清空和原按键回退，不调用云端 |

测试继承 `XDG_CONFIG_HOME`、`XDG_DATA_HOME`，也可用 `NVIM_BIN` 指定 Neovim。所有常规检查通过旧 `g:codeium_enabled` 开关关闭 AI 网络请求，不改写用户项目文件。类型层级与迟到响应使用受控请求覆盖边界，不能代替具体语言服务器的完整验证。

### 插件维护与替换记录

2026-11-07 核对当时启用的 52 个仓库，归档状态以 GitHub 仓库元数据为准。

| 原依赖 | 当前处理 | 保留的习惯 |
| --- | --- | --- |
| 已归档的 [Codeium/Windsurf Vim 插件](https://github.com/Exafunction/windsurf.vim) | [NeoCodeium](https://github.com/monkoose/neocodeium) | Ctrl-G 接受，Alt-n/Alt-N 循环，Ctrl-X 清空，以及旧命令和备用键 |
| 已归档的 [glow.nvim](https://github.com/ellisonleao/glow.nvim) | Neovim 原生浮窗 + 现有 [Glow CLI](https://github.com/charmbracelet/glow) | `:Glow`、`<leader>mp`、q/Esc 关闭，支持未保存文本 |
| 未启用 setup 的 Comment.nvim | 清理重复依赖，继续使用 Neovim 原生注释 | 原有 gc/gcc；不凭空增加 gb 操作 |
| 旧 mini.pairs / mini.surround 仓库地址 | 改用维护组织 `nvim-mini/*` 的固定稳定版 | 原有括号及 gs* 键；显式补回上游取消注册的 gsn |

Gitsigns、IBL、LuaSnip 和 mini.pairs 使用已修复 `vim.validate` 的上游版本。Lspsaga 尚未修复的两个布局方法由局部兼容代码适配，没有改写全局 `vim.validate` 或隐藏警告。测试要求 `:checkhealth vim.deprecated` 不出现警告。

ToggleTerm 和 Diffview 的固定版本仍有上游未修复的校验。兼容清单明确列出旧/新源码，加载器核对原文件 SHA256 和片段唯一性后，只在内存中将其改为现代参数校验调用。插件 checkout 保持干净，`:Lazy restore` 后仍可重现；全局 API 与告警机制保持原样。升级这两个插件时，需要同时重新审查清单，源码不符会明确报错，避免悄悄套用过期补丁。

Gitsigns 的旧 `toggle_deleted` 接口已经失效，`<leader>td` 现在打开/关闭当前文件的统一差异视图以查看删除行。`<leader>hu` 继续撤销最近一次暂存，不改成“反向暂存光标处的 hunk”。新版 surround 的查找操作额外支持可视和操作符模式，原有普通模式操作不变。

NeoCodeium 复用 `~/.codeium/config.json`。旧 `apiKey` 字段只在内存中适配为新插件需要的格式，不把认证数据写入仓库。新环境使用 `:NeoCodeium auth`，默认服务二进制由插件管理；本地服务路径可通过 `vim.g.neocodeium_bin` 指定。首次迁移实测旧账号认证、服务连接和合成请求响应正常，但该请求返回空候选，因此云端生成效果仍以实际使用为准。

日常排查使用 `:checkhealth vim.lsp`、`:checkhealth vim.deprecated`、`:ConformInfo` 和 `:messages`。已有配置的模块职责、关键选项、延迟加载原因和兼容边界均写在对应代码注释中。

## 隐私与本地数据

Git 提交记录会公开作者邮箱。新机器提交前，建议在 GitHub 的邮箱设置中开启邮箱隐私，复制 GitHub 提供的 noreply 地址，再为本仓库设置 `git config user.email "你的 GitHub noreply 地址"`；这只影响之后的提交，不会自动清除历史邮箱。

撤销记录、交换文件、备份、日志和插件运行数据应保存在 Neovim 的标准数据、状态或缓存目录中，不放在配置仓库内。可用 `:echo stdpath('state')`、`:echo stdpath('data')` 和 `:echo stdpath('cache')` 查看本机位置。代码片段使用通用占位，个人笔记和机构信息留在自己的项目中。

禁止提交令牌、密码、私钥和带真实认证值的环境文件；认证信息由对应工具存放在仓库外。`.gitignore` 只防止误加入匹配的新文件，不能移除已经跟踪的文件或清理提交历史。提交前检查 `git diff --cached`，示例环境文件也应只使用占位值。
