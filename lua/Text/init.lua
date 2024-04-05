local M = {}
M = {
	-- "Text.leap",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error in calling Text: " .. err)
	end
end
