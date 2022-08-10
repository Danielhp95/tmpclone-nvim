local Scandir = require('plenary.scandir')
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"


local colors = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "colors",
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        -- print(vim.inspect(selection))
        vim.api.nvim_put({ selection[1] }, "", false, true)
      end)
      return true
    end,
    finder = finders.new_table {
          results = {
            { "red", "very_red" },
            { "green", "very_green" },
            { "blue", "very_blue" },
          },
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry[2],
              ordinal = entry[2],
            }
          end
        },
    sorter = conf.generic_sorter(opts),
  }):find()
end

local test_files = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Files",
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        -- print(vim.inspect(selection))
        vim.api.nvim_put({ selection[1] }, "", false, true)
      end)
      return true
    end,
    finder = finders.new_table {
      results = preprocess_cloned_repo_paths(),
      entry_maker = function(entry)
        return {
          value = entry,
          path = entry[2],
          display = entry[1],
          ordinal = entry[2],
          previewe_command = function(entry, bufnr)
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, 'dani')
          end
        }
      end,
      --previewer = require("telescope.previewers").new_termopen_previewer({
      --  get_command = function(entry, status)
      --    print("Dani " .. entry)
      --    return { 'bat', entry.path }
      --  end,
      --  title = "README.md"
      --}),
      previewer = require'telescope.previewers'.display_content.new(opts)
    },
    sorter = conf.generic_sorter(opts),
  }):find()
end

get_cloned_repos = function ()
  -- Finds all cloned repositories
  return Scandir.scan_dir(".", {only_dirs = false, depth=1})
end

-- TODO: rename
preprocess_cloned_repo_paths = function ()
  -- Creates an array containing entries of {absolute_path_to_repo, repo_name}
  local repos = get_cloned_repos()
  local entries = {}
  for _, repo in ipairs(repos) do
    table.insert(entries, { repo, repo })
  end
  return entries
end

get_repo_name_from_absolute_path = function (path)
  -- Returns last value from :arg: path
  local split_path = vim.split(path, "/")
  return split_path[#split_path]
end

test_files()
