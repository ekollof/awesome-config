--[[

     Awesome WM configuration
     https://github.com/awesomeWM

     Vendored libraries:
       freedesktop : https://github.com/lcpz/awesome-freedesktop
       lain        : https://github.com/lcpz/lain

     Copycats themes : https://github.com/lcpz/awesome-copycats

--]]

-- {{{ Required libraries
local awesome, client = awesome, client
local string, os, tostring = string, os, tostring

--https://awesomewm.org/doc/api/documentation/05-awesomerc.md.html
-- Standard awesome library
local gears = require("gears") --Utilities such as color parsing and objects
local awful = require("awful") --Everything related to window managment
require("awful.autofocus")
-- Widget and layout library loaded in theme/screens modules

-- OS detection (used for portable power commands etc.)
_G._is_linux = io.open("/proc/version", "r") ~= nil
local _suspend_cmd  = _is_linux and "systemctl suspend"  or "acpiconf -s 3"
local _reboot_cmd   = _is_linux and "systemctl reboot"   or "shutdown -r now"
local _poweroff_cmd = _is_linux and "systemctl poweroff" or "shutdown -p now"

-- Theme handling library
local beautiful = require("beautiful")

-- keep themes in alphabetical order for ATT
_G.themes = {
	"colorful", -- 1
	"copland", -- 2
	"powerarrow", -- 3
}

-- load persisted theme choice, fall back to default
local chosen_theme = _G.themes[2]
local theme_state_file = os.getenv("HOME") .. "/.cache/awesome/current_theme"
local fh = io.open(theme_state_file, "r")
if fh then
	local saved = fh:read("*line")
	fh:close()
	for _, t in ipairs(_G.themes) do
		if t == saved then
			chosen_theme = t
			break
		end
	end
end

-- Notification library
local naughty = require("naughty")
naughty.config.defaults["icon_size"] = 100

-- Notification behaviour
naughty.config.defaults.timeout      = 5
naughty.config.defaults.position     = "top_right"

-- Fill in default icon and title if the sender didn't provide them
naughty.config.notify_callback = function(args)
    if not args.icon then
        args.icon = os.getenv("HOME") .. "/.config/awesome/themes/" .. chosen_theme .. "/icons/note.png"
    end
    if not args.title or args.title == "" then
        args.title = "Notification"
    end
    return args
end

-- Critical preset: use urgent colors, longer timeout
naughty.config.presets.critical.timeout  = 0  -- stay until dismissed
naughty.config.presets.critical.bg       = "#900000"
naughty.config.presets.critical.fg       = "#ffffff"
naughty.config.presets.critical.border_color = "#ff0000"

--local menubar       = require("menubar")

local freedesktop = require("freedesktop")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
local hotkeys_popup = require("awful.hotkeys_popup").widget
require("awful.hotkeys_popup.keys")
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility
local dpi = require("beautiful.xresources").apply_dpi
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- This function implements the XDG autostart specification
--[[
awful.spawn.with_shell(
    'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
    'xrdb -merge <<< "awesome.started:true";' ..
    -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
    'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
)
--]]

-- }}}

-- modkey or mod4 = super key
modkey = "Mod4"
local modkey = modkey
_G.altkey = "Mod1"
_G.modkey1 = "Control"

-- personal variables
--change these variables if you want
_G.browser1 = "brave"
_G.browser2 = "brave"
_G.browser3 = "brave"
_G.editor = os.getenv("EDITOR") or "nano"
_G.filemanager = "thunar"
_G.mediaplayer = "ncmpcpp"
_G.terminal = "kitty"

-- awesome variables
awful.util.terminal = terminal
awful.util.tagnames = { "➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒" }
--awful.util.tagnames = { "⠐", "⠡", "⠲", "⠵", "⠻", "⠿" }
--awful.util.tagnames = { "⌘", "♐", "⌥", "ℵ" }
--awful.util.tagnames = { "www", "edit", "gimp", "inkscape", "music" }
-- Use this : https://fontawesome.com/cheatsheet
--awful.util.tagnames = { "", "", "", "", "" }
awful.layout.suit.tile.left.mirror = true
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.floating,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	--awful.layout.suit.fair,
	--awful.layout.suit.fair.horizontal,
	--awful.layout.suit.spiral,
	--awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	--awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
	--awful.layout.suit.corner.nw,
	--awful.layout.suit.corner.ne,
	--awful.layout.suit.corner.sw,
	--awful.layout.suit.corner.se,
	--lain.layout.cascade,
	--lain.layout.cascade.tile,
	--lain.layout.centerwork,
	--lain.layout.centerwork.horizontal,
	--lain.layout.termfair,
	--lain.layout.termfair.center,
}

awful.util.taglist_buttons = my_table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local tasklist_menu_instance = nil
awful.util.tasklist_buttons = my_table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			--c:emit_signal("request::activate", "tasklist", {raise = true})<Paste>

			-- Without this, the following
			-- :isvisible() makes no sense
			c.minimized = false
			if not c:isvisible() and c.first_tag then
				c.first_tag:view_only()
			end
			-- This will also un-minimize
			-- the client, if needed
			client.focus = c
			c:raise()
		end
	end),
	awful.button({}, 3, function()
		if tasklist_menu_instance and tasklist_menu_instance.wibox.visible then
			tasklist_menu_instance:hide()
			tasklist_menu_instance = nil
		else
			tasklist_menu_instance = awful.menu.clients({ theme = { width = dpi(250) } })
		end
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)


beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))

-- Show which theme was loaded (helpful when multiple theme files look identical with wallust)
naughty.notify({
	title = "AwesomeWM",
	text = "Loaded theme: " .. chosen_theme,
	timeout = 3,
})

-- {{{ Systray Color Fix
-- Communicates theme colors to symbolic icons via X11 specification
local function set_systray_colors()
    local fg = beautiful.fg_normal or "#ffffff"
    local r, g, b = gears.color.parse_color(fg)
    local r16, g16, b16 = math.floor(r * 65535), math.floor(g * 65535), math.floor(b * 65535)
    local color_str = string.format("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
        r16, g16, b16, r16, g16, b16, r16, g16, b16, r16, g16, b16
    )

    -- Find all tray manager windows and set the property there (where apps actually look)
    local cmd = "xwininfo -root -tree | grep 'Awesome systray window' | sed 's/^[[:space:]]*//' | cut -d' ' -f1"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
        for window_id in stdout:gmatch("0x%x+") do
            awful.spawn.with_shell(string.format("xprop -id %s -f _NET_SYSTEM_TRAY_COLORS 32c -set _NET_SYSTEM_TRAY_COLORS %s", window_id, color_str))
        end
        -- Also set on root as a fallback for some older apps
        awful.spawn.with_shell("xprop -root -f _NET_SYSTEM_TRAY_COLORS 32c -set _NET_SYSTEM_TRAY_COLORS " .. color_str)
    end)
end

-- Run once on startup/restart (delayed to ensure tray windows exist)
gears.timer.delayed_call(set_systray_colors)
-- }}}

-- {{{ Menu
local myawesomemenu = {
	{
		"hotkeys",
		function()
			return false, hotkeys_popup.show_help
		end,
	},
	{ "arandr", "arandr" },
}

awful.util.mymainmenu = freedesktop.menu.build({
	before = {
		{ "Awesome", myawesomemenu },
		--{ "Atom", "atom" },
		-- other triads can be put here
	},
	after = {
		{ "Terminal", terminal },
		{
			"Log out",
			function()
				awesome.quit()
			end,
		},
		{ "Sleep",    _suspend_cmd },
		{ "Restart",  _reboot_cmd },
		{ "Shutdown", _poweroff_cmd },
		-- other triads can be put here
	},
})
-- hide menu when mouse leaves it
--awful.util.mymainmenu.wibox:connect_signal("mouse::leave", function() awful.util.mymainmenu:hide() end)

--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it
-- }}}

-- {{{ Mouse bindings
root.buttons(my_table.join(
	awful.button({}, 3, function()
		awful.util.mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- }}} Variable definitions

-- {{{ Persistence (load before screens so restore is ready)
local persistence = require("widgets.client_persistence")
persistence.load()
-- }}}

-- {{{ Load modular configuration
local keys = require("config.keys")
clientkeys = keys.clientkeys
require("config.rules")
require("config.screens")

-- Set global keys
root.keys(keys.globalkeys)
-- }}}
