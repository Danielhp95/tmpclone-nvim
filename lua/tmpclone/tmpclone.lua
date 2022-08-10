local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local Path = require('plenary.path')
local Scandir = require('plenary.scandir')

local M = {}

-- Make sure that this file is created
M.tmpDir = vim.fn.stdpath("data") .. "/tmpclone-dir"

M.init_tmp_dir = function()
  local tmp_repos_dir_path = Path:new(M.tmpDir)
  if not tmp_repos_dir_path:exists() then
    tmp_repos_dir_path:mkdir()
  end
end

-- Clones {repo_url} into temporary directory
-- It can be searched using listRepos
M.clone = function (repo_url)
  require"os".execute("git -C " .. M.tmpDir .. " clone " .. repo_url)
  print("Succesfully cloned: " .. repo_url)
end

-- Lists all cloned repos for selection as to which to open
M.openRepo = function (opts)
  -- scans data directory and presents all of the directories' readme in telescope picker
  opts = opts or {}

  pickers.new(opts, {
    prompt_title = "Select from cloned repos",
    finder = finders.new_table {
      results = M.preprocess_cloned_repo_paths(),
      entry_maker = M.cloned_repo_entry_maker,
      previewer = require('telescope.config').values.cat_previewer, -- TODO: not working
    },
    sorter = conf.generic_sorter(opts),
    previwer = conf.file_previewer(opts)
  }):find()
end


M.cloned_repo_entry_maker = function(entry)
  -- Entry maker for telescope picker
  return {
    value = entry,
    path = entry[1],
    display = entry[2],
    ordinal = entry[2],
  }
end


-- Deletes repo_name
M.deleteRepo = function (opts)
  -- Matches repo_name against cloned directories And removes them
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Select cloned repo to remove",
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        require"os".execute("rm -rf " .. selection.path)
        print("Succesfully deleted repo: " .. selection.display)
      end)
      return true
    end,
    finder = finders.new_table {
      results = M.preprocess_cloned_repo_paths(),
      entry_maker = M.cloned_repo_entry_maker,
      previewer = require("telescope.previewers").new_termopen_previewer({
        get_command = function(entry, status)
          print("Dani " .. entry)
          return { 'bat', entry.path .. "/README.md" }
        end
      }),
    },
    sorter = conf.generic_sorter(opts),
    previwer = conf.file_previewer(opts)
  }):find()
end

M.get_cloned_repos = function ()
  -- Finds all cloned repositories
  return Scandir.scan_dir(M.tmpDir, {only_dirs = true, depth=1})
end

-- TODO: rename
M.preprocess_cloned_repo_paths = function ()
  -- Creates an array containing entries of {absolute_path_to_repo, repo_name}
  local repos = M.get_cloned_repos()
  local entries = {}
  for _, repo in ipairs(repos) do
    table.insert(entries, { repo, M.get_repo_name_from_absolute_path(repo) })
  end
  return entries
end

M.get_repo_name_from_absolute_path = function (path)
  -- Returns last value from :arg: path
  local split_path = vim.split(path, "/")
  return split_path[#split_path]
end

--M.init_tmp_dir()
--M.clone("https://github.com/nvim-telescope/telescope-project.nvim/")
--P(M.get_cloned_repos())
--M.openRepo(conf)
P(M.deleteRepo())
