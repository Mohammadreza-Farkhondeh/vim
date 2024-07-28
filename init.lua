local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'  -- Package manager
    use 'nvim-lua/plenary.nvim'  -- Required by several plugins

    -- LSP and autocompletion
    use 'neovim/nvim-lspconfig'  -- LSP configuration
    use 'hrsh7th/nvim-cmp'  -- Autocompletion plugin
    use 'hrsh7th/cmp-nvim-lsp'  -- LSP source for nvim-cmp
    use 'hrsh7th/cmp-buffer'  -- Buffer source for nvim-cmp
    use 'hrsh7th/cmp-path'  -- Path source for nvim-cmp
    use 'L3MON4D3/LuaSnip'  -- Snippet engine
    use 'saadparwaiz1/cmp_luasnip'  -- Snippet source for nvim-cmp

    -- Fuzzy finder
    use 'junegunn/fzf'
    use 'junegunn/fzf.vim'

    -- Treesitter for better syntax highlighting
    use 'nvim-treesitter/nvim-treesitter'

    -- Null-ls for linting and formatting
    -- use 'jose-elias-alvarez/null-ls.nvim'
    use 'nvimtools/none-ls.nvim'
    
    -- Colorscheme
    use 'gruvbox-community/gruvbox'

    -- Indent guides
    use 'lukas-reineke/indent-blankline.nvim'

    if packer_bootstrap then
        require('packer').sync()
    end
end)

-- General settings
vim.o.termguicolors = false
vim.o.background = "dark"
vim.cmd [[colorscheme gruvbox]]

-- Line numbers
vim.wo.number = true
vim.wo.relativenumber = false

-- Indent guides
require("ibl").overwrite {
    exclude = { filetypes = {"help", "packer", "lspinfo", "TelescopePrompt", "TelescopeResults", "NvimTree"}}
}

-- Keybindings
vim.g.mapleader = ' '  -- Set leader key to space

-- Better navigation
vim.api.nvim_set_keymap('n', '<Leader>ff', ':Files<CR>', { noremap = true, silent = true })  -- Fuzzy file finder
vim.api.nvim_set_keymap('n', '<Leader>fg', ':Rg<CR>', { noremap = true, silent = true })  -- Fuzzy grep

-- Better scrolling
vim.api.nvim_set_keymap('n', '<C-u>', '<C-u>zz', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-d>', '<C-d>zz', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-b>', '<C-b>zz', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-f>', '<C-f>zz', { noremap = true, silent = true })

-- LSP settings
local nvim_lsp = require('lspconfig')

-- Setup nvim-cmp.
local cmp = require 'cmp'
local luasnip = require 'luasnip'


cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body) -- For `LuaSnip` users.
        end,
    },
    mapping = {
        ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
        { name = 'path' },
    })
})

-- Setup LSP servers
local servers = { 'jedi_language_server' }
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
    }
end

-- Configure Treesitter
require'nvim-treesitter.configs'.setup {
    ensure_installed = "all", -- Install all available maintained parsers
    highlight = {
        enable = true, -- Enable syntax highlighting
    },
    indent = {
        enable = true -- Enable indentation support
    }
}

-- Configure null-ls
local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,
        null_ls.builtins.diagnostics.mypy.with({
            extra_args = function()
            local virtual = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX") or "/usr"
            return { "--python-executable", virtual .. "/bin/python3" }
            end,
        }),
    },
    on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({
            group = augroup,
            buffer = bufnr,
        })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
            end,
        })
        end
    end,
})


