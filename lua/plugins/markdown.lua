return {

	-- Markdown
	{
		"ellisonleao/glow.nvim",
		ft = "markdown",
		config = function()
			require("glow").setup({ glow_path = "/home/user/go/bin/glow" })
		end,
	},
}
