-- Default rule override:
function Linemode:mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		return ""
	elseif os.date("%Y", time) == os.date("%Y") then
		return os.date("%d/%m %H:%M", time)
	else
		return os.date("%d/%m  %Y", time)
	end
end

-- Add linemode option:
function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	-- Options: "%b", "%k", "%m", "%g", "%t", "%p", "%e", "%z", "%y", "%r", "%q"
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%p %d/%m %H:%M", time)
	else
		time = os.date("%p %d/%m %Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

------------------------------------------------------------------
-- Share tab paths with other Yazi instances:
require("open-paths"):setup()

------------------------------------------------------------------
-- Folder saving preferences:
local pref_by_location = require("pref-by-location")
pref_by_location:setup({
	prefs = { -- (Optional)
	},
})

------------------------------------------------------------------
-- Border:
require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

------------------------------------------------------------------
-- relative-motions:
require("relative-motions"):setup({
	show_numbers = "relative_absolute",
	show_motion = true,
	line_numbers_styles = {
		hovered = ui.Style():bold():reverse(true),
		normal = ui.Style(),
	},
})

------------------------------------------------------------------
-- Augment command:
-- Custom configuration
-- https://github.com/hankertrix/augment-command.yazi
-- ~/.config/yazi/init.lua for Linux and macOS
-- %AppData%\yazi\config\init.lua for Windows

-- Using the default configuration
require("augment-command"):setup({
	prompt = true,
	smooth_scrolling = true,
	wraparound_file_navigation = false,
})

------------------------------------------------------------------
-- Fzf/rg
require("yafg"):setup({
	--  toggle_mode_key = "alt-t",          -- fzf key to switch ripgrep/fzf mode (default: "ctrl-t")
	editor = "nvim", -- Editor command (default: "hx")
	--  args = { "--noplugin" },            -- Additional editor arguments (default: {})
	file_arg_format = "+{row} {file}", -- File argument format (default: "{file}:{row}:{col}")
})

------------------------------------------------------------------
require("git"):setup({
	-- Order of status signs showing in the linemode
	order = 1500,
})

------------------------------------------------------------------
-- whoosh bookmarks
-- You can configure your bookmarks using simplified syntax
local bookmarks = {
	{ tag = "Home", path = "~", key = "h" },
	{ tag = "Root", path = "/", key = "r" },
	{ tag = "Downloads", path = "~/Downloads", key = "d" },
	{ tag = "Documents", path = "~/Documents", key = "D" },
	{ tag = "Pictures", path = "~/Pictures", key = "p" },
	{ tag = "Pictures", path = "~/Videos", key = "v" },
	{ tag = "Music", path = "~/Music", key = { "M", "M" } },
	{ tag = "Config", path = "~/.config", key = "c" },
	{ tag = "Yazi config", path = "~/.config/yazi", key = "y" },
	{ tag = "Neovim config", path = "~/.config/nvim", key = "n" },
	{ tag = "Niri config", path = "~/.config/niri", key = "N" },
	{ tag = "Scripts", path = "~/.config/scripts", key = "S" },
	{ tag = ".local", path = "~/.local", key = "l" },
	{ tag = "Chezmoi source", path = "~/.local/share/chezmoi", key = "C" },
	{ tag = "Desktop files (user)", path = "~/.local/share/applications", key = { "a", "l" } },
	{ tag = "Binaries (user)", path = "~/.local/bin", key = { "b", "l" } },
	{ tag = "Icons (user)", path = "~/.local/share/icons", key = { "i", "l" } },
	{ tag = "Desktop files (system)", path = "/usr/share/applications", key = { "a", "u" } },
	{ tag = "Binaries (system)", path = "/usr/local/bin", key = { "b", "u" } },
	{ tag = "Icons (system)", path = "/usr/share/icons", key = { "i", "u" } },
	{ tag = "Notes", path = "~/ServerSync/Documents/notes", key = "t" },
	{ tag = "usr", path = "/usr", key = "u" },
	{ tag = "opt", path = "/opt", key = "o" },
	{ tag = "etc", path = "/etc", key = "e" },
	{ tag = "Drives", path = "/media", key = "m" },
	{ tag = "Drives", path = "/mnt", key = { "M", "m" } },
	{ tag = "Server", path = "/mnt/4TB", key = "s" },
}

-- You can also configure bookmarks with key arrays
-- local bookmarks = {
-- 	{ tag = "Desktop", path = "~/Desktop", key = { "d", "D" } },
-- 	{ tag = "Documents", path = "~/Documents", key = { "d", "d" } },
-- 	{ tag = "Downloads", path = "~/Downloads", key = "o" },
-- }

-- Windows-specific bookmarks
-- if ya.target_family() == "windows" then
-- 	local home_path = os.getenv("USERPROFILE")
-- 	table.insert(bookmarks, {
-- 		tag = "Scoop Local",
-- 		path = os.getenv("SCOOP") or (home_path .. "\\scoop"),
-- 		key = "p",
-- 	})
-- 	table.insert(bookmarks, {
-- 		tag = "Scoop Global",
-- 		path = os.getenv("SCOOP_GLOBAL") or "C:\\ProgramData\\scoop",
-- 		key = "P",
-- 	})
-- end

require("whoosh"):setup({
	-- Configuration bookmarks (cannot be deleted through plugin)
	bookmarks = bookmarks,

	-- Notification settings
	jump_notify = false,

	-- Key generation for auto-assigning bookmark keys
	keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",

	-- Configure the built-in menu action hotkeys
	-- false - hide menu item
	special_keys = {
		create_temp = "<Enter>", -- Create a temporary bookmark from the menu
		fuzzy_search = "<Space>", -- Launch fuzzy search (fzf)
		history = "<Tab>", -- Open directory history
		previous_dir = "<Backspace>", -- Jump back to the previous directory
		project_root = "-", -- Jump to the current Git repository root
	},

	-- File path for storing user bookmarks
	bookmarks_path = (
		ya.target_family() == "windows"
		and os.getenv("APPDATA") .. "\\yazi\\config\\plugins\\whoosh.yazi\\bookmarks"
	) or (os.getenv("HOME") .. "/.config/yazi/plugins/whoosh.yazi/bookmarks"),

	-- Replace home directory with "~"
	home_alias_enabled = true, -- Toggle home aliasing in displays

	-- Path truncation in navigation menu
	path_truncate_enabled = false, -- Enable/disable path truncation
	path_max_depth = 3, -- Maximum path depth before truncation

	-- Path truncation in fuzzy search (fzf)
	fzf_path_truncate_enabled = false, -- Enable/disable path truncation in fzf
	fzf_path_max_depth = 5, -- Maximum path depth before truncation in fzf

	-- Long folder name truncation
	path_truncate_long_names_enabled = false, -- Enable in navigation menu
	fzf_path_truncate_long_names_enabled = false, -- Enable in fzf
	path_max_folder_name_length = 20, -- Max length in navigation menu
	fzf_path_max_folder_name_length = 20, -- Max length in fzf

	-- History directory settings
	history_size = 10, -- Number of directories in history (default 10)
	history_fzf_path_truncate_enabled = false, -- Enable/disable path truncation by depth for history
	history_fzf_path_max_depth = 5, -- Maximum path depth before truncation for history (default 5)
	history_fzf_path_truncate_long_names_enabled = false, -- Enable/disable long folder name truncation for history
	history_fzf_path_max_folder_name_length = 30, -- Maximum length for folder names in history (default 30)
})

------------------------------------------------------------------
-- gvfs mount
require("gvfs"):setup({
	-- (Optional) Allowed keys to select device.
	which_keys = "1234567890qwertyuiopasdfghjklzxcvbnm-=[]\\;',./!@#$%^&*()_+{}|:\"<>?",

	-- (Optional) Table of blacklisted devices. These devices will be ignored in any actions
	-- List of device properties to match, or a string to match the device name:
	-- https://github.com/boydaihungst/gvfs.yazi/blob/master/main.lua#L144
	blacklist_devices = { { name = "Wireless Device", scheme = "mtp" }, { scheme = "file" }, "Device Name" },

	-- (Optional) Save file.
	-- Default: ~/.config/yazi/gvfs.private
	save_path = os.getenv("HOME") .. "/.config/yazi/gvfs.private",

	-- (Optional) Save file for automount devices. Use with `automount-when-cd` action.
	-- Default: ~/.config/yazi/gvfs_automounts.private
	save_path_automounts = os.getenv("HOME") .. "/.config/yazi/gvfs_automounts.private",

	-- (Optional) Input box position.
	-- Default: { "top-center", y = 3, w = 60 },
	-- Position, which is a table:
	-- 	`1`: Origin position, available values: "top-left", "top-center", "top-right",
	-- 	     "bottom-left", "bottom-center", "bottom-right", "center", and "hovered".
	--         "hovered" is the position of hovered file/folder
	-- 	`x`: X offset from the origin position.
	-- 	`y`: Y offset from the origin position.
	-- 	`w`: Width of the input.
	-- 	`h`: Height of the input.
	input_position = { "center", y = 0, w = 60 },

	-- (Optional) Select where to save passwords.
	-- Default: nil
	-- Available options: "keyring", "pass", or nil
	password_vault = "keyring",

	-- (Optional) Only need if you set password_vault = "pass"
	-- Read the guide at SECURE_SAVED_PASSWORD.md to get your key_grip
	key_grip = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB",

	-- (Optional) Auto-save password after mount.
	-- Default: false
	save_password_autoconfirm = true,
	-- (Optional) mountpoint of gvfs. Default: /run/user/USER_ID/gvfs
	-- On some system it could be ~/.gvfs
	-- You can't decide this path, it will be created automatically. Only changed if you know where gvfs mountpoint is.
	-- Use command `ps aux | grep gvfs` to search for gvfs process and get the mountpoint path.
	-- root_mountpoint = (os.getenv("XDG_RUNTIME_DIR") or ("/run/user/" .. ya.uid())) .. "/gvfs"
})
