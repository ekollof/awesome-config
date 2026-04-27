--[[
    Portable net stats widget
    Works on Linux (/sys/class/net sysfs), FreeBSD and OpenBSD (netstat -ibn).

    Usage:
        local net = require("widgets.net")
        -- net.widget  : textbox showing total rx/tx rates
        -- net.devices : table of { [devname] = { carrier, received, sent } }
                         updated every poll interval
--]]

local wibox   = require("wibox")
local awful   = require("awful")
local gears   = require("gears")
local markup  = require("lain.util").markup
local dpi     = require("beautiful.xresources").apply_dpi

local _is_linux = io.open("/proc/version", "r") ~= nil

local net = {
    widget  = wibox.widget.textbox(),
    devices = {},  -- [devname] = { carrier, received, sent }
}

local _prev      = {}   -- [dev] = { rx=n, tx=n }
local _graphs    = {}   -- [dev] = { rx=graph, tx=graph }
local _ifaces    = nil  -- cached list, populated on first poll
local _timeout   = 2

local function create_graph(color)
    return wibox.widget {
        max_value = 10,
        scale = true,
        background_color = "#333333",
        border_width = 1,
        border_color = "#444444",
        color = color,
        width = dpi(180),
        height = dpi(25),
        step_width = dpi(2),
        step_spacing = 1,
        widget = wibox.widget.graph
    }
end

local function fmt(kb)
    if kb >= 1024 then return string.format("%5.1f M", kb / 1024)
    else               return string.format("%5.1f K", kb) end
end

local function get_ifaces(cb)
    if _ifaces then cb(_ifaces); return end
    if _is_linux then
        -- Read interface names directly from sysfs
        local ifaces = {}
        local f = io.popen("ls /sys/class/net/ 2>/dev/null")
        if f then
            for name in f:read("*a"):gmatch("[^\n]+") do
                if name ~= "lo" then
                    table.insert(ifaces, name)
                end
            end
            f:close()
        end
        _ifaces = ifaces
        cb(ifaces)
    else
        awful.spawn.easy_async_with_shell(
            "netstat -ibn 2>/dev/null | awk 'NR>1 && $1 !~ /^lo/ && $1 !~ /Name/ {print $1}' | sort -u",
            function(out)
                local ifaces = {}
                for iface in out:gmatch("[^\n]+") do
                    table.insert(ifaces, iface)
                end
                _ifaces = ifaces
                cb(ifaces)
            end)
    end
end

local function update()
    get_ifaces(function(ifaces)
        local function process(out)
            local raw = {}

            if _is_linux then
                for _, dev in ipairs(ifaces) do
                    local rx_f      = io.open("/sys/class/net/" .. dev .. "/statistics/rx_bytes", "r")
                    local tx_f      = io.open("/sys/class/net/" .. dev .. "/statistics/tx_bytes", "r")
                    local carrier_f = io.open("/sys/class/net/" .. dev .. "/carrier", "r")
                    local rx      = rx_f      and tonumber(rx_f:read("*l"))      or 0
                    local tx      = tx_f      and tonumber(tx_f:read("*l"))      or 0
                    local carrier = carrier_f and carrier_f:read("*l")           or "0"
                    if rx_f      then rx_f:close()      end
                    if tx_f      then tx_f:close()      end
                    if carrier_f then carrier_f:close() end

                    -- Fetch extra info (Linux)
                    local extra = ""
                    if dev:match("^wl") then
                        local f = io.popen("iwgetid " .. dev .. " -r 2>/dev/null")
                        if f then
                            local ssid = f:read("*l")
                            f:close()
                            if ssid then extra = "SSID: " .. ssid end
                        end
                    else
                        local f = io.open("/sys/class/net/" .. dev .. "/speed", "r")
                        if f then
                            local speed = f:read("*l")
                            f:close()
                            if speed and speed ~= "-1" then extra = speed .. " Mb/s" end
                        end
                    end

                    raw[dev] = { rx = rx, tx = tx, carrier = carrier, extra = extra }
                end
            else
                -- BSD: parse netstat -ibn; use first (link-level) row per interface
                local seen = {}
                for line in out:gmatch("[^\n]+") do
                    local name, ibytes, obytes = line:match(
                        "^(%S+)%s+%S+%s+%S+%s+%S+%s+%d+%s+%d+%s+(%d+)%s+%d+%s+%d+%s+(%d+)")
                    if name and ibytes and obytes and not seen[name] and not name:match("^lo") then
                        seen[name] = true
                        raw[name] = { rx = tonumber(ibytes), tx = tonumber(obytes), carrier = "1", extra = "" }
                    end
                end
            end

            local total_rx, total_tx = 0, 0
            local devices = {}

            for dev, cur in pairs(raw) do
                local prev  = _prev[dev] or { rx = cur.rx, tx = cur.tx }
                local drx   = math.max(0, cur.rx - prev.rx)
                local dtx   = math.max(0, cur.tx - prev.tx)
                local rx_kb = drx / _timeout / 1024
                local tx_kb = dtx / _timeout / 1024
                total_rx    = total_rx + rx_kb
                total_tx    = total_tx + tx_kb

                if not _graphs[dev] then
                    _graphs[dev] = {
                        rx = create_graph("#f9e2af"), -- Yellow-ish for RX
                        tx = create_graph("#f38ba8"), -- Red-ish for TX
                    }
                end
                _graphs[dev].rx:add_value(rx_kb)
                _graphs[dev].tx:add_value(tx_kb)

                devices[dev] = {
                    carrier  = cur.carrier,
                    received = fmt(rx_kb),
                    sent     = fmt(tx_kb),
                    extra    = cur.extra,
                }
                _prev[dev] = { rx = cur.rx, tx = cur.tx }
            end

            net.devices = devices

            local beautiful = require("beautiful")
            net.widget:set_markup(markup.fontfg(
                beautiful.font, beautiful.fg_normal,
                " " .. fmt(total_rx) .. "↓ " .. fmt(total_tx) .. "↑ "))
        end

        if _is_linux then
            -- sysfs reads are synchronous; no subprocess needed
            process(nil)
        else
            awful.spawn.easy_async_with_shell("netstat -ibn 2>/dev/null", process)
        end
    end)
end

local _timer = gears.timer { timeout = _timeout, autostart = true, call_now = true, callback = update }

-- Popup ------------------------------------------------------------------

local _popup       = nil
local _popup_timer = nil

local function build_popup_widget()
    local beautiful = require("beautiful")
    if not next(net.devices) then return nil end
    local rows = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = dpi(4) }
    local devs = {}
    for dev in pairs(net.devices) do table.insert(devs, dev) end
    table.sort(devs)
    for _, dev in ipairs(devs) do
        local d = net.devices[dev]
        local g = _graphs[dev]
        local state_color = d.carrier == "1" and "#a6e3a1" or "#f38ba8"
        local state       = d.carrier == "1" and "up" or "down"
        local info_txt    = d.extra ~= "" and ("  <span color='#f9e2af'>" .. d.extra .. "</span>") or ""
        
        rows:add(wibox.widget {
            {
                { markup = markup.fontfg(beautiful.font, beautiful.fg_normal, "<b>" .. dev .. "</b>") .. info_txt,
                  widget = wibox.widget.textbox, forced_width = dpi(220) },
                { markup = markup.fontfg(beautiful.font, beautiful.fg_normal .. "99", "↓ "),
                  widget = wibox.widget.textbox },
                { markup = markup.fontfg(beautiful.font, beautiful.fg_normal, string.format("%8s", d.received or "0")),
                  widget = wibox.widget.textbox, forced_width = dpi(80) },
                { markup = markup.fontfg(beautiful.font, beautiful.fg_normal .. "99", "↑ "),
                  widget = wibox.widget.textbox },
                { markup = markup.fontfg(beautiful.font, beautiful.fg_normal, string.format("%8s", d.sent or "0")),
                  widget = wibox.widget.textbox, forced_width = dpi(80) },
                { markup = markup.fontfg(beautiful.font, state_color, "  " .. state),
                  widget = wibox.widget.textbox },
                layout = wibox.layout.fixed.horizontal,
            },
            {
                {
                    { text = "RX ", widget = wibox.widget.textbox, font = "BerkeleyMono Nerd Font 8" },
                    g and g.rx or wibox.widget.textbox("N/A"),
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(5)
                },
                {
                    { text = "TX ", widget = wibox.widget.textbox, font = "BerkeleyMono Nerd Font 8" },
                    g and g.tx or wibox.widget.textbox("N/A"),
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(5)
                },
                layout = wibox.layout.flex.horizontal,
                spacing = dpi(10)
            },
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(5)
        })
        -- Add a separator margin between interfaces
        rows:add(wibox.container.margin(wibox.widget.base.make_widget(), 0, 0, 0, dpi(5)))
    end
    return wibox.container.margin(rows, dpi(10), dpi(10), dpi(8), dpi(8))
end

function net.popup_show()
    if _popup then return end
    local w = build_popup_widget()
    if not w then return end
    local beautiful = require("beautiful")
    local awful_mod = require("awful")
    local s  = awful_mod.screen.focused()
    local wb = s.mywibox
    local px = math.min(mouse.coords().x, s.geometry.x + s.geometry.width - dpi(510))
    local py = wb and (wb.y + wb.height + dpi(8)) or dpi(30)
    _popup = awful_mod.popup {
        widget = w, x = px, y = py,
        bg = beautiful.bg_normal, border_width = dpi(1), border_color = beautiful.border_focus,
        ontop = true, visible = true, screen = s,
        forced_width = dpi(500)
    }
    _popup_timer = gears.timer {
        timeout = _timeout, autostart = true,
        callback = function()
            local nw = build_popup_widget()
            if nw and _popup then _popup.widget = nw end
        end,
    }
end

function net.popup_hide()
    if _popup_timer then _popup_timer:stop(); _popup_timer = nil end
    if _popup then _popup.visible = false; _popup = nil end
end

return net
