-- required in which-key plugin spec in plugins/ui.lua as `require 'config.keymap'`
local wk = require("which-key")
local ms = vim.lsp.protocol.Methods

P = vim.print

vim.g["quarto_is_r_mode"] = nil
vim.g["reticulate_running"] = false

local nmap = function(key, effect)
	vim.keymap.set("n", key, effect, { silent = true, noremap = true })
end

local vmap = function(key, effect)
	vim.keymap.set("v", key, effect, { silent = true, noremap = true })
end

local imap = function(key, effect)
	vim.keymap.set("i", key, effect, { silent = true, noremap = true })
end

local cmap = function(key, effect)
	vim.keymap.set("c", key, effect, { silent = true, noremap = true })
end

-- move in command line
cmap("<C-a>", "<Home>")

-- exit insert mode with jk
imap("jk", "<esc>")

-- save with ctrl+s
imap("<C-s>", "<esc>:update<cr><esc>")
nmap("<C-s>", "<cmd>:update<cr><esc>")

-- Move between windows using <ctrl> direction
nmap("<C-j>", "<C-W>j")
nmap("<C-k>", "<C-W>k")
nmap("<C-h>", "<C-W>h")
nmap("<C-l>", "<C-W>l")

-- Resize window using <shift> arrow keys
nmap("<S-Up>", "<cmd>resize +2<CR>")
nmap("<S-Down>", "<cmd>resize -2<CR>")
nmap("<S-Left>", "<cmd>vertical resize -2<CR>")
nmap("<S-Right>", "<cmd>vertical resize +2<CR>")

-- Add undo break-points
imap(",", ",<c-g>u")
imap(".", ".<c-g>u")
imap(";", ";<c-g>u")

nmap("Q", "<Nop>")

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
--- TODO: incorpoarate this into quarto-nvim plugin
--- such that QuartoRun functions get the same capabilities
--- TODO: figure out bracketed paste for reticulate python repl.
local function send_cell()
	if vim.b["quarto_is_r_mode"] == nil then
		vim.fn["slime#send_cell"]()
		return
	end
	if vim.b["quarto_is_r_mode"] == true then
		vim.g.slime_python_ipython = 0
		local is_python = require("otter.tools.functions").is_otter_language_context("python")
		if is_python and not vim.b["reticulate_running"] then
			vim.fn["slime#send"]("reticulate::repl_python()" .. "\r")
			vim.b["reticulate_running"] = true
		end
		if not is_python and vim.b["reticulate_running"] then
			vim.fn["slime#send"]("exit" .. "\r")
			vim.b["reticulate_running"] = false
		end
		vim.fn["slime#send_cell"]()
	end
end

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
local slime_send_region_cmd = ":<C-u>call slime#send_op(visualmode(), 1)<CR>"
slime_send_region_cmd = vim.api.nvim_replace_termcodes(slime_send_region_cmd, true, false, true)
local function send_region()
	-- if filetyps is not quarto, just send_region
	if vim.bo.filetype ~= "quarto" or vim.b["quarto_is_r_mode"] == nil then
		vim.cmd("normal" .. slime_send_region_cmd)
		return
	end
	if vim.b["quarto_is_r_mode"] == true then
		vim.g.slime_python_ipython = 0
		local is_python = require("otter.tools.functions").is_otter_language_context("python")
		if is_python and not vim.b["reticulate_running"] then
			vim.fn["slime#send"]("reticulate::repl_python()" .. "\r")
			vim.b["reticulate_running"] = true
		end
		if not is_python and vim.b["reticulate_running"] then
			vim.fn["slime#send"]("exit" .. "\r")
			vim.b["reticulate_running"] = false
		end
		vim.cmd("normal" .. slime_send_region_cmd)
	end
end

-- send code with ctrl+Enter
-- just like in e.g. RStudio
-- needs kitty (or other terminal) config:
-- map shift+enter send_text all \x1b[13;2u
-- map ctrl+enter send_text all \x1b[13;5u
nmap("<c-cr>", send_cell)
nmap("<s-cr>", send_cell)
imap("<c-cr>", send_cell)
imap("<s-cr>", send_cell)

--- Show R dataframe in the browser
-- might not use what you think should be your default web browser
-- because it is a plain html file, not a link
-- see https://askubuntu.com/a/864698 for places to look for
local function show_r_table()
	local node = vim.treesitter.get_node({ ignore_injections = false })
	assert(node, "no symbol found under cursor")
	local text = vim.treesitter.get_node_text(node, 0)
	local cmd = [[call slime#send("DT::datatable(]] .. text .. [[)" . "\r")]]
	vim.cmd(cmd)
end

-- keep selection after indent/dedent
vmap(">", ">gv")
vmap("<", "<gv")

-- center after search and jumps
nmap("n", "nzz")
nmap("<c-d>", "<c-d>zz")
nmap("<c-u>", "<c-u>zz")

-- move between splits and tabs
nmap("<c-h>", "<c-w>h")
nmap("<c-l>", "<c-w>l")
nmap("<c-j>", "<c-w>j")
nmap("<c-k>", "<c-w>k")
nmap("H", "<cmd>tabprevious<cr>")
nmap("L", "<cmd>tabnext<cr>")

local function toggle_light_dark_theme()
	if vim.o.background == "light" then
		vim.o.background = "dark"
	else
		vim.o.background = "light"
	end
end

local is_code_chunk = function()
	local current, _ = require("otter.keeper").get_current_language_context()
	if current then
		return true
	else
		return false
	end
end

--- Insert code chunk of given language
--- Splits current chunk if already within a chunk
--- @param lang string
local insert_code_chunk = function(lang)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)
	local keys
	if is_code_chunk() then
		keys = [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]]
	else
		keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
	end
	keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
	vim.api.nvim_feedkeys(keys, "n", false)
end

local insert_r_chunk = function()
	insert_code_chunk("r")
end

local insert_py_chunk = function()
	insert_code_chunk("python")
end

local insert_lua_chunk = function()
	insert_code_chunk("lua")
end

local insert_julia_chunk = function()
	insert_code_chunk("julia")
end

local insert_bash_chunk = function()
	insert_code_chunk("bash")
end

local insert_ojs_chunk = function()
	insert_code_chunk("ojs")
end

--show kepbindings with whichkey
--add your own here if you want them to
--show up in the popup as well

-- normal mode
wk.add({
	{ "<c-LeftMouse>", "<cmd>lua vim.lsp.buf.definition()<CR>", desc = "go to definition" },
	{ "<c-q>", "<cmd>q<cr>", desc = "close buffer" },
	{ "<esc>", "<cmd>noh<cr>", desc = "remove search highlight" },
	{ "<cm-i>", insert_py_chunk, desc = "python code chunk" },
	{ "<m-I>", insert_py_chunk, desc = "python code chunk" },
	{ "<m-i>", insert_r_chunk, desc = "r code chunk" },
	{ "[q", ":silent cprev<cr>", desc = "[q]uickfix prev" },
	{ "]q", ":silent cnext<cr>", desc = "[q]uickfix next" },
	{ "gN", "Nzzzv", desc = "center search" },
	{ "gf", ":e <cfile><CR>", desc = "edit file" },
	{ "gl", "<c-]>", desc = "open help link" },
	{ "n", "nzzzv", desc = "center search" },
	{ "z?", ":setlocal spell!<cr>", desc = "toggle [z]pellcheck" },
	{ "zl", ":Telescope spell_suggest<cr>", desc = "[l]ist spelling suggestions" },
}, { mode = "n", silent = true })

-- visual mode
wk.add({
	{ ".", ":norm .<cr>", desc = "repat last normal mode command" },
	{ "<M-j>", ":m'>+<cr>`<my`>mzgv`yo`z", desc = "move line down" },
	{ "<M-k>", ":m'<-2<cr>`>my`<mzgv`yo`z", desc = "move line up" },
	{ "<cr>", send_region, desc = "run code region" },
	{ "q", ":norm @q<cr>", desc = "repat q macro" },
}, { mode = "v" })

-- visual with <leader>
wk.add({
	{ "<localleader>p", '"_dP', desc = "replace without overwriting reg" },
	{ "<localleader>d", '"_d', desc = "delete without overwriting reg" },
}, { mode = "v" })

-- insert mode
wk.add({
	{ "<m-->", " <- ", desc = "assign" },
	{ "<m-m>", " |>", desc = "pipe" },
	{ "<m-i>", insert_r_chunk, desc = "r code chunk" },
	{ "<cm-i>", insert_py_chunk, desc = "python code chunk" },
	{ "<m-I>", insert_py_chunk, desc = "python code chunk" },
	{ "<c-x><c-x>", "<c-x><c-o>", desc = "omnifunc completion" },
}, { mode = "i" })

local function new_terminal(lang)
	vim.cmd("vsplit term://" .. lang)
end

local function new_terminal_python()
	new_terminal("python")
end

local function new_terminal_r()
	new_terminal("R --no-save")
end

local function new_terminal_ipython()
	new_terminal("ipython --no-confirm-exit")
end

local function new_terminal_julia()
	new_terminal("julia")
end

local function new_terminal_shell()
	new_terminal("$SHELL")
end

local function get_otter_symbols_lang()
	local otterkeeper = require("otter.keeper")
	local main_nr = vim.api.nvim_get_current_buf()
	local langs = {}
	for i, l in ipairs(otterkeeper.rafts[main_nr].languages) do
		langs[i] = i .. ": " .. l
	end
	-- promt to choose one of langs
	local i = vim.fn.inputlist(langs)
	local lang = otterkeeper.rafts[main_nr].languages[i]
	local params = {
		textDocument = vim.lsp.util.make_text_document_params(),
		otter = {
			lang = lang,
		},
	}
	-- don't pass a handler, as we want otter to use it's own handlers
	vim.lsp.buf_request(main_nr, ms.textDocument_documentSymbol, params, nil)
end

vim.keymap.set("n", "<localleader>os", get_otter_symbols_lang, { desc = "otter [s]ymbols" })

-- normal mode with <localleader>
wk.add({
	{ "<localleader><cr>", send_cell, desc = "run code cell" },
	{ "<localleader>c", group = "[c]ode / [c]ell / [c]hunk" },
	{
		{ "<localleader>cn", new_terminal_shell, desc = "[n]ew terminal with shell" },
		{
			"cr",
			function()
				vim.b["quarto_is_r_mode"] = true
				new_terminal_r()
			end,
			desc = "new [R] terminal",
		},
		{ "<localleader>cp", new_terminal_python, desc = "new [p]ython terminal" },
		{ "<localleader>ci", new_terminal_ipython, desc = "new [i]python terminal" },
		{ "<localleader>cj", new_terminal_julia, desc = "new [j]ulia terminal" },
	},
	{ "<localleader>e", group = "[e]dit" },
	{ "<localleader>d", group = "[d]ebug" },
	{
		{ "<localleader>dt", desc = "[t]est" },
	},
	{ "<localleader>f", group = "[f]ind (telescope)" },
	{
		{ "<localleader>ff", "<cmd>Telescope find_files<cr>", desc = "[f]iles" },
		{ "<localleader>fh", "<cmd>Telescope help_tags<cr>", desc = "[h]elp" },
		{ "<localleader>fk", "<cmd>Telescope keymaps<cr>", desc = "[k]eymaps" },
		{ "<localleader>fg", "<cmd>Telescope live_grep<cr>", desc = "[g]rep" },
		{ "<localleader>fb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "[b]uffer fuzzy find" },
		{ "<localleader>fm", "<cmd>Telescope marks<cr>", desc = "[m]arks" },
		{ "<localleader>fM", "<cmd>Telescope man_pages<cr>", desc = "[M]an pages" },
		{ "<localleader>fc", "<cmd>Telescope git_commits<cr>", desc = "git [c]ommits" },
		{ "<localleader>f<space>", "<cmd>Telescope buffers<cr>", desc = "[ ] buffers" },
		{ "<localleader>fd", "<cmd>Telescope buffers<cr>", desc = "[d] buffers" },
		{ "<localleader>fq", "<cmd>Telescope quickfix<cr>", desc = "[q]uickfix" },
		{ "<localleader>fl", "<cmd>Telescope loclist<cr>", desc = "[l]oclist" },
		{ "<localleader>fj", "<cmd>Telescope jumplist<cr>", desc = "[j]umplist" },
	},
	{ "<localleader>g", group = "[g]it" },
	{
		{ "<localleader>gc", ":GitConflictRefresh<cr>", desc = "[c]onflict" },
		{ "<localleader>gs", ":Gitsigns<cr>", desc = "git [s]igns" },
		{
			"<localleader>gwc",
			":lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>",
			desc = "worktree create",
		},
		{
			"<localleader>gws",
			":lua require('telescope').extensions.git_worktree.git_worktrees()<cr>",
			desc = "worktree switch",
		},
		{ "<localleader>gd", group = "[d]iff" },
		{
			{ "<localleader>gdo", ":DiffviewOpen<cr>", desc = "[o]pen" },
			{ "<localleader>gdc", ":DiffviewClose<cr>", desc = "[c]lose" },
		},
		{ "<localleader>gb", group = "[b]lame" },
		{
			{ "<localleader>gbb", ":GitBlameToggle<cr>", desc = "[b]lame toggle virtual text" },
			{ "<localleader>gbo", ":GitBlameOpenCommitURL<cr>", desc = "[o]pen" },
			{ "<localleader>gbc", ":GitBlameCopyCommitURL<cr>", desc = "[c]opy" },
		},
	},
	{ "<localleader>h", group = "[h]elp / [h]ide / debug" },
	{
		{ "<localleader>hc", group = "[c]onceal" },

		{ "<localleader>hh", ":set conceallevel=1<cr>", desc = "[h]ide/conceal" },
		{ "<localleader>hs", ":set conceallevel=0<cr>", desc = "[s]how/unconceal" },
	},
	{ "<localleader>t", group = "[t]reesitter" },
	{
		{ "<localleader>tt", vim.treesitter.inspect_tree, desc = "show [t]ree" },
	},
	{ "<localleader>i", group = "[i]mage" },
	{ "<localleader>l", group = "[l]anguage/lsp" },
	{
		{ "<localleader>lr", vim.lsp.buf.references, desc = "[r]eferences" },
		{ "<localleader>R", desc = "[R]ename" },
		{ "<localleader>lD", vim.lsp.buf.type_definition, desc = "type [D]efinition" },
		{ "<localleader>la", vim.lsp.buf.code_action, desc = "code [a]ction" },
		{ "<localleader>le", vim.diagnostic.open_float, desc = "diagnostics (show hover [e]rror)" },
		{ "<localleader>ld", group = "[d]iagnostics" },
		{
			{
				"<localleader>ldd",
				function()
					vim.diagnostic.enable(false)
				end,
				desc = "[d]isable",
			},
			{ "<localleader>lde", vim.diagnostic.enable, desc = "[e]nable" },
		},
		{ "<localleader>lg", ":Neogen<cr>", desc = "neo[g]en docstring" },
	},
	{ "<localleader>o", group = "[o]tter & c[o]de" },
	{
		{ "<localleader>oa", require("otter").activate, desc = "otter [a]ctivate" },
		{ "<localleader>od", require("otter").deactivate, desc = "otter [d]eactivate" },
		{ "<localleader>oc", "O# %%<cr>", desc = "magic [c]omment code chunk # %%" },
		{ "<localleader>or", insert_r_chunk, desc = "[r] code chunk" },
		{ "<localleader>op", insert_py_chunk, desc = "[p]ython code chunk" },
		{ "<localleader>oj", insert_julia_chunk, desc = "[j]ulia code chunk" },
		{ "<localleader>ob", insert_bash_chunk, desc = "[b]ash code chunk" },
		{ "<localleader>oo", insert_ojs_chunk, desc = "[o]bservable js code chunk" },
		{ "<localleader>ol", insert_lua_chunk, desc = "[l]lua code chunk" },
	},
	{ "<localleader>q", group = "[q]uarto" },
	{
		{ "<localleader>qa", ":QuartoActivate<cr>", desc = "[a]ctivate" },
		{ "<localleader>qp", ":lua require'quarto'.quartoPreview()<cr>", desc = "[p]review" },
		{ "<localleader>qq", ":lua require'quarto'.quartoClosePreview()<cr>", desc = "[q]uiet preview" },
		{ "<localleader>qh", ":QuartoHelp ", desc = "[h]elp" },
		{ "<localleader>qr", group = "[r]un" },
		{
			{ "<localleader>qrr", ":QuartoSendAbove<cr>", desc = "to cu[r]sor" },
			{ "<localleader>qra", ":QuartoSendAll<cr>", desc = "run [a]ll" },
			{ "<localleader>qrb", ":QuartoSendBelow<cr>", desc = "run [b]elow" },
		},
		{ "<localleader>qe", require("otter").export, desc = "[e]xport" },
		{
			"<localleader>qE",
			function()
				require("otter").export(true)
			end,
			desc = "[E]xport with overwrite",
		},
	},
	{ "<localleader>r", group = "[r] R specific tools" },
	{
		{ "<localleader>rt", show_r_table, desc = "show [t]able" },
	},
	{ "<localleader>v", group = "[v]im" },
	{
		{ "<localleader>vt", toggle_light_dark_theme, desc = "[t]oggle light/dark theme" },
		{ "<localleader>vc", ":Telescope colorscheme<cr>", desc = "[c]olortheme" },
		{ "<localleader>vl", ":Lazy<cr>", desc = "[l]azy package manager" },
		{ "<localleader>vm", ":Mason<cr>", desc = "[m]ason software installer" },
		{ "<localleader>vs", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k<cr>", desc = "[s]ettings, edit vimrc" },
		{ "<localleader>vh", ':execute "h " . expand("<cword>")<cr>', desc = "vim [h]elp for current word" },
	},
	{ "<localleader>x", group = "e[x]ecute" },
	{
		{ "<localleader>xx", ":w<cr>:source %<cr>", desc = "[x] source %" },
	},
}, { mode = "n" })
