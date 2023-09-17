local exe_resolve = function(name)
	if vim.fn.exepath(name) then
		return name
	end
end

require("lspconfig").jsonls.setup(require("utils.lua").make_default_opts({
	cmd = { exe_resolve("vscode-json-languageserver") or "vscode-json-language-server", "--stdio" },
}))
