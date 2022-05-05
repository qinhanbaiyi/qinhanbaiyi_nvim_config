--                 /\ \                     /\  _`\           __
--                 \ \ \      __  __     __ \ \,\L\_\    ___ /\_\  _____
--                  \ \ \  __/\ \/\ \  /'__`\\/_\__ \  /' _ `\/\ \/\ '__`\
--                   \ \ \L\ \ \ \_\ \/\ \L\.\_/\ \L\ \/\ \/\ \ \ \ \ \L\ \
--                    \ \____/\ \____/\ \__/.\_\ `\____\ \_\ \_\ \_\ \ ,__/
--                     \/___/  \/___/  \/__/\/_/\/_____/\/_/\/_/\/_/\ \ \/
--                                                                   \ \_\
--                                                                    \/_/
local function muiltmod(modtabel)
	for _, mod in ipairs(modtabel) do
		local ok, err = pcall(require, mod)
		if not ok then
			print("Error while call luasnip: ", err)
		end
	end
end
local M = {
	"Snippets.appearence",
	"Snippets.config",
	"Snippets.keymap",
}
muiltmod(M)
