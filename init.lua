local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
vim.api.nvim_create_autocmd("VimEnter", { command = "clearjumps" })

vim.opt.number = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 4
vim.opt.signcolumn = "yes"
vim.opt.ignorecase = true
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = " "
vim.o.background = "dark"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

local plugins = {
	{ "neovim/nvim-lspconfig" },
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{
		"ellisonleao/gruvbox.nvim",
		config = function()
			vim.cmd([[colorscheme gruvbox]])
		end,
	},
	"nvim-lua/plenary.nvim",
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			defaults = {
				file_ignore_patterns = {
					"node_modules/",
					"obj/",
					"bin/",
					"target/",
					".git/",
					"dist/",
					"xmljs",
				},
				mappings = {
					i = {
						["<esc>"] = "close",
					},
				},
			},
		},
	},
	"nvim-treesitter/nvim-treesitter",
	{ "nvim-lualine/lualine.nvim", opts = { extensions = { "nvim-tree" } } },
	"numToStr/Comment.nvim",
	{ "windwp/nvim-autopairs", opts = {} },
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { { "prettier" } },
				typescript = { { "prettier" } },
				json = { { "prettier" } },
			},
		},
		keys = {
			{
				"<leader>am",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({
				filters = {
					dotfiles = false,
					exclude = { vim.fn.stdpath("config") .. "/lua/custom", "node_modules" },
				},
				disable_netrw = true,
				hijack_netrw = true,
				hijack_cursor = true,
				hijack_unnamed_buffer_when_opening = false,
				sync_root_with_cwd = true,
				update_focused_file = {
					enable = true,
					update_root = false,
				},
				view = {
					adaptive_size = false,
					side = "left",
					width = 30,
					preserve_window_proportions = true,
				},
				git = {
					enable = false,
					ignore = true,
				},
				filesystem_watchers = {
					enable = true,
				},
				actions = {
					open_file = {
						resize_window = true,
					},
				},
				renderer = {
					root_folder_label = false,
					highlight_git = false,
					highlight_opened_files = "none",

					indent_markers = {
						enable = false,
					},
				},
			})
		end,
	},
	{
		"numToStr/FTerm.nvim",
		config = function()
			require("FTerm").setup({
				dimensions = {
					height = 0.9,
					width = 0.9,
				},
			})
		end,
	},
}

require("lazy").setup(plugins)
require("Comment").setup()

require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "lua", "vim", "rust", "typescript", "json", "prisma", "javascript", "tsx" },
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>f", builtin.find_files, {})
vim.keymap.set("n", "<leader>F", "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", {})
vim.keymap.set("n", "<leader>g", builtin.live_grep, {})
vim.keymap.set("n", "<leader>b", builtin.buffers, {})
vim.keymap.set("n", "<leader>h", builtin.help_tags, {})
vim.keymap.set("n", "<leader>q", builtin.diagnostics, {})
vim.keymap.set("n", "<leader>p", builtin.resume, {})
vim.keymap.set("n", "<leader>s", builtin.lsp_document_symbols, {})
vim.keymap.set("n", "<C-h>", "<C-w>h", {})
vim.keymap.set("n", "<C-l>", "<C-w>l", {})
vim.keymap.set("n", "<C-k>", "<C-w>k", {})
vim.keymap.set("n", "<C-j>", "<C-w>j", {})
vim.keymap.set("n", "<C-d>", "<C-d>zz", {})
vim.keymap.set("n", "<C-u>", "<C-u>zz", {})
vim.keymap.set("n", "<A-i>", '<CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set("t", "<A-i>", '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set("n", "<ESC>", ":noh<cr>")
vim.keymap.set("n", "<leader>/", '<CMD>lua require("Comment.api").toggle.linewise.current()<CR>')
vim.keymap.set("v", "<leader>/", '<ESC><cmd>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>')
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-c>", "<cmd> %y+ <CR>", { silent = true, noremap = true })
vim.keymap.set("v", "p", '"_dP')

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local servers = { "tsserver", "rust_analyzer", "eslint", "lua_ls", "jsonls", "prismals" }
for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = function(client)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false

			if client.supports_method("textDocument/semanticTokens") then
				client.server_capabilities.semanticTokensProvider = nil
			end
		end,
		capabilities = capabilities,
		handlers = {
			["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
				virtual_text = false,
				underline = false,
				signs = true,
			}),
		},
	})
end

lspconfig.prismals.setup({
	on_attach = function(client)
		-- client.server_capabilities.documentFormattingProvider = false
		-- client.server_capabilities.documentRangeFormattingProvider = false

		if client.supports_method("textDocument/semanticTokens") then
			client.server_capabilities.semanticTokensProvider = nil
		end
	end,
	capabilities = capabilities,
	handlers = {
		["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
			virtual_text = false,
			underline = false,
			signs = true,
		}),
	},
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", "<cmd>lua require('telescope.builtin').lsp_references()<cr>", opts)
		vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
	end,
})

local cmp = require("cmp")
cmp.setup({
	completion = {
		autocomplete = false,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
		["<C-d>"] = cmp.mapping.scroll_docs(4), -- Down
		-- C-b (back) C-f (forward) for snippet placeholder navigation.
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp" },
	},
})
