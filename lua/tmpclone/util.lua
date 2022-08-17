local Scandir = require('plenary.scandir')

local M = {}

M.datadir = nil  -- To be populated in setup function

-- Finds all cloned repositories under tmpclone.datadir
M.get_cloned_repos = function ()
  return Scandir.scan_dir(M.datadir, {only_dirs = true, depth=1})
end

-- Whether :repo: name is already present in tmpcloned repos
M.is_contained_in_repos = function(repo)
  for _, cloned_repo in ipairs(M.get_cloned_repos()) do
    if M.get_repo_name_from_absolute_path(cloned_repo) == repo then
      return true
    end
  end
  return false
end

-- Returns last value from :arg: path
M.get_repo_name_from_absolute_path = function (path)
  local split_path = vim.split(path, "/")
  return split_path[#split_path]
end

-- Completion function for user commands
-- For info on custom complete :command-complete
M.vimscript_command_completion = function(argLead, cmdLine, cusorPos)
  local completions = {}
  for _, repo in ipairs(M.get_cloned_repos()) do
    if string.match(repo, argLead) then
      table.insert(completions, M.get_repo_name_from_absolute_path(repo))
    end
  end
  return completions
end

local escape_lua_pattern = function(s)
  -- Lua's builtin string.match(string, pattern) treats some values of
  -- :arg:pattern as special regex characters that need to be escaped
  local matches =
    { ["^"] = "%^";
      ["$"] = "%$";
      ["("] = "%(";
      [")"] = "%)";
      ["%"] = "%%";
      ["."] = "%.";
      ["["] = "%[";
      ["]"] = "%]";
      ["*"] = "%*";
      ["+"] = "%+";
      ["-"] = "%-";
      ["?"] = "%?";
    }
    return (s:gsub(".", matches))
end

-- Tries to match the root directory of :arg: buf_path against all paths
-- in :cloned_dirs:
M.match_root_dir_of_current_path = function (buf_path, cloned_dirs)
  for _, cloned_dir in ipairs(cloned_dirs) do
    if string.match(buf_path, escape_lua_pattern(M.get_repo_name_from_absolute_path(cloned_dir))) then
      return cloned_dir
    end
  end
  return nil
end

-- WORK IN PROGRESS
-- The logic that magically switches between working directories
M.change_working_directory_for_tmpclone_directories = function ()
  -- 1. if buff not in clone_paths and curr_wd not in path:
  -- 1. nothing
  -- 2. if buff not in clone_paths and curr_wd in path:
  -- 2. pop
  -- 3. if buff in clone_paths and curr_wd not in path:
  -- 3. find root directory from buffer in cloned paths, set it and push
  -- 4. if buff in clone_paths and curr_wd in path:
  -- 4. Same as 3 (inefficient)

  local cwd = vim.fn.getcwd()
  local buffer_path = vim.fn.expand('%')

  local buffer_matching_tmp_root_dir = M.match_root_dir_of_current_path(buffer_path, M.get_cloned_repos())
  local cwd_matching_tmp_root_dir = M.match_root_dir_of_current_path(cwd, M.get_cloned_repos())

  print("\n")
  print("BUF: " .. buffer_path .. " CWD: " .. cwd .. " BROOT: " .. (buffer_matching_tmp_root_dir or "nil") .. " CROOT: " .. (cwd_matching_tmp_root_dir or "nil"))

  local outside_of_tmpclone = (buffer_matching_tmp_root_dir == nil) and (cwd_matching_tmp_root_dir == nil)
  local leaving_tmpclone = (buffer_matching_tmp_root_dir == nil) and not (cwd_matching_tmp_root_dir == nil)
  local entering_tmpclone = not (buffer_matching_tmp_root_dir == nil) and (cwd_matching_tmp_root_dir == nil)
  local moving_between_tmpclone = not (buffer_matching_tmp_root_dir == nil) and not (cwd_matching_tmp_root_dir == nil)

  print(string.format("%s %s %s %s", outside_of_tmpclone, leaving_tmpclone, entering_tmpclone, moving_between_tmpclone))

  -- Cases 1: Not on tmpclone territory
  -- if outside_of_tmpclone then print("Case 1: Nothing should happen"); return
  -- -- Cases 2.
  -- elseif leaving_tmpclone then
  --   print("Case2 2: Moving out of tmpclone dirs")
  --   local old_cwd = M.working_dir_stack[#M.working_dir_stack] -- THere should be one here!
  --   table.remove(M.working_dir_stack,  #M.working_dir_stack)
  --   vim.api.nvim_set_current_dir(old_cwd)
  -- -- Case 3.
  -- elseif entering_tmpclone then
  --   print("Case 3: Going into a new tmpclone repo: ", M.get_repo_name_from_absolute_path(buffer_path))
  --   M.working_dir_stack[#M.working_dir_stack+1] = vim.fn.getcwd()
  --   vim.api.nvim_set_current_dir(buffer_matching_tmp_root_dir)
  -- -- Case 4: TODO: make more efficient
  -- elseif moving_between_tmpclone then
  --   print("Case 4: moving between tmpclone paths")
  --   print((buffer_matching_tmp_root_dir and cwd_matching_tmp_root_dir) == true)
  --   vim.api.nvim_set_current_dir(buffer_matching_tmp_root_dir)
  -- end
end

return M
