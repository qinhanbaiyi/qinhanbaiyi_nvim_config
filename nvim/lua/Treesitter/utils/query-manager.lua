local class = require("plenary.class")
local ts = vim.treesitter

local M = class()

-- M:new
-- @param { string } language
function M:_init(language)
	self.language = language
end

-- @param { string } name
-- @param { string } query
function M:add_query(name, query)
	ts.set_query(self.language, name, query)
end

-- @param { string } name
-- @param { number } buffer
function M:get_matches_iter(name, buffer)
	buffer = buffer or 0
	local root = ts.get_parser(buffer, self.language):parse()[1]:root()
	local query = ts.get_query(name, self.language)

	return query:iter_matches(root, buffer)
end
