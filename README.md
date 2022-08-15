# Tmpclone-nvim

A small tool to help you temporarily clone repositories to navigate in nvim.

Motivation: Navigating code via Github or derivatives is annoying, most developers whom
use nvim will surely have a local workflow for navigating code which is superior to
browser based methods.

This plugin gives the following functionality:
  1. Clone repos into a temporary data folder (via `TmpcloneClone`)
  2. Navigate those repositories with all nvim tooling (via `TmpcloneOpen`)
  3. Remove cloned repos when they are no longer needed (via `TmpcloneRemove`)
  4. (Work in Progress) Seemlessly switch between "local" files and cloned repositories by managing switching the working directory under the hood.

## Installation and setup

Install with your favorite Neovim package manager, and example using
[`packer.nvim`](https://github.com/wbthomason/packer.nvim).

```lua
use {'danielhp95/tmpclone-nvim',
     requires = {'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim'},
```

## Example usage

Install with your favorite Neovim package manager. Be sure to call the setup function before using it.
if you wish to change the default configuration or register the user commands. Defaults and options
are presented here

```lua
require("tmpclone").setup({
  datadir = vim.fn.stdpath('data')
})
```

## Usage

See `:h tmpclone` for the official [documentation](./doc/tmpclone.txt). A normal workflow would
be cloning a repository via `TmpcloneClone`, opening it up with `TmpcloneOpen` and however long later
get rid of it via `TmpcloneRemove`.

### Keymaps

Some basic keymaps for both vimscript and lua could be:

```vim
nnoremap <leader>tc :TmpcloneClone<cr>   # Or :lua require("tmpclone.core").clone()<cr>
nnoremap <leader>to :TmpcloneOpen<cr>    # Or :lua require("tmpclone.core").open_repo()<cr>
nnoremap <leader>tr :TmpcloneRemove<cr>  # Or :lua require("tmpclone.core").remove_repo()<cr>
```
