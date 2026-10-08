-- Overrides for the LazyVim `lang.java` extra.
-- jdtls itself requires Java 21+ to RUN, but this project compiles with Java 17,
-- so we point jdtls's JVM to mise-installed JDK 21 while telling it to use
-- JDK 17 as the project runtime.

local jdk21_java = vim.fn.expand("~/.local/share/mise/installs/java/21.0.2/bin/java")
local jdk17_home = vim.fn.expand("~/.local/share/mise/installs/java/17.0.2")

return {
	{
		"mfussenegger/nvim-jdtls",
		opts = function(_, opts)
			-- 1) Make jdtls's launcher use JDK 21 explicitly, ignoring JAVA_HOME.
			opts.cmd = opts.cmd or { vim.fn.exepath("jdtls") }
			vim.list_extend(opts.cmd, { "--java-executable", jdk21_java })

			-- 2) Tell jdtls the project compiles against JDK 17.
			opts.jdtls = opts.jdtls or {}
			opts.jdtls.settings = vim.tbl_deep_extend("force", opts.jdtls.settings or {}, {
				java = {
					configuration = {
						runtimes = {
							{
								name = "JavaSE-17",
								path = jdk17_home,
								default = true,
							},
						},
					},
				},
			})

			return opts
		end,
	},
}
