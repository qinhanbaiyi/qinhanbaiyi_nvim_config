local snacks = require("snacks")
local M = {}
---Add two values.
---@param first number
---@param second number
---@return number
function M.add(first, second)
	return first + second
end
local total = M.add(1, 2)
print(total)
local unused = 123
return M
