--[[
    Key bindings configuration.

    Depends on globals set by rc.lua: modkey, altkey, modkey1, terminal,
    browser1, browser2, browser3, editor, filemanager, mediaplayer, _is_linux
--]]

local awful   = require("awful")
local gears   = require("gears")
local lain    = require("lain")
local naughty = require("naughty")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local my_table = awful.util.table or gears.table

-- ---------------------------------------------------------------------------
-- Global keys
-- ---------------------------------------------------------------------------

globalkeys = my_table.join(

	-- {{{ Personal keybindings
	awful.key({ modkey }, "w", function()
		awful.util.spawn(browser1)
	end, { description = browser1, group = "function keys" }),
	-- dmenu
	awful.key({ modkey, "Shift" }, "d", function()
		awful.spawn(
			string.format(
				"dmenu_run -i -nb '#191919' -nf '#fea63c' -sb '#fea63c' -sf '#191919' -fn NotoMonoRegular:bold:pixelsize=14",
				beautiful.bg_normal,
				beautiful.fg_normal,
				beautiful.bg_focus,
				beautiful.fg_focus
			)
		)
	end, { description = "show dmenu", group = "hotkeys" }),

	-- Function keys
	awful.key({}, "F12", function()
		awful.util.spawn("xfce4-terminal --drop-down")
	end, { description = "dropdown terminal", group = "function keys" }),

	-- super + ... function keys
	awful.key({ modkey }, "F1", function()
		awful.util.spawn(browser1)
	end, { description = browser1, group = "function keys" }),
	-- awful.key({ modkey }, "F2", function() awful.util.spawn(editorgui) end,  -- atom not installed
	-- { description = editorgui, group = "function keys" }),
	-- awful.key({ modkey }, "F3", function() awful.util.spawn("inkscape") end,  -- inkscape not installed
	-- { description = "inkscape", group = "function keys" }),
	awful.key({ modkey }, "F4", function()
		awful.util.spawn("gimp")
	end, { description = "gimp", group = "function keys" }),
	-- awful.key({ modkey }, "F5", function() awful.util.spawn("meld") end,  -- meld not installed
	-- { description = "meld", group = "function keys" }),
	awful.key({ modkey }, "F6", function()
		awful.util.spawn("vlc --video-on-top")
	end, { description = "vlc", group = "function keys" }),
	-- awful.key({ modkey }, "F7", function() awful.util.spawn("virtualbox") end,  -- virtualbox not installed
	-- { description = virtualmachine, group = "function keys" }),
	awful.key({ modkey }, "F8", function()
		awful.util.spawn(filemanager)
	end, { description = filemanager, group = "function keys" }),
	-- awful.key({ modkey }, "F9", function() awful.util.spawn(mailclient) end,  -- evolution not installed
	-- { description = mailclient, group = "function keys" }),
	awful.key({ modkey }, "F10", function()
		awful.util.spawn(mediaplayer)
	end, { description = mediaplayer, group = "function keys" }),
	awful.key({ modkey }, "F11", function()
		awful.util.spawn("rofi -theme-str 'window {width: 100%;height: 100%;}' -show drun")
	end, { description = "rofi fullscreen", group = "function keys" }),
	awful.key({ modkey }, "F12", function()
		awful.util.spawn("rofi -show drun")
	end, { description = "rofi", group = "function keys" }),

	-- super + ...
	-- awful.key({ modkey }, "c", function() awful.util.spawn("conky-toggle") end,  -- conky not installed
	-- { description = "conky-toggle", group = "super" }),
	-- awful.key({ modkey, modkey1 }, "c", function() awful.util.spawn("killall conky") end,  -- conky not installed
	-- { description = "conky killall", group = "super" }),
	-- awful.key({ modkey }, "e", function() awful.util.spawn(editorgui) end,  -- atom not installed
	-- { description = "run gui editor", group = "super" }),
	awful.key({ modkey }, "r", function()
		awful.util.spawn("rofi-theme-selector")
	end, { description = "rofi theme selector", group = "super" }),
	awful.key({ modkey }, "t", function()
		awful.util.spawn(terminal)
	end, { description = "terminal", group = "super" }),
	awful.key({ modkey }, "v", function()
		awful.util.spawn("pavucontrol")
	end, { description = "pulseaudio control", group = "super" }),
	-- awful.key({ modkey }, "x", function() awful.util.spawn("archlinux-logout") end,  -- not installed
	-- { description = "exit", group = "hotkeys" }),
	awful.key({ modkey }, "Escape", function()
		awful.util.spawn("xkill")
	end, { description = "Kill proces", group = "hotkeys" }),

	-- super + shift + ...
	awful.key({ modkey, "Shift" }, "Return", function()
		awful.util.spawn(filemanager)
	end),

	-- ctrl + shift + ...
	awful.key({ modkey1, "Shift" }, "Escape", function()
		awful.util.spawn("xfce4-taskmanager")
	end),

	-- ctrl+alt +  ...
	-- awful.key({ modkey1, altkey }, "w", function() awful.util.spawn("arcolinux-welcome-app") end,  -- not installed
	-- { description = "ArcoLinux Welcome App", group = "alt+ctrl" }),
	-- awful.key({ modkey1, altkey }, "e", function() awful.util.spawn("archlinux-tweak-tool") end,  -- not installed
	-- { description = "ArcoLinux Tweak Tool", group = "alt+ctrl" }),
	-- awful.key({ modkey1, altkey }, "Next", function() awful.util.spawn("conky-rotate -n") end,  -- not installed
	-- { description = "Next conky rotation", group = "alt+ctrl" }),
	-- awful.key({ modkey1, altkey }, "Prior", function() awful.util.spawn("conky-rotate -p") end,  -- not installed
	-- { description = "Previous conky rotation", group = "alt+ctrl" }),
	awful.key({ modkey1, altkey }, "a", function()
		awful.util.spawn("xfce4-appfinder")
	end, { description = "Xfce appfinder", group = "alt+ctrl" }),
	awful.key({ modkey1, altkey }, "b", function()
		awful.util.spawn(filemanager)
	end, { description = filemanager, group = "alt+ctrl" }),
	-- awful.key({ modkey1, altkey }, "c", function() awful.util.spawn("catfish") end,  -- not installed
	-- { description = "catfish", group = "alt+ctrl" }),
	awful.key({ modkey1, altkey }, "f", function()
		awful.util.spawn(browser2)
	end, { description = browser2, group = "alt+ctrl" }),
	awful.key({ modkey1, altkey }, "g", function()
		awful.util.spawn(browser3)
	end, { description = browser3, group = "alt+ctrl" }),
	-- awful.key({ modkey1, altkey }, "i", function() awful.util.spawn("nitrogen") end,  -- not installed
	-- { description = "nitrogen", group = "alt+ctrl" }),
	-- awful.key({ modkey1, altkey }, "k", function() awful.util.spawn("archlinux-logout") end,  -- not installed
	-- { description = "archlinux-logout", group = "alt+ctrl" }),
	-- awful.key({ modkey1, altkey }, "l", function() awful.util.spawn("archlinux-logout") end,  -- not installed
	-- { description = "archlinux-logout", group = "alt+ctrl" }),
	awful.key({ modkey1, altkey }, "o", function()
		awful.spawn.with_shell("$HOME/.config/awesome/scripts/picom-toggle.sh")
	end, { description = "Picom toggle", group = "alt+ctrl" }),
	awful.key({ modkey1, altkey }, "s", function()
		awful.util.spawn(mediaplayer)
	end, { description = mediaplayer, group = "alt+ctrl" }),
	awful.key({ modkey1, altkey }, "t", function()
		awful.util.spawn(terminal)
	end, { description = terminal, group = "alt+ctrl" }),
	awful.key({ modkey1, altkey }, "u", function()
		awful.util.spawn("pavucontrol")
	end, { description = "pulseaudio control", group = "alt+ctrl" }),
	awful.key({ modkey1, altkey }, "v", function()
		awful.util.spawn(browser1)
	end, { description = browser1, group = "alt+ctrl" }),
	awful.key({ modkey1, altkey }, "Return", function()
		awful.util.spawn(terminal)
	end, { description = terminal, group = "alt+ctrl" }),
	awful.key({ modkey1, altkey }, "m", function()
		awful.util.spawn("xfce4-settings-manager")
	end, { description = "Xfce settings manager", group = "alt+ctrl" }),
	-- awful.key({ modkey1, altkey }, "p", function() awful.util.spawn("pamac-manager") end,  -- not installed
	-- { description = "Pamac Manager", group = "alt+ctrl" }),

	-- alt + ...
	-- variety keybindings commented out — variety not installed
	-- awful.key({ altkey, "Shift" }, "t", ...
	-- awful.key({ altkey, "Shift" }, "n", ...
	-- awful.key({ altkey, "Shift" }, "u", ...
	-- awful.key({ altkey, "Shift" }, "p", ...
	-- awful.key({ altkey }, "t", ...
	-- awful.key({ altkey }, "n", ...
	-- awful.key({ altkey }, "p", ...
	-- awful.key({ altkey }, "f", ...
	-- awful.key({ altkey }, "Left", ...
	-- awful.key({ altkey }, "Right", ...
	-- awful.key({ altkey }, "Up", ...
	-- awful.key({ altkey }, "Down", ...
	awful.key({ altkey }, "F2", function()
		awful.util.spawn("xfce4-appfinder --collapsed")
	end, { description = "Xfce appfinder", group = "altkey" }),
	awful.key({ altkey }, "F3", function()
		awful.util.spawn("xfce4-appfinder")
	end, { description = "Xfce appfinder", group = "altkey" }),

	-- screenshots
	awful.key({}, "Print", function()
		awful.util.spawn("scrot 'ArcoLinux-%Y-%m-%d-%s_screenshot_$wx$h.jpg' -e 'mv $f $$(xdg-user-dir PICTURES)'")
	end, { description = "Scrot", group = "screenshots" }),
	awful.key({ modkey1 }, "Print", function()
		awful.util.spawn("xfce4-screenshooter")
	end, { description = "Xfce screenshot", group = "screenshots" }),
	-- awful.key({ modkey1, "Shift" }, "Print", function() awful.util.spawn("gnome-screenshot -i") end,  -- not installed
	-- { description = "Gnome screenshot", group = "screenshots" }),

	-- Personal keybindings}}}

	-- Hotkeys Awesome

	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),

	-- Tag browsing with modkey
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ altkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

	-- Alt+Tab / Shift+Alt+Tab: cycle clients on the current tag by LRU order
	-- Forward (Alt+Tab) focuses the next-most-recently-used client.
	-- Backward (Shift+Alt+Tab) focuses the least-recently-used client.
	awful.key({ altkey }, "Tab", function()
		local s = awful.screen.focused()
		local t = s.selected_tag
		if not t then return end
		local clients, seen = {}, {}
		for _, c in ipairs(awful.client.focus.history.list) do
			if (not c.minimized or c._max_auto_minimized) and c.screen == s then
				for _, ct in ipairs(c:tags()) do
					if ct == t and not seen[c] then
						seen[c] = true
						clients[#clients + 1] = c
					end
				end
			end
		end
		for _, c in ipairs(t:clients()) do
			if (not c.minimized or c._max_auto_minimized) and not seen[c] then
				clients[#clients + 1] = c
			end
		end
		if #clients < 2 then return end
		clients[2]:emit_signal("request::activate", "key.unminimize", { raise = true })
	end, { description = "focus next client by LRU", group = "client" }),

	awful.key({ altkey, "Shift" }, "Tab", function()
		local s = awful.screen.focused()
		local t = s.selected_tag
		if not t then return end
		local clients, seen = {}, {}
		for _, c in ipairs(awful.client.focus.history.list) do
			if (not c.minimized or c._max_auto_minimized) and c.screen == s then
				for _, ct in ipairs(c:tags()) do
					if ct == t and not seen[c] then
						seen[c] = true
						clients[#clients + 1] = c
					end
				end
			end
		end
		for _, c in ipairs(t:clients()) do
			if (not c.minimized or c._max_auto_minimized) and not seen[c] then
				clients[#clients + 1] = c
			end
		end
		if #clients < 2 then return end
		clients[#clients]:emit_signal("request::activate", "key.unminimize", { raise = true })
	end, { description = "focus previous client by LRU", group = "client" }),

	-- Tag browsing modkey + tab
	awful.key({ modkey }, "Tab", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey, "Shift" }, "Tab", awful.tag.viewprev, { description = "view previous", group = "tag" }),

	-- Non-empty tag browsing
	--awful.key({ modkey }, "Left", function () lain.util.tag_view_nonempty(-1) end,
	--{description = "view  previous nonempty", group = "tag"}),
	-- awful.key({ modkey }, "Right", function () lain.util.tag_view_nonempty(1) end,
	-- {description = "view  next nonempty", group = "tag"}),

	-- Default client focus
	awful.key({ altkey }, "j", function()
        local s = awful.screen.focused()
        if awful.layout.get(s) == awful.layout.suit.max then
            local t = s.selected_tag
            if not t then return end
            local clients = t:clients()
            if #clients < 2 then return end
            local index = gears.table.find_first_index(clients, client.focus) or 0
            local next_c = clients[gears.math.cycle(#clients, index + 1)]
            if next_c then
                next_c:emit_signal("request::activate", "key.byidx", { raise = true })
            end
        else
            awful.client.focus.byidx(1)
        end
	end, { description = "focus next by index", group = "client" }),
	awful.key({ altkey }, "k", function()
        local s = awful.screen.focused()
        if awful.layout.get(s) == awful.layout.suit.max then
            local t = s.selected_tag
            if not t then return end
            local clients = t:clients()
            if #clients < 2 then return end
            local index = gears.table.find_first_index(clients, client.focus) or 0
            local prev_c = clients[gears.math.cycle(#clients, index - 1)]
            if prev_c then
                prev_c:emit_signal("request::activate", "key.byidx", { raise = true })
            end
        else
            awful.client.focus.byidx(-1)
        end
	end, { description = "focus previous by index", group = "client" }),

	-- By direction client focus
	awful.key({ modkey }, "j", function()
		awful.client.focus.global_bydirection("down")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus down", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.global_bydirection("up")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus up", group = "client" }),
	awful.key({ modkey }, "h", function()
		awful.client.focus.global_bydirection("left")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus left", group = "client" }),
	awful.key({ modkey }, "l", function()
		awful.client.focus.global_bydirection("right")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus right", group = "client" }),

	-- By direction client focus with arrows
	awful.key({ modkey1, modkey }, "Down", function()
		awful.client.focus.global_bydirection("down")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus down", group = "client" }),
	awful.key({ modkey1, modkey }, "Up", function()
		awful.client.focus.global_bydirection("up")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus up", group = "client" }),
	awful.key({ modkey1, modkey }, "Left", function()
		awful.client.focus.global_bydirection("left")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus left", group = "client" }),
	awful.key({ modkey1, modkey }, "Right", function()
		awful.client.focus.global_bydirection("right")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus right", group = "client" }),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ modkey1 }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	-- Show/Hide Wibox
	awful.key({ modkey }, "b", function()
		for s in screen do
			s.mywibox.visible = not s.mywibox.visible
			if s.mybottomwibox then
				s.mybottomwibox.visible = not s.mybottomwibox.visible
			end
		end
	end, { description = "toggle wibox", group = "awesome" }),

	-- Show/Hide Systray
	awful.key({ modkey }, "-", function()
		awful.screen.focused().systray.visible = not awful.screen.focused().systray.visible
	end, { description = "Toggle systray visibility", group = "awesome" }),

	-- Show/Hide Systray
	awful.key({ modkey }, "KP_Subtract", function()
		awful.screen.focused().systray.visible = not awful.screen.focused().systray.visible
	end, { description = "Toggle systray visibility", group = "awesome" }),

	-- On the fly useless gaps change
	awful.key({ altkey, "Control" }, "j", function()
		lain.util.useless_gaps_resize(1)
	end, { description = "increment useless gaps", group = "tag" }),
	awful.key({ altkey, "Control" }, "h", function()
		lain.util.useless_gaps_resize(-1)
	end, { description = "decrement useless gaps", group = "tag" }),

	-- Dynamic tagging
	awful.key({ modkey, "Shift" }, "n", function()
		lain.util.add_tag()
	end, { description = "add new tag", group = "tag" }),
	awful.key({ modkey, "Control" }, "r", function()
		lain.util.rename_tag()
	end, { description = "rename tag", group = "tag" }),
	-- awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(-1) end,
	--          {description = "move tag to the left", group = "tag"}),
	-- awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(1) end,
	--          {description = "move tag to the right", group = "tag"}),
	awful.key({ modkey, "Shift" }, "y", function()
		lain.util.delete_tag()
	end, { description = "delete tag", group = "tag" }),

	-- Standard program
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = terminal, group = "super" }),
	awful.key({ modkey, "Shift" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, modkey1 }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

	-- Theme picker
	awful.key({ modkey, "Shift" }, "t", function()
		local theme_menu_items = {}
		-- read current theme so we can mark it with a check
		local current_theme = nil
		local fh = io.open(os.getenv("HOME") .. "/.cache/awesome/current_theme", "r")
		if fh then
			current_theme = fh:read("*line")
			fh:close()
		end
		for _, t in ipairs(_G.themes) do
			local label = (t == current_theme) and ("✓ " .. t) or t
			table.insert(theme_menu_items, {
				label,
				function()
					local state_dir = os.getenv("HOME") .. "/.cache/awesome"
					local state_file = state_dir .. "/current_theme"
					awful.spawn.easy_async_with_shell(
						string.format("mkdir -p %q && printf %q > %q && sync", state_dir, t, state_file),
						function(stdout, stderr, reason, exit_code)
							if exit_code == 0 then
								naughty.notify({
									title = "Theme changed",
									text = "Restarting AwesomeWM with theme: " .. t,
									timeout = 2,
								})
								awesome.restart()
							else
								naughty.notify({
									title = "Theme save failed",
									text = stderr or "unknown error",
									preset = naughty.config.presets.critical,
								})
							end
						end
					)
				end,
			})
		end
		local theme_menu = awful.menu({ items = theme_menu_items, theme = { width = 220 } })
		theme_menu:show()
	end, { description = "pick theme", group = "awesome" }),

	awful.key({ altkey, "Shift" }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ altkey, "Shift" }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	--awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
	-- {description = "select previous", group = "layout"}),

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			client.focus = c
			c:raise()
		end
	end, { description = "restore minimized", group = "client" }),

	-- Widgets popups
	--awful.key({ altkey, }, "c", function () lain.widget.calendar.show(7) end,
	--{description = "show calendar", group = "widgets"}),
	--awful.key({ altkey, }, "h", function () if beautiful.fs then beautiful.fs.show(7) end end,
	--{description = "show filesystem", group = "widgets"}),
	--awful.key({ altkey, }, "w", function () if beautiful.weather then beautiful.weather.show(7) end end,
	--{description = "show weather", group = "widgets"}),

	-- Brightness
	awful.key({}, "XF86MonBrightnessUp", function()
        if _is_linux then
            awful.spawn.with_shell("xbacklight -inc 10 || light -A 10")
        else
            awful.spawn.with_shell("backlight +10 2>/dev/null || intel_backlight incr 10 2>/dev/null")
        end
	end, { description = "+10%", group = "hotkeys" }),
	awful.key({}, "XF86MonBrightnessDown", function()
        if _is_linux then
            awful.spawn.with_shell("xbacklight -dec 10 || light -U 10")
        else
            awful.spawn.with_shell("backlight -10 2>/dev/null || intel_backlight decr 10 2>/dev/null")
        end
	end, { description = "-10%", group = "hotkeys" }),

	-- PulseAudio/PipeWire volume control
	--awful.key({ modkey1 }, "Up",
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ +1%")
		beautiful.volume_notify()
	end),
	--awful.key({ modkey1 }, "Down",
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ -1%")
		beautiful.volume_notify()
	end),
	awful.key({}, "XF86AudioMute", function()
		awful.spawn.with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle")
		beautiful.volume_notify()
	end),
	awful.key({ modkey1, "Shift" }, "m", function()
		awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ 100%")
		beautiful.volume_notify()
	end),
	awful.key({ modkey1, "Shift" }, "0", function()
		awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ 0%")
		beautiful.volume_notify()
	end),

	--Media keys supported by vlc, spotify, audacious, xmm2, ...
	--awful.key({}, "XF86AudioPlay", function() awful.util.spawn("playerctl play-pause", false) end),
	--awful.key({}, "XF86AudioNext", function() awful.util.spawn("playerctl next", false) end),
	--awful.key({}, "XF86AudioPrev", function() awful.util.spawn("playerctl previous", false) end),
	--awful.key({}, "XF86AudioStop", function() awful.util.spawn("playerctl stop", false) end),

	--Media keys supported by mpd.
	awful.key({}, "XF86AudioPlay", function()
		awful.util.spawn("mpc toggle")
	end),
	awful.key({}, "XF86AudioNext", function()
		awful.util.spawn("mpc next")
	end),
	awful.key({}, "XF86AudioPrev", function()
		awful.util.spawn("mpc prev")
	end),
	awful.key({}, "XF86AudioStop", function()
		awful.util.spawn("mpc stop")
	end),

	-- MPD control
	awful.key({ modkey1, "Shift" }, "Up", function()
		awful.spawn.with_shell("mpc toggle")
		beautiful.mpd.update()
	end, { description = "mpc toggle", group = "widgets" }),
	awful.key({ modkey1, "Shift" }, "Down", function()
		awful.spawn.with_shell("mpc stop")
		beautiful.mpd.update()
	end, { description = "mpc stop", group = "widgets" }),
	awful.key({ modkey1, "Shift" }, "Left", function()
		awful.spawn.with_shell("mpc prev")
		beautiful.mpd.update()
	end, { description = "mpc prev", group = "widgets" }),
	awful.key({ modkey1, "Shift" }, "Right", function()
		awful.spawn.with_shell("mpc next")
		beautiful.mpd.update()
	end, { description = "mpc next", group = "widgets" }),
	awful.key({ modkey1, "Shift" }, "s", function()
		local common = { text = "MPD widget ", position = "top_middle", timeout = 2 }
		if beautiful.mpd.timer.started then
			beautiful.mpd.timer:stop()
			common.text = common.text .. lain.util.markup.bold("OFF")
		else
			beautiful.mpd.timer:start()
			common.text = common.text .. lain.util.markup.bold("ON")
		end
		naughty.notify(common)
	end, { description = "mpc on/off", group = "widgets" }),

	-- Copy primary to clipboard (terminals to gtk)
	--awful.key({ modkey }, "c", function () awful.spawn.with_shell("xsel | xsel -i -b") end,
	-- {description = "copy terminal to gtk", group = "hotkeys"}),
	--Copy clipboard to primary (gtk to terminals)
	--awful.key({ modkey }, "v", function () awful.spawn.with_shell("xsel -b | xsel") end,
	--{description = "copy gtk to terminal", group = "hotkeys"}),

	-- Default
	--[[ Menubar

    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "super"})
    --]]

	awful.key({ altkey }, "x", function()
		awful.prompt.run({
			prompt = "Run Lua code: ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval",
		})
	end, { description = "lua execute prompt", group = "awesome" })
	--]]
)

-- ---------------------------------------------------------------------------
-- Client keys
-- ---------------------------------------------------------------------------

clientkeys = my_table.join(
	awful.key({ altkey, "Shift" }, "m", lain.util.magnify_client, { description = "magnify client", group = "client" }),
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey, "Shift" }, "q", function(c)
		c:kill()
	end, { description = "close", group = "hotkeys" }),
	awful.key({ modkey }, "q", function(c)
		c:kill()
	end, { description = "close", group = "hotkeys" }),
	awful.key(
		{ modkey, "Shift" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),

	-- Reset window to default tiled state (clears maximized, fullscreen, floating, ontop, sticky)
	awful.key({ modkey }, "F5", function(c)
		c.maximized            = false
		c.maximized_horizontal = false
		c.maximized_vertical   = false
		c.fullscreen           = false
		c.floating             = false
		c.ontop                = false
		c.sticky               = false
		c.minimized            = false
		c._max_auto_minimized  = false
		c:raise()
	end, { description = "reset window to default tiled state", group = "client" }),
	awful.key({ modkey, "Shift" }, "Left", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),
	awful.key({ modkey, "Shift" }, "Right", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),
	--awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
	--{description = "toggle keep on top", group = "client"}),
	awful.key({ modkey }, "n", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "maximize", group = "client" })
)

-- ---------------------------------------------------------------------------
-- Tag number keys (1–9)
-- ---------------------------------------------------------------------------

for i = 1, 9 do
	-- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
	local descr_view, descr_toggle, descr_move, descr_toggle_focus
	if i == 1 or i == 9 then
		descr_view = { description = "view tag #", group = "tag" }
		descr_toggle = { description = "toggle tag #", group = "tag" }
		descr_move = { description = "move focused client to tag #", group = "tag" }
		descr_toggle_focus = { description = "toggle focused client on tag #", group = "tag" }
	end
	globalkeys = my_table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, descr_view),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, descr_toggle),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
					tag:view_only()
				end
			end
		end, descr_move),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, descr_toggle_focus)
	)
end

-- ---------------------------------------------------------------------------
-- Wallpaper & lock hotkeys (appended after tag keys)
-- ---------------------------------------------------------------------------

globalkeys = my_table.join(
	globalkeys,
	awful.key({ "Control", "Mod1" }, "w",
		function() awful.spawn.with_shell("~/bin/wallpaper") end,
		{ description = "set random wallpaper", group = "wallpaper" }),
	awful.key({ "Control", "Mod1", "Shift" }, "w",
		function() awful.spawn.with_shell("~/bin/wallpaper -R") end,
		{ description = "reload current wallpaper", group = "wallpaper" })
)

globalkeys = my_table.join(
	globalkeys,
	awful.key({ "Control", "Mod1" }, "l",
		function()
			awful.spawn.with_shell(os.getenv("HOME") .. "/.config/awesome/scripts/lock.sh")
		end,
		{ description = "lock screen", group = "awesome" })
)

-- ---------------------------------------------------------------------------
-- Client mouse buttons
-- ---------------------------------------------------------------------------

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Expose to rc.lua
return {
	globalkeys  = globalkeys,
	clientkeys  = clientkeys,
	clientbuttons = clientbuttons,
}
