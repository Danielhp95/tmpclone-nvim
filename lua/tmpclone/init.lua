local Path = require('plenary.path')
local util = require('tmpclone.util')

local Tmpclone  = {}

Tmpclone.init_tmp_dir = function()
-- Ensures that datadir exists
  local tmp_repos_dir_path = Path:new(Tmpclone.datadir)
  if not tmp_repos_dir_path:exists() then
    tmp_repos_dir_path:mkdir()
  end
end

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

local setup_aucommands = function()
  -- To manage swapping working directories under the hood
  -- TODO: add an options flag to disable this
  vim.api.nvim_create_autocmd(
    "BufEnter", {
      group = vim.api.nvim_create_augroup("tmpclone", {}),
      pattern = "*",
      callback = util.change_working_directory_for_tmpclone_directories,
    }
  )
end

Tmpclone.setup = function(opts)
  opts = opts or {}  -- Ensures that if nothing is passed, we have an empty set
  util.datadir = opts.datadir or vim.fn.stdpath('data') .. '/tmpclone-data'
  Tmpclone.datadir = util.datadir

  setup_commands()
  -- setup_aucommands() Work In Progress

  Tmpclone.init_tmp_dir()
end

return Tmpclone
