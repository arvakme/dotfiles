-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	command = "set nopaste",
})

-- Pick up `theme light|dark` written by ~/.config/theme/switch
vim.api.nvim_create_autocmd({ "FocusGained", "VimEnter" }, {
	callback = function()
		pcall(function()
			require("config.appearance").sync_if_changed()
		end)
	end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "butler",
	callback = function()
		pcall(function()
			require("config.appearance").chrome()
		end)
	end,
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json", "jsonc", "markdown" },
	callback = function()
		vim.opt.conceallevel = 0
	end,
})
