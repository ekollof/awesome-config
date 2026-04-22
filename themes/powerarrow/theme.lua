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
local mpd_last_title  = ""
local mpd_cover_surface = nil   -- cairo.ImageSurface, loaded in memory

local function mpd_fetch_cover(file, callback)
    awful.spawn.easy_async_with_shell(
        string.format("mpc readpicture %q 2>/dev/null | base64", file),
        function(out)
            if not out or #out < 4 then callback(nil); return end
            local ok, surf = pcall(function()
                local lgi       = require("lgi")
                local GLib      = lgi.GLib
                local GdkPixbuf = lgi.GdkPixbuf
                local Gdk       = lgi.require("Gdk", "3.0")
                local cairo     = lgi.cairo
                local Gio       = lgi.Gio
                local decoded = GLib.base64_decode(out:gsub("%s+", ""))
                if not decoded or #decoded < 4 then return nil end
                local stream = Gio.MemoryInputStream.new_from_data(decoded)
                local pb     = GdkPixbuf.Pixbuf.new_from_stream(stream)
                if not pb then return nil end
                local s  = cairo.ImageSurface.create(cairo.Format.ARGB32, pb.width, pb.height)
                local cr = cairo.Context.create(s)
                Gdk.cairo_set_source_pixbuf(cr, pb, 0, 0)
                cr:paint()
                return s
            end)
            callback(ok and surf or nil)
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
                    mpd_cover_surface = cover
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
            mpd_last_title  = ""
            mpd_cover_surface = nil
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
    if mpd_cover_surface then cover_widget:set_image(mpd_cover_surface) end

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

local mem_popup       = nil
local mem_popup_timer = nil
local mem_proc_last   = {}   -- cached process list {name, mb}
local mem_zfs_last    = nil  -- cached ZFS ARC stats table, or false if unavailable

local _zfs_arcstats  = "/proc/spl/kstat/zfs/arcstats"
local _zfs_linux     = io.open(_zfs_arcstats, "r") and true or false
local _zfs_freebsd   = (not _zfs_linux) and (io.popen("sysctl -n kstat.zfs.misc.arcstats.size 2>/dev/null"):read("*l") ~= nil)
local _zfs_available = _zfs_linux or _zfs_freebsd

-- Keys we want from arcstats (Linux procfs name == FreeBSD sysctl suffix)
local _zfs_keys = {
    "size", "c", "c_max",
    "hits", "misses",
    "mru_size", "mfu_size", "anon_size", "metadata_size",
    "compressed_size", "uncompressed_size",
    "l2_size", "l2_hits", "l2_misses",
}

local function mem_fetch_zfs(callback)
    if not _zfs_available then callback(nil); return end

    local function parse(t)
        if not t.size then callback(nil); return end
        local function mb(v) return math.floor((v or 0) / 1048576) end
        local hits, misses = (t.hits or 0), (t.misses or 0)
        local total = hits + misses
        local hitratio = total > 0 and string.format("%.1f%%", hits / total * 100) or "n/a"
        local compr = (t.uncompressed_size or 0) > 0
            and string.format("%.2fx", t.uncompressed_size / t.compressed_size)
            or "n/a"
        local l2h, l2m = (t.l2_hits or 0), (t.l2_misses or 0)
        local l2total = l2h + l2m
        local l2ratio = l2total > 0 and string.format("%.1f%%", l2h / l2total * 100) or nil
        callback({
            size     = mb(t.size),
            target   = mb(t.c),
            max      = mb(t.c_max),
            mru      = mb(t.mru_size),
            mfu      = mb(t.mfu_size),
            anon     = mb(t.anon_size),
            meta     = mb(t.metadata_size),
            hitratio = hitratio,
            compr    = compr,
            l2size   = mb(t.l2_size or 0),
            l2ratio  = l2ratio,
        })
    end

    if _zfs_linux then
        awful.spawn.easy_async_with_shell("cat " .. _zfs_arcstats, function(out)
            local t = {}
            for key, val in out:gmatch("(%w+)%s+%d+%s+(%d+)") do t[key] = tonumber(val) end
            parse(t)
        end)
    else
        -- FreeBSD: read each key via sysctl in one shot
        local keys_arg = table.concat((function()
            local r = {}
            for _, k in ipairs(_zfs_keys) do
                table.insert(r, "kstat.zfs.misc.arcstats." .. k)
            end
            return r
        end)(), " ")
        awful.spawn.easy_async_with_shell(
            "sysctl -e " .. keys_arg .. " 2>/dev/null",
            function(out)
                local t = {}
                for line in out:gmatch("[^\n]+") do
                    -- sysctl -e output: kstat.zfs.misc.arcstats.size=12345
                    local k, v = line:match("kstat%.zfs%.misc%.arcstats%.(%w+)=(%d+)")
                    if k and v then t[k] = tonumber(v) end
                end
                parse(t)
            end)
    end
end

local function mem_fetch_procs(callback)
    awful.spawn.easy_async_with_shell(
        "ps -axo rss,comm 2>/dev/null | sort -rn | awk 'NR<=10 {printf \"%s %s\\n\", $1, $2}'",
        function(out)
            local procs = {}
            for rss, name in out:gmatch("(%d+)%s+(%S+)") do
                table.insert(procs, { name = name, mb = math.floor(tonumber(rss) / 1024) })
            end
            callback(procs)
        end
    )
end

local function mem_build_widget()
    local m = mem_now_last
    if not m or not m.total then return nil end
    local function row(label, value, label_w)
        return wibox.widget {
            { markup = markup.fontfg(theme.font, theme.fg_normal .. "99", label),
              widget = wibox.widget.textbox, forced_width = label_w or dpi(120) },
            { markup = markup.fontfg(theme.font, theme.fg_normal, value),
              widget = wibox.widget.textbox },
            layout = wibox.layout.fixed.horizontal,
        }
    end
    local function section(label)
        return wibox.widget {
            markup = markup.fontfg(theme.font, theme.fg_normal .. "88", label),
            widget = wibox.widget.textbox,
        }
    end

    local stats = wibox.widget {
        row("RAM used",  string.format("%d MB / %d MB (%d%%)", m.used, m.total, m.perc)),
        row("Cache",     string.format("%d MB", m.cache)),
        row("Buffers",   string.format("%d MB", m.buf)),
        row("Swap used", string.format("%d MB / %d MB", m.swapused, m.swap)),
        layout = wibox.layout.fixed.vertical, spacing = dpi(4),
    }

    local layout = wibox.widget { stats, layout = wibox.layout.fixed.vertical, spacing = dpi(6) }

    -- ZFS ARC section
    if _zfs_available then
        layout:add(wibox.widget {
            markup = markup.fontfg(theme.font, theme.fg_normal .. "44", "─────────────────────────────"),
            widget = wibox.widget.textbox,
        })
        if mem_zfs_last then
            local z = mem_zfs_last
            local zfs_rows = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = dpi(4) }
            zfs_rows:add(section("🗄  ZFS ARC"))
            zfs_rows:add(row("ARC size",    string.format("%d MB  (target %d MB, max %d MB)", z.size, z.target, z.max)))
            zfs_rows:add(row("  MRU",       string.format("%d MB", z.mru)))
            zfs_rows:add(row("  MFU",       string.format("%d MB", z.mfu)))
            zfs_rows:add(row("  anon",      string.format("%d MB", z.anon)))
            zfs_rows:add(row("  metadata",  string.format("%d MB", z.meta)))
            zfs_rows:add(row("Hit ratio",   z.hitratio))
            zfs_rows:add(row("Compression", z.compr))
            if z.l2size > 0 then
                zfs_rows:add(row("L2ARC",   string.format("%d MB", z.l2size)))
            end
            layout:add(zfs_rows)
        else
            layout:add(wibox.widget {
                markup = markup.fontfg(theme.font, theme.fg_normal .. "66", "loading…"),
                widget = wibox.widget.textbox,
            })
        end
    end

    -- Process list section
    layout:add(wibox.widget {
        markup = markup.fontfg(theme.font, theme.fg_normal .. "44", "─────────────────────────────"),
        widget = wibox.widget.textbox,
    })
    local proc_rows = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = dpi(2) }
    proc_rows:add(section("📋  top processes"))
    if #mem_proc_last > 0 then
        for _, p in ipairs(mem_proc_last) do
            proc_rows:add(row(p.name, string.format("%d MB", p.mb), dpi(180)))
        end
    else
        proc_rows:add(wibox.widget {
            markup = markup.fontfg(theme.font, theme.fg_normal .. "66", "loading…"),
            widget = wibox.widget.textbox,
        })
    end
    layout:add(proc_rows)

    return wibox.container.margin(layout, dpi(10), dpi(10), dpi(8), dpi(8))
end

local function mem_popup_show()
    if mem_popup then return end
    local w = mem_build_widget()
    if not w then return end
    local s  = awful.screen.focused()
    local wb = s.mywibox
    local px = math.min(mouse.coords().x, s.geometry.x + s.geometry.width - dpi(320))
    local py = wb and (wb.y + wb.height + dpi(8)) or dpi(30)
    mem_popup = awful.popup {
        widget = w, x = px, y = py,
        bg = theme.bg_normal, border_width = dpi(1), border_color = theme.border_focus,
        ontop = true, visible = true, screen = s,
    }
    local function refresh()
        -- fetch procs and ZFS in parallel; rebuild widget when both done
        local pending = 2
        local function done()
            pending = pending - 1
            if pending == 0 then
                local nw = mem_build_widget()
                if nw and mem_popup then mem_popup.widget = nw end
            end
        end
        mem_fetch_procs(function(procs) mem_proc_last = procs; done() end)
        mem_fetch_zfs(function(zfs)    mem_zfs_last  = zfs;   done() end)
    end
    refresh()  -- fetch immediately on open
    mem_popup_timer = gears.timer {
        timeout = 2, autostart = true,
        callback = refresh,
    }
end
local function mem_popup_hide()
    if mem_popup_timer then mem_popup_timer:stop(); mem_popup_timer = nil end
    if mem_popup then mem_popup.visible = false; mem_popup = nil end
    mem_proc_last = {}
    mem_zfs_last  = nil
end
memicon:connect_signal("mouse::enter", mem_popup_show)
mem.widget:connect_signal("mouse::enter", mem_popup_show)
memicon:connect_signal("mouse::leave", mem_popup_hide)
mem.widget:connect_signal("mouse::leave", mem_popup_hide)

-- CPU
local cpuicon = wibox.widget.imagebox(theme.widget_cpu)
local cpu_now_last = {}
local cpu = lain.widget.cpu({
    settings = function()
        cpu_now_last = cpu_now
        widget:set_markup(markup.font(theme.font, " " .. cpu_now.usage .. "% "))
    end
})

local cpu_popup       = nil
local cpu_popup_timer = nil

local function cpu_build_widget()
    local cores = cpu_now_last
    if not cores or #cores == 0 then return nil end
    local rows = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = dpi(3) }
    local i = 1
    while i <= #cores do
        local ll = string.format("Core %-2d", i - 1)
        local lv = string.format("%3d%%", cores[i].usage or 0)
        local rl = cores[i+1] and string.format("Core %-2d", i) or ""
        local rv = cores[i+1] and string.format("%3d%%", cores[i+1].usage or 0) or ""
        rows:add(wibox.widget {
            { markup = markup.fontfg(theme.font, theme.fg_normal .. "99", ll),
              widget = wibox.widget.textbox, forced_width = dpi(70) },
            { markup = markup.fontfg(theme.font, theme.fg_normal, lv),
              widget = wibox.widget.textbox, forced_width = dpi(40) },
            { markup = markup.fontfg(theme.font, theme.fg_normal .. "99", "   " .. rl),
              widget = wibox.widget.textbox, forced_width = dpi(80) },
            { markup = markup.fontfg(theme.font, theme.fg_normal, rv),
              widget = wibox.widget.textbox },
            layout = wibox.layout.fixed.horizontal,
        })
        i = i + 2
    end
    return wibox.container.margin(rows, dpi(10), dpi(10), dpi(8), dpi(8))
end

local function cpu_popup_show()
    if cpu_popup then return end
    local w = cpu_build_widget()
    if not w then return end
    local s  = awful.screen.focused()
    local wb = s.mywibox
    local px = math.min(mouse.coords().x, s.geometry.x + s.geometry.width - dpi(250))
    local py = wb and (wb.y + wb.height + dpi(8)) or dpi(30)
    cpu_popup = awful.popup {
        widget = w, x = px, y = py,
        bg = theme.bg_normal, border_width = dpi(1), border_color = theme.border_focus,
        ontop = true, visible = true, screen = s,
    }
    cpu_popup_timer = gears.timer {
        timeout = 2, autostart = true,
        callback = function()
            local nw = cpu_build_widget()
            if nw and cpu_popup then cpu_popup.widget = nw end
        end,
    }
end
local function cpu_popup_hide()
    if cpu_popup_timer then cpu_popup_timer:stop(); cpu_popup_timer = nil end
    if cpu_popup then cpu_popup.visible = false; cpu_popup = nil end
end
cpuicon:connect_signal("mouse::enter", cpu_popup_show)
cpu.widget:connect_signal("mouse::enter", cpu_popup_show)
cpuicon:connect_signal("mouse::leave", cpu_popup_hide)
cpu.widget:connect_signal("mouse::leave", cpu_popup_hide)

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
local _is_linux = io.open("/proc/version", "r") ~= nil

local function find_hwmon_dir(drivers)
    -- /sys/class/hwmon/ is Linux-only
    if not _is_linux then return nil, nil end
    for _, name in ipairs(drivers) do
        -- grep -l: the glob already expands paths, no -r needed
        local iter = io.popen("grep -l '^" .. name .. "$' /sys/class/hwmon/*/name 2>/dev/null | head -1")
        if iter then
            local namefile = iter:read("*l"); iter:close()
            if namefile then
                local dir = namefile:match("^(.+)/name$")
                if dir then return dir, name end
            end
        end
    end
    return nil, nil
end

local _tempdir,  _cputempdriver  = find_hwmon_dir({ "zenpower", "k10temp", "coretemp", "cpu_thermal" })
local _tempfile  = _tempdir and _tempdir .. "/temp1_input"
-- validate
if _tempfile then
    local tf = io.open(_tempfile, "r")
    if tf then tf:close() else _tempfile = nil; _tempdir = nil end
end

local _gputempdir, _gputempdriver = find_hwmon_dir({ "amdgpu", "nvidia", "nouveau", "radeon" })

local tempicon = wibox.widget.imagebox(theme.widget_temp)
local temp = { widget = wibox.widget.textbox() }

local temp_popup       = nil
local temp_popup_timer = nil
local temp_popup_lines = {}   -- updated each watch tick

local function temp_build_widget()
    if #temp_popup_lines == 0 then return nil end
    local rows = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = dpi(4) }
    for _, entry in ipairs(temp_popup_lines) do
        if entry.section then
            rows:add(wibox.widget {
                markup = markup.fontfg(theme.font, theme.fg_normal .. "88", entry.label),
                widget = wibox.widget.textbox,
            })
        else
            rows:add(wibox.widget {
                { markup = markup.fontfg(theme.font, theme.fg_normal .. "99", entry.label),
                  widget = wibox.widget.textbox, forced_width = dpi(160) },
                { markup = markup.fontfg(theme.font, theme.fg_normal, entry.value),
                  widget = wibox.widget.textbox },
                layout = wibox.layout.fixed.horizontal,
            })
        end
    end
    return wibox.container.margin(rows, dpi(10), dpi(10), dpi(8), dpi(8))
end

local function temp_popup_show()
    if temp_popup then return end
    local w = temp_build_widget()
    if not w then return end
    local s  = awful.screen.focused()
    local wb = s.mywibox
    local px = math.min(mouse.coords().x, s.geometry.x + s.geometry.width - dpi(270))
    local py = wb and (wb.y + wb.height + dpi(8)) or dpi(30)
    temp_popup = awful.popup {
        widget = w, x = px, y = py,
        bg = theme.bg_normal, border_width = dpi(1), border_color = theme.border_focus,
        ontop = true, visible = true, screen = s,
    }
    temp_popup_timer = gears.timer {
        timeout = 5, autostart = true,
        callback = function()
            local nw = temp_build_widget()
            if nw and temp_popup then temp_popup.widget = nw end
        end,
    }
end
local function temp_popup_hide()
    if temp_popup_timer then temp_popup_timer:stop(); temp_popup_timer = nil end
    if temp_popup then temp_popup.visible = false; temp_popup = nil end
end
tempicon:connect_signal("mouse::enter", temp_popup_show)
temp.widget:connect_signal("mouse::enter", temp_popup_show)
tempicon:connect_signal("mouse::leave", temp_popup_hide)
temp.widget:connect_signal("mouse::leave", temp_popup_hide)

if _tempfile then
    -- Linux: read directly from sysfs, divide by 1000
    awful.widget.watch({"cat", _tempfile}, 5, function(widget, stdout)
        local val = tonumber(stdout:match("%d+"))
        local deg = val and string.format("%.0f", val / 1e3) or "?"
        widget:set_markup(markup.font(theme.font, " " .. deg .. "°C "))

        -- helper: read all temp*_input entries from a hwmon dir into a list
        local function read_hwmon_temps(dir, section_label, dest, on_done)
            awful.spawn.easy_async_with_shell(
                string.format(
                    "for f in %s/temp*_input; do label=\"${f%%_input}_label\";" ..
                    " echo \"$(cat \"$label\" 2>/dev/null || echo \"${f##*/}\" | sed 's/_input$//') : $(cat \"$f\")\"; done",
                    dir),
                function(out)
                    table.insert(dest, { label = section_label, value = "", section = true })
                    for line in out:gmatch("[^\n]+") do
                        local label, raw = line:match("^(.+): (%d+)$")
                        if label and raw then
                            table.insert(dest, {
                                label = label,
                                value = string.format("%.1f°C", tonumber(raw) / 1e3),
                            })
                        end
                    end
                    on_done()
                end)
        end

        local lines = {}
        read_hwmon_temps(_tempdir, "🖥  CPU (" .. (_cputempdriver or "cpu") .. ")", lines,
            function()
                if _gputempdir then
                    read_hwmon_temps(_gputempdir, "🎮  GPU (" .. (_gputempdriver or "gpu") .. ")", lines,
                        function()
                            temp_popup_lines = lines
                        end)
                else
                    temp_popup_lines = lines
                end
            end)
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

-- Net (portable: uses netstat -ibn which works on Linux, FreeBSD, OpenBSD)
local neticon = wibox.widget.imagebox(theme.widget_net)
local net_now_last = {}

local net = { widget = wibox.widget.textbox() }
local _net_prev   = {}   -- { [dev] = { tx=n, rx=n } }
local _net_ifaces = nil  -- cached list of non-loopback interfaces

local function net_fmt(kb)
    if kb >= 1024 then return string.format("%5.1f M", kb / 1024)
    else               return string.format("%5.1f K", kb) end
end

-- Build interface list once: all non-loopback interfaces from netstat -ibn
local function net_get_ifaces(cb)
    if _net_ifaces then cb(_net_ifaces); return end
    awful.spawn.easy_async_with_shell(
        "netstat -ibn 2>/dev/null | awk 'NR>1 && $1 !~ /^lo/ && $1 !~ /Name/ {print $1}' | sort -u",
        function(out)
            local ifaces = {}
            for iface in out:gmatch("[^\n]+") do
                table.insert(ifaces, iface)
            end
            _net_ifaces = ifaces
            cb(ifaces)
        end)
end

-- Poll byte counters via netstat -ibn; update widget and net_now_last
local function net_update()
    net_get_ifaces(function(ifaces)
        awful.spawn.easy_async_with_shell(
            "netstat -ibn 2>/dev/null",
            function(out)
                -- netstat -ibn columns (Linux & BSD compatible):
                --   Name Mtu Network Address Ipkts Ierrs Ibytes Opkts Oerrs Obytes [Drop]
                -- We grab Name(1), Ibytes(7), Obytes(10) — but Linux omits Mtu/Network/Address
                -- and puts columns differently. Use awk to handle both:
                -- Linux:  Iface MTU RX-OK RX-ERR RX-DRP RX-OVR TX-OK TX-ERR TX-DRP TX-OVR Flg
                -- BSD:    Name  Mtu Network   Address       Ipkts Ierrs  Ibytes  Opkts Oerrs  Obytes
                -- Strategy: run 'netstat -ibn' and also check /proc on Linux for bytes.
                -- Simpler: on Linux use /sys/class/net; on BSD use netstat -ibn.
                local devices = {}
                if _is_linux then
                    -- Linux: read bytes directly from sysfs (reliable column positions)
                    for _, dev in ipairs(ifaces) do
                        local rx_f = io.open("/sys/class/net/" .. dev .. "/statistics/rx_bytes", "r")
                        local tx_f = io.open("/sys/class/net/" .. dev .. "/statistics/tx_bytes", "r")
                        local carrier_f = io.open("/sys/class/net/" .. dev .. "/carrier", "r")
                        local rx = rx_f and tonumber(rx_f:read("*l")) or 0
                        local tx = tx_f and tonumber(tx_f:read("*l")) or 0
                        local carrier = carrier_f and carrier_f:read("*l") or "0"
                        if rx_f then rx_f:close() end
                        if tx_f then tx_f:close() end
                        if carrier_f then carrier_f:close() end
                        devices[dev] = { rx = rx, tx = tx, carrier = carrier }
                    end
                else
                    -- BSD: parse netstat -ibn; take first line per interface (link-level row)
                    local seen = {}
                    for line in out:gmatch("[^\n]+") do
                        local name, ibytes, obytes = line:match("^(%S+)%s+%S+%s+%S+%s+%S+%s+%d+%s+%d+%s+(%d+)%s+%d+%s+%d+%s+(%d+)")
                        if name and ibytes and obytes and not seen[name] then
                            seen[name] = true
                            -- exclude loopback
                            if not name:match("^lo") then
                                devices[name] = { rx = tonumber(ibytes), tx = tonumber(obytes), carrier = "1" }
                            end
                        end
                    end
                end

                -- Calculate rates (bytes/s → KB/s), build net_now_last
                local now_devices = {}
                local total_rx_kb, total_tx_kb = 0, 0
                local timeout = 2  -- matches timer below

                for dev, cur in pairs(devices) do
                    local prev = _net_prev[dev] or { rx = cur.rx, tx = cur.tx }
                    local drx = math.max(0, cur.rx - prev.rx)
                    local dtx = math.max(0, cur.tx - prev.tx)
                    local rx_kb = drx / timeout / 1024
                    local tx_kb = dtx / timeout / 1024
                    total_rx_kb = total_rx_kb + rx_kb
                    total_tx_kb = total_tx_kb + tx_kb
                    now_devices[dev] = {
                        carrier  = cur.carrier,
                        received = net_fmt(rx_kb),
                        sent     = net_fmt(tx_kb),
                    }
                    _net_prev[dev] = { rx = cur.rx, tx = cur.tx }
                end

                net_now_last = { devices = now_devices }

                net.widget:set_markup(markup.fontfg(theme.font, theme.fg_normal,
                    " " .. net_fmt(total_rx_kb) .. "↓ " .. net_fmt(total_tx_kb) .. "↑ "))
            end)
    end)
end

gears.timer { timeout = 2, autostart = true, call_now = true, callback = net_update }

local net_popup       = nil
local net_popup_timer = nil

local function net_build_widget()
    local n = net_now_last
    if not n or not n.devices then return nil end
    local rows = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = dpi(4) }
    local devs = {}
    for dev in pairs(n.devices) do table.insert(devs, dev) end
    table.sort(devs)
    for _, dev in ipairs(devs) do
        local d = n.devices[dev]
        local state       = d.carrier == "1" and "up" or "down"
        local state_color = d.carrier == "1" and "#a6e3a1" or "#f38ba8"
        rows:add(wibox.widget {
            { markup = markup.fontfg(theme.font, theme.fg_normal, "<b>" .. dev .. "</b>"),
              widget = wibox.widget.textbox, forced_width = dpi(100) },
            { markup = markup.fontfg(theme.font, theme.fg_normal .. "99", "↓ "),
              widget = wibox.widget.textbox },
            { markup = markup.fontfg(theme.font, theme.fg_normal, string.format("%8s", d.received or "0")),
              widget = wibox.widget.textbox, forced_width = dpi(80) },
            { markup = markup.fontfg(theme.font, theme.fg_normal .. "99", "↑ "),
              widget = wibox.widget.textbox },
            { markup = markup.fontfg(theme.font, theme.fg_normal, string.format("%8s", d.sent or "0")),
              widget = wibox.widget.textbox, forced_width = dpi(80) },
            { markup = markup.fontfg(theme.font, state_color, "  " .. state),
              widget = wibox.widget.textbox },
            layout = wibox.layout.fixed.horizontal,
        })
    end
    return wibox.container.margin(rows, dpi(10), dpi(10), dpi(8), dpi(8))
end

local function net_popup_show()
    if net_popup then return end
    local w = net_build_widget()
    if not w then return end
    local s  = awful.screen.focused()
    local wb = s.mywibox
    local px = math.min(mouse.coords().x, s.geometry.x + s.geometry.width - dpi(370))
    local py = wb and (wb.y + wb.height + dpi(8)) or dpi(30)
    net_popup = awful.popup {
        widget = w, x = px, y = py,
        bg = theme.bg_normal, border_width = dpi(1), border_color = theme.border_focus,
        ontop = true, visible = true, screen = s,
    }
    net_popup_timer = gears.timer {
        timeout = 2, autostart = true,
        callback = function()
            local nw = net_build_widget()
            if nw and net_popup then net_popup.widget = nw end
        end,
    }
end
local function net_popup_hide()
    if net_popup_timer then net_popup_timer:stop(); net_popup_timer = nil end
    if net_popup then net_popup.visible = false; net_popup = nil end
end
neticon:connect_signal("mouse::enter", net_popup_show)
net.widget:connect_signal("mouse::enter", net_popup_show)
neticon:connect_signal("mouse::leave", net_popup_hide)
net.widget:connect_signal("mouse::leave", net_popup_hide)

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
