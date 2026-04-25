--[[
    Consolidated System Monitor Widget
    Combines CPU, Memory, Temp, and Disk I/O into one widget/popup.
    Supports Linux, FreeBSD, and OpenBSD.
--]]

local wibox     = require("wibox")
local awful     = require("awful")
local gears     = require("gears")
local markup    = require("lain.util").markup

local sysmon = {
    _wibar_updates = {}
}

-- Logging Helper ---------------------------------------------------------
local function log(msg)
    local f = io.open(os.getenv("HOME") .. "/.cache/awesome/sysmon.log", "a")
    if f then
        f:write(os.date("%Y-%m-%d %H:%M:%S") .. " [SYSMON] " .. tostring(msg) .. "\n")
        f:close()
    end
end

-- Data State
local _data = {
    cpu_usage = 0,
    mem_used  = 0,
    mem_total = 0,
    mem_perc  = 0,
    temp      = 0,
    disk_read = 0,
    disk_write = 0,
}

-- Helper for IO formatting
local function fmt_io(kb)
    if kb >= 1024 then return string.format("%.1f MB/s", kb / 1024)
    else               return string.format("%.0f KB/s", kb) end
end

-- Sub-widgets for popup text updates
local cpu_header_val  = wibox.widget.textbox()
local mem_header_val  = wibox.widget.textbox()
local temp_header_val = wibox.widget.textbox()
local disk_header_val = wibox.widget.textbox()

-- Visual Components (Graphs/Bars)
local function create_graph(color, height, max_val, scale)
    local dpi = require("beautiful.xresources").apply_dpi
    return wibox.widget {
        max_value = max_val or 100,
        scale = (scale == nil) and true or scale,
        background_color = "#333333",
        border_width = 1,
        border_color = "#444444",
        color = color,
        width = dpi(220),
        height = height or dpi(40),
        step_width = dpi(2),
        step_spacing = 1,
        widget = wibox.widget.graph
    }
end

local function create_bar(color)
    local dpi = require("beautiful.xresources").apply_dpi
    return wibox.widget {
        max_value        = 100,
        value            = 0,
        forced_height    = dpi(12),
        forced_width     = dpi(220),
        shape            = gears.shape.rounded_rect,
        paddings         = 1,
        border_width     = 1,
        color            = color,
        background_color = "#333333",
        border_color     = "#444444",
        widget           = wibox.widget.progressbar,
    }
end

local cpu_bar = nil
local cpu_graph = nil
local mem_bar = nil
local mem_graph = nil
local temp_bar = nil
local temp_graph = nil
local disk_read_graph = nil
local disk_write_graph = nil

local function ensure_visuals()
    local dpi = require("beautiful.xresources").apply_dpi
    if not cpu_bar then cpu_bar = create_bar("#32D6FF") end
    if not cpu_graph then cpu_graph = create_graph("#32D6FF", dpi(40), 100, false) end
    if not mem_bar then mem_bar = create_bar("#a6e3a1") end
    if not mem_graph then mem_graph = create_graph("#a6e3a1", dpi(25), 100, false) end
    if not temp_bar then temp_bar = create_bar("#fab387") end
    if not temp_graph then temp_graph = create_graph("#fab387", dpi(25), 100, false) end
    if not disk_read_graph then disk_read_graph = create_graph("#f9e2af", dpi(25), 10, true) end
    if not disk_write_graph then disk_write_graph = create_graph("#f38ba8", dpi(25), 10, true) end
end

-- Data Fetching ----------------------------------------------------------
local _is_linux = io.open("/proc/version", "r") ~= nil
local _stats_last = {}
local _time_last = os.time()
local _last_cpu_active, _last_cpu_total = 0, 0

local function get_cpu(callback)
    if _is_linux then
        local f = io.open("/proc/stat", "r")
        if f then
            local line = f:read("*l")
            f:close()
            if line then
                local user, nice, system, idle, iowait, irq, softirq, steal = line:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
                if user then
                    local total = tonumber(user) + tonumber(nice) + tonumber(system) + tonumber(idle) + 
                                  tonumber(iowait) + tonumber(irq) + tonumber(softirq) + tonumber(steal)
                    local active = total - tonumber(idle)
                    callback(active, total)
                    return
                end
            end
        end
        callback(0, 0)
    else
        awful.spawn.easy_async_with_shell("sysctl -n kern.cp_time 2>/dev/null", function(stdout)
            local current_ticks = {}
            for match in stdout:gmatch("(%d+)") do
                table.insert(current_ticks, tonumber(match))
            end
            if #current_ticks < 5 then return callback(0, 0) end
            local total = 0
            for i=1, #current_ticks do total = total + current_ticks[i] end
            local idle = current_ticks[#current_ticks]
            local active = total - idle
            callback(active, total)
        end)
    end
end

-- Initialize CPU counters
get_cpu(function(a, t) _last_cpu_active, _last_cpu_total = a, t end)

local function update_data()
    pcall(function()
        local beautiful = require("beautiful")
        local font = beautiful.font or "sans 10"
        local fg = beautiful.fg_normal or "#ffffff"
        ensure_visuals()

        -- 1. CPU
        get_cpu(function(active, total)
            if _last_cpu_total > 0 then
                local d_active = active - _last_cpu_active
                local d_total = total - _last_cpu_total
                _data.cpu_usage = d_total > 0 and math.floor((d_active / d_total) * 100) or 0
                cpu_bar.value = _data.cpu_usage
                cpu_graph:add_value(_data.cpu_usage)
                cpu_header_val.text = _data.cpu_usage .. "%"
            end
            _last_cpu_active, _last_cpu_total = active, total
        end)

        -- 2. Mem
        if _is_linux then
            local f = io.open("/proc/meminfo", "r")
            if f then
                local mem_total, mem_avail
                for line in f:lines() do
                    if line:match("MemTotal") then mem_total = tonumber(line:match("%d+"))
                    elseif line:match("MemAvailable") then mem_avail = tonumber(line:match("%d+")) end
                end
                f:close()
                if mem_total and mem_avail then
                    _data.mem_total = math.floor(mem_total / 1024)
                    _data.mem_used = math.floor((mem_total - mem_avail) / 1024)
                    _data.mem_perc = math.floor((_data.mem_used / _data.mem_total) * 100)
                    mem_bar.value = _data.mem_perc
                    mem_graph:add_value(_data.mem_perc)
                    mem_header_val.text = _data.mem_used .. " / " .. _data.mem_total .. " MB"
                end
            end
        end

        -- 3. Temp
        local temp_cmd = _is_linux 
            and "cat /sys/class/hwmon/hwmon4/temp1_input 2>/dev/null || cat /sys/class/hwmon/hwmon*/temp1_input | head -1"
            or "sysctl -n hw.sensors.cpu0.temp0 2>/dev/null || sysctl -n dev.cpu.0.temperature 2>/dev/null"
        
        awful.spawn.easy_async_with_shell(temp_cmd, function(out)
            local val = tonumber(out:match("(%-?%d+%.?%d*)"))
            if val then
                _data.temp = (_is_linux and val > 1000) and math.floor(val / 1000) or math.floor(val)
                temp_bar.value = _data.temp
                temp_graph:add_value(_data.temp)
                temp_header_val.text = _data.temp .. "°C"
            end
        end)

        -- 4. Disk I/O
        if _is_linux then
            local df = io.open("/proc/diskstats", "r")
            if df then
                local stats_now = {}
                for line in df:lines() do
                    local dev, s_read, s_write = line:match("%s*%d+%s+%d+%s+(%S+)%s+%d+%s+%d+%s+(%d+)%s+%d+%s+%d+%s+%d+%s+(%d+)")
                    if dev and (s_read ~= "0" or s_write ~= "0") then
                        stats_now[dev] = { r = tonumber(s_read), w = tonumber(s_write) }
                    end
                end
                df:close()
                local time_now = os.time()
                local interval = os.difftime(time_now, _time_last)
                if interval <= 0 then interval = 1 end
                local total_r, total_w = 0, 0
                for dev, s in pairs(stats_now) do
                    local last = _stats_last[dev] or s
                    local dr = (s.r - last.r) * 0.5 / interval
                    local dw = (s.w - last.w) * 0.5 / interval
                    local is_partition = dev:match("sd[a-z]%d+$") or dev:match("nvme%dn%dp%d+$")
                    if not is_partition and (dev:match("^sd[a-z]$") or dev:match("^nvme%dn%d$")) then
                        total_r = total_r + dr
                        total_w = total_w + dw
                    end
                end
                _stats_last = stats_now
                _time_last = time_now
                _data.disk_read, _data.disk_write = total_r, total_w
                disk_read_graph:add_value(total_r)
                disk_write_graph:add_value(total_w)
                disk_header_val.text = "R: " .. fmt_io(total_r) .. " | W: " .. fmt_io(total_w)
            end
        end

        -- Update all wibar text
        for _, update_func in ipairs(sysmon._wibar_updates) do
            update_func(_data, font, fg)
        end
    end)
end

-- Popup Construction -----------------------------------------------------

local function build_popup_rows()
    local dpi = require("beautiful.xresources").apply_dpi
    ensure_visuals()

    local function section(title, val_txt, bar, graph)
        return {
            {
                { text = title, widget = wibox.widget.textbox, font = "BerkeleyMono Nerd Font Bold 11" },
                nil,
                val_txt,
                layout = wibox.layout.align.horizontal,
            },
            {
                bar,
                wibox.container.margin(graph, 0, 0, dpi(5)),
                layout = wibox.layout.fixed.vertical
            },
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(5)
        }
    end

    return wibox.widget {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(15),
        section("CPU Usage", cpu_header_val, cpu_bar, cpu_graph),
        section("Memory", mem_header_val, mem_bar, mem_graph),
        section("Temperature", temp_header_val, temp_bar, temp_graph),
        { -- Disk I/O
            {
                { text = "Disk I/O", widget = wibox.widget.textbox, font = "BerkeleyMono Nerd Font Bold 11" },
                nil,
                disk_header_val,
                layout = wibox.layout.align.horizontal,
            },
            {
                {
                    { text = "READ", widget = wibox.widget.textbox, font = "BerkeleyMono Nerd Font 8" },
                    disk_read_graph,
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(2)
                },
                {
                    { text = "WRITE", widget = wibox.widget.textbox, font = "BerkeleyMono Nerd Font 8" },
                    disk_write_graph,
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(2)
                },
                layout = wibox.layout.flex.horizontal,
                spacing = dpi(10)
            },
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(5)
        }
    }
end

local function show_popup()
    local beautiful = require("beautiful")
    local dpi = require("beautiful.xresources").apply_dpi
    local s = awful.screen.focused()
    local wb = s.mywibox
    
    if not sysmon.popup then
        sysmon.popup = awful.popup {
            widget = wibox.container.margin(build_popup_rows(), dpi(15), dpi(15), dpi(15), dpi(15)),
            bg = beautiful.bg_normal or "#111111",
            border_width = dpi(1),
            border_color = beautiful.border_focus or "#333333",
            shape = gears.shape.rounded_rect,
            ontop = true,
            visible = false,
            screen = s,
        }
    end

    local px = math.min(mouse.coords().x, s.geometry.x + s.geometry.width - dpi(260))
    local py = wb and (wb.y + wb.height + dpi(8)) or dpi(30)
    
    sysmon.popup.x = px
    sysmon.popup.y = py
    sysmon.popup.screen = s
    sysmon.popup.visible = true
end

-- Exported Factory Method ------------------------------------------------

function sysmon.create()
    local beautiful = require("beautiful")
    local dpi = require("beautiful.xresources").apply_dpi
    
    local cpu_txt  = wibox.widget.textbox(" --%")
    local mem_txt  = wibox.widget.textbox(" ----M")
    local temp_txt = wibox.widget.textbox(" --°C")

    local cpu_icon  = wibox.widget.imagebox()
    local mem_icon  = wibox.widget.imagebox()
    local temp_icon = wibox.widget.imagebox()

    -- Delayed icon loading
    gears.timer.delayed_call(function()
        cpu_icon:set_image(beautiful.widget_cpu)
        mem_icon:set_image(beautiful.widget_mem)
        temp_icon:set_image(beautiful.widget_temp)
    end)

    local inner = wibox.widget {
        cpu_icon,
        cpu_txt,
        { text = " ", widget = wibox.widget.textbox },
        mem_icon,
        mem_txt,
        { text = " ", widget = wibox.widget.textbox },
        temp_icon,
        temp_txt,
        layout = wibox.layout.fixed.horizontal,
    }

    local w = wibox.container.margin(inner, dpi(6), dpi(6))

    table.insert(sysmon._wibar_updates, function(data, font, fg)
        cpu_txt:set_markup(markup.fontfg(font, fg, string.format(" %2d%%", data.cpu_usage)))
        mem_txt:set_markup(markup.fontfg(font, fg, string.format(" %4dM", data.mem_used)))
        temp_txt:set_markup(markup.fontfg(font, fg, string.format(" %2d°C", data.temp)))
    end)

    w:connect_signal("mouse::enter", function() show_popup() end)
    w:connect_signal("mouse::leave", function()
        if sysmon.popup then sysmon.popup.visible = false end
    end)

    return w
end

-- Global Timer
gears.timer {
    timeout = 2,
    autostart = true,
    callback = update_data
}

return sysmon
