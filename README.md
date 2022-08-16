# Tmpclone ⏳😉😉

A small tool to help you temporarily clone repositories to navigate in nvim.

**Motivation**: Navigating code via Github or derivatives is annoying, most developers whom
use nvim will surely have a local workflow for navigating code which is superior to
browser based methods.

This plugin offers the following functionality:
  1. Clone repos into a temporary data folder (via `TmpcloneClone`)
  2. Navigate those repositories with all nvim tooling (via `TmpcloneOpen`)
  3. Remove cloned repos when they are no longer needed (via `TmpcloneRemove`)
  4. (TODO Roadmap) Seemlessly switch working directories between "local" files and cloned repositories by meddling with the working directory under the hood.

A normal workflow would be cloning a repository via `TmpcloneClone`, opening it up with
`TmpcloneOpen` and however long later get rid of it via `TmpcloneRemove`.

## Installation and setup

Install with your favorite Neovim package manager, here is and example using
[`packer.nvim`](https://github.com/wbthomason/packer.nvim).

```lua
use {'danielhp95/tmpclone-nvim',
     requires = {'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim'},
```

Be sure to call `require("tmpclone").setup` function before using `tmpclone`.
if you wish to change the default configuration or register the user commands.
Defaults and options are presented here:

```lua
require("tmpclone").setup({
  datadir = vim.fn.stdpath('data') .. '/tmpclone-data'
})
```

### Keymaps

Some basic keymaps for both vimscript and lua could be:

```vim
nnoremap <leader>tc :TmpcloneClone<cr>   " Or :lua require("tmpclone.core").clone()<cr>
nnoremap <leader>to :TmpcloneOpen<cr>    " Or :lua require("tmpclone.core").open_repo()<cr>
nnoremap <leader>tr :TmpcloneRemove<cr>  " Or :lua require("tmpclone.core").remove_repo()<cr>
```

### TODO Roadmap 🏎️
[ ] - Seemlessly switch working directories between "local" files and cloned repositories by meddling with the working directory under the hood.
