-- 片段模板共用的缩进和多行字符串处理。
local M = {}

-- 生成明确数量的空格，供模板控制缩进；不依赖当前缓冲区的 tabstop。
function M.get_space_str(number_of_spaces)
	return string.format("%%-%ds", number_of_spaces):format("")
end

-- 按换行遍历文本；补上末尾换行，让没有终止换行的最后一行也能被读取。
function M.get_line_iter(str)
	if str:sub(-1) ~= "\n" then
		str = str .. "\n"
	end

	return str:gmatch("(.-)\n")
end

-- 清除模板每一行两侧的空白，并保留现有的起始换行约定。
-- 这会移除原有相对缩进，所需缩进由模板的文本节点显式补入。
function M.box_trim_lines(str)
	local new_str = ""

	for line in M.get_line_iter(str) do
		line = line:gsub("^%s+", "")
		line = string.gsub(line, "%s+$", "")
		new_str = new_str .. "\n" .. line
	end

	return new_str
end

return M
