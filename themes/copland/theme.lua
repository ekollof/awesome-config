--[[

     Copland Awesome WM theme 2.0
     github.com/lcpz

     Adapted for wallust dynamic colors and BerkeleyMono Nerd Font.
     Layout kept original: bar separators, progress bars, no powerline arrows.

--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi

local awesome, client, os = awesome, client, os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

-- ---------------------------------------------------------------------------
-- Load wallust-generated colors (falls back to built-in defaults if not found)
-- ---------------------------------------------------------------------------
local wallust_colors_path = os.getenv("HOME") .. "/.cache/wal/awesome-colors.lua"
local wallust_ok, wc = pcall(dofile, wallust_colors_path)
if not wallust_ok then wc = {} end

-- Copland fallback palette
wc.foreground = wc.foreground or "#BBBBBB"
wc.background = wc.background or "#111111"
wc.color0 = wc.color0 or "#141414"
wc.color1 = wc.color1 or "#EB8F8F"
wc.color2 = wc.color2 or "#8FEB8F"
wc.color3 = wc.color3 or "#FBC02D"
wc.color4 = wc.color4 or "#78A4FF"
wc.color5 = wc.color5 or "#C678DD"
wc.color6 = wc.color6 or "#56B6C2"
wc.color7 = wc.color7 or "#BBBBBB"
wc.color8 = wc.color8 or "#474747"
wc.color9 = wc.color9 or "#EB8F8F"
wc.color10 = wc.color10 or "#8FEB8F"
wc.color11 = wc.color11 or "#FBC02D"
wc.color12 = wc.color12 or "#78A4FF"
wc.color13 = wc.color13 or "#C678DD"
wc.color14 = wc.color14 or "#56B6C2"
wc.color15 = wc.color15 or "#FFFFFF"

-- ---------------------------------------------------------------------------
-- Theme definition
-- ---------------------------------------------------------------------------
local theme                                     = {}
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/themes/copland"
theme.wallpaper                                 = wc.wallpaper or theme.dir .. "/wall.png"
theme.font                                      = "BerkeleyMono Nerd Font 11"
theme.fg_normal                                 = wc.foreground
theme.fg_focus                                  = wc.color4
theme.bg_normal                                 = wc.background
theme.bg_focus                                  = wc.background
theme.fg_urgent                                 = wc.background
theme.bg_urgent                                 = wc.foreground
theme.border_width                              = dpi(1)
theme.border_normal                             = wc.color0
theme.border_focus                              = wc.color4
theme.taglist_fg_focus                          = wc.color12
theme.taglist_bg_focus                          = wc.color0
theme.taglist_bg_normal                         = wc.background
theme.tasklist_fg_focus                         = wc.color12
theme.tasklist_bg_focus                         = wc.color0
theme.bg_systray                                = wc.color0
theme.systray_icon_spacing                      = dpi(2)
theme.titlebar_bg_normal                        = wc.color0
theme.titlebar_bg_focus                         = wc.color8
theme.titlebar_fg_focus                         = wc.foreground
theme.titlebar_fg_normal                        = wc.color7
theme.border_marked                             = wc.color3
theme.menu_height                               = dpi(18)
theme.menu_width                                = dpi(140)
theme.menu_bg_normal                            = wc.background
theme.menu_bg_focus                             = wc.color0
theme.menu_fg_normal                            = wc.foreground
theme.menu_fg_focus                             = wc.color12
theme.tasklist_disable_icon                     = false
-- Notifications
theme.notification_font                         = "BerkeleyMono Nerd Font 10"
theme.notification_bg                           = wc.background
theme.notification_fg                           = wc.foreground
theme.notification_border_color                 = wc.color12
theme.notification_border_width                 = dpi(2)
theme.notification_icon_size                    = dpi(48)
theme.notification_max_width                    = dpi(400)
theme.notification_margin                       = dpi(8)
theme.notification_opacity                      = 0.95
theme.awesome_icon                              = theme.dir .."/icons/awesome.png"
theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"
theme.taglist_squares_sel                       = theme.dir .. "/icons/square_unsel.png"
theme.taglist_squares_unsel                     = theme.dir .. "/icons/square_unsel.png"
theme.vol                                       = theme.dir .. "/icons/vol.png"
theme.vol_low                                   = theme.dir .. "/icons/vol_low.png"
theme.vol_no                                    = theme.dir .. "/icons/vol_no.png"
theme.vol_mute                                  = theme.dir .. "/icons/vol_mute.png"
theme.disk                                      = theme.dir .. "/icons/disk.png"
theme.ac                                        = theme.dir .. "/icons/ac.png"
theme.bat                                       = theme.dir .. "/icons/bat.png"
theme.bat_low                                   = theme.dir .. "/icons/bat_low.png"
theme.bat_no                                    = theme.dir .. "/icons/bat_no.png"
theme.play                                      = theme.dir .. "/icons/play.png"
theme.pause                                     = theme.dir .. "/icons/pause.png"
theme.stop                                      = theme.dir .. "/icons/stop.png"
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

-- lain related
theme.layout_centerfair                         = theme.dir .. "/icons/centerfair.png"
theme.layout_termfair                           = theme.dir .. "/icons/termfair.png"
theme.layout_centerwork                         = theme.dir .. "/icons/centerwork.png"

local markup = lain.util.markup
local red    = wc.color1
local green  = wc.color2
local blue   = wc.color4
local gray   = wc.color8

-- ---------------------------------------------------------------------------
-- Widgets (original Copland layout)
-- ---------------------------------------------------------------------------

-- Textclock
local mytextclock = wibox.widget.textclock(" %H:%M ")
mytextclock.font = theme.font

-- Calendar
theme.cal = lain.widget.cal({
    attach_to = { mytextclock },
    notification_preset = {
        font = theme.font,
        fg   = theme.fg_normal,
        bg   = theme.bg_normal
    }
})

-- MPD
local mpdicon = wibox.widget.imagebox()
theme.mpd = lain.widget.mpd({
    settings = function()
        if mpd_now.state == "play" then
            title = mpd_now.title
            artist  = " " .. mpd_now.artist  .. markup(gray, "  |  ")
            mpdicon:set_image(theme.play)
        elseif mpd_now.state == "pause" then
            title = "mpd "
            artist  = "paused " .. markup(gray, "| ")
            mpdicon:set_image(theme.pause)
        else
            title  = ""
            artist = ""
            mpdicon._private.image = nil
            mpdicon:emit_signal("widget::redraw_needed")
            mpdicon:emit_signal("widget::layout_changed")
        end

        widget:set_markup(markup.font(theme.font, markup(blue, title) .. artist))
    end
})

-- Battery (portable version)
local bat_widget = require("widgets.battery")
local baticon    = bat_widget.icon
local bat        = bat_widget.widget
bat_widget.attach(30)

-- Check for battery presence for wibar layout visibility
-- Battery (portable version)
local bat_widget = require("widgets.battery")
bat_widget.attach(30)

-- Check for battery presence for wibar layout visibility
local has_battery = false
if _G._os == "Linux" then
    has_battery = gears.filesystem.dir_readable("/sys/class/power_supply/BAT0")
elseif _G._os == "FreeBSD" then
    local s = io.popen("sysctl -n hw.acpi.battery.units 2>/dev/null")
    if s then
        local out = s:read("*all")
        has_battery = tonumber(out) and tonumber(out) > 0
        s:close()
    end
elseif _G._os == "OpenBSD" then
    local s = io.popen("apm -l 2>/dev/null")
    if s then
        local out = s:read("*all")
        has_battery = tonumber(out) and tonumber(out) ~= 255
        s:close()
    end
end

-- Net
local net_widget = require("widgets.net")
local neticon    = wibox.widget.textbox(" 󰲝 ")

-- System Monitor
local sysmon
local sysmon_ok, sysmon_mod = pcall(require, "widgets.sysmon")
if sysmon_ok then
    sysmon = sysmon_mod
else
    sysmon = { create = function() return wibox.widget.textbox("sysmon error") end }
end


-- ALSA volume bar
local volicon = wibox.widget.imagebox(theme.vol)
theme.volume = lain.widget.alsabar {
    width = dpi(59), border_width = 0, ticks = true, ticks_size = dpi(6),
    notification_preset = { font = theme.font },
    settings = function()
        if volume_now.status == "off" then
            volicon:set_image(theme.vol_mute)
        elseif volume_now.level == 0 then
            volicon:set_image(theme.vol_no)
        elseif volume_now.level <= 50 then
            volicon:set_image(theme.vol_low)
        else
            volicon:set_image(theme.vol)
        end
    end,
    colors = {
        background   = theme.bg_normal,
        mute         = red,
        unmute       = theme.fg_normal
    }
}
theme.volume.tooltip.wibox.fg = theme.fg_focus
theme.volume.bar:buttons(my_table.join (
          awful.button({}, 1, function()
            awful.spawn(string.format("%s -e alsamixer", awful.util.terminal))
          end),
          awful.button({}, 2, function()
            awful.spawn.with_shell(string.format("%s set %s 100%%", theme.volume.cmd, theme.volume.channel))
            theme.volume.update()
          end),
          awful.button({}, 3, function()
            awful.spawn.with_shell(string.format("%s set %s toggle", theme.volume.cmd, theme.volume.togglechannel or theme.volume.channel))
            theme.volume.update()
          end),
          awful.button({}, 4, function()
            awful.spawn.with_shell(string.format("%s set %s 1%%+", theme.volume.cmd, theme.volume.channel))
            theme.volume.update()
          end),
          awful.button({}, 5, function()
            awful.spawn.with_shell(string.format("%s set %s 1%%-", theme.volume.cmd, theme.volume.channel))
            theme.volume.update()
          end)
))
local volumebg = wibox.container.background(theme.volume.bar, gray, gears.shape.rectangle)
local volumewidget = wibox.container.margin(volumebg, dpi(2), dpi(7), dpi(4), dpi(4))

-- Eminent-like task filtering
local orig_filter = awful.widget.taglist.filter.all

-- Taglist label functions
awful.widget.taglist.filter.all = function (t, args)
    if t.selected or #t:clients() > 0 then
        return orig_filter(t, args)
    end
end

-- ---------------------------------------------------------------------------
-- Per-screen setup
-- ---------------------------------------------------------------------------
function theme.at_screen_connect(s)
    -- Quake application
    s.quake = lain.util.quake({ app = awful.util.terminal })

    -- Wallpaper
    local wallpaper = theme.wallpaper
    if type(wallpaper) == "function" then wallpaper = wallpaper(s) end
    gears.wallpaper.fit(wallpaper, s)

    -- Tags
    awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

    -- Promptbox
    s.mypromptbox = awful.widget.prompt()

    local spr = wibox.widget.textbox(" ")
    local bar_spr = wibox.widget.textbox()
    bar_spr:set_markup(markup.fontfg(theme.font, gray, " | "))

    -- Per-screen widgets
    local net_text = net_widget.create()
    local bat_text, bat_icon = bat_widget.create()
    local local_neticon = wibox.widget.textbox(" 󰲝 ")

    local_neticon:connect_signal("mouse::enter", net_widget.popup_show)
    net_text:connect_signal("mouse::enter", net_widget.popup_show)
    local_neticon:connect_signal("mouse::leave", net_widget.popup_hide)
    net_text:connect_signal("mouse::leave", net_widget.popup_hide)

    -- Layoutbox
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(my_table.join(
                           awful.button({}, 1, function () awful.layout.inc( 1) end),
                           awful.button({}, 2, function () awful.layout.set( awful.layout.layouts[1] ) end),
                           awful.button({}, 3, function () awful.layout.inc(-1) end),
                           awful.button({}, 4, function () awful.layout.inc( 1) end),
                           awful.button({}, 5, function () awful.layout.inc(-1) end)))

    -- Taglist
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Tasklist
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

    -- Wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = dpi(22), bg = theme.bg_normal, fg = theme.fg_normal })

    -- Assemble wibar
    local notif_hist = require("widgets.notification_history")

    local right_widgets = {
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.systray(),
        spr,
        notif_hist.create(),
        spr,
        mpdicon,
        theme.mpd.widget,
        bar_spr,
        wibox.widget { sysmon.create(), layout = wibox.layout.fixed.horizontal },
        bar_spr,
    }

    if has_battery then
        table.insert(right_widgets, bat_icon)
        table.insert(right_widgets, bat_text)
        table.insert(right_widgets, bar_spr)
    end

    table.insert(right_widgets, volicon)
    table.insert(right_widgets, volumewidget)
    table.insert(right_widgets, bar_spr)
    table.insert(right_widgets, local_neticon)
    table.insert(right_widgets, net_text)
    table.insert(right_widgets, bar_spr)
    table.insert(right_widgets, mytextclock)

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            spr,
            s.mylayoutbox,
            spr,
            bar_spr,
            s.mytaglist,
            spr,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        right_widgets,
    }
end

return theme
