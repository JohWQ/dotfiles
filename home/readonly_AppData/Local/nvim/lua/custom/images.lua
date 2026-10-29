local M = {}

function M.hover()
  local image = Snacks.image
  if image.supports_terminal() then return image.hover() end

  -- Use the OS image viewer when the terminal cannot render images.
  local function open(src)
    if not src then return vim.notify('No image under cursor', vim.log.levels.INFO) end
    local _, err = vim.ui.open(src)
    if err then vim.notify(tostring(err), vim.log.levels.ERROR) end
  end
  local file = vim.api.nvim_buf_get_name(0)
  if image.supports_file(file) then return open(file) end
  image.doc.at_cursor(open)
end

return M
