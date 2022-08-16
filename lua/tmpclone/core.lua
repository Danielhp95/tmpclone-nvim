local Path = require('plenary.path')

local util = require("tmpclone.util")
local telescope_util = require("tmpclone.telescope_util")

local M = {}

M.working_dir_stack = {}

M.clone = function (repo_url)
  -- Clones {repo_url} into temporary directory
  -- It can be searched using listRepos
  require"os".execute("git -C " .. util.datadir .. " clone " .. repo_url .. " > /dev/null 2>&1") -- Redirecting stdout and stderr to not mess with my nvim setup

  local tmp_repos_dir_path = Path:new(util.datadir .. "/" .. util.get_repo_name_from_absolute_path(repo_url))
  if not tmp_repos_dir_path:exists() then
    print("Git failed to clone \"" .. repo_url .. "\" is the url formatted correctly?")
  else
    print("Succesfully cloned: " .. repo_url)
  end
end

-- Lists all cloned repos for selection as to which to open
M.open_repo = function (repo)
  -- scans data directory and presents all of the directories' readme in telescope picker

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


-- Removes repo_name
M.remove_repo = function (repo)
  -- Matches repo_name against cloned directories And removes them

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
