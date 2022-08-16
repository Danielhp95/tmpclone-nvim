local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local util = require "tmpclone.util"

local M = {}

function M.cloned_repo_entry_maker(entry)
  -- Entry maker for telescope picker
  return {
    value = entry,
    path = entry[1],
    display = entry[2],
    ordinal = entry[2],
  }
end

function M.open_or_remove_picker(title, on_success_fn)
  opts = {} -- TODO
  pickers.new(opts, {
    prompt_title = title,
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        on_success_fn(action_state.get_selected_entry().path)
      end)
      return true
    end,
    finder = finders.new_table {
      results = M.preprocess_cloned_repo_paths(),
      entry_maker = M.cloned_repo_entry_maker,
      -- Previewer not working
      previewer = require("telescope.previewers").new_termopen_previewer({
        get_command = function(entry, _)
          return { 'bat', action_state.get_selected_entry().path .. "/README.md" }
        end
      }),
    },
    sorter = conf.generic_sorter(opts),
  }):find()
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
