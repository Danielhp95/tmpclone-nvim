describe("tmpclone", function()

  it("Can be required", function() require("tmpclone") end)

  local tmpclone = require("tmpclone")
  tmpclone.tmpclone_datadir = vim.fn.stdpath("data") .. "tmpclone-data/tests"
  -- How to get this working...
  -- Tmpclone = require("tmpclone")
  -- Clone own repo
  it("Can clone repositories from Github", function()
       local plugin_own_repo = "https://github.com/Danielhp95/tmpclone-nvim"
       require("tmpclone").clone()
     end
  )

  it("Can remove installed repos", function()
       assert(false, "not implemented")
     end
  )

  it("Can open cloned project", function()
       assert(false, "not implemented")
     end
  )

end)
