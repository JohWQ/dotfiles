local M = {}

function M.paste_or_attach()
  local bufnr = vim.api.nvim_get_current_buf()
  local function finish(has_image)
    -- The clipboard probe is asynchronous; do not paste into a different buffer.
    if not vim.api.nvim_buf_is_valid(bufnr) or vim.api.nvim_get_current_buf() ~= bufnr then return end
    if has_image then
      vim.cmd 'Obsidian paste_img'
    else
      require('obsidian.actions').add_attachment('.', { insert = true })
    end
  end

  if vim.fn.executable 'powershell.exe' ~= 1 then return finish(false) end
  local ok = pcall(vim.system, {
    'powershell.exe',
    '-NoLogo',
    '-NoProfile',
    '-NonInteractive',
    '-STA',
    '-Command',
    [[Add-Type -AssemblyName System.Windows.Forms; if ([System.Windows.Forms.Clipboard]::ContainsImage()) { exit 0 }; exit 1]],
  }, { text = true, timeout = 3000 }, function(result)
    vim.schedule(function() finish(result.code == 0) end)
  end)
  if not ok then finish(false) end
end

return M
