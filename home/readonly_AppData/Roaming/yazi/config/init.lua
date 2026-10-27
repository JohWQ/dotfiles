-- Open-paths.yazi
require("open-paths"):setup()

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
-- require("git"):setup({
-- 	-- Order of status signs showing in the linemode
-- 	order = 1500,
-- })

-- You can configure your bookmarks using simplified syntax
local bookmarks = {
	{ tag = "Home", path = "~", key = "h" },
	{ tag = "Root", path = "C:", key = "c" },
	{ tag = "Downloads", path = "~/Downloads", key = "d" },
	{ tag = "Documents", path = "~/Documents", key = "D" },
	{ tag = "Pictures", path = "~/Pictures", key = "p" },
	{ tag = "Videos", path = "~/Videos", key = "v" },
	{ tag = "Music", path = "~/Music", key = "m" },
	{ tag = "Yazi config", path = "~/AppData/Roaming/yazi/config", key = "y" },
	{ tag = "Neovim config", path = "~/AppData/Local/nvim", key = "n" },
	{ tag = "Notes", path = "~/ServerSync/Documents/notes", key = "t" },
	{ tag = "Server", path = "~/Drives/S", key = "s" },
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
