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

  if not util.is_contained_in_repos(repo) then
    print("Repository " .. repo .. " could not be found")
    return
  end

  -- No string was passed as argument
  local abs_path_repo = nil
  if repo == "" then
    abs_path_repo = nil -- Summon telescope
    -- pickers.new(opts, {
    --   prompt_title = "Select from cloned repos",
    --   finder = finders.new_table {
    --     results = M.preprocess_cloned_repo_paths(),
    --     entry_maker = telescope_util.cloned_repo_entry_maker,
    --     previewer = require('telescope.config').values.cat_previewer, -- TODO: not working
    --   },
    --   sorter = conf.generic_sorter(opts),
    --   previwer = conf.file_previewer(opts)
    -- }):find()
    -- TODO: escape hatch in case they cancel out!
  else
    abs_path_repo = util.datadir .. "/" .. repo
  end
  vim.api.nvim_exec(string.format("tabe %s", abs_path_repo), false)
  print("Changed working directory to repository: " .. abs_path_repo)
  --print("Changed working directory to repository: " .. repo)
end


-- Removes repo_name
M.remove_repo = function (repo)
  -- Matches repo_name against cloned directories And removes them

  if not util.is_contained_in_repos(repo) then
    print("Repository " .. repo .. " could not be found")
    return
  end

  local abs_path_repo = nil
  if repo == "" then
    local opts = {}
    abs_path_repo = telescope_util.get_open_or_remove_picker():find()
  else
    abs_path_repo = util.datadir .. "/" .. repo
  end
  require"os".execute("rm -rf " .. abs_path_repo)
  print("Succesfully deleted repo: " .. repo)
end

-- TODO: rename
M.preprocess_cloned_repo_paths = function ()
  -- Creates an array containing entries of {absolute_path_to_repo, repo_name}
  local repos = util.get_cloned_repos()
  local entries = {}
  for _, repo in ipairs(repos) do
    table.insert(entries, { repo, util.get_repo_name_from_absolute_path(repo) })
  end
  return entries
end

return M
