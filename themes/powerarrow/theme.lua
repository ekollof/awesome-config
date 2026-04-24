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
local updates = require("updatewidget")
-- update_widget_hook is a global called by the pacman alpm hook on Arch.
-- It is harmless on other distros (no hook fires, the function just never runs).
update_widget_hook = function() updates.hook() end
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
theme.font                                      = "BerkeleyMono Nerd Font 11"
local font10                                    = "BerkeleyMono Nerd Font 12"
theme.fg_normal                                 = wc.foreground  or "#FEFEFE"
theme.fg_focus                                  = wc.color6      or "#32D6FF"
theme.fg_urgent                                 = wc.color1      or "#C83F11"
theme.bg_normal                                 = wc.background  or "#222222"
theme.bg_systray                                = wc.color0      or "#333333"
theme.systray_icon_spacing                      = dpi(2)
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

-- Package updates widget (Arch: checkupdates+yay; Ubuntu/Mint: apt)
-- Returns nil on unsupported distros so the wibar slot is simply omitted.
local pacman_widget = updates.distro ~= "unknown" and updates.create() or nil

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
local volicon = wibox.widget.imagebox(theme.widget_vol)
theme.volume = lain.widget.alsabar({
    --togglechannel = "IEC958,3",
    notification_preset = { font = font10, fg = theme.fg_normal },
    settings = function()
        if volume_now.status == "off" then
            volicon:set_image(theme.widget_vol_mute)
        elseif volume_now.level == 0 then
            volicon:set_image(theme.widget_vol_no)
        elseif volume_now.level <= 33 then
            volicon:set_image(theme.widget_vol_low)
        else
            volicon:set_image(theme.widget_vol)
        end
    end,
})

-- Volume notification with progress bar.
-- Reuses a single notification handle so rapid scrolling updates it in-place
-- rather than stacking multiple notifications.
local vol_notif = nil
local VOL_BAR_WIDTH = 20  -- characters wide

theme.volume_notify = function()
    theme.volume.update(function()
        local level  = theme.volume._current_level or 0
        local muted  = theme.volume._playback == "off"
        local filled = math.floor(level / 100 * VOL_BAR_WIDTH + 0.5)
        local bar    = string.rep("█", filled) .. string.rep("░", VOL_BAR_WIDTH - filled)
        local title  = muted
            and string.format("󰝟  Volume: %d%% [muted]", level)
            or  string.format("󰕾  Volume: %d%%", level)
        local text   = bar

        if vol_notif then
            naughty.replace_text(vol_notif, title, text)
        else
            vol_notif = naughty.notify({
                title   = title,
                text    = text,
                timeout = 2,
                screen  = awful.screen.focused(),
                preset  = theme.volume.notification_preset,
                destroy = function() vol_notif = nil end,
            })
        end
    end)
end

-- Scroll wheel on the volume bar: adjust volume and show notification
theme.volume.bar:buttons(my_table.join(
    awful.button({}, 4, function()  -- scroll up → raise
        awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ +2%")
        theme.volume_notify()
    end),
    awful.button({}, 5, function()  -- scroll down → lower
        awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ -2%")
        theme.volume_notify()
    end),
    awful.button({}, 1, function()  -- left click → toggle mute
        awful.spawn.with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle")
        theme.volume_notify()
    end)
))

-- MPD
local mpd_widget = require("widgets.mpd")({ color_artist = wc.color1 or "#FF8466", color_paused = wc.color4 or "#aaaaaa", modkey = modkey })
local mpdwidget = mpd_widget.container
local mpdicon   = mpd_widget.icon
mpd_widget.attach()
-- MEM
local mem_widget = require("widgets.mem")
local memicon    = wibox.widget.imagebox(theme.widget_mem)
mem_widget.attach(memicon, mem_widget.widget)
-- CPU
local cpu_widget = require("widgets.cpu")
local cpuicon    = wibox.widget.imagebox(theme.widget_cpu)
cpu_widget.attach(cpuicon, cpu_widget.widget)
-- Temp
local temp_widget = require("widgets.temp")
local tempicon    = wibox.widget.imagebox(theme.widget_temp)
temp_widget.attach(tempicon, temp_widget.widget)
-- Battery (portable version)
local bat_widget = require("widgets.battery")
local baticon    = bat_widget.icon
local bat        = bat_widget.widget
bat_widget.attach(30)

-- Check for battery presence for wibar layout visibility
local has_battery = false
local f = io.popen("uname")
local _os = f:read("*all"):gsub("%s+", "")
f:close()

if _os == "Linux" then
    has_battery = gears.filesystem.dir_readable("/sys/class/power_supply/BAT0")
elseif _os == "FreeBSD" then
    -- synchronous check for wibar layout stability
    local s = io.popen("sysctl -n hw.acpi.battery.units 2>/dev/null")
    if s then
        local out = s:read("*all")
        has_battery = tonumber(out) and tonumber(out) > 0
        s:close()
    end
elseif _os == "OpenBSD" then
    local s = io.popen("apm -l 2>/dev/null")
    if s then
        local out = s:read("*all")
        has_battery = tonumber(out) and tonumber(out) ~= 255
        s:close()
    end
end

-- Net
local net_widget = require("widgets.net")
local neticon    = wibox.widget.imagebox(theme.widget_net)
neticon:connect_signal("mouse::enter", net_widget.popup_show)
net_widget.widget:connect_signal("mouse::enter", net_widget.popup_show)
neticon:connect_signal("mouse::leave", net_widget.popup_hide)
net_widget.widget:connect_signal("mouse::leave", net_widget.popup_hide)
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
local seg1    = wc.color0  or "#343434"
local seg2    = wc.color2  or "#777E76"
local seg3    = wc.color4  or "#4B696D"
local seg4    = wc.color5  or "#4B3B51"
local seg5    = wc.color1  or "#CB755B"
local seg6    = wc.color6  or "#8DAA9A"
local seg7    = wc.color3  or "#C0C0A2"
local seg_vol = wc.color8  or "#606060"  -- distinct segment for volume widget

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
    s.systray:set_base_size(dpi(24))
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
    s.mywibox = awful.wibar({ position = "top", screen = s, height = dpi(32), bg = theme.bg_normal, fg = theme.fg_normal })

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
            -- using separators
            arrow(theme.bg_normal, seg1),
            pacman_widget and wibox.container.background(wibox.container.margin(pacman_widget, dpi(3), dpi(3)), seg1) or nil,
            wibox.container.background(wibox.container.margin(s.systray, dpi(6), dpi(4), dpi(2), dpi(2)), seg1),
            pacman_widget and arrow(seg1, theme.bg_normal) or nil,
            mpdwidget,
            arrow(theme.bg_normal, seg2),
            wibox.container.background(wibox.container.margin(wibox.widget { memicon, mem_widget.widget, layout = wibox.layout.align.horizontal }, dpi(2), dpi(3)), seg2),
            arrow(seg2, seg3),
            wibox.container.background(wibox.container.margin(wibox.widget { cpuicon, cpu_widget.widget, layout = wibox.layout.align.horizontal }, dpi(3), dpi(4)), seg3),
            arrow(seg3, seg4),
             wibox.container.background(wibox.container.margin(wibox.widget { tempicon, temp_widget.widget, layout = wibox.layout.align.horizontal }, dpi(4), dpi(4)), seg4),
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
             has_battery and arrow(seg5, seg6) or arrow(seg5, seg_vol),
             has_battery and wibox.container.background(wibox.container.margin(wibox.widget { baticon, bat, layout = wibox.layout.align.horizontal }, dpi(3), dpi(3)), seg6) or nil,
             has_battery and arrow(seg6, seg_vol) or nil,
             wibox.container.background(wibox.container.margin(wibox.widget {
                 volicon,
                 wibox.container.constraint(theme.volume.bar, "exact", dpi(50), dpi(10)),
                 layout = wibox.layout.fixed.horizontal,
             }, dpi(3), dpi(4), dpi(8), dpi(8)), seg_vol),
             arrow(seg_vol, seg7),
            wibox.container.background(wibox.container.margin(wibox.widget { nil, neticon, net_widget.widget, layout = wibox.layout.align.horizontal }, dpi(3), dpi(3)), seg7),
            arrow(seg7, seg2),
            wibox.container.background(wibox.container.margin(clock, dpi(4), dpi(8)), seg2),
            arrow(seg2, theme.bg_normal),
            --]]
            s.mylayoutbox,
        },
    }
end

return theme
