local M = {}

function M.paste_or_attach()
  -- Obsidian selects the clipboard provider for Wayland, X11, or macOS.
  local ok, image_type = pcall(function() return require('obsidian.img_paste').get_clipboard_img_type() end)
  if ok and image_type then
    vim.cmd 'Obsidian paste_img'
  else
    require('obsidian.actions').add_attachment('.', { insert = true })
  end
end

return M
