--Lua:
-- vim.g.material_style = "deep ocean"
vim.g.material_style = "Palenight"
-- vim.g.material_style = "Darker"
-- vim.g.material_style = "Oceanic"

require("material").setup({
	contrast = {
		terminal = false, -- Enable contrast for the built-in terminal
		sidebars = false, -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
		floating_windows = false, -- Enable contrast for floating windows
		cursor_line = false, -- Enable darker background for the cursor line
		non_current_windows = false, -- Enable darker background for non-current windows
		filetypes = {}, -- Specify which filetypes get the contrasted (darker) background
	},

	styles = { -- Give comments style such as bold, italic, underline etc.
		comments = { italic = true },
		strings = { --[[ bold = true ]]
		},
		keywords = { --[[ underline = true ]]
		},
		functions = { --[[ bold = true, undercurl = true ]]
		},
		variables = {},
		operators = {},
		types = {},
	},

	plugins = { -- Uncomment the plugins that you use to highlight them
		-- Available plugins:
		-- "dap",
		-- "dashboard",
		"gitsigns",
		-- "hop",
		-- "indent-blankline",
		"lspsaga",
		-- "mini",
		-- "neogit",
		-- "neorg",
		"nvim-cmp",
		-- "nvim-navic",
		-- "nvim-tree",
		-- "nvim-web-devicons",
		-- "sneak",
		-- "telescope",
		-- "trouble",
		-- "which-key",
	},

	disable = {
		colored_cursor = false, -- Disable the colored cursor
		borders = false, -- Disable borders between verticaly split windows
		background = false, -- Prevent the theme from setting the background (NeoVim then uses your terminal background)
		term_colors = false, -- Prevent the theme from setting terminal colors
		eob_lines = false, -- Hide the end-of-buffer lines
	},

	high_visibility = {
		lighter = false, -- Enable higher contrast text for lighter style
		darker = false, -- Enable higher contrast text for darker style
	},

	lualine_style = "default", -- Lualine style ( can be 'stealth' or 'default' )

	async_loading = true, -- Load parts of the theme asyncronously for faster startup (turned on by default)

	custom_colors = nil, -- If you want to everride the default colors, set this to a function

	custom_highlights = {
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
	}, -- Overwrite highlights with your own
})
