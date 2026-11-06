-- Flash 的语法树搜索使用可视/操作符模式 R，选择模式 R 留给 SnipRun。
return {
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {},
	  -- stylua: ignore
	  keys = {
	    { "<leader>j", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
	    { "<leader>J", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
	    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
	    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
	    { "<leader>tf", mode = { "n" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
	  },
	},
}
