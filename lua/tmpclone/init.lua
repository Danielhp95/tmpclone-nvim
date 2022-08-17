local Path = require('plenary.path')
local util = require('tmpclone.util')

local Tmpclone  = {}

-- Ensures that tmpclone datadir exists
Tmpclone.init_tmp_dir = function()
  local tmp_repos_dir_path = Path:new(Tmpclone.datadir)
  if not tmp_repos_dir_path:exists() then
    tmp_repos_dir_path:mkdir()
  end
end

-- Setup user commands
local setup_commands = function()
  local cmd = vim.api.nvim_create_user_command

  cmd("TmpcloneOpen", function(argtable) require("tmpclone.core").open_repo(argtable.args) end,
      {nargs = "?", -- "?" 0 or 1 arguments
       complete = util.vimscript_command_completion,
      })
  cmd("TmpcloneRemove", function(argtable) require("tmpclone.core").remove_repo(argtable.args) end,
      {nargs = "?",
       complete = util.vimscript_command_completion,
      })
  cmd("TmpcloneClone", function(argtable) require("tmpclone.core").clone(argtable.args) end, {nargs = 1}) -- Exactly 1 argument
end

-- NOT YET IMPLEMENTED
-- Manages swapping the working directory under the hood when swapping from
-- directories cloned by tmpclone and other files
local setup_aucommands = function()
  vim.api.nvim_create_autocmd(
    "BufEnter", {
      group = vim.api.nvim_create_augroup("tmpclone", {}),
      pattern = "*",
      callback = util.change_working_directory_for_tmpclone_directories,
    }
  )
end

-- Highest level plugin function.
-- opts:
--   - datadir (string): Directory where tmpclone repositories will live
--   - auto_change_dir (boolean): NOT YET IMPLEMENTED. Whether to activate the
--                                auto swapping of working directories
Tmpclone.setup = function(opts)
  opts = opts or {}  -- Ensures that if nothing is passed, we have an empty set
  util.datadir = opts.datadir or vim.fn.stdpath('data') .. '/tmpclone-data'
  Tmpclone.datadir = util.datadir  -- Maybe not a good idea that we save this in 2 places
  Tmpclone.opts = opts  -- Save options on highest level module if

  local auto_change_dir = opts.auto_change_dir or false

  setup_commands()
  if auto_change_dir then setup_aucommands() end

  Tmpclone.init_tmp_dir()
end

return Tmpclone
