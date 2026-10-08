return {
	-- 解析器的安装、高亮、缩进、折叠都交给 LazyVim 的 treesitter 配置（它需要 tree-sitter 命令行：brew install tree-sitter-cli）；
	-- 这里只补充要装的解析器和 MDX 的文件类型。旧的 playground / query_linter 是 master 分支的功能，新分支用 :InspectTree。
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"astro",
				"cmake",
				"cpp",
				"css",
				"fish",
				"gitignore",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"graphql",
				"http",
				"java",
				"php",
				"rust",
				"scss",
				"sql",
				"svelte",
			},
		},
		init = function()
			vim.filetype.add({ extension = { mdx = "mdx" } })
			vim.treesitter.language.register("markdown", "mdx")
		end,
	},
}
