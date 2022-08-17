local Path = require('plenary.path')

local util = require("tmpclone.util")
local telescope_util = require("tmpclone.telescope_util")

local M = {}

-- NOT YET IMPLEMENTED
M.working_dir_stack = {}

-- Clones git repository pointed to by :repo_url: into internal temporary folder.
-- Technically, any :url: accepted  by the standard `git clone` command can be
-- passed. The cloned repository can be accessed via user command `TmpcloneOpen`.
M.clone = function (repo_url)
  require"os".execute("git -C " .. util.datadir .. " clone " .. repo_url .. " > /dev/null 2>&1") -- Redirecting stdout and stderr to not mess with my nvim setup

  local tmp_repos_dir_path = Path:new(util.datadir .. "/" .. util.get_repo_name_from_absolute_path(repo_url))
  if not tmp_repos_dir_path:exists() then
    print("Git failed to clone \"" .. repo_url .. "\" is the url formatted correctly?")
  else
    print("Succesfully cloned: " .. repo_url)
  end
end

-- Opens previously cloned :repo: (optional parameter) in a new tab.
-- If no parameter is passed, then Telescope will be launched to select amongst
-- cloned repos.
M.open_repo = function (repo)
  if repo ~= "" and not util.is_contained_in_repos(repo) then
    print("Repository " .. repo .. " could not be found")
    return
  end

  local on_success_fn = function(path)
    vim.api.nvim_exec(string.format("tabe %s", path), false)
    print("Changed working directory to repository: " .. path)
  end

  if repo == "" then -- No string was passed as argument
    telescope_util.open_or_remove_picker("Select cloned repo to open", on_success_fn)
  else
    on_success_fn(util.datadir .. "/" .. repo)
  end
end

-- Removes previously cloned :repo: (optional parameter) from the
-- temporary data folder. If no parameter is passed, then Telescope will be
-- launched to select amongst cloned repos.
M.remove_repo = function (repo)
  if repo ~= "" and not util.is_contained_in_repos(repo) then
    print("Repository " .. repo .. " could not be found")
    return
  end

  local on_success_fn = function(path)
    require"os".execute("rm -rf " .. path)
    print("Succesfully deleted repo: " .. util.get_repo_name_from_absolute_path(path))
  end

  if repo == "" then
    telescope_util.open_or_remove_picker("Select cloned repo to remove", on_success_fn)
  else
    on_success_fn(util.datadir .. "/" .. repo)
  end
end

return M
