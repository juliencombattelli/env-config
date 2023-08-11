-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Colorscheme
lvim.colorscheme = "onedarker"

-- Open file explorer on Nvim startup
local function open_nvim_tree(data)
  local no_name = data.file == "" and vim.bo[data.buf].buftype == ""
  if no_name then
    return
  end
  local directory = vim.fn.isdirectory(data.file) == 1
  if directory then
    vim.cmd.cd(data.file)
  end
  require("nvim-tree.api").tree.toggle({ focus = false, find_file = true, })
  if directory then
    require("alpha").start()
    require("nvim-tree.api").tree.focus()
  end
end
vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
