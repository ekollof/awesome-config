--[[
    Portable Uptime Widget
    Works on Linux (/proc/uptime), FreeBSD and OpenBSD (sysctl kern.boottime).
--]]

local wibox   = require("wibox")
local awful   = require("awful")
local gears   = require("gears")
local markup  = require("lain.util").markup
local beautiful = require("beautiful")

local uptime = {
    now    = ""
}

local _widgets = {}

local function update_widget()
    local function finish(seconds)
        seconds = tonumber(seconds) or 0
        local days = math.floor(seconds / 86400)
        seconds = seconds % 86400
        local hours = math.floor(seconds / 3600)
        seconds = seconds % 3600
        local mins = math.floor(seconds / 60)

        local text = ""
        if days > 0 then
            text = string.format("%dd %dh %dm", days, hours, mins)
        elseif hours > 0 then
            text = string.format("%dh %dm", hours, mins)
        else
            text = string.format("%dm", mins)
        end
        
        uptime.now = text
        local m = markup.font(beautiful.font, " " .. text .. " ")

        for _, w in ipairs(_widgets) do
            if w.valid then
                w:set_markup(m)
            end
        end
    end

    if _G._os == "Linux" then
        awful.spawn.easy_async_with_shell(
            "cat /proc/uptime",
            function(stdout)
                local secs = stdout:match("^(%d+%.?%d*)")
                finish(secs)
            end
        )
    else
        -- BSDs
        awful.spawn.easy_async_with_shell(
            "sysctl -n kern.boottime | awk '{print $4}' | tr -d ','",
            function(stdout)
                local boot_time = tonumber(stdout) or 0
                if boot_time > 0 then
                    local now = os.time()
                    finish(now - boot_time)
                end
            end
        )
    end
end

function uptime.create()
    local w = wibox.widget.textbox()
    table.insert(_widgets, w)
    return w
end

function uptime.attach(timeout)
    gears.timer {
        timeout   = timeout or 60,
        autostart = true,
        call_now  = true,
        callback  = update_widget
    }
end

return uptime
