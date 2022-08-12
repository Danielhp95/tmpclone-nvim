local M = {}

M.get_repo_name_from_absolute_path = function (path)
  -- Returns last value from :arg: path
  local split_path = vim.split(path, "/")
  return split_path[#split_path]
end

return M
