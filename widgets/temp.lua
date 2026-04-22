--[[
    Temperature widget with hover popup.
    Linux: reads hwmon sysfs (auto-detects CPU/GPU driver).
    BSD:   reads via sysctl hw.sensors / dev.cpu.

    Usage:
        local temp = require("widgets.temp")
        -- temp.widget  : textbox showing current CPU temp
        -- temp.attach(icon, widget) : wire hover signals
--]]

local wibox  = require("wibox")
local awful  = require("awful")
local gears  = require("gears")
local markup = require("lain.util").markup
local dpi    = require("beautiful.xresources").apply_dpi

local _is_linux = io.open("/proc/version", "r") ~= nil

-- hwmon detection (Linux only) -------------------------------------------

local function find_hwmon_dir(drivers)
    if not _is_linux then return nil, nil end
    for _, name in ipairs(drivers) do
        local iter = io.popen(
            "grep -l '^" .. name .. "$' /sys/class/hwmon/*/name 2>/dev/null | head -1")
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

local _tempdir,   _cputempdriver  = find_hwmon_dir({ "zenpower", "k10temp", "coretemp", "cpu_thermal" })
local _tempfile   = _tempdir and (_tempdir .. "/temp1_input")
local _gputempdir, _gputempdriver = find_hwmon_dir({ "amdgpu", "nvidia", "nouveau", "radeon" })

-- validate tempfile exists
if _tempfile then
    local tf = io.open(_tempfile, "r")
    if tf then tf:close() else _tempfile = nil; _tempdir = nil end
end

-- Widget -----------------------------------------------------------------

local temp = { widget = wibox.widget.textbox() }

local _popup_lines = {}   -- updated each watch tick

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

local function refresh_popup_lines(on_done)
    if not _tempdir then on_done(); return end
    local lines = {}
    read_hwmon_temps(_tempdir, "🖥  CPU (" .. (_cputempdriver or "cpu") .. ")", lines,
        function()
            if _gputempdir then
                read_hwmon_temps(_gputempdir, "🎮  GPU (" .. (_gputempdriver or "gpu") .. ")", lines,
                    function()
                        _popup_lines = lines
                        on_done()
                    end)
            else
                _popup_lines = lines
                on_done()
            end
        end)
end

if _tempfile then
    -- Linux: watch sysfs directly
    awful.widget.watch({"cat", _tempfile}, 5, function(widget, stdout)
        local beautiful = require("beautiful")
        local val = tonumber(stdout:match("%d+"))
        local deg = val and string.format("%.0f", val / 1e3) or "?"
        widget:set_markup(markup.font(beautiful.font, " " .. deg .. "°C "))
        refresh_popup_lines(function() end)
    end, temp.widget)
else
    -- BSD: sysctl
    awful.widget.watch(
        { awful.util.shell, "-c",
          "sysctl -n hw.sensors.cpu0.temp0 2>/dev/null || sysctl -n dev.cpu.0.temperature 2>/dev/null" },
        5,
        function(widget, stdout)
            local beautiful = require("beautiful")
            local deg = stdout:match("(%-?%d+%.?%d*)") or "?"
            widget:set_markup(markup.font(beautiful.font, " " .. deg .. "°C "))
        end,
        temp.widget)
end

-- Popup ------------------------------------------------------------------

local _popup       = nil
local _popup_timer = nil

local function build_popup_widget()
    local beautiful = require("beautiful")
    if #_popup_lines == 0 then return nil end
    local rows = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = dpi(4) }
    for _, entry in ipairs(_popup_lines) do
        if entry.section then
            rows:add(wibox.widget {
                markup = markup.fontfg(beautiful.font, beautiful.fg_normal .. "88", entry.label),
                widget = wibox.widget.textbox,
            })
        else
            rows:add(wibox.widget {
                { markup = markup.fontfg(beautiful.font, beautiful.fg_normal .. "99", entry.label),
                  widget = wibox.widget.textbox, forced_width = dpi(160) },
                { markup = markup.fontfg(beautiful.font, beautiful.fg_normal, entry.value),
                  widget = wibox.widget.textbox },
                layout = wibox.layout.fixed.horizontal,
            })
        end
    end
    return wibox.container.margin(rows, dpi(10), dpi(10), dpi(8), dpi(8))
end

function temp.popup_show()
    if _popup then return end
    local w = build_popup_widget()
    if not w then return end
    local beautiful = require("beautiful")
    local s  = awful.screen.focused()
    local wb = s.mywibox
    local px = math.min(mouse.coords().x, s.geometry.x + s.geometry.width - dpi(270))
    local py = wb and (wb.y + wb.height + dpi(8)) or dpi(30)
    _popup = awful.popup {
        widget = w, x = px, y = py,
        bg = beautiful.bg_normal, border_width = dpi(1), border_color = beautiful.border_focus,
        ontop = true, visible = true, screen = s,
    }
    _popup_timer = gears.timer {
        timeout = 5, autostart = true,
        callback = function()
            refresh_popup_lines(function()
                local nw = build_popup_widget()
                if nw and _popup then _popup.widget = nw end
            end)
        end,
    }
end

function temp.popup_hide()
    if _popup_timer then _popup_timer:stop(); _popup_timer = nil end
    if _popup then _popup.visible = false; _popup = nil end
end

function temp.attach(icon, widget_tb)
    icon:connect_signal("mouse::enter", temp.popup_show)
    icon:connect_signal("mouse::leave", temp.popup_hide)
    widget_tb:connect_signal("mouse::enter", temp.popup_show)
    widget_tb:connect_signal("mouse::leave", temp.popup_hide)
end

return temp
