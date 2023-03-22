require("onedarkpro").setup({
	plugins = { -- Override which plugin highlight groups are loaded
		barbar = true,
		gitsigns = false,
		indentline = true,
		leap = true,
		lsp_saga = false,
		lsp_semantic_tokens = true,
		marks = true,
		neotest = true,
		nvim_cmp = true,
		nvim_bqf = true,
		nvim_dap = false,
		nvim_dap_ui = false,
		nvim_hlslens = false,
		nvim_lsp = true,
		nvim_navic = true,
		nvim_notify = false,
		nvim_tree = false,
		nvim_ts_rainbow = false,
		polygot = true,
		telescope = false,
		toggleterm = false,
		treesitter = true,
		trouble = false,
		which_key = false,
	},
	highlights = {
		PmenuSel = { bg = "#282C34", fg = "NONE" },
		Pmenu = { fg = "#C5CDD9", bg = "#22252A" },

		CmpItemAbbrDeprecated = { fg = "#7E8294", bg = "NONE" },
		CmpItemAbbrMatch = { fg = "#82AAFF", bg = "NONE" },
		CmpItemAbbrMatchFuzzy = { fg = "#82AAFF", bg = "NONE" },
		CmpItemMenu = { fg = "#e6e6e6", bg = "NONE" },

		CmpItemKindField = { fg = "#b34dc4" },
		CmpItemKindProperty = { fg = "#b34dc4" },
		CmpItemKindEvent = { fg = "#b34dc4" },

		CmpItemKindText = { fg = "#cccccc" },
		CmpItemKindEnum = { fg = "#ffffff" },
		CmpItemKindKeyword = { fg = "#ffffff" },

		CmpItemKindConstant = { fg = "#80b34d" },
		CmpItemKindConstructor = { fg = "#80b34d" },
		CmpItemKindReference = { fg = "#80b34d" },

		CmpItemKindFunction = { fg = "#ff5f5d" },
		CmpItemKindStruct = { fg = "#ff5f5d" },
		CmpItemKindClass = { fg = "#ff5f5d" },
		CmpItemKindModule = { fg = "#ff5f5d" },
		CmpItemKindOperator = { fg = "#ff5f5d" },

		CmpItemKindVariable = { fg = "#7E8294" },
		CmpItemKindFile = { fg = "#7E8294" },

		CmpItemKindUnit = { fg = "#ffff00" },
		CmpItemKindSnippet = { fg = "#ffff00" },
		CmpItemKindFolder = { fg = "#ffff00" },

		CmpItemKindMethod = { fg = "#6C8ED4" },
		CmpItemKindValue = { fg = "#6C8ED4" },
		CmpItemKindEnumMember = { fg = "#6C8ED4" },

		CmpItemKindInterface = { fg = "#58B5A8" },
		CmpItemKindColor = { fg = "#58B5A8" },
		CmpItemKindTypeParameter = { fg = "#58B5A8" },
	}, -- Override default highlight groups or create your own
	styles = { -- For example, to apply bold and italic, use "bold,italic"
		types = "italic", -- Style that is applied to types
		methods = "NONE", -- Style that is applied to methods
		numbers = "NONE", -- Style that is applied to numbers
		strings = "NONE", -- Style that is applied to strings
		comments = "italic", -- Style that is applied to comments
		keywords = "bold", -- Style that is applied to keywords
		constants = "italic", -- Style that is applied to constants
		functions = "bold", -- Style that is applied to functions
		operators = "NONE", -- Style that is applied to operators
		variables = "NONE", -- Style that is applied to variables
		parameters = "NONE", -- Style that is applied to parameters
		conditionals = "NONE", -- Style that is applied to conditionals
		virtual_text = "italic", -- Style that is applied to virtual text
	},
	options = {
		cursorline = false, -- Use cursorline highlighting?
		transparency = false, -- Use a transparent background?
		terminal_colors = true, -- Use the theme's colors for Neovim's :terminal?
		highlight_inactive_windows = false, -- When the window is out of focus, change the normal background?
	},
})
