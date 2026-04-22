--[[

     Powerarrow Awesome WM theme
     github.com/lcpz

--]]

local gears = require("gears")
local lain  = require("lain")
local awful   = require("awful")
local wibox   = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local pacman  = require("pacmanwidget")
pacman_widget_hook = function() pacman.hook() end  -- global for pacman hook
local weather_api = require("awesome-wm-widgets.weather-api-widget.weather")
local dpi     = require("beautiful.xresources").apply_dpi

local math, string, os = math, string, os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme                                     = {}
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/themes/powerarrow"

-- Load wallust-generated colors (falls back to built-in defaults if not found)
local wallust_colors_path = os.getenv("HOME") .. "/.cache/wal/awesome-colors.lua"
local wallust_ok, wc = pcall(dofile, wallust_colors_path)
if not wallust_ok then wc = {} end

theme.wallpaper                                 = wc.wallpaper or theme.dir .. "/wall.png"
theme.font                                      = "BerkeleyMono Nerd Font 9"
local font10                                    = "BerkeleyMono Nerd Font 10"
theme.fg_normal                                 = wc.foreground  or "#FEFEFE"
theme.fg_focus                                  = wc.color6      or "#32D6FF"
theme.fg_urgent                                 = wc.color1      or "#C83F11"
theme.bg_normal                                 = wc.background  or "#222222"
theme.bg_focus                                  = wc.color0      or "#1E2320"
theme.bg_urgent                                 = wc.color8      or "#3F3F3F"
theme.taglist_fg_focus                          = wc.color4      or "#00CCFF"
theme.tasklist_bg_focus                         = wc.background  or "#222222"
theme.tasklist_fg_focus                         = wc.color4      or "#00CCFF"
theme.border_width                              = dpi(2)
theme.border_normal                             = wc.color8      or "#3F3F3F"
theme.border_focus                              = wc.color7      or "#6F6F6F"
theme.border_marked                             = wc.color3      or "#CC9393"
theme.titlebar_bg_focus                         = wc.color0      or "#3F3F3F"
theme.titlebar_bg_normal                        = wc.background  or "#3F3F3F"
theme.titlebar_fg_focus                         = wc.foreground  or theme.fg_focus
-- Notifications
theme.notification_font                         = "BerkeleyMono Nerd Font 10"
theme.notification_bg                           = wc.background  or "#222222"
theme.notification_fg                           = wc.foreground  or "#FEFEFE"
theme.notification_border_color                 = wc.color4      or "#00CCFF"
theme.notification_border_width                 = dpi(2)
theme.notification_icon_size                    = dpi(48)
theme.notification_max_width                    = dpi(400)
theme.notification_margin                       = dpi(8)
theme.notification_opacity                      = 0.95
theme.menu_height                               = dpi(16)
theme.menu_width                                = dpi(140)
theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"
theme.awesome_icon                              = theme.dir .. "/icons/awesome.png"
theme.taglist_squares_sel                       = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel                     = theme.dir .. "/icons/square_unsel.png"
theme.layout_tile                               = theme.dir .. "/icons/tile.png"
theme.layout_tileleft                           = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom                         = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop                            = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv                              = theme.dir .. "/icons/fairv.png"
theme.layout_fairh                              = theme.dir .. "/icons/fairh.png"
theme.layout_spiral                             = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle                            = theme.dir .. "/icons/dwindle.png"
theme.layout_max                                = theme.dir .. "/icons/max.png"
theme.layout_fullscreen                         = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier                          = theme.dir .. "/icons/magnifier.png"
theme.layout_floating                           = theme.dir .. "/icons/floating.png"
theme.widget_ac                                 = theme.dir .. "/icons/ac.png"
theme.widget_battery                            = theme.dir .. "/icons/battery.png"
theme.widget_battery_low                        = theme.dir .. "/icons/battery_low.png"
theme.widget_battery_empty                      = theme.dir .. "/icons/battery_empty.png"
theme.widget_brightness                         = theme.dir .. "/icons/brightness.png"
theme.widget_mem                                = theme.dir .. "/icons/mem.png"
theme.widget_cpu                                = theme.dir .. "/icons/cpu.png"
theme.widget_temp                               = theme.dir .. "/icons/temp.png"
theme.widget_net                                = theme.dir .. "/icons/net.png"
theme.widget_hdd                                = theme.dir .. "/icons/hdd.png"
theme.widget_music                              = theme.dir .. "/icons/note.png"
theme.widget_music_on                           = theme.dir .. "/icons/note_on.png"
theme.widget_music_pause                        = theme.dir .. "/icons/pause.png"
theme.widget_music_stop                         = theme.dir .. "/icons/stop.png"
theme.widget_vol                                = theme.dir .. "/icons/vol.png"
theme.widget_vol_low                            = theme.dir .. "/icons/vol_low.png"
theme.widget_vol_no                             = theme.dir .. "/icons/vol_no.png"
theme.widget_vol_mute                           = theme.dir .. "/icons/vol_mute.png"
theme.widget_mail                               = theme.dir .. "/icons/mail.png"
theme.widget_mail_on                            = theme.dir .. "/icons/mail_on.png"
theme.widget_task                               = theme.dir .. "/icons/task.png"
theme.widget_scissors                           = theme.dir .. "/icons/scissors.png"
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true
theme.useless_gap                               = 0
theme.titlebar_close_button_focus               = theme.dir .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = theme.dir .. "/icons/titlebar/close_normal.png"
theme.titlebar_ontop_button_focus_active        = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = theme.dir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = theme.dir .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_sticky_button_focus_active       = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = theme.dir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = theme.dir .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_floating_button_focus_active     = theme.dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = theme.dir .. "/icons/titlebar/floating_normal_inactive.png"
theme.titlebar_maximized_button_focus_active    = theme.dir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = theme.dir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.dir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.dir .. "/icons/titlebar/maximized_normal_inactive.png"

local markup = lain.util.markup
local separators = lain.util.separators
local spr = wibox.widget.textbox(" ")

-- Digital clock with date
local clock = wibox.widget.textclock(
    markup.font(theme.font, " %a %d %b  %H:%M "))

-- Pacman updates widget
local pacman_widget = pacman.create()

-- Calendar (attach to clock)
theme.cal = lain.widget.cal({
    attach_to = { clock },
    notification_preset = {
        font = font10,
        fg   = theme.fg_normal,
        bg   = theme.bg_normal
    }
})

-- ALSA volume
theme.volume = lain.widget.alsabar({
    --togglechannel = "IEC958,3",
    notification_preset = { font = font10, fg = theme.fg_normal },
})

-- MPD
local musicplr = awful.util.terminal .. " -title Music -g 130x34-320+16 -e ncmpcpp"
local mpdicon = wibox.widget.imagebox(theme.widget_music)
local mpd_toggle_guard = false
local mpd_prev_guard   = false
local mpd_next_guard   = false
local mpd_stop_guard   = false

local mpd_buttons = my_table.join(
    awful.button({ modkey }, 1, nil, function () awful.spawn.with_shell(musicplr) end),
    awful.button({ "Shift" }, 1, function ()
        if mpd_stop_guard then return end
        mpd_stop_guard = true
        awful.spawn.with_shell("mpc stop")
        theme.mpd.update()
        local t = timer({ timeout = 0.5 })
        t:connect_signal("timeout", function() t:stop(); mpd_stop_guard = false end)
        t:start()
    end, nil),
    awful.button({ }, 1, function ()
        if mpd_prev_guard then return end
        mpd_prev_guard = true
        awful.spawn.with_shell("mpc prev")
        theme.mpd.update()
        local t = timer({ timeout = 0.5 })
        t:connect_signal("timeout", function() t:stop(); mpd_prev_guard = false end)
        t:start()
    end, nil),
    awful.button({ }, 2, function ()
        if mpd_toggle_guard then return end
        mpd_toggle_guard = true
        awful.spawn.with_shell("mpc toggle")
        theme.mpd.update()
        local t = timer({ timeout = 0.5 })
        t:connect_signal("timeout", function() t:stop(); mpd_toggle_guard = false end)
        t:start()
    end, nil),
    awful.button({ }, 3, function ()
        if mpd_next_guard then return end
        mpd_next_guard = true
        awful.spawn.with_shell("mpc next")
        theme.mpd.update()
        local t = timer({ timeout = 0.5 })
        t:connect_signal("timeout", function() t:stop(); mpd_next_guard = false end)
        t:start()
    end, nil),
    awful.button({ }, 4, nil, function ()
        awful.spawn.with_shell("mpc volume +5")
        theme.mpd.update()
    end),
    awful.button({ }, 5, nil, function ()
        awful.spawn.with_shell("mpc volume -5")
        theme.mpd.update()
    end))
mpdicon:buttons(mpd_buttons)

-- Helper: format seconds as m:ss
local function fmt_time(s)
    s = tonumber(s) or 0
    return string.format("%d:%02d", math.floor(s / 60), s % 60)
end

-- Track change notification
local mpd_last_title = ""
local mpd_cover = "/tmp/mpd-cover-0.jpg"

local function mpd_fetch_cover(file, callback)
    -- write to a unique path each time to bypass awesome's image path cache
    local tmpfile = string.format("/tmp/mpd-cover-%d.jpg", os.time())
    awful.spawn.easy_async_with_shell(
        string.format("mpc readpicture %q > %s 2>/dev/null && echo ok", file, tmpfile),
        function(out)
            if out:match("ok") then
                mpd_cover = tmpfile
                callback(tmpfile)
            else
                callback(nil)
            end
        end
    )
end

theme.mpd = lain.widget.mpd({
    notify  = "off",
    timeout = 1,
    settings = function()
        if theme.mpd then theme.mpd.now = mpd_now end
        if mpd_now.state == "play" then
            local elapsed = fmt_time(mpd_now.elapsed)
            local total   = fmt_time(mpd_now.time)
            local pos     = " " .. elapsed .. "/" .. total .. " "
            local artist  = " " .. mpd_now.artist .. " "
            local title   = mpd_now.title .. " "
            mpdicon:set_image(theme.widget_music_on)
            widget:set_markup(markup.fontfg(theme.font, theme.fg_normal,
                markup.fontfg(theme.font, wc.color1 or "#FF8466", artist) ..
                title .. markup.fontfg(theme.font, wc.color4 or "#aaaaaa", pos)))

            -- Notification on track change
            if mpd_now.title ~= mpd_last_title then
                mpd_last_title = mpd_now.title
                local n_artist = mpd_now.artist
                local n_title  = mpd_now.title
                local n_album  = mpd_now.album
                local n_date   = mpd_now.date
                local n_file   = mpd_now.file
                local n_text   = n_title ..
                                 (n_album ~= "N/A" and ("\n" .. n_album) or "") ..
                                 (n_date  ~= "N/A" and (" (" .. n_date:match("^%d%d%d%d") .. ")") or "")
                -- fire immediately without icon, then replace with icon once fetched
                local notif = naughty.notify({
                    title   = n_artist,
                    text    = n_text,
                    timeout = 8,
                })
                mpd_fetch_cover(n_file, function(cover)
                    naughty.notify({
                        title       = n_artist,
                        text        = n_text,
                        icon        = cover,
                        timeout     = 8,
                        replaces_id = notif and notif.id,
                    })
                end)
            end
        elseif mpd_now.state == "pause" then
            local elapsed = fmt_time(mpd_now.elapsed)
            local total   = fmt_time(mpd_now.time)
            local pos     = " " .. elapsed .. "/" .. total .. " "
            local artist  = " " .. mpd_now.artist .. " "
            local title   = mpd_now.title .. " "
            mpdicon:set_image(theme.widget_music_pause)
            widget:set_markup(markup.fontfg(theme.font, theme.fg_normal,
                markup.fontfg(theme.font, wc.color4 or "#aaaaaa", artist) ..
                markup.fontfg(theme.font, wc.color4 or "#aaaaaa", title) ..
                markup.fontfg(theme.font, wc.color4 or "#aaaaaa", pos)))
            mpd_last_title = ""
        else
            widget:set_text("")
            mpdicon:set_image(theme.widget_music)
            mpd_last_title = ""
        end
    end
})
theme.mpd.widget:buttons(mpd_buttons)
theme.mpd.now = {} -- will be populated by settings()
local mpdwidget = wibox.container.background(wibox.container.margin(wibox.widget { mpdicon, theme.mpd.widget, layout = wibox.layout.align.horizontal }, dpi(3), dpi(6)), theme.bg_normal)
mpdwidget:buttons(mpd_buttons)

-- Hover popup showing cover art + track info
local mpd_popup_wibox = nil
local function mpd_popup_show()
    if mpd_popup_wibox then return end
    local n = theme.mpd and theme.mpd.now
    if not n or n.state == "stop" then return end

    local cover_widget = wibox.widget.imagebox()
    local has_cover = n.file and n.file ~= "N/A" and
                      io.open(mpd_cover) ~= nil
    if has_cover then cover_widget:set_image(mpd_cover) end

    local lines = {}
    if n.title  ~= "N/A" then lines[#lines+1] = "<b>" .. n.title  .. "</b>" end
    if n.artist ~= "N/A" then lines[#lines+1] = n.artist end
    if n.album  ~= "N/A" then
        lines[#lines+1] = n.album .. (n.date ~= "N/A" and (" (" .. n.date:match("^%d%d%d%d") .. ")") or "")
    end
    if n.genre  ~= "N/A" then lines[#lines+1] = "<i>" .. n.genre .. "</i>" end

    local text_widget = wibox.widget {
        markup = markup.fontfg(theme.font, theme.fg_normal, table.concat(lines, "\n")),
        widget = wibox.widget.textbox,
    }

    local size = dpi(96)
    local popup_w = size + dpi(200)
    local popup_h = size + dpi(16)

    -- anchor below the widget using current mouse x position
    local s  = awful.screen.focused()
    local wb = s.mywibox
    local mouse_x = mouse.coords().x
    local py = wb and (wb.y + wb.height + dpi(8)) or dpi(30)
    -- clamp so popup doesn't go off the right edge of the screen
    local px = math.min(mouse_x, s.geometry.x + s.geometry.width - popup_w - dpi(8))

    mpd_popup_wibox = wibox {
        width        = popup_w,
        height       = popup_h,
        x            = px,
        y            = py,
        bg           = theme.bg_normal,
        border_width = dpi(1),
        border_color = theme.border_focus,
        ontop        = true,
        visible      = true,
        screen       = s,
    }
    mpd_popup_wibox:setup {
        {
            {
                forced_width  = size,
                forced_height = size,
                cover_widget,
                widget = wibox.container.background,
            },
            {
                wibox.container.margin(text_widget, dpi(8), dpi(8), dpi(8), dpi(8)),
                widget = wibox.container.place,
                valign = "center",
            },
            layout = wibox.layout.fixed.horizontal,
        },
        widget = wibox.container.background,
    }
end

local function mpd_popup_hide()
    if mpd_popup_wibox then
        mpd_popup_wibox.visible = false
        mpd_popup_wibox = nil
    end
end

mpdwidget:connect_signal("mouse::enter", mpd_popup_show)
mpdwidget:connect_signal("mouse::leave", mpd_popup_hide)

-- MEM
local memicon = wibox.widget.imagebox(theme.widget_mem)
local mem_now_last = {}
local mem = lain.widget.mem({
    settings = function()
        mem_now_last = mem_now
        widget:set_markup(markup.font(theme.font, " " .. mem_now.used .. "MB "))
    end
})
local mem_tooltip = awful.tooltip({
    objects = { mem.widget, memicon },
    timer_function = function()
        local m = mem_now_last
        return string.format(
            "RAM:  %d MB used / %d MB total (%d%%)\nCache: %d MB   Buffers: %d MB\nSwap: %d MB used / %d MB total",
            m.used or 0, m.total or 0, m.perc or 0,
            m.cache or 0, m.buf or 0,
            m.swapused or 0, m.swap or 0)
    end,
    timeout = 2,
})

-- CPU
local cpuicon = wibox.widget.imagebox(theme.widget_cpu)
local cpu_now_last = {}
local cpu = lain.widget.cpu({
    settings = function()
        cpu_now_last = cpu_now
        widget:set_markup(markup.font(theme.font, " " .. cpu_now.usage .. "% "))
    end
})
local cpu_tooltip = awful.tooltip({
    objects = { cpu.widget, cpuicon },
    timer_function = function()
        local lines = {}
        for i, core in ipairs(cpu_now_last) do
            table.insert(lines, string.format("Core %-2d: %3d%%", i - 1, core.usage or 0))
        end
        return #lines > 0 and table.concat(lines, "\n") or "No data"
    end,
    timeout = 2,
})

--[[ Coretemp (lm_sensors, per core)
local tempwidget = awful.widget.watch({awful.util.shell, '-c', 'sensors | grep Core'}, 30,
function(widget, stdout)
    local temps = ""
    for line in stdout:gmatch("[^\r\n]+") do
        temps = temps .. line:match("+(%d+).*°C")  .. "° " -- in Celsius
    end
    widget:set_markup(markup.font(theme.font, " " .. temps))
end)
--]]
-- Coretemp — portable sensor detection
-- Searches hwmon by driver name on Linux, falls back to sysctl on BSD
local function find_tempfile()
    local preferred = { "zenpower", "k10temp", "coretemp", "cpu_thermal" }
    for _, name in ipairs(preferred) do
        local iter = io.popen("grep -rl '^" .. name .. "$' /sys/class/hwmon/*/name 2>/dev/null | head -1")
        if iter then
            local namefile = iter:read("*l"); iter:close()
            if namefile then
                local dir = namefile:match("^(.+)/name$")
                local t = dir .. "/temp1_input"
                local tf = io.open(t, "r")
                if tf then tf:close(); return t end
            end
        end
    end
    -- fallback: first hwmon temp1_input found
    local iter = io.popen("ls /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -1")
    if iter then
        local t = iter:read("*l"); iter:close()
        if t then return t end
    end
    return nil
end

local _tempfile = find_tempfile()
local _tempdir  = _tempfile and _tempfile:match("^(.+)/temp%d+_input$")

local tempicon = wibox.widget.imagebox(theme.widget_temp)
local temp = { widget = wibox.widget.textbox() }
local temp_tooltip = awful.tooltip({ objects = { temp.widget, tempicon } })

if _tempfile then
    -- Linux: read directly from sysfs, divide by 1000
    awful.widget.watch({"cat", _tempfile}, 5, function(widget, stdout)
        local val = tonumber(stdout:match("%d+"))
        local deg = val and string.format("%.0f", val / 1e3) or "?"
        widget:set_markup(markup.font(theme.font, " " .. deg .. "°C "))
        -- Build tooltip from all temp nodes in the same hwmon dir
        if _tempdir then
            awful.spawn.easy_async_with_shell(
                string.format("for f in %s/temp*_input; do label=%s/$(basename $f _input)_label; echo \"$(cat $label 2>/dev/null || basename $f _input): $(cat $f)\"; done", _tempdir, _tempdir),
                function(out)
                    local lines = {}
                    for line in out:gmatch("[^\n]+") do
                        local label, raw = line:match("^(.+): (%d+)$")
                        if label and raw then
                            table.insert(lines, string.format("%-20s %5.1f°C", label, tonumber(raw) / 1e3))
                        end
                    end
                    if #lines > 0 then
                        temp_tooltip:set_text(table.concat(lines, "\n"))
                    end
                end)
        end
    end, temp.widget)
else
    -- BSD: read via sysctl
    awful.widget.watch(
        {awful.util.shell, "-c", "sysctl -n hw.sensors.cpu0.temp0 2>/dev/null || sysctl -n dev.cpu.0.temperature 2>/dev/null"},
        5, function(widget, stdout)
        local deg = stdout:match("(%-?%d+%.?%d*)") or "?"
        widget:set_markup(markup.font(theme.font, " " .. deg .. "°C "))
    end, temp.widget)
end

-- Battery (only created when a battery is present)
local has_battery = require("gears.filesystem").dir_readable("/sys/class/power_supply/") and
    (function()
        local f = io.popen("ls /sys/class/power_supply/")
        if not f then return false end
        local out = f:read("*a"); f:close()
        return out:match("BAT") ~= nil
    end)()

local baticon, bat
if has_battery then
    baticon = wibox.widget.imagebox(theme.widget_battery)
    bat = lain.widget.bat({
        settings = function()
            if bat_now.status and bat_now.status ~= "N/A" then
                if bat_now.ac_status == 1 then
                    widget:set_markup(markup.font(theme.font, " AC "))
                    baticon:set_image(theme.widget_ac)
                    return
                elseif bat_now.perc and tonumber(bat_now.perc) <= 5 then
                    baticon:set_image(theme.widget_battery_empty)
                elseif bat_now.perc and tonumber(bat_now.perc) <= 15 then
                    baticon:set_image(theme.widget_battery_low)
                else
                    baticon:set_image(theme.widget_battery)
                end
                widget:set_markup(markup.font(theme.font, " " .. bat_now.perc .. "% "))
            else
                widget:set_markup()
                baticon:set_image(theme.widget_ac)
            end
        end
    })
end

-- Net
local neticon = wibox.widget.imagebox(theme.widget_net)
local net_now_last = {}
local net = lain.widget.net({
    format = "%g",
    settings = function()
        net_now_last = net_now
        local function fmt(val)
            local n = tonumber(val) or 0
            if n >= 1024 then
                return string.format("%5.1f M", n / 1024)
            else
                return string.format("%5.1f K", n)
            end
        end
        widget:set_markup(markup.fontfg(theme.font, theme.fg_normal,
            " " .. fmt(net_now.received) .. "↓ " .. fmt(net_now.sent) .. "↑ "))
    end
})
local net_tooltip = awful.tooltip({
    objects = { net.widget, neticon },
    timer_function = function()
        local lines = {}
        local n = net_now_last
        if n and n.devices then
            for dev, d in pairs(n.devices) do
                local state = d.carrier == "1" and "up" or "down"
                table.insert(lines, string.format("%-12s  ↓%8s  ↑%8s  [%s]",
                    dev,
                    d.received or "0",
                    d.sent or "0",
                    state))
            end
            table.sort(lines)
        end
        return #lines > 0 and table.concat(lines, "\n") or "No data"
    end,
    timeout = 2,
})

-- Weather widget (API key from pass, coordinates resolved via GeoIP)
-- Callbacks stored so each screen can spawn its own widget instance
local weather_args = nil          -- set once async chain completes
local weather_containers = {}     -- one entry per screen, filled by at_screen_connect
local weather_placeholders = {}   -- parallel list of placeholder textboxes, hidden on populate

local function make_weather_widget()
    if not weather_args then return nil end
    local font_name = beautiful.font and beautiful.font:gsub("%s%d+$", "") or "sans"
    return weather_api({
        api_key                = weather_args.api_key,
        coordinates            = weather_args.coordinates,
        units                  = "metric",
        lang                   = "en",
        font_name              = font_name,
        timeout                = 600,
        show_forecast_on_hover = true,
    })
end

local function populate_weather_containers()
    for i, c in ipairs(weather_containers) do
        if weather_placeholders[i] then
            weather_placeholders[i].visible = false
        end
        c:reset()
        local w = make_weather_widget()
        if w then c:add(w) end
    end
end

awful.spawn.easy_async_with_shell(
    "pass api/weatherapi.com/key 2>/dev/null | tr -d '\\n'",
    function(api_key)
        api_key = api_key:gsub("%s+$", "")
        if not api_key or api_key == "" then return end
        awful.spawn.easy_async_with_shell(
            "curl -s 'https://ipapi.co/json/' | grep -E '\"latitude\"|\"longitude\"' | awk -F': ' '{print $2}' | tr -d ','",
            function(stdout)
                local coords = {}
                for v in stdout:gmatch("[%d%.]+") do coords[#coords+1] = tonumber(v) end
                if #coords >= 2 then
                    weather_args = { api_key = api_key, coordinates = { coords[1], coords[2] },
                                     show_forecast_on_hover = true }
                    populate_weather_containers()
                end
            end
        )
    end
)

-- Powerline segment colors (sourced from wallust palette)
local seg1 = wc.color0  or "#343434"
local seg2 = wc.color2  or "#777E76"
local seg3 = wc.color4  or "#4B696D"
local seg4 = wc.color5  or "#4B3B51"
local seg5 = wc.color1  or "#CB755B"
local seg6 = wc.color6  or "#8DAA9A"
local seg7 = wc.color3  or "#C0C0A2"

-- Separators
local arrow = separators.arrow_left

function theme.powerline_rl(cr, width, height)
    local arrow_depth, offset = height/2, 0

    -- Avoid going out of the (potential) clip area
    if arrow_depth < 0 then
        width  =  width + 2*arrow_depth
        offset = -arrow_depth
    end

    cr:move_to(offset + arrow_depth         , 0        )
    cr:line_to(offset + width               , 0        )
    cr:line_to(offset + width - arrow_depth , height/2 )
    cr:line_to(offset + width               , height   )
    cr:line_to(offset + arrow_depth         , height   )
    cr:line_to(offset                       , height/2 )

    cr:close_path()
end

function theme.at_screen_connect(s)
    -- Quake application
    s.quake = lain.util.quake({ app = awful.util.terminal })

    -- If wallpaper is a function, call it with the screen
    local wallpaper = theme.wallpaper
    if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
    end
    gears.wallpaper.fit(wallpaper, s, theme.bg_normal)

    -- Tags
    awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create systray
    s.systray = wibox.widget.systray()
    s.systray:set_base_size(dpi(20))
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(my_table.join(
                           awful.button({}, 1, function () awful.layout.inc( 1) end),
                           awful.button({}, 2, function () awful.layout.set( awful.layout.layouts[1] ) end),
                           awful.button({}, 3, function () awful.layout.inc(-1) end),
                           awful.button({}, 4, function () awful.layout.inc( 1) end),
                           awful.button({}, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = dpi(26), bg = theme.bg_normal, fg = theme.fg_normal })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --spr,
            s.mytaglist,
            s.mypromptbox,
            spr,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.container.margin(s.systray, dpi(4), dpi(4), dpi(2), dpi(2)),
            -- using separators
            arrow(theme.bg_normal, seg1),
            wibox.container.background(wibox.container.margin(pacman_widget, dpi(3), dpi(6)), seg1),
            arrow(seg1, theme.bg_normal),
            mpdwidget,
            arrow(theme.bg_normal, seg2),
            wibox.container.background(wibox.container.margin(wibox.widget { memicon, mem.widget, layout = wibox.layout.align.horizontal }, dpi(2), dpi(3)), seg2),
            arrow(seg2, seg3),
            wibox.container.background(wibox.container.margin(wibox.widget { cpuicon, cpu.widget, layout = wibox.layout.align.horizontal }, dpi(3), dpi(4)), seg3),
            arrow(seg3, seg4),
             wibox.container.background(wibox.container.margin(wibox.widget { tempicon, temp.widget, layout = wibox.layout.align.horizontal }, dpi(4), dpi(4)), seg4),
             arrow(seg4, seg5),
             (function()
                 local placeholder = wibox.widget {
                     markup = "<span foreground='" .. (wc.foreground or "#ffffff") .. "'>...</span>",
                     widget = wibox.widget.textbox,
                 }
                 local c = wibox.widget { placeholder, layout = wibox.layout.fixed.horizontal }
                 table.insert(weather_containers, c)
                 table.insert(weather_placeholders, placeholder)
                 if weather_args then populate_weather_containers() end
                 return wibox.container.background(wibox.container.margin(c, dpi(2), dpi(2)), seg5)
             end)(),
             has_battery and arrow(seg5, seg6) or arrow(seg5, seg7),
             has_battery and wibox.container.background(wibox.container.margin(wibox.widget { baticon, bat and bat.widget, layout = wibox.layout.align.horizontal }, dpi(3), dpi(3)), seg6) or nil,
             has_battery and arrow(seg6, seg7) or nil,
            wibox.container.background(wibox.container.margin(wibox.widget { nil, neticon, net.widget, layout = wibox.layout.align.horizontal }, dpi(3), dpi(3)), seg7),
            arrow(seg7, seg2),
            wibox.container.background(wibox.container.margin(clock, dpi(4), dpi(8)), seg2),
            arrow(seg2, theme.bg_normal),
            --]]
            s.mylayoutbox,
        },
    }
end

return theme
