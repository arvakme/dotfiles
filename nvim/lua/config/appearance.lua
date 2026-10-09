local M = {}

-- 明暗判断不在这里做。~/.config/theme/mode 是唯一入口（读全局的 theme/current）。这里只负责问它、缓存答案。
local mode_script = vim.fn.expand("~/.config/theme/mode")
local applied

-- 一次 apply() 会调 read_mode() 几次，不缓存就是几个 fork，切窗口能感觉到顿挫。
-- 100ms 足够把一次 apply 收敛成一次 fork，又短到不会让 FocusGained 读到隔夜的值。
local cached, cached_at = nil, 0
local CACHE_MS = 100

local function read_mode()
	local now = vim.uv.now()
	if cached and now - cached_at < CACHE_MS then
		return cached
	end
	local out = vim.trim(vim.fn.system({ mode_script }))
	cached = out == "dark" and "dark" or "light"
	cached_at = now
	return cached
end

function M.mode()
	return read_mode()
end

local function palette()
	return require("butler.palette")[read_mode()]
end

function M.bufferline_highlights()
	local p = palette()
	-- bufferline 默认以 default=true 写高亮，已存在的组不会被覆盖，明暗切换就卡在首次的颜色上
	local hls = {
		fill = { bg = "NONE" },
		background = { fg = p.muted, bg = "NONE" },
		buffer = { fg = p.muted, bg = "NONE" },
		buffer_selected = { fg = p.ice, bg = p.panel, bold = true, italic = false },
		tab = { fg = p.muted, bg = "NONE" },
		tab_selected = { fg = p.ice, bg = p.panel, bold = true },
		separator = { fg = p.deep, bg = "NONE" },
		separator_selected = { fg = p.panel, bg = p.panel },
		tab_separator = { fg = p.deep, bg = "NONE" },
		tab_separator_selected = { fg = p.panel, bg = p.panel },
		indicator_selected = { fg = p.cyan, bg = p.panel },
		modified = { fg = p.amber, bg = "NONE" },
		modified_selected = { fg = p.amber, bg = p.panel },
	}
	for _, hl in pairs(hls) do
		hl.default = false
	end
	return hls
end

function M.chrome()
	local p = palette()
	vim.api.nvim_set_hl(0, "InclineNormal", { bg = p.fill, fg = p.on_fill, bold = true })
	vim.api.nvim_set_hl(0, "InclineNormalNC", { bg = p.panel, fg = p.muted })
	vim.api.nvim_set_hl(0, "OilBorder", { fg = p.cyan, bg = "NONE" })
	-- 只重配已加载的插件。colorscheme 在 LazyVim setup 早期就会跑，这时 require 会把
	-- lualine 提前拉起来，而它的 opts 依赖尚未初始化的 Snacks 全局，会在 lazy 里报错。
	-- 首次加载时插件自己的 opts 已经指定 theme = "butler"，无需这里代劳。
	if package.loaded["lualine"] then
		local lualine = require("lualine")
		local cfg = lualine.get_config()
		-- 主题模块按当前 background 取色，切换后要把缓存的模块丢掉重新求值
		package.loaded["lualine.themes.butler"] = nil
		cfg.options.theme = "butler"
		lualine.setup(cfg)
	end
	if package.loaded["bufferline"] then
		require("bufferline").setup({
			options = {
				mode = "tabs",
				separator_style = "slant",
				indicator = { style = "underline" },
				show_buffer_close_icons = false,
				show_close_icon = false,
			},
			highlights = M.bufferline_highlights(),
		})
	end
end

function M.apply(mode)
	mode = mode or read_mode()
	applied = mode
	vim.o.background = mode
	vim.cmd.colorscheme("butler")
	M.chrome()
end

function M.sync_if_changed()
	cached = nil -- 这个函数的全部意义就是查有没有变，不能吃缓存
	local want = read_mode()
	if want ~= applied then
		M.apply(want)
	end
end

-- 全局切换，交给 switch 去扇出（tmux / 壁纸 / Rime / 系统外观）。这里不自己算
-- 下一个模式、也不乐观地 apply：切完再问一次 mode。
function M.toggle()
	vim.fn.jobstart({ vim.fn.expand("~/.config/theme/switch"), "toggle" }, {
		on_exit = function()
			vim.schedule(M.sync_if_changed)
		end,
	})
end

return M
