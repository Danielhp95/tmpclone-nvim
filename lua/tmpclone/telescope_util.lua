local M = {}

M.cloned_repo_entry_maker = function(entry)
  -- Entry maker for telescope picker
  return {
    value = entry,
    path = entry[1],
    display = entry[2],
    ordinal = entry[2],
  }
end

return M
