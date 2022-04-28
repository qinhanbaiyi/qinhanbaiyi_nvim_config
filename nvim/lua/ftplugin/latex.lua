local cmp = require("cmp")
------修复2021年10月12日 nvim-cmp.luaattempt to index field 'menu' (a nil value)---------
--重写插件方法,为了实现function 后,自动追加()
local keymap = require("cmp.utils.keymap")
cmp.confirm = function(option)
	option = option or {}
	local e = cmp.core.view:get_selected_entry() or (option.select and cmp.core.view:get_first_entry() or nil)
	if e then
		cmp.core:confirm(e, {
			behavior = option.behavior,
		}, function()
			local myContext = cmp.core:get_context({ reason = cmp.ContextReason.TriggerOnly })
			cmp.core:complete(myContext)
			--function() 自动增加{}
			if
				e
				and e.resolved_completion_item
				and (e.resolved_completion_item.kind == 3 or e.resolved_completion_item.kind == 2)
			then
				vim.api.nvim_feedkeys(keymap.t("{}<Left>"), "n", true)
			end
		end)
		return true
	else
		if vim.fn.complete_info({ "selected" }).selected ~= -1 then
			keymap.feedkeys(keymap.t("<C-y>"), "n")
			return true
		end
		return false
	end
end

-------------------------------------------------------------------------------
--------------------------------- SETTING -------------------------------------
-------------------------------------------------------------------------------

cmp.setup({
	mapping = {
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = false,
		}),
	},
})
