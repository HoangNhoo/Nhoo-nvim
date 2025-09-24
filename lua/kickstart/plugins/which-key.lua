-- NOTE: Plugins can also be configured to run Lua code when they are loaded.

return { -- Useful plugin to show you pending keybinds.
	"folke/which-key.nvim",
	"echasnovski/mini.icons",
	event = "VimEnter", -- Sets the loading event to 'VimEnter'
	config = function() -- This is the function that runs, AFTER loading
		require("which-key").add({
			{ "<leader>c", group = "[C]ode" },
			{ "<leader>c_", hidden = true },
			{ "<leader>d", group = "[D]ocument" },
			{ "<leader>d_", hidden = true },
			{ "<leader>g", group = "[G]it" },
			{ "<leader>g_", hidden = true },
			{ "<leader>m", group = "[M]arkdown" },
			{ "<leader>m_", hidden = true },
			{ "<leader>r", group = "[R]ename" },
			{ "<leader>r_", hidden = true },
			{ "<leader>s", group = "[S]earch" },
			{ "<leader>s_", hidden = true },
			{ "<leader>t", group = "[T]oggle" },
			{ "<leader>t_", hidden = true },
			{ "<leader>w", group = "[W]orkspace" },
			{ "<leader>w_", hidden = true },
			{ "ignore_missing", desc = "true" },
		})

		-- visual mode
		-- require('which-key').register({
		--   '<leader>gh' = { '[G]it [H]unk' },
		-- }, { mode = 'v' })
	end,
}
