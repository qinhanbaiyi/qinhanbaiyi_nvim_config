local filetypes = { "all", "r", "lua", "tex", "python", "rust", "markdown", "go" }

local function load_snippets(ls)
	local snippets = {}
	for _, filetype in ipairs(filetypes) do
		snippets[filetype] = require("plugins.Snippets.snippets." .. filetype)
	end
	for _, filetype in ipairs(filetypes) do
		ls.add_snippets(filetype, snippets[filetype], { key = filetype })
	end
end

local function reload_snippets()
	for module in pairs(package.loaded) do
		if type(module) == "string" and vim.startswith(module, "plugins.Snippets.") then
			package.loaded[module] = nil
		end
	end
	local ls = require("luasnip")
	local ok, err = pcall(load_snippets, ls)
	if ok then
		ls.clean_invalidated()
		vim.notify("LuaSnip snippets reloaded")
	else
		vim.notify(err, vim.log.levels.ERROR)
	end
end

return {
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		event = "InsertEnter",
		keys = {
			{ "<leader><leader>s", reload_snippets, desc = "Reload LuaSnip snippets" },
		},
		config = function()
			local ls = require("luasnip")
			local types = require("luasnip.util.types")
			ls.config.set_config({
				history = true,
				updateevents = "TextChanged,TextChangedI",
				enable_autosnippets = true,
				ext_opts = { [types.choiceNode] = { active = { virt_text = { { "●", "GruvboxOrange" } } } } },
			})
			load_snippets(ls)

			-- Keep the editor's cursor motions when there is no active snippet to navigate.
			vim.keymap.set({ "i", "s" }, "<C-k>", function()
				if ls.expand_or_jumpable() then
					ls.expand_or_jump()
				elseif vim.fn.mode() == "i" then
					vim.api.nvim_feedkeys(vim.keycode("<Up>"), "n", false)
				end
			end, { silent = true, desc = "Expand snippet, jump forward or move up" })

			vim.keymap.set({ "i", "s" }, "<C-j>", function()
				if ls.jumpable(-1) then
					ls.jump(-1)
				elseif vim.fn.mode() == "i" then
					vim.api.nvim_feedkeys(vim.keycode("<Down>"), "n", false)
				end
			end, { silent = true, desc = "Jump back in snippet or move down" })

			vim.keymap.set({ "i", "s" }, "<C-l>", function()
				if ls.choice_active() then
					ls.change_choice(1)
				else
					vim.api.nvim_feedkeys(vim.keycode("<Right>"), "n", false)
				end
			end, { silent = true, desc = "Cycle snippet choice or move right" })

			vim.keymap.set("i", "<C-u>", require("luasnip.extras.select_choice"), {
				silent = true,
				desc = "Select snippet choice",
			})
		end,
	},
}
