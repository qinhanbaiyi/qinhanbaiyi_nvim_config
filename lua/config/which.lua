-- 这里只描述菜单分组。实际快捷键跟随对应插件或 config/keymaps.lua。
return {
	mode = { "n", "v" },
	{ "[", group = "prev" },
	{ "]", group = "next" },
	{ "<leader><leader>", group = "Windows Movement", remap = false },
	{ "g", group = "goto" },
	{ "<leader>c", group = "Code" },
	{ "<leader>g", group = "Git" },
	{ "<leader>gh", group = "Hunks" },
	{ "<leader>s", group = "Search" },
	{ "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
	{ "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
	{ "<leader>d", group = "Debug" },
	{ "<leader>f", group = "File / Find" },
	{ "<leader>m", group = "Markdown", remap = false },
	{ "<leader>v", group = "Symbols", remap = false },
}
