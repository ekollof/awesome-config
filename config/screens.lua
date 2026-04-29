--[[
    Screen setup, client signals, and autostart.

    Loaded by rc.lua after keys, rules, and persistence are initialised.
--]]

local awful       = require("awful")
local gears       = require("gears")
local beautiful   = require("beautiful")
local naughty     = require("naughty")
local wibox       = require("wibox")
local lain        = require("lain")
local my_table    = awful.util.table or gears.table
local dpi         = require("beautiful.xresources").apply_dpi
local persistence = require("widgets.client_persistence")

-- ---------------------------------------------------------------------------
-- Screen signals
-- ---------------------------------------------------------------------------

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.fit(wallpaper, s, beautiful.bg_normal)
	end
end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function(s)
	local only_one = #s.tiled_clients == 1
	for _, c in pairs(s.clients) do
		if (only_one and not c.floating) or c.maximized then
			c.border_width = 2
		else
			c.border_width = beautiful.border_width
		end
	end
end)

-- In max layout, minimize unfocused tiled clients (like DWM) so their
-- transparency doesn't bleed through the focused window.
-- We tag auto-minimized clients so we don't accidentally restore ones the
-- user minimized intentionally.
local function max_layout_minimize(s)
	local layout = awful.layout.get(s)
	local is_max = (layout == awful.layout.suit.max or
	                layout == awful.layout.suit.max.fullscreen)
	local focused = client.focus

	-- If we're in max layout, we must ensure at least one client is visible.
	-- If nothing is focused on this screen, or the focused client is not on
	-- the current tag, we pick the first available client to be "visible".
	local target_visible = focused
	if is_max and (not focused or focused.screen ~= s or not focused:isvisible()) then
		local t = s.selected_tag
		if t then
			-- 1. Try to find the most recently focused client on this tag from history
			local history = awful.client.focus.history.list
			for _, c in ipairs(history) do
				if c.screen == s and not c.floating then
					for _, ct in ipairs(c:tags()) do
						if ct == t then
							target_visible = c
							break
						end
					end
				end
				if target_visible ~= focused then break end
			end

			-- 2. Fallback to first available tiled client if history search fails
			if target_visible == focused or not target_visible then
				local cls = t:clients()
				for _, c in ipairs(cls) do
					if not c.floating then
						target_visible = c
						break
					end
				end
			end

			-- Force focus if we are switching to this tag
			if target_visible and target_visible ~= focused then
				client.focus = target_visible
				target_visible:raise()
			end
		end
	end

	for _, c in ipairs(s.clients) do
		if not c.floating then
			if is_max and c ~= target_visible then
				if not c.minimized then
					c.minimized = true
					c._max_auto_minimized = true
				end
			elseif c._max_auto_minimized then
				c.minimized = false
				c._max_auto_minimized = false
			end
		end
	end
end
screen.connect_signal("arrange", max_layout_minimize)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s)
 end)

-- ---------------------------------------------------------------------------
-- Client signals
-- ---------------------------------------------------------------------------

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end

	-- Restore screen, tags, and geometry from the previous session.
	persistence.restore(c)
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- Custom
	if beautiful.titlebar_fun then
		beautiful.titlebar_fun(c)
		return
	end

	-- Default
	-- buttons for the titlebar
	local buttons = my_table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c, { size = dpi(21) }):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
	-- In max layout, unminimize this client if we auto-minimized it.
	if c._max_auto_minimized then
		c.minimized = false
		c._max_auto_minimized = false
	end
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

-- Notify when a client becomes urgent, but only if it isn't already focused.
client.connect_signal("property::urgent", function(c)
	if c.urgent and c ~= client.focus then
		naughty.notify({
			title   = "Needs attention",
			text    = (c.class or "A window") .. (c.name and (": " .. c.name) or ""),
			timeout = 8,
			screen  = c.screen,
			icon    = c.icon,
		})
	end
end)

-- Persist window placement when moved between screens or tags.
client.connect_signal("property::screen", function(c)
    persistence.record(c)
end)
client.connect_signal("property::tags", function(c)
    persistence.record(c)
end)
client.connect_signal("unmanage", function(c)
    persistence.forget(c)
end)

-- Flush state before restart or quit.
awesome.connect_signal("exit", function()
    persistence.save_all()
end)

-- ---------------------------------------------------------------------------
-- Autostart
-- ---------------------------------------------------------------------------

-- Run a command only if it's not already running
local function run_once(cmd)
    local bin = cmd:match("^%S+")
    awful.spawn.easy_async_with_shell(
        string.format("pgrep -f %q", bin),
        function(_, _, _, code)
            if code ~= 0 then
                awful.spawn.with_shell(cmd)
            end
        end
    )
end

-- Autostart: defer until the event loop is running
awful.spawn.easy_async_with_shell("true", function()
    -- Windowless processes
    run_once("unclutter -root")

    -- XDG autostart entries (skip picom — launched below with our config)
    awful.spawn.easy_async_with_shell("$HOME/bin/autostart list 2>/dev/null", function(stdout)
        for cmd in stdout:gmatch("  [^\n]+%.desktop: ([^\n]+)") do
            if not cmd:match("^picom") then
                run_once(cmd)
            end
        end
    end)

    run_once("picom -b --config " .. os.getenv("HOME") .. "/.config/awesome/picom.conf")

    -- Screen locker: kill any existing xss-lock (e.g. from a previous awesome
    -- restart) then relaunch so it always uses the current lock.sh.
    local lock_script = os.getenv("HOME") .. "/.config/awesome/scripts/lock.sh"
    awful.spawn.easy_async_with_shell("pkill -x xss-lock; sleep 0.2", function()
        awful.spawn.with_shell("xss-lock --transfer-sleep-lock -- " .. lock_script)
    end)
end)
