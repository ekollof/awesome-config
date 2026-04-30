--[[
    MPD widget with cover art popup and track-change notifications.
    Cover art is decoded fully in memory (base64 | GLib/GdkPixbuf/Cairo).

    Usage:
        local mpd = require("widgets.mpd")({
            color_artist = "#FF8466",   -- optional, defaults shown
            color_paused = "#aaaaaa",
        })
        -- mpd.widget     : textbox
        -- mpd.icon       : imagebox (needs theme.widget_music* icons set first)
        -- mpd.container  : margin container wrapping icon + widget
        -- mpd.lain       : underlying lain.widget.mpd instance
        -- mpd.attach()   : wire hover signals on container
--]]

local wibox   = require("wibox")
local awful   = require("awful")
local gears   = require("gears")
local lain    = require("lain")
local naughty = require("naughty")
local markup  = require("lain.util").markup
local dpi     = require("beautiful.xresources").apply_dpi
local timer   = gears.timer

local function factory(args)
    args = args or {}
    local color_artist = args.color_artist or "#FF8466"
    local color_paused = args.color_paused or "#aaaaaa"
    local modkey       = args.modkey or "Mod4"

    local beautiful = require("beautiful")

    local mpd = {
        widget    = nil,
        icon      = nil,
        container = nil,
        lain      = nil,
        now       = {},
    }

    -- Icons (must be set in beautiful before requiring this module)
    mpd.icon = wibox.widget.imagebox(beautiful.widget_music)

    -- Cover art (cairo.ImageSurface held in memory) ----------------------
    local _cover_surface = nil
    local _last_title    = ""

    local function fetch_cover(file, callback)
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
            end)
    end

    -- Helper: format seconds as mm:ss
    local function fmt_time(s)
        s = tonumber(s) or 0
        return string.format("%2d:%02d", math.floor(s / 60), s % 60)
    end

    -- lain mpd widget ----------------------------------------------------
    mpd.lain = lain.widget.mpd({
        notify   = "off",
        timeout  = 1,
        settings = function()
            mpd.now = mpd_now

            if mpd_now.state == "play" then
                local pos    = " " .. fmt_time(mpd_now.elapsed) .. "/" .. fmt_time(mpd_now.time) .. " "
                local artist = " " .. mpd_now.artist .. " "
                local title  = mpd_now.title .. " "
                mpd.icon:set_image(beautiful.widget_music_on)
                widget:set_markup(markup.fontfg(beautiful.font, beautiful.fg_normal,
                    markup.fontfg(beautiful.font, color_artist, artist) ..
                    title ..
                    markup.fontfg(beautiful.font, color_paused, pos)))

                -- Track change notification
                if mpd_now.title ~= _last_title then
                    _last_title = mpd_now.title
                    local n_artist = mpd_now.artist
                    local n_title  = mpd_now.title
                    local n_album  = mpd_now.album
                    local n_date   = mpd_now.date
                    local n_file   = mpd_now.file
                    local n_text   = n_title ..
                        (n_album ~= "N/A" and ("\n" .. n_album) or "") ..
                        (n_date  ~= "N/A" and (" (" .. n_date:match("^%d%d%d%d") .. ")") or "")
                    local notif = naughty.notify({ title = n_artist, text = n_text, timeout = 8 })
                    fetch_cover(n_file, function(cover)
                        _cover_surface = cover
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
                local pos    = " " .. fmt_time(mpd_now.elapsed) .. "/" .. fmt_time(mpd_now.time) .. " "
                local artist = " " .. mpd_now.artist .. " "
                local title  = mpd_now.title .. " "
                mpd.icon:set_image(beautiful.widget_music_pause)
                widget:set_markup(markup.fontfg(beautiful.font, beautiful.fg_normal,
                    markup.fontfg(beautiful.font, color_paused, artist) ..
                    markup.fontfg(beautiful.font, color_paused, title) ..
                    markup.fontfg(beautiful.font, color_paused, pos)))
                _last_title = ""
            else
                widget:set_text("")
                mpd.icon:set_image(beautiful.widget_music)
                _last_title    = ""
                _cover_surface = nil
            end
        end
    })
    mpd.widget = mpd.lain.widget

    -- Buttons ------------------------------------------------------------
    local function make_guard_button(cmd)
        local guard = false
        return function()
            if guard then return end
            guard = true
            awful.spawn.with_shell(cmd)
            mpd.lain.update()
            local t = timer({ timeout = 0.5 })
            t:connect_signal("timeout", function() t:stop(); guard = false end)
            t:start()
        end
    end

    local musicplr = awful.util.terminal .. " --title Music ncmpcpp"
    local buttons  = awful.util.table.join(
        awful.button({ modkey }, 1, nil,               function() awful.spawn.with_shell(musicplr) end),
        awful.button({ "Shift" },          1, make_guard_button("mpc stop"),  nil),
        awful.button({},                   1, make_guard_button("mpc prev"),  nil),
        awful.button({},                   2, make_guard_button("mpc toggle"), nil),
        awful.button({},                   3, make_guard_button("mpc next"),  nil),
        awful.button({},                   4, nil, function() awful.spawn.with_shell("mpc volume +5"); mpd.lain.update() end),
        awful.button({},                   5, nil, function() awful.spawn.with_shell("mpc volume -5"); mpd.lain.update() end))

    mpd.icon:buttons(buttons)
    mpd.widget:buttons(buttons)

    -- Container ----------------------------------------------------------
    mpd.container = wibox.container.background(
        wibox.container.margin(
            wibox.widget { mpd.icon, mpd.widget, layout = wibox.layout.align.horizontal },
            dpi(3), dpi(6)),
        beautiful.bg_normal)
    mpd.container:buttons(buttons)

    -- Hover popup --------------------------------------------------------
    local _popup_wibox = nil

    local function popup_show()
        if _popup_wibox then return end
        local n = mpd.now
        if not n or n.state == "stop" then return end

        local cover_widget = wibox.widget.imagebox()
        if _cover_surface then cover_widget:set_image(_cover_surface) end

        local lines = {}
        if n.title  ~= "N/A" then lines[#lines+1] = "<b>" .. n.title  .. "</b>" end
        if n.artist ~= "N/A" then lines[#lines+1] = n.artist end
        if n.album  ~= "N/A" then
            lines[#lines+1] = n.album ..
                (n.date ~= "N/A" and (" (" .. n.date:match("^%d%d%d%d") .. ")") or "")
        end
        if n.genre ~= "N/A" then lines[#lines+1] = "<i>" .. n.genre .. "</i>" end

        local text_widget = wibox.widget {
            markup = markup.fontfg(beautiful.font, beautiful.fg_normal, table.concat(lines, "\n")),
            widget = wibox.widget.textbox,
        }

        local size    = dpi(96)
        local popup_w = size + dpi(200)
        local popup_h = size + dpi(16)
        local s       = awful.screen.focused()
        local wb      = s.mywibox
        local px      = math.min(mouse.coords().x, s.geometry.x + s.geometry.width - popup_w - dpi(8))
        local py      = wb and (wb.y + wb.height + dpi(8)) or dpi(30)

        _popup_wibox = wibox {
            width = popup_w, height = popup_h, x = px, y = py,
            bg = beautiful.bg_normal, border_width = dpi(1), border_color = beautiful.border_focus,
            ontop = true, visible = true, screen = s,
        }
        _popup_wibox:setup {
            {
                { forced_width = size, forced_height = size, cover_widget,
                  widget = wibox.container.background },
                { wibox.container.margin(text_widget, dpi(8), dpi(8), dpi(8), dpi(8)),
                  widget = wibox.container.place, valign = "center" },
                layout = wibox.layout.fixed.horizontal,
            },
            widget = wibox.container.background,
        }
    end

    local function popup_hide()
        if _popup_wibox then _popup_wibox.visible = false; _popup_wibox = nil end
    end

    function mpd.attach()
        mpd.container:connect_signal("mouse::enter", popup_show)
        mpd.container:connect_signal("mouse::leave", popup_hide)
    end

    return mpd
end

return factory
