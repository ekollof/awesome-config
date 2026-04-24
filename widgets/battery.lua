--[[
    Portable Battery Widget
    Works on Linux (sysfs), FreeBSD (sysctl), and OpenBSD (apm).
--]]

local wibox   = require("wibox")
local awful   = require("awful")
local gears   = require("gears")
local markup  = require("lain.util").markup
local beautiful = require("beautiful")

-- OS detection
local f = io.popen("uname")
local _os = f:read("*all"):gsub("%s+", "")
f:close()

local battery = {
    widget = wibox.widget.textbox(),
    icon   = wibox.widget.imagebox(),
    now    = {
        perc      = 0,
        ac_status = 0, -- 0: DC, 1: AC
    }
}

local function update_widget()
    local function finish(perc, ac_status)
        perc = tonumber(perc) or 0
        ac_status = tonumber(ac_status) or 0
        
        battery.now.perc = perc
        battery.now.ac_status = ac_status

        -- Update Icon
        if ac_status == 1 then
            battery.icon:set_image(beautiful.widget_ac)
            battery.widget:set_markup(markup.font(beautiful.font, " AC "))
        else
            if perc <= 5 then
                battery.icon:set_image(beautiful.widget_battery_empty)
            elseif perc <= 15 then
                battery.icon:set_image(beautiful.widget_battery_low)
            else
                battery.icon:set_image(beautiful.widget_battery)
            end
            battery.widget:set_markup(markup.font(beautiful.font, " " .. perc .. "% "))
        end
    end

    if _os == "Linux" then
        local base = "/sys/class/power_supply/"
        awful.spawn.easy_async_with_shell(
            string.format("cat %sBAT*/capacity %sAC*/online 2>/dev/null", base, base),
            function(stdout)
                local lines = {}
                for line in stdout:gmatch("[^\n]+") do table.insert(lines, line) end
                finish(lines[1], lines[2])
            end
        )
    elseif _os == "FreeBSD" then
        awful.spawn.easy_async_with_shell(
            "sysctl -n hw.acpi.battery.life hw.acpi.acline",
            function(stdout)
                local lines = {}
                for line in stdout:gmatch("[^\n]+") do table.insert(lines, line) end
                finish(lines[1], lines[2])
            end
        )
    elseif _os == "OpenBSD" then
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
    if _os == "Linux" then
        cb(gears.filesystem.dir_readable("/sys/class/power_supply/BAT0"))
    elseif _os == "FreeBSD" then
        awful.spawn.easy_async_with_shell("sysctl -n hw.acpi.battery.units", function(out)
            cb(tonumber(out) and tonumber(out) > 0)
        end)
    elseif _os == "OpenBSD" then
        -- On OpenBSD apm -l returns 255 if no battery
        awful.spawn.easy_async_with_shell("apm -l", function(out)
            cb(tonumber(out) and tonumber(out) ~= 255)
        end)
    else
        cb(false)
    end
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
