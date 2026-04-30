--[[
    Portable Battery Widget
    Works on Linux (sysfs), FreeBSD (sysctl), and OpenBSD (apm).
--]]

local wibox   = require("wibox")
local awful   = require("awful")
local gears   = require("gears")
local markup  = require("lain.util").markup
local beautiful = require("beautiful")

local battery = {
    now    = {
        perc      = 0,
        ac_status = 0, -- 0: DC, 1: AC
    }
}

local _widgets = {}
local _icons   = {}

local function update_widget()
    local function finish(perc, ac_status)
        perc = tonumber(perc) or 0
        ac_status = tonumber(ac_status) or 0
        
        battery.now.perc = perc
        battery.now.ac_status = ac_status

        -- Update Icons
        local icon_img = ac_status == 1 and beautiful.widget_ac or (
            perc <= 5 and beautiful.widget_battery_empty or (
                perc <= 15 and beautiful.widget_battery_low or beautiful.widget_battery
            )
        )
        
        local m = ac_status == 1 
            and markup.font(beautiful.font, " AC ")
            or  markup.font(beautiful.font, " " .. string.format("%3d", perc) .. "% ")

        for _, i in ipairs(_icons) do
            if i.valid then i:set_image(icon_img) end
        end
        for _, w in ipairs(_widgets) do
            if w.valid then w:set_markup(m) end
        end
    end

    if _G._os == "Linux" then
        local base = "/sys/class/power_supply/"
        awful.spawn.easy_async_with_shell(
            string.format("cat %sBAT*/capacity %sAC*/online 2>/dev/null", base, base),
            function(stdout)
                local lines = {}
                for line in stdout:gmatch("[^\n]+") do table.insert(lines, line) end
                finish(lines[1], lines[2])
            end
        )
    elseif _G._os == "FreeBSD" then
        awful.spawn.easy_async_with_shell(
            "sysctl -n hw.acpi.battery.life hw.acpi.acline",
            function(stdout)
                local lines = {}
                for line in stdout:gmatch("[^\n]+") do table.insert(lines, line) end
                finish(lines[1], lines[2])
            end
        )
    elseif _G._os == "OpenBSD" then
        awful.spawn.easy_async_with_shell(
            "apm -l && apm -a",
            function(stdout)
                local lines = {}
                for line in stdout:gmatch("[^\n]+") do table.insert(lines, line) end
                -- apm -a returns 0: DC, 1: AC, 2: Backup (treat as AC for icon)
                local ac = (lines[2] == "0") and 0 or 1
                finish(lines[1], ac)
            end
        )
    end
end

-- Check if battery exists before starting
local function check_has_battery(cb)
    if _G._os == "Linux" then
        cb(gears.filesystem.dir_readable("/sys/class/power_supply/BAT0"))
    elseif _G._os == "FreeBSD" then
        awful.spawn.easy_async_with_shell("sysctl -n hw.acpi.battery.units", function(out)
            cb(tonumber(out) and tonumber(out) > 0)
        end)
    elseif _G._os == "OpenBSD" then
        -- On OpenBSD apm -l returns 255 if no battery
        awful.spawn.easy_async_with_shell("apm -l", function(out)
            cb(tonumber(out) and tonumber(out) ~= 255)
        end)
    else
        cb(false)
    end
end

function battery.create()
    local w = wibox.widget.textbox()
    local i = wibox.widget.imagebox()
    table.insert(_widgets, w)
    table.insert(_icons, i)
    return w, i
end

function battery.attach(timeout)
    check_has_battery(function(has)
        if has then
            gears.timer {
                timeout   = timeout or 30,
                autostart = true,
                call_now  = true,
                callback  = update_widget
            }
        end
    end)
end

return battery
