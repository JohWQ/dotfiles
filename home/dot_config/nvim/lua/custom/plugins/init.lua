-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)

-- See the kickstart.nvim README for more information

return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local alpha = require 'alpha'
      local dashboard = require 'alpha.themes.dashboard'

      dashboard.section.header.val = {
        [[   N E O V I M   ]],
      }

      dashboard.section.buttons.val = {
        dashboard.button('n', '󰈔  New file', ':enew<CR>'),
        dashboard.button('f', '󰱼  Find file cwd', ':lua Snacks.picker.files()<CR>'),
        dashboard.button('g', '󰱼  Search file contents cwd', ':lua Snacks.picker.grep()<CR>'),
        dashboard.button('d', '  Daily Note', ':Obsidian today<CR>'),
        dashboard.button('t', '  Notes', function() require('yazi').yazi({}, vim.fn.expand '~/ServerSync/Documents/notes') end),
        dashboard.button('r', '󱑂  Recent', ':lua Snacks.picker.recent()<CR>'),
        dashboard.button('-', '  Open Yazi at current file', ':Yazi<CR>'),
        dashboard.button('q', '󰗼  Quit', ':qa<CR>'),
      }

      dashboard.section.footer.val = 'leat fingies'

      dashboard.config.opts.noautocmd = true

      alpha.setup(dashboard.config)
    end,
  },
  --  {
  --    'catppuccin/nvim',
  --    name = 'catppuccin',
  --    priority = 1000,
  --    vim.cmd.colorscheme 'catppuccin-macchiato',
  --  },
  {
    'inkarkat/vim-SpellCheck',
    dependencies = {
      'inkarkat/vim-ingo-library',
    },

    config = function()
      vim.keymap.set('n', '<leader>ss', function()
        vim.cmd 'SpellCheck'
        vim.cmd 'copen'
      end, { desc = 'Spell check' })

      vim.keymap.set('n', '<leader>us', function()
        if vim.opt.spell:get() then
          vim.opt.spell = false
          vim.notify 'Spell checker disabled'
        else
          vim.opt.spell = true
          vim.notify 'Spell checker enabled'
        end
      end, { desc = 'Toggle spell checker' })
    end,
  },
  {
    'obsidian-nvim/obsidian.nvim',
    dependencies = 'folke/snacks.nvim',
    version = '*', -- use latest release, remove to use latest commit
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      ui = {
        enable = false,
      },
      legacy_commands = false, -- this will be removed in 4.0.0
      picker = {
        name = 'snacks.picker', -- use Snacks picker
      },
      daily_notes = {
        enabled = true,
        folder = '2_Notes/Daily',
        date_format = 'YYYY-MM-DD',
        default_tags = { 'daily' },
        template = 'daily-note.md',
      },
      note = {
        enabled = true,
        -- template = vim.NIL, -- disables the default note template and just use a blank note
        template = 'normal-note.md',
      },
      templates = {
        folder = '4_Templates',
        date_format = 'YYYY-MM-DD',
        time_format = 'HH:mm',
        substitutions = {
          yesterday = function() return os.date('%Y-%m-%d', os.time() - 86400) end,
        },
      },
      attachments = {
        folder = './assets',
        default = {
          dir = 'assets',
        },
      },
      workspaces = {
        {
          name = 'notes',
          path = '~/ServerSync/Documents/notes',
        },
      },
    },
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      dashboard = { enabled = false },
      explorer = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      quickfile = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
      bigfile = {},
      notifier = {},
      picker = {
        hidden = true,
        ignored = true,
        sources = {
          files = {
            exclude = { '**/.git', '*.rpm', '*.exe' },
          },
        },
        win = {
          input = {
            keys = {
              ['<c-v>'] = { 'edit_split', mode = { 'i', 'n' } },
              ['<c-g>'] = { 'edit_vsplit', mode = { 'i', 'n' } },
            },
          },
        },
      },
      image = {
        formats = { 'svg' },
        backend = 'kitty',
        inline = false,
        doc = {
          enabled = false,
          inline = false,
          float = true,
          max_width = 80,
          max_height = 40,
        },
        ---@class snacks.image.convert.Config
        convert = {
          notify = false, -- show a notification on error
          ---@type table<string,snacks.image.args>
          magick = {
            vector = { '-density', 192, '{src}[{page}]' }, -- used by vector images like svg
          },
        },
        math = {
          enabled = true,
        },

        resolve = function(path, src)
          local api = require 'obsidian.api'
          if api.path_is_note(path) then return api.resolve_attachment_path(src) end
        end,
      },
    },
    keys = {
      { '<leader><space>', function() Snacks.picker.smart() end, desc = 'Smart Find Files' },
      { '<leader>sr', function() Snacks.picker.recent() end, desc = 'Recent files' },
      { '<leader>s:', function() Snacks.picker.command_history() end, desc = 'Command History' },
      { '<leader>s/', function() Snacks.picker.search_history() end, desc = 'Search History' },
      { '<leader>sg', function() Snacks.picker.grep() end, desc = 'Grep' },
      { '<leader>sn', function() Snacks.picker.notifications() end, desc = 'Notification History' },
      { '<leader>su', function() Snacks.picker.undo() end, desc = 'Undo History' },
      { '<leader>sl', function() Snacks.picker.lines() end, desc = 'Lines' },
      { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Keymaps' },
      { '<leader>.', function() Snacks.scratch() end, desc = 'Toggle Scratch Buffer' },
      { '<leader>s?', function() Snacks.picker.help() end, desc = 'Help Pages' },
      { '<leader>si', function() Snacks.picker.icons() end, desc = 'Emoticons' },
      { '<leader>sB', function() Snacks.picker.grep_buffers() end, desc = 'Grep Open Buffers' },
      { '<leader>uc', function() Snacks.picker.colorschemes() end, desc = 'Colorschemes' },
    },
    config = function(_, opts)
      require('snacks').setup(opts)

      vim.keymap.set('n', '<leader>ui', function()
        local line = vim.api.nvim_get_current_line()
        local new = line:gsub('2_Notes/Daily/assets/', ''):gsub('https://youtu%.be/2arL1jh8ihA', ''):gsub('assets/', '')

        if new ~= line then
          vim.api.nvim_set_current_line(new)
          vim.defer_fn(function() Snacks.image.hover() end, 200)
        else
          Snacks.image.hover()
        end
      end, {
        desc = 'Show image under cursor',
      })
    end,
  },
  {
    'akinsho/bufferline.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {},
  },
  {
    'brenoprata10/nvim-highlight-colors',
    enabled = true,
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      render = 'background',
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_var_usage = true,
      enable_named_colors = true,
      enable_tailwind = true,
    },
  },
  {
    'ThePrimeagen/vim-be-good',
  },
  {
    'aserowy/tmux.nvim',

    opts = {
      navigation = {
        enable_default_keybindings = false,
      },
      resize = {
        enable_default_keybindings = false,
        resize_step_x = 1,
        resize_step_y = 1,
      },
      swap = {
        enable_default_keybindings = false,
      },
    },

    keys = {
      -- Navigation
      { '<M-h>', function() require('tmux').move_left() end, desc = 'Tmux Left' },
      { '<M-j>', function() require('tmux').move_bottom() end, desc = 'Tmux Down' },
      { '<M-k>', function() require('tmux').move_top() end, desc = 'Tmux Up' },
      { '<M-l>', function() require('tmux').move_right() end, desc = 'Tmux Right' },

      -- Resize
      { '<C-M-h>', function() require('tmux').resize_left() end, desc = 'Resize Left' },
      { '<C-M-j>', function() require('tmux').resize_bottom() end, desc = 'Resize Down' },
      { '<C-M-k>', function() require('tmux').resize_top() end, desc = 'Resize Up' },
      { '<C-M-l>', function() require('tmux').resize_right() end, desc = 'Resize Right' },
    },
  },

  ---@type LazySpec
  {
    'mikavilpas/yazi.nvim',
    version = '*', -- use the latest stable version
    event = 'VeryLazy',
    dependencies = {
      { 'nvim-lua/plenary.nvim', lazy = true },
    },
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        '<leader>-',
        mode = { 'n', 'v' },
        '<cmd>Yazi<cr>',
        desc = 'Open yazi at the current file',
      },
      {
        -- Open in the current working directory
        '<leader>,',
        '<cmd>Yazi cwd<cr>',
        desc = "Open the file manager in nvim's working directory",
      },
      {
        '<c-up>',
        '<cmd>Yazi toggle<cr>',
        desc = 'Resume the last yazi session',
      },
      {
        '<leader>w',
        mode = 'n',
        function()
          if vim.fn.expand '%:p' == '' then
            local keys = vim.api.nvim_replace_termcodes('<leader>W', true, false, true)
            vim.api.nvim_feedkeys(keys, 'm', false)
          else
            vim.cmd.write()
          end
        end,
        desc = 'Write buffer to existing file',
      },
      {
        '<leader>W',
        mode = { 'n', 'v' },
        function()
          require('yazi').yazi {
            hooks = {
              -- when yazi was successfully closed
              yazi_closed_successfully = function(chosen_file, config, state)
                if chosen_file then
                  local f = io.open(chosen_file, 'r')
                  local filesize
                  if f then
                    filesize = f:seek 'end'
                    f:close()
                  else
                    -- if chosen_file couldn't be opened, set a non-0 value so
                    -- that the file won't be force-overwritten if it exists
                    filesize = -1
                  end
                  if filesize == 0 then
                    -- skip warning if file exists but is empty
                    vim.cmd(':write! ' .. chosen_file)
                  else
                    vim.cmd(':write ' .. chosen_file)
                  end
                end
              end,

              yazi_opened = function(preselected_path, yazi_buffer_id, config) end,
              yazi_opened_multiple_files = function(chosen_files, config, state) end,
              on_yazi_ready = function(buffer, config, process_api) end,
            },
          }
        end,
        desc = 'Write current buffer to file dialog',
      },
    },
    ---@type YaziConfig | {}
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = true,
      open_for_multiple_tabs = true,
      change_neovim_cwd_on_close = true,
      keymaps = {
        show_help = '<f1>',
        open_file_in_vertical_split = '<c-g>',
        open_file_in_horizontal_split = '<c-v>',
        replace_in_directory = '<c-x>',
        send_to_quickfix_list = '<c-l>',
      },
    },
    -- 👇 if you use `open_for_directories=true`, this is recommended
    init = function()
      -- mark netrw as loaded so it's not loaded at all.
      --
      -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
      vim.g.loaded_netrwPlugin = 1
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwSettings = 1
      vim.g.loaded_netrwFileHandlers = 1
    end,
  },
}
