--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- trying gruber theme
  { "blazkowolf/gruber-darker.nvim" },

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',         opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
      end,
    },
  },

  {
    -- Theme inspired by Atom
    'morhetz/gruvbox',
    priority = 1000,
    opts = {
      undercurl = true,
      underline = true,
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = false,   -- invert background for search, diffs, statuslines and errors
      contrast = "hard", -- can be "hard", "soft" or empty string
      overrides = {
        SignColumn = { bg = "#ff9900" },
      },
    },
    config = function()
      vim.cmd.colorscheme 'gruvbox'
    end,
  },

  {
    -- Theme inspired by Atom
    'aktersnurra/no-clown-fiesta.nvim',
    priority = 1001,
    opts = {
      undercurl = true,
      underline = true,
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = false,   -- invert background for search, diffs, statuslines and errors
      contrast = "hard", -- can be "hard", "soft" or empty string
      overrides = {
        SignColumn = { bg = "#ff9900" },
      },
    },
    config = function()
      vim.cmd.colorscheme 'no-clown-fiesta'
    end,
  },


  {
    'navarasu/onedark.nvim',
  },

  {
    'norcalli/nvim-colorizer.lua'
  },

  {
    'nvim-treesitter/playground'
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'gruvbox',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {
      indent = { char = "│" },
      scope = {
        enabled = false,
      },
    },
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim',  opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

vim.diagnostic.config({
  virtual_text = true,
})

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true
vim.o.linebreak = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Custom Delinx stuff
--opt
vim.o.number = true         -- Enables line numbers on the left side of the window.
vim.o.relativenumber = true -- Enables relative line numbering from the cursor line.
vim.o.cursorline = true     -- Highlights the current line where the cursor is located.
vim.o.background = "dark"   -- Sets the background to dark mode for syntax highlighting.
--vim.o.colorcolumn = "80"  -- Highlights the 80th column to indicate the length of code lines.
vim.o.textwidth = 120       -- Sets the maximum width of text that is being inserted.
vim.o.hlsearch = false      -- Disables highlighting of search matches.
vim.o.hidden = true         -- Allows switching buffers without saving them.
vim.o.showmatch = true      -- Enables showing matching brackets when the cursor is over them.
vim.o.ignorecase = true     -- Makes searches case-insensitive.
vim.o.incsearch = true      -- Shows search matches as you type.
vim.o.expandtab = true      -- Converts tabs to spaces.
vim.o.shiftwidth = 4        -- Sets the number of space characters inserted for indentation.
vim.o.tabstop = 4           -- Sets the number of space characters equivalent to one tab.
vim.o.softtabstop = 4       -- Number of spaces that a Tab counts for while performing editing operations.
vim.o.autoindent = true     -- Copies indentation from current line when starting a new line.
vim.o.signcolumn = "yes"    -- Always show the sign column, used for 'diff' and other things.
vim.o.spell = false         -- Disables spelling checks.
vim.o.swapfile = false      -- Disables the creation of a swapfile.
vim.o.backup = false        -- Disables creating a backup before overwriting a file.
vim.o.scrolloff = 8         -- Keeps 8 lines visible above and below the cursor when scrolling.
vim.o.cmdheight = 1         -- Sets the height of the command line to 1 line.
vim.o.linespace = 4         -- Sets the spacing between lines to 4 pixels.
vim.o.undolevels = 10000    -- Maximum number of changes that can be undone.
vim.o.undofile = true       -- Enables persistent undo, which allows undoing even after closing and reopening Vim.
vim.o.hidden = true         -- Buffers remain in memory when hidden instead of being unloaded.
vim.o.termguicolors = true  -- Enables true color support in the terminal.
vim.o.updatetime = 50       -- Sets the time (in milliseconds) that Vim waits before writing to the swap file.
vim.o.encoding = "utf-8"    -- Sets the character encoding to UTF-8.
vim.o.foldenable = false
--vim.keymap.set("n", "<C-y>", "<", { silent = true })
-- pmenu
vim.o.pumheight = 10
vim.o.title = true
vim.o.titlestring = "Neovide"


NEOVIDE_SCALE = 1.0;
if vim.g.neovide then
  print("Hello neovide")
  vim.o.guifont = "Comic_Code:h17:#e-subpixelantialias"
  vim.g.neovide_scale_factor = 1

  vim.opt.linespace = 0

  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0

  local alpha = function()
    return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
  end
  vim.g.neovide_transparency = 1.0
  vim.g.transparency = 1.0
  vim.g.neovide_background_color = "#0f1117" .. alpha()

  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0

  vim.g.neovide_floating_shadow = false
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 0
  vim.g.neovide_light_radius = 4

  vim.g.neovide_scroll_animation_length = 0.0
  vim.g.neovide_scroll_animation_far_lines = 0

  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_underline_stroke_scale = 1.00
  vim.g.neovide_unlink_border_highlights = true
  vim.g.neovide_refresh_rate = 145
  vim.g.neovide_refresh_rate_idle = 144
  vim.g.neovide_no_idle = true
  vim.g.neovide_confirm_quit = false

  vim.g.neovide_remember_window_size = true
  vim.g.neovide_profiler = false
  vim.g.neovide_input_ime = false

  vim.g.neovide_cursor_animation_length = 0.0
  vim.g.neovide_cursor_trail_size = 0.0
  vim.g.neovide_cursor_antialiasing = false

  --vim.keymap.set('n', '<C-s>', ':w<CR>')      -- Save
  vim.keymap.set('v', '<C-c>', '"+y')         -- Copy
  vim.keymap.set('n', '<C-v>', '"+P')         -- Paste normal mode
  vim.keymap.set('v', '<C-v>', '"+P')         -- Paste visual mode
  vim.keymap.set('c', '<C-v>', '<C-R>+')      -- Paste command mode
  vim.keymap.set('i', '<C-v>', '<ESC>l"+Pli') -- Paste insert mode

  -- Neovide remaps
  function Resize_neovide(direction)
    local pscale = NEOVIDE_SCALE + direction
    if (pscale >= 0.1) and (pscale < 2.0) then
      NEOVIDE_SCALE = pscale
    end
    vim.g.neovide_scale_factor = NEOVIDE_SCALE
    print(NEOVIDE_SCALE)
  end

  vim.keymap.set("n", "<C-ScrollWheelUp>", ":lua Resize_neovide(0.05)<CR>", { silent = true })
  vim.keymap.set("n", "<C-ScrollWheelDown>", ":lua Resize_neovide(-0.05)<CR>", { silent = true })
  vim.keymap.set("n", "<C-MiddleMouse>", ":lua vim.g.neovide_scale_factor = 1.0<CR>:lua NEOVIDE_SCALE = 1.0<CR>",
    { silent = true })
end

-- [[ Basic Keymaps ]]

-- Custom
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = 'Go to next buffer' })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = 'Go to previous buffer' })
-- Yep, we all know this one
vim.api.nvim_create_user_command('W', ":w", { nargs = 0 })
vim.api.nvim_create_user_command('X', ":x", { nargs = 0 })
vim.api.nvim_create_user_command('Q', ":q", { nargs = 0 })
-- tab << or >>
vim.keymap.set("n", "<Tab>", ">>_")
vim.keymap.set("n", "<S-Tab>", "<<_")
vim.keymap.set("v", "<Tab>", ">>_")
vim.keymap.set("v", "<S-Tab>", "<<_")
-- Move lines up / down
vim.keymap.set("n", "<A-k>", "mz:m-2<CR>`z==")
vim.keymap.set("n", "<A-j>", "mz:m+<CR>`z==")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("i", "<A-k>", "<Esc>:m-2<CR>==gi")
vim.keymap.set("i", "<A-j>", "<Esc>:m+<CR>==gi")
-- extra save, just to be save, ba dum tssss
--vim.keymap.set("n", "<C-s>", "<cmd>w!<CR>")

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
    file_ignore_patterns = { "zig-cache/.*", "/home/del/.cache/.*", "/home/del/.local/.*", "/home/del/.config/.*", ".git/.*" },
    preview = {
      treesitter = true
    }
  },
}

require("telescope").load_extension('harpoon')

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == "" then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ":h")
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep({
      search_dirs = { git_root },
    })
  end
end

-- /home/del/zig_source/src
local function live_grep_zig()
  require('telescope.builtin').live_grep({
    search_dirs = { "/home/del/zig_source/" },
  })
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})
vim.api.nvim_create_user_command('LiveGrepZig', live_grep_zig, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>f', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sz', ':LiveGrepZig<cr>', { desc = '[S]earch by grep in [Z]ig source' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'vimdoc', 'vim', 'bash', 'zig' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- document existing key chains
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'More git', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },
  -- verse = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },

}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
    keyword_length = 0,
    autocomplete = false,
  },

  formatting = {
    expandable_indicator = true,
    fields = { "abbr", "menu", "kind" },
    format = function(entry, item)
      -- Define menu shorthand for different completion sources.
      local menu_icon = {
        nvim_lsp = "NLSP",
        nvim_lua = "NLUA",
        luasnip  = "LSNP",
        buffer   = "BUFF",
        path     = "PATH",
      }
      -- Set the menu "icon" to the shorthand for each completion source.
      item.menu = menu_icon[entry.source.name]

      -- Set the fixed width of the completion menu to 60 characters.
      fixed_width = 40

      -- Set 'fixed_width' to false if not provided.
      fixed_width = fixed_width or false

      -- Get the completion entry text shown in the completion window.
      local content = item.abbr

      -- Set the fixed completion window width.
      if fixed_width then
        vim.o.pumwidth = fixed_width
      end

      -- Get the width of the current window.
      local win_width = vim.api.nvim_win_get_width(0)

      -- Set the max content width based on either: 'fixed_width'
      -- or a percentage of the window width, in this case 20%.
      -- We subtract 10 from 'fixed_width' to leave room for 'kind' fields.
      local max_content_width = fixed_width and fixed_width - 10 or math.floor(win_width * 0.2)

      -- Truncate the completion entry text if it's longer than the
      -- max content width. We subtract 3 from the max content width
      -- to account for the "..." that will be appended to it.
      if #content > max_content_width then
        item.abbr = vim.fn.strcharpart(content, 0, max_content_width - 3) .. "..."
      else
        item.abbr = content .. (" "):rep(max_content_width - #content)
      end
      return item
    end,
  },

  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

function ColorMyPencils()
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  vim.api.nvim_set_hl(0, "NonText", { bg = "none" })
  vim.api.nvim_set_hl(0, "VirtColumn", { fg = "#1c1c1c" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
  vim.api.nvim_set_hl(0, "TermCursor", { bg = "black", fg = "black" })
  vim.api.nvim_set_hl(0, "CursorLine", { fg = "none", bg = "none" })
  vim.api.nvim_set_hl(0, "CursorLineNR", { fg = "#D79717", bg = "none" })

  vim.api.nvim_set_hl(0, "GitSignsAdd", { bg = "none", fg = "#76C683" })
  vim.api.nvim_set_hl(0, "GitSignsChange", { bg = "none", fg = "#CBC874" })
  vim.api.nvim_set_hl(0, "GitSignsDelete", { bg = "none", fg = "#DC666A" })

  vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { bg = "none", fg = "#D79717" })
  vim.api.nvim_set_hl(0, "DiagnosticSignError", { bg = "none", fg = "#DC666A" })
  vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { bg = "none", fg = "#76C683" })
  vim.api.nvim_set_hl(0, "DiagnosticSignHint", { bg = "none", fg = "#76C683" })

  vim.api.nvim_set_hl(0, "String", { bg = "none", fg = "#95C0A9" })

  vim.api.nvim_set_hl(0, "Visual", { bg = "#ebdbb2", fg = "#3c3836" })
end

ColorMyPencils()
vim.cmd.colorscheme 'delinx'

vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  desc = 'return cursor to where it was last time closing the file',
  pattern = '*',
  command = 'silent! normal! g`"zv',
})

function Build_rust()
  vim.cmd.terminal()
  vim.cmd.cd(vim.loop.cwd())
  vim.api.nvim_chan_send(vim.bo.channel, 'cmd.exe /c "cls && cargo run"\n')
end

function IfTermThenExit()
  if vim.bo.buftype == "terminal" then
    vim.api.nvim_command('startinsert')
    vim.api.nvim_input('<Esc>')
  end
end

function RunTermAndInsert()
  vim.cmd.terminal()
  vim.cmd.cd(vim.loop.cwd())
  vim.api.nvim_command('startinsert')
end

vim.keymap.set("n", "<f5>", ":lua Build_rust()<cr>", { silent = true })
vim.keymap.set("n", "<f4>", ":lua RunTermAndInsert()<cr>", { silent = true })
vim.keymap.set("t", "<Esc>", [[<C-c><C-\><C-n>:bw!<CR>]], { silent = true })
vim.keymap.set("n", "<Esc>", ":lua IfTermThenExit()<cr>", { silent = true })

-- Stream todo rename
function Stream_todo()
  vim.o.title = true
  vim.o.titlestring = "Stream:TODO"
  vim.cmd("highlight Normal guibg=#031b1b")
end

vim.cmd [[
    augroup CustomFileTypeStreamTODO
        autocmd!
        autocmd BufRead,BufNewFile *.stream.md lua Stream_todo()
    augroup END
]]
