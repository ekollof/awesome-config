--[[
    CPU usage widget with hover popup showing per-core usage.
    Wraps lain.widget.cpu; popup is custom.

    Usage:
        local cpu = require("widgets.cpu")
        -- cpu.widget  : textbox (from lain)
        -- cpu.attach(icon, widget) : wire hover signals
--]]

local wibox  = require("wibox")
local awful  = require("awful")
local gears  = require("gears")
local lain   = require("lain")
local markup = require("lain.util").markup
local dpi    = require("beautiful.xresources").apply_dpi

local cpu = {
    icon   = nil,
    widget = nil,
}

local _now_last = {}

cpu.lain = lain.widget.cpu({
    settings = function()
        _now_last = cpu_now
        local beautiful = require("beautiful")
        widget:set_markup(markup.font(beautiful.font, " " .. cpu_now.usage .. "% "))
    end
})
cpu.widget = cpu.lain.widget

local function build_popup_widget()
    local beautiful = require("beautiful")
    local cores = _now_last
    if not cores or #cores == 0 then return nil end
    local rows = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = dpi(3) }
    local i = 1
    while i <= #cores do
        local ll = string.format("Core %-2d", i - 1)
        local lv = string.format("%3d%%", cores[i].usage or 0)
        local rl = cores[i+1] and string.format("Core %-2d", i)            or ""
        local rv = cores[i+1] and string.format("%3d%%", cores[i+1].usage or 0) or ""
        rows:add(wibox.widget {
            { markup = markup.fontfg(beautiful.font, beautiful.fg_normal .. "99", ll),
              widget = wibox.widget.textbox, forced_width = dpi(70) },
            { markup = markup.fontfg(beautiful.font, beautiful.fg_normal, lv),
              widget = wibox.widget.textbox, forced_width = dpi(40) },
            { markup = markup.fontfg(beautiful.font, beautiful.fg_normal .. "99", "   " .. rl),
              widget = wibox.widget.textbox, forced_width = dpi(80) },
            { markup = markup.fontfg(beautiful.font, beautiful.fg_normal, rv),
              widget = wibox.widget.textbox },
            layout = wibox.layout.fixed.horizontal,
        })
        i = i + 2
    end
    return wibox.container.margin(rows, dpi(10), dpi(10), dpi(8), dpi(8))
end

-- Popup ------------------------------------------------------------------

local _popup       = nil
local _popup_timer = nil

function cpu.popup_show()
    if _popup then return end
    local w = build_popup_widget()
    if not w then return end
    local beautiful = require("beautiful")
    local s  = awful.screen.focused()
    local wb = s.mywibox
    local px = math.min(mouse.coords().x, s.geometry.x + s.geometry.width - dpi(250))
    local py = wb and (wb.y + wb.height + dpi(8)) or dpi(30)
    _popup = awful.popup {
        widget = w, x = px, y = py,
        bg = beautiful.bg_normal, border_width = dpi(1), border_color = beautiful.border_focus,
        ontop = true, visible = true, screen = s,
    }
    _popup_timer = gears.timer {
        timeout = 2, autostart = true,
        callback = function()
            local nw = build_popup_widget()
            if nw and _popup then _popup.widget = nw end
        end,
    }
end

function cpu.popup_hide()
    if _popup_timer then _popup_timer:stop(); _popup_timer = nil end
    if _popup then _popup.visible = false; _popup = nil end
end

function cpu.attach(icon, widget_tb)
    icon:connect_signal("mouse::enter", cpu.popup_show)
    icon:connect_signal("mouse::leave", cpu.popup_hide)
    widget_tb:connect_signal("mouse::enter", cpu.popup_show)
    widget_tb:connect_signal("mouse::leave", cpu.popup_hide)
end

return cpu
