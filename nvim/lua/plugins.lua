
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end



return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Nvim-tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function() require'nvim-tree'.setup {} end
}

  -- markdown-preview
  use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview'}
  -- LSP
  use 'neovim/nvim-lspconfig'


  -- UI to select things (files, grep results, open buffers...)
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use 'joshdick/onedark.vim' -- Theme inspired by Atom
  use 'itchyny/lightline.vim' -- Fancier statusline
  use "neovim/nvim-lspconfig"
  use {
  "hrsh7th/nvim-cmp",
  requires = {
  "hrsh7th/cmp-nvim-lsp", --neovim 内置 LSP 客户端的 nvim-cmp 源
  --以下插件可选，可以根据个人喜好删减
  "onsails/lspkind-nvim", --美化自动完成提示信息
  "hrsh7th/cmp-buffer", --从buffer中智能提示
  "hrsh7th/cmp-nvim-lua", --nvim-cmp source for neovim Lua API.
  "octaltree/cmp-look", --用于完成英语单词
  "hrsh7th/cmp-path", --自动提示硬盘上的文件
  "hrsh7th/cmp-calc", --输入数学算式（如1+1=）自动计算
  "f3fora/cmp-spell", --nvim-cmp 的拼写源基于 vim 的拼写建议
  "hrsh7th/cmp-emoji", --输入: 可以显示表情
}}

  -- 代码段提示
  use {
  "L3MON4D3/LuaSnip",
  requires = {
  "saadparwaiz1/cmp_luasnip", -- Snippets source for nvim-cmp
  "rafamadriz/friendly-snippets" --代码段合集
  }}

end)

