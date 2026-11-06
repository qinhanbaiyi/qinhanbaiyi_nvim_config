-- LSP 行为集中在这里；插件版本和加载时机见 plugins/lsp.lua。
local M = {}

local function diagnostic_goto(forward, severity)
	return function()
		vim.diagnostic.jump({
			count = forward and 1 or -1,
			severity = vim.diagnostic.severity[severity],
			on_jump = function(_, bufnr)
				vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
			end,
		})
	end
end

-- 原有全局键位在启动时注册，不依赖服务器是否已经连接。
---@return nil
function M.keymaps()
	local function map(modes, lhs, rhs, desc, extra)
		vim.keymap.set(
			modes,
			lhs,
			rhs,
			vim.tbl_extend("force", { desc = desc, silent = true, remap = false }, extra or {})
		)
	end
	local modes = { "n", "v" }
	map(modes, "gH", vim.lsp.buf.signature_help, "Signature Help")
	map(modes, "<leader>cf", "<cmd>lua vim.lsp.buf.format {async = true}<CR>", "LSP Format")
	map(modes, "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "LSP Health")
	map(modes, "<leader>cc", vim.lsp.codelens.run, "Run Codelens")
	map("n", "<leader>cC", function()
		vim.lsp.codelens.enable(true, { bufnr = 0 })
	end, "Refresh & Display Codelens")
	map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
	map(
		modes,
		"<leader>ll",
		"<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>",
		"List Workspace Folders"
	)
	map("n", "[e", diagnostic_goto(false, "ERROR"), "Prev Error")
	map("n", "]e", diagnostic_goto(true, "ERROR"), "Next Error")
	map("n", "[w", diagnostic_goto(false, "WARN"), "Prev Warning")
	map("n", "]w", diagnostic_goto(true, "WARN"), "Next Warning")
end

-- 只补充主题没有定义的组；主题自身的诊断颜色和下划线保持优先。
function M.highlights()
	local function get(name)
		return vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
	end
	local function fallback(name, attrs)
		if not next(get(name)) then
			vim.api.nvim_set_hl(0, name, attrs)
		end
	end
	for severity, color in pairs({ Error = "#db4b4b", Warn = "#e0af68", Info = "#0db9d7", Hint = "#10B981" }) do
		local base = "Diagnostic" .. severity
		fallback(base, { fg = color })
		fallback("DiagnosticVirtualText" .. severity, { link = base })
		fallback("DiagnosticUnderline" .. severity, { undercurl = true, sp = get(base).fg or color })
	end
	fallback("LspReferenceText", { link = "CursorLine" })
	fallback("LspReferenceRead", { link = "LspReferenceText" })
	fallback("LspReferenceWrite", { link = "LspReferenceText" })
end

-- init 在服务器尚未连接时运行，确保快捷键和主题回退不会依赖 LspAttach。
function M.init()
	M.keymaps()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("UserLspHighlights", { clear = true }),
		desc = "Fill missing LSP highlight groups",
		callback = M.highlights,
	})
	M.highlights()
end

-- 插件加载后注册 LSP 行为，再交由 Mason 自动启用已安装的服务器。
function M.setup()
	vim.diagnostic.config({
		underline = true,
		update_in_insert = false,
		virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
		severity_sort = true,
		signs = {},
	})

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
		desc = "Enable supported inlay hints",
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client and client:supports_method("textDocument/inlayHint", args.buf) then
				vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
			end
		end,
	})

	-- 使用 Neovim 原生 API，避免旧 require("lspconfig").SERVER.setup 入口。
	vim.lsp.config("*", {
		capabilities = require("blink.cmp").get_lsp_capabilities({
			workspace = { fileOperations = { didRename = true, willRename = true } },
		}),
	})
	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				workspace = { checkThirdParty = false },
				codeLens = { enable = true },
				completion = { callSnippet = "Replace" },
				doc = { privateName = { "^_" } },
				hint = {
					enable = true,
					setType = false,
					paramType = true,
					paramName = "Disable",
					semicolon = "Disable",
					arrayIndex = "Disable",
				},
			},
		},
	})
	vim.lsp.config("rust_analyzer", {
		filetypes = { "rust" },
		cmd = { "rust-analyzer" },
	})

	-- 新增语言时在这里安装服务器，在上方添加需要覆盖的设置。
	require("mason-lspconfig").setup({
		ensure_installed = { "bashls", "vimls", "lua_ls", "rust_analyzer", "jsonls", "ruff" },
		automatic_enable = { exclude = { "tombi" } }, -- 保留 Tombi 手动启用的习惯。
	})
end

return M
