return {
	"fedepujol/move.nvim",
	config = function()
		require("move").setup({
			hide_status = true,
		})
		local opts = { noremap = true, silent = true }

		-- Normal-mode commands
		vim.keymap.set("n", "<A-j>", ":MoveLine(1)<CR>", opts)
		vim.keymap.set("n", "<A-k>", ":MoveLine(-1)<CR>", opts)
		vim.keymap.set("n", "<A-h>", ":MoveHChar(-1)<CR>", opts)
		vim.keymap.set("n", "<A-l>", ":MoveHChar(1)<CR>", opts)
		vim.keymap.set("n", "<leader>wf", ":MoveWord(1)<CR>", opts)
		vim.keymap.set("n", "<leader>wb", ":MoveWord(-1)<CR>", opts)

		-- Visual-mode commands
		vim.keymap.set("v", "<A-j>", ":MoveBlock(1)<CR>", opts)
		vim.keymap.set("v", "<A-k>", ":MoveBlock(-1)<CR>", opts)
		vim.keymap.set("v", "<A-h>", ":MoveHBlock(-1)<CR>", opts)
		vim.keymap.set("v", "<A-l>", ":MoveHBlock(1)<CR>", opts)
	end,
}
