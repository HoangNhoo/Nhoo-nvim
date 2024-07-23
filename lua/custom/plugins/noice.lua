return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  opts = {
    routes = {
      view = 'notify',
      filter = { event = 'msg_showmode ' },
    },
    -- add any options here
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    'MunifTanjim/nui.nvim',
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    -- 'rcarriga/nvim-notify',
  },
  keys = {
    -- require('notify').dismiss({ silent = true, pending = true })
    -- {
    -- '<leader>un',
    -- function()
    --   require('notify').dismiss { silent = true, pending = true }
    -- end,
    -- desc = 'clear notifications',
    -- },
  },
}
