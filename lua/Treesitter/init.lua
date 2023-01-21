local M = {
	"Treesitter.ts",
	"Treesitter.spellsitter",
	"Treesitter.ts_context",
	"Treesitter.playground",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Err in calling TreeSitter: ", err)
	end
end
