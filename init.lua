-- Bootstrap lazy.nvim plugin manager
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

-- Basic VSCode-like settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = false -- VSCode doesn't use relative numbers by default
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.cursorline = true

-- Python provider (for full Python support)
vim.g.python3_host_prog = vim.fn.exepath("python3")

-- Plugin specifications
require("lazy").setup({
	-- VSCode theme
	{
		"Mofiqul/vscode.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("vscode").setup({
				transparent = false,
				italic_comments = true,
				disable_nvimtree_bg = true,
			})
			vim.cmd([[colorscheme vscode]])
		end,
	},

	-- VSCode-like icons
	{
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup()
		end,
	},

	-- Treesitter for better syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"python",
					"javascript",
					"typescript",
					"go",
					"rust",
					"bash",
					"json",
					"html",
					"css",
				},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	{
		"rcarriga/nvim-notify",
		config = function()
			vim.notify = require("notify")
		end,
	},

	-- Telescope for fuzzy finding (like VSCode Ctrl+P)
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			-- VSCode Ctrl+P / Cmd+P - Quick Open
			vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
			vim.keymap.set("n", "<D-p>", builtin.find_files, { desc = "Find files" })

			-- VSCode Ctrl+Shift+F / Cmd+Shift+F - Search in files
			vim.keymap.set("n", "<C-S-f>", builtin.live_grep, { desc = "Search in files" })
			vim.keymap.set("n", "<D-S-f>", builtin.live_grep, { desc = "Search in files" })

			-- VSCode Ctrl+Shift+O / Cmd+Shift+O - Go to symbol
			vim.keymap.set("n", "<C-S-o>", builtin.lsp_document_symbols, { desc = "Go to symbol" })
			vim.keymap.set("n", "<D-S-o>", builtin.lsp_document_symbols, { desc = "Go to symbol" })
		end,
	},

	-- LSP configuration
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "pyright", "ts_ls" },
			})

			local lspconfig = require("lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()

			-- Setup LSP servers
			lspconfig.lua_ls.setup({ capabilities = capabilities })
			lspconfig.pyright.setup({ capabilities = capabilities })
			lspconfig.ts_ls.setup({ capabilities = capabilities })

			-- VSCode-like LSP keymaps
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
			vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
			vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
			vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })

			-- VSCode F2 - Rename
			vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename" })

			-- VSCode Shift+Alt+F / Shift+Option+F - Format document
			vim.keymap.set("n", "<S-A-f>", vim.lsp.buf.format, { desc = "Format document" })
			vim.keymap.set("n", "<S-D-f>", vim.lsp.buf.format, { desc = "Format document" })
		end,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},

	-- File explorer (like VSCode sidebar)
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				view = {
					width = 35,
					side = "left",
				},
				renderer = {
					icons = {
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
							git = true,
						},
					},
				},
			})
			-- VSCode Ctrl+B / Cmd+B - Toggle sidebar
			vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>", { desc = "Toggle sidebar", silent = true })
			vim.keymap.set("n", "<D-b>", ":NvimTreeToggle<CR>", { desc = "Toggle sidebar", silent = true })
		end,
	},

	-- Status line (like VSCode bottom bar)
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "vscode",
					section_separators = "",
					component_separators = "|",
				},
			})
		end,
	},

	-- Buffer line (tabs like VSCode)
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",
					style_preset = require("bufferline").style_preset.default,
					themable = true,
					numbers = "none",
					close_command = "bdelete! %d",
					diagnostics = "nvim_lsp",
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							text_align = "center",
							separator = true,
						},
					},
					separator_style = "thin",
				},
			})

			-- VSCode tab navigation
			-- Cmd+Shift+[ / Cmd+Shift+] - Previous/Next tab
			vim.keymap.set("n", "<D-S-[>", ":BufferLineCyclePrev<CR>", { desc = "Previous tab", silent = true })
			vim.keymap.set("n", "<D-S-]>", ":BufferLineCycleNext<CR>", { desc = "Next tab", silent = true })
			-- Ctrl+Tab / Ctrl+Shift+Tab alternative
			vim.keymap.set("n", "<C-Tab>", ":BufferLineCycleNext<CR>", { desc = "Next tab", silent = true })
			vim.keymap.set("n", "<C-S-Tab>", ":BufferLineCyclePrev<CR>", { desc = "Previous tab", silent = true })
			-- Cmd+W - Close tab
			vim.keymap.set("n", "<D-w>", ":bdelete<CR>", { desc = "Close tab", silent = true })
			vim.keymap.set("n", "<C-w>", ":bdelete<CR>", { desc = "Close tab", silent = true })
		end,
	},

	-- OLLAMA AI Integration (gen.nvim)
	{
		"David-Kunz/gen.nvim",
		config = function()
			require("gen").setup({
				model = "gemma3:4b",
				host = "localhost",
				port = "11434",
				quit_map = "q",
				retry_map = "<c-r>",
				init = function(options)
					pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
				end,
				command = function(options)
					local body = { model = options.model, stream = true }
					return "curl --silent --no-buffer -X POST http://"
						.. options.host
						.. ":"
						.. options.port
						.. "/api/chat -d $body"
				end,
				display_mode = "float",
				show_prompt = true,
				show_model = true,
				no_auto_close = false,
				debug = false,
			})

			-- AI keymaps (VSCode-like)
			vim.keymap.set({ "n", "v" }, "<C-S-i>", ":Gen<CR>", { desc = "Open AI menu" })
			vim.keymap.set("v", "<C-S-g>", ":Gen<CR>", { desc = "Generate code" })
			vim.keymap.set("v", "<C-S-c>", ":Gen Chat<CR>", { desc = "Chat with AI" })
			vim.keymap.set("v", "<C-S-e>", ":Gen Enhance_Code<CR>", { desc = "Enhance code" })
			vim.keymap.set("v", "<C-S-r>", ":Gen Review_Code<CR>", { desc = "Review code" })
		end,
	},

	-- Alternative: ollama.nvim
	{
		"nomnivore/ollama.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },
		keys = {
			{
				"<C-S-a>",
				":<c-u>lua require('ollama').prompt()<cr>",
				desc = "Ollama prompt",
				mode = { "n", "v" },
			},
		},
		opts = {
			model = "gemma3:4b",
			url = "http://127.0.0.1:11434",
			serve = {
				on_start = false,
				command = "ollama",
				args = { "serve" },
				stop_command = "pkill",
				stop_args = { "-SIGTERM", "ollama" },
			},
		},
	},

	-- Simple OLLAMA completion plugin
	{
		"huggingface/llm.nvim",
		config = function()
			require("llm").setup({
				backend = "ollama",
				model = "gemma3:4b",
				url = "http://localhost:11434",
				request_body = {
					options = {
						temperature = 0.7,
						top_p = 0.9,
					},
				},
				context_window = 32000, -- max number of tokens for the context window
				enable_suggestions_on_startup = true,
				enable_suggestions_on_files = "*", -- pattern matching syntax to enable suggestions on specific files, either a string or a list of strings
				disable_url_path_completion = false, -- cf Backend
				debounce_ms = 150,
				tokens_to_clear = { "<|endoftext|>" }, -- tokens to remove from the model's output

				-- set this if the model supports fill in the middle
				fim = {
					enabled = true,
					prefix = "<fim_prefix>",
					middle = "<fim_middle>",
					suffix = "<fim_suffix>",
				},
				stream = true,
				lsp = {
					bin_path = vim.api.nvim_call_function("stdpath", { "data" }) .. "/mason/bin/llm-ls",
				},

				prompt = {
					completion = "[[Continue ONLY what should come next at the cursor. Do NOT rewrite the entire file. Do NOT re-create imports, function signatures, or previous code. Do NOT output comments or explanations unless asked. Produce only the minimal raw code needed. Never output markdown or code fences.]]",
				},

				-- 🔥 Strip markdown and extra indentation
				strip_markdown = true,
				dedent = true,

				-- 🔥 Enable <Tab> to accept inline suggestion
				accept_keymap = "<Tab>",
			})

			vim.keymap.set("i", "<Tab>", function()
				local llm = require("llm.completion")
				if llm.has_suggestion() then
					llm.accept_suggestion()
				else
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
				end
			end)
		end,
	},

	-- Git integration (like VSCode Git)
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
			})
		end,
	},

	-- Comment plugin (VSCode Cmd+/ or Ctrl+/)
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},

	-- Auto pairs
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},

	-- Indent guides (like VSCode)
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = function()
			require("ibl").setup()
		end,
	},

	-- Which-key for keybinding hints (like VSCode command palette)
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup()
		end,
	},

	-- Terminal (like VSCode integrated terminal)
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 15,
				open_mapping = [[<C-`>]], -- VSCode Ctrl+` toggle terminal
				hide_numbers = true,
				shade_terminals = true,
				direction = "horizontal",
				close_on_exit = true,
			})
			-- Cmd+` as alternative
			vim.keymap.set("n", "<D-`>", ":ToggleTerm<CR>", { desc = "Toggle terminal", silent = true })
		end,
	},
})

-- VSCode-like keybindings

-- File operations
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save file", silent = true })
vim.keymap.set("n", "<D-s>", ":w<CR>", { desc = "Save file", silent = true })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save file", silent = true })
vim.keymap.set("i", "<D-s>", "<Esc>:w<CR>a", { desc = "Save file", silent = true })

-- Quit
vim.keymap.set("n", "<C-q>", ":qa<CR>", { desc = "Quit all", silent = true })
vim.keymap.set("n", "<D-q>", ":qa<CR>", { desc = "Quit all", silent = true })

-- VSCode Ctrl+/ or Cmd+/ - Toggle comment
vim.keymap.set("n", "<C-_>", "gcc", { desc = "Toggle comment", remap = true })
vim.keymap.set("n", "<D-_>", "gcc", { desc = "Toggle comment", remap = true })
vim.keymap.set("v", "<C-_>", "gc", { desc = "Toggle comment", remap = true })
vim.keymap.set("v", "<D-_>", "gc", { desc = "Toggle comment", remap = true })

-- Undo/Redo like VSCode
vim.keymap.set("n", "<C-z>", "u", { desc = "Undo" })
vim.keymap.set("n", "<D-z>", "u", { desc = "Undo" })
vim.keymap.set("n", "<C-S-z>", "<C-r>", { desc = "Redo" })
vim.keymap.set("n", "<D-S-z>", "<C-r>", { desc = "Redo" })

-- Select all
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })
vim.keymap.set("n", "<D-a>", "ggVG", { desc = "Select all" })

-- Copy/Paste (already handled by clipboard setting)
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy" })
vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy" })
vim.keymap.set("n", "<C-v>", '"+p', { desc = "Paste" })
vim.keymap.set("n", "<D-v>", '"+p', { desc = "Paste" })
vim.keymap.set("i", "<C-v>", "<C-r>+", { desc = "Paste" })
vim.keymap.set("i", "<D-v>", "<C-r>+", { desc = "Paste" })

-- Cut
vim.keymap.set("v", "<C-x>", '"+d', { desc = "Cut" })
vim.keymap.set("v", "<D-x>", '"+d', { desc = "Cut" })

-- Find
vim.keymap.set("n", "<C-f>", "/", { desc = "Find" })
vim.keymap.set("n", "<D-f>", "/", { desc = "Find" })

-- Move lines up/down (VSCode Alt+Up/Down)
vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move lines up", silent = true })
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move lines down", silent = true })

-- Duplicate line (VSCode Shift+Alt+Up/Down)
vim.keymap.set("n", "<S-A-Down>", ":t.<CR>", { desc = "Duplicate line down", silent = true })
vim.keymap.set("n", "<S-A-Up>", ":t.-1<CR>", { desc = "Duplicate line up", silent = true })

-- Multi-cursor-like functionality would require additional plugins like vim-visual-multi

-- Window navigation (keep some vim navigation for splits)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Split windows (VSCode-like)
vim.keymap.set("n", "<C-\\>", ":vsplit<CR>", { desc = "Split vertically", silent = true })

-- Escape alternatives
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("i", "kj", "<Esc>", { desc = "Exit insert mode" })

-- Keep cursor centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- VSCode Command Palette equivalent
vim.keymap.set("n", "<C-S-p>", ":Telescope commands<CR>", { desc = "Command palette", silent = true })

-- Custom OLLAMA AI keybindings
local ollama = require("ollama_helper")

-- AI Ask Question (Ctrl+Shift+A or Cmd+Shift+A)
vim.keymap.set("n", "<C-S-a>", function()
	ollama.ask_question()
end, { desc = "Ask AI", silent = true })
vim.keymap.set("n", "<D-S-a>", function()
	ollama.ask_question()
end, { desc = "Ask AI", silent = true })

-- AI Complete/Improve Selection (Ctrl+Shift+I or Cmd+Shift+I)
vim.keymap.set("v", "<C-S-i>", function()
	ollama.complete_selection()
end, { desc = "AI Complete", silent = true })
vim.keymap.set("v", "<D-S-i>", function()
	ollama.complete_selection()
end, { desc = "AI Complete", silent = true })

-- AI Explain Code (Ctrl+Shift+E or Cmd+Shift+E)
vim.keymap.set("v", "<C-S-e>", function()
	ollama.explain_code()
end, { desc = "AI Explain", silent = true })
vim.keymap.set("v", "<D-S-e>", function()
	ollama.explain_code()
end, { desc = "AI Explain", silent = true })

-- Leader key alternatives for AI
vim.keymap.set("n", "<leader>aa", function()
	ollama.ask_question()
end, { desc = "Ask AI" })
vim.keymap.set("v", "<leader>ac", function()
	ollama.complete_selection()
end, { desc = "AI Complete" })
vim.keymap.set("v", "<leader>ae", function()
	ollama.explain_code()
end, { desc = "AI Explain" })

-- Notifications
vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function()
		vim.notify("Saved successfully ✨", "info", {
			title = "File Written",
			timeout = 1200,
		})
	end,
})

vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#2f334d" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#8aadf4", bg = "#2f334d" })
