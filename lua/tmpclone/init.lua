local M = {}

M.tmpDir = vim.fn.stdpath("data") .. "/tmpclone-dir"

M.init_tmp_dir = function()
  -- Creates a directory to host cloned repos if there isn't one
  local tmp_repos_dir_path = Path:new(M.tmpDir)
  if not tmp_repos_dir_path:exists() then
    tmp_repos_dir_path:mkdir()
  end
end

M.setup = function()
  M.init_tmp_dir()
  -- Used to register commands
  vim.cmd[[
    command! OpenTmpRepos lua require("tmpclone").openRepo()
    command! DeleteTmpRepos lua require("tmpclone").deleteRepo()
    command! -nargs=1 CloneTmpRepo lua require("tmpclone").clone("<f-args>")
  ]]
end

return M
