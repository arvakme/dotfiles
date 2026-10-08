-- lualine theme for the Butler colorscheme; picks the palette from vim.o.background at load.
local p = require("butler.palette")[vim.o.background == "dark" and "dark" or "light"]

local function mode(accent)
	return {
		a = { fg = p.on_accent, bg = accent, gui = "bold" },
		b = { fg = p.ice, bg = p.panel },
		c = { fg = p.muted, bg = "NONE" },
	}
end

return {
	normal = mode(p.cyan),
	insert = mode(p.mint),
	visual = mode(p.lavender),
	replace = mode(p.coral),
	command = mode(p.amber),
	terminal = mode(p.sky),
	inactive = {
		a = { fg = p.muted, bg = p.deep },
		b = { fg = p.dim, bg = "NONE" },
		c = { fg = p.dim, bg = "NONE" },
	},
}
