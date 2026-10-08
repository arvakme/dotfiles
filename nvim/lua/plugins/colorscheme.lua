return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = function()
				require("config.appearance").apply()
			end,
		},
	},
	-- Butler 是本地 colors/butler.lua，不需要插件；下面只是关掉 LazyVim 自带的默认主题。
	{ "folke/tokyonight.nvim", enabled = false },
	{ "catppuccin/nvim", name = "catppuccin", enabled = false },
}
