return {
	-- color display and change
	{
		"uga-rosa/ccc.nvim",
		events = "VeryLazy",
		config = function()
			require("ccc").setup()
		end,
	},
}
