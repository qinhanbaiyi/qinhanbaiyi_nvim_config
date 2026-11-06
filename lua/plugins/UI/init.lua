local highlight_opts = {
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
}
return {
	-- UI
	-- Color scheme
	{
		"olimorris/onedarkpro.nvim",
		opts = highlight_opts,
		config = function()
			vim.api.nvim_command("colorscheme onedark")
		end,
	},
	{
		"marko-cerovac/material.nvim",
		init = function()
			vim.g.material_style = "Palenight"
		end,
		opts = highlight_opts,
		config = false,
	},
	-- {
	-- 	"projekt0n/github-nvim-theme",
	-- 	opts = {
	-- 		theme_style = "dark",
	-- 		function_style = "italic",
	-- 		sidebars = { "qf", "vista_kind", "terminal", "packer" },
	--
	-- 		-- Change the "hint" color to the "orange" color, and make the "error" color bright red
	-- 		colors = { hint = "orange", error = "#ff0000" },
	--
	-- 		-- Overwrite the highlight groups
	-- 		overrides = function(c)
	-- 			return {
	-- 				htmlTag = { fg = c.red, bg = "#282c34", sp = c.hint, style = "underline" },
	-- 				DiagnosticHint = { link = "LspDiagnosticsDefaultHint" },
	-- 				-- this will remove the highlight groups
	-- 				TSField = {},
	-- 			}
	-- 		end,
	-- 	},
	-- 	config = false,
	-- },

	-- Fancier statusline
	{
		"nvim-lualine/lualine.nvim",
		event = "VimEnter",
		opts = {
			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {},
				always_divide_middle = true,
				globalstatus = false,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename" },
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = {},
		},
		config = true,
	},

	-- Add indentation guides even on blank lines
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = "VimEnter",
		init = function()
			vim.opt.list = true
			vim.opt.listchars:append("eol:↴")
		end,
		---@module "ibl"
		---@type ibl.config
		opts = {},
	},

	-- barbar plugin, which makes tags upper windows
	{
		"romgrk/barbar.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
			"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		event = "VimEnter",
		opts = {
			-- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
			-- animation = true,
			-- insert_at_start = true,
			-- …etc.
		},
		version = "^1.0.0", -- optional: only update when a new 1.x version is released
		keys = {},
	},
}
