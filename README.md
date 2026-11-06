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
| `<leader>cl` | 查看 LSP 健康检查 |
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

- `init.lua` 定义 leader 和模块加载顺序。
- `lua/config/` 放基础选项、全局事件、基础键位、Which-key 和 Lazy 引导。
- `lua/plugins/` 按功能管理插件及其专用键位。
- `lua/plugins/Snippets/snippets/` 放各语言的自定义 LuaSnip 片段。
