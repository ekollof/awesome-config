--[[
    Consolidated System Monitor Widget
    Combines CPU, Memory, Temp, and Disk I/O into one widget/popup.
    Features:
    - Compact wibar display
    - Rich popup with graphs and progress bars
--]]

local wibox     = require("wibox")
local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")
local markup    = require("lain.util").markup
local dpi       = require("beautiful.xresources").apply_dpi

local sysmon = {
    widget = nil,
    popup  = nil,
}

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

-- Graphs/History
local cpu_graph = wibox.widget {
    max_value = 100,
    background_color = "#00000000",
    color = beautiful.fg_focus or "#32D6FF",
    width = dpi(200),
    height = dpi(40),
    step_width = dpi(2),
    step_spacing = 1,
    widget = wibox.widget.graph
}

local disk_read_graph = wibox.widget {
    max_value = 1024,
    background_color = "#00000000",
    color = "#a6e3a1",
    width = dpi(100),
    height = dpi(25),
    widget = wibox.widget.graph
}

local disk_write_graph = wibox.widget {
    max_value = 1024,
    background_color = "#00000000",
    color = "#f38ba8",
    width = dpi(100),
    height = dpi(25),
    widget = wibox.widget.graph
}

-- Progress Bars
local mem_bar = wibox.widget {
    max_value        = 100,
    value            = 0,
    forced_height    = dpi(12),
    forced_width     = dpi(200),
    shape            = gears.shape.rounded_rect,
    paddings         = 1,
    border_width     = 1,
    color            = beautiful.fg_focus or "#32D6FF",
    background_color = (beautiful.fg_normal or "#ffffff") .. "22",
    border_color     = beautiful.border_normal or "#333333",
    widget           = wibox.widget.progressbar,
}

local temp_bar = wibox.widget {
    max_value        = 100,
    value            = 0,
    forced_height    = dpi(12),
    forced_width     = dpi(200),
    shape            = gears.shape.rounded_rect,
    paddings         = 1,
    border_width     = 1,
    color            = "#fab387",
    background_color = (beautiful.fg_normal or "#ffffff") .. "22",
    border_color     = beautiful.border_normal or "#333333",
    widget           = wibox.widget.progressbar,
}

-- Sub-widgets for wibar
local cpu_txt  = wibox.widget.textbox()
local mem_txt  = wibox.widget.textbox()
local temp_txt = wibox.widget.textbox()

sysmon.widget = wibox.widget {
    {
        wibox.widget.imagebox(beautiful.widget_cpu),
        cpu_txt,
        { text = " ", widget = wibox.widget.textbox },
        wibox.widget.imagebox(beautiful.widget_mem),
        mem_txt,
        { text = " ", widget = wibox.widget.textbox },
        wibox.widget.imagebox(beautiful.widget_temp),
        temp_txt,
        layout = wibox.layout.fixed.horizontal,
    },
    margins = { left = dpi(6), right = dpi(6) },
    widget = wibox.container.margin
}

local _is_linux = io.open("/proc/version", "r") ~= nil

-- Data Fetching Helpers --------------------------------------------------

local _stats_last = {}
local _time_last = 0
local _prev_ticks = nil

local function get_disk_io()
    if not _is_linux then return 0, 0 end
    local df = io.open("/proc/diskstats", "r")
    if not df then return 0, 0 end
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
        if not dev:match("%d$") then
            total_r = total_r + dr
            total_w = total_w + dw
        end
    end
    _stats_last = stats_now
    _time_last = time_now
    return total_r, total_w
end

local function get_cpu(callback)
    if _is_linux then
        local f = io.open("/proc/stat", "r")
        if not f then return callback(0, 0) end
        local line = f:read("*l")
        f:close()
        local user, nice, system, idle, iowait, irq, softirq, steal = line:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
        local total = user + nice + system + idle + iowait + irq + softirq + steal
        local active = total - idle
        callback(active, total)
    else
        -- BSDs
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

local _last_cpu_active, _last_cpu_total = 0, 0
get_cpu(function(a, t) _last_cpu_active, _last_cpu_total = a, t end)

local function get_mem(callback)
    if _is_linux then
        local f = io.open("/proc/meminfo", "r")
        if not f then return callback(0, 0, 0) end
        local mem_total, mem_avail
        for line in f:lines() do
            if line:match("MemTotal") then mem_total = tonumber(line:match("%d+"))
            elseif line:match("MemAvailable") then mem_avail = tonumber(line:match("%d+")) end
        end
        f:close()
        if mem_total and mem_avail then
            local total = math.floor(mem_total / 1024)
            local used = math.floor((mem_total - mem_avail) / 1024)
            local perc = math.floor((used / total) * 100)
            callback(used, total, perc)
        end
    else
        -- BSD (FreeBSD example)
        awful.spawn.easy_async_with_shell("sysctl -n hw.physmem vm.stats.vm.v_free_count hw.pagesize", function(stdout)
            local total_bytes, free_pages, page_size = stdout:match("(%d+)%s+(%d+)%s+(%d+)")
            if total_bytes and free_pages and page_size then
                local total = math.floor(tonumber(total_bytes) / 1048576)
                local free = math.floor((tonumber(free_pages) * tonumber(page_size)) / 1048576)
                local used = total - free
                local perc = math.floor((used / total) * 100)
                callback(used, total, perc)
            else
                callback(0, 0, 0)
            end
        end)
    end
end

local function update_data()
    -- CPU
    get_cpu(function(active, total)
        local d_active = active - _last_cpu_active
        local d_total = total - _last_cpu_total
        _last_cpu_active, _last_cpu_total = active, total
        _data.cpu_usage = d_total > 0 and math.floor((d_active / d_total) * 100) or 0
        cpu_graph:add_value(_data.cpu_usage)
        cpu_txt:set_markup(markup.font(beautiful.font, string.format(" %2d%%", _data.cpu_usage)))
    end)

    -- Mem
    get_mem(function(used, total, perc)
        _data.mem_used, _data.mem_total, _data.mem_perc = used, total, perc
        mem_bar.value = perc
        mem_txt:set_markup(markup.font(beautiful.font, string.format(" %4dM", used)))
    end)

    -- Temp
    local temp_cmd = _is_linux 
        and "cat /sys/class/hwmon/hwmon4/temp1_input 2>/dev/null || cat /sys/class/hwmon/hwmon*/temp1_input | head -1"
        or "sysctl -n hw.sensors.cpu0.temp0 2>/dev/null || sysctl -n dev.cpu.0.temperature 2>/dev/null"
    
    awful.spawn.easy_async_with_shell(temp_cmd, function(out)
        local val = tonumber(out:match("(%-?%d+%.?%d*)"))
        if val then
            -- Linux reports millidegrees, BSD reports degrees (usually)
            _data.temp = (_is_linux and val > 1000) and math.floor(val / 1000) or math.floor(val)
            temp_bar.value = _data.temp
            temp_txt:set_markup(markup.font(beautiful.font, string.format(" %2d°C", _data.temp)))
        end
    end)

    -- Disk I/O (Linux only)
    if _is_linux then
        local r, w = get_disk_io()
        _data.disk_read, _data.disk_write = r, w
        disk_read_graph:add_value(r)
        disk_write_graph:add_value(w)
    end
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
        if not dev:match("%d$") then
            total_r = total_r + dr
            total_w = total_w + dw
        end
    end
    _stats_last = stats_now
    _time_last = time_now
    return total_r, total_w
end

local function get_cpu()
    local f = io.open("/proc/stat", "r")
    if not f then return 0, 0 end
    local line = f:read("*l")
    f:close()
    local user, nice, system, idle, iowait, irq, softirq, steal = line:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
    local total = user + nice + system + idle + iowait + irq + softirq + steal
    local active = total - idle
    return active, total
end

local _last_cpu_active, _last_cpu_total = get_cpu()

local function update_data()
    -- CPU
    local active, total = get_cpu()
    local d_active = active - _last_cpu_active
    local d_total = total - _last_cpu_total
    _last_cpu_active, _last_cpu_total = active, total
    _data.cpu_usage = d_total > 0 and math.floor((d_active / d_total) * 100) or 0
    cpu_graph:add_value(_data.cpu_usage)
    cpu_txt:set_markup(markup.font(beautiful.font, string.format("%2d%%", _data.cpu_usage)))

    -- Mem
    local f = io.open("/proc/meminfo", "r")
    if f then
        local mem_total, mem_free, mem_avail
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
            mem_txt:set_markup(markup.font(beautiful.font, string.format("%4dM", _data.mem_used)))
        end
    end

    -- Temp
    awful.spawn.easy_async_with_shell("cat /sys/class/hwmon/hwmon4/temp1_input 2>/dev/null || cat /sys/class/hwmon/hwmon*/temp1_input | head -1", function(out)
        local val = tonumber(out)
        if val then
            _data.temp = math.floor(val / 1000)
            temp_bar.value = _data.temp
            temp_txt:set_markup(markup.font(beautiful.font, string.format("%2d°C", _data.temp)))
        end
    end)

    -- Disk I/O
    local r, w = get_disk_io()
    _data.disk_read, _data.disk_write = r, w
    disk_read_graph:add_value(r)
    disk_write_graph:add_value(w)
end

-- Popup Construction -----------------------------------------------------

local function create_popup()
    local s = awful.screen.focused()
    local wb = s.mywibox
    
    local function header(text, val)
        return wibox.widget {
            { text = text, widget = wibox.widget.textbox, font = "BerkeleyMono Nerd Font Bold 11" },
            nil,
            { text = val, widget = wibox.widget.textbox, font = "BerkeleyMono Nerd Font 10" },
            layout = wibox.layout.align.horizontal,
        }
    end

    local function fmt_io(kb)
        if kb >= 1024 then return string.format("%.1f MB/s", kb / 1024)
        else               return string.format("%.0f KB/s", kb) end
    end

    -- Sub-widgets for popup updates
    local cpu_header_val  = wibox.widget.textbox()
    local mem_header_val  = wibox.widget.textbox()
    local temp_header_val = wibox.widget.textbox()
    local disk_header_val = wibox.widget.textbox()

    local rows = wibox.widget {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(12),
        { -- CPU
            {
                { text = "CPU Usage", widget = wibox.widget.textbox, font = "BerkeleyMono Nerd Font Bold 11" },
                nil,
                cpu_header_val,
                layout = wibox.layout.align.horizontal,
            },
            { cpu_graph, margins = { top = dpi(5) }, widget = wibox.container.margin },
            layout = wibox.layout.fixed.vertical
        },
        { -- Memory
            {
                { text = "Memory", widget = wibox.widget.textbox, font = "BerkeleyMono Nerd Font Bold 11" },
                nil,
                mem_header_val,
                layout = wibox.layout.align.horizontal,
            },
            { mem_bar, margins = { top = dpi(5) }, widget = wibox.container.margin },
            layout = wibox.layout.fixed.vertical
        },
        { -- Temp
            {
                { text = "Temperature", widget = wibox.widget.textbox, font = "BerkeleyMono Nerd Font Bold 11" },
                nil,
                temp_header_val,
                layout = wibox.layout.align.horizontal,
            },
            { temp_bar, margins = { top = dpi(5) }, widget = wibox.container.margin },
            layout = wibox.layout.fixed.vertical
        },
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
            layout = wibox.layout.fixed.vertical
        }
    }

    local px = math.min(mouse.coords().x, s.geometry.x + s.geometry.width - dpi(240))
    local py = wb and (wb.y + wb.height + dpi(8)) or dpi(30)

    sysmon.popup = awful.popup {
        widget = wibox.container.margin(rows, dpi(15), dpi(15), dpi(15), dpi(15)),
        x = px, y = py,
        bg = beautiful.bg_normal,
        border_width = dpi(1),
        border_color = beautiful.border_focus,
        shape = gears.shape.rounded_rect,
        ontop = true,
        visible = false,
        screen = s,
    }

    -- Auto-refresh popup values while visible
    local p_timer = gears.timer {
        timeout = 2,
        autostart = true,
        callback = function()
            if sysmon.popup and sysmon.popup.visible then
                cpu_header_val.text  = _data.cpu_usage .. "%"
                mem_header_val.text  = _data.mem_used .. " / " .. _data.mem_total .. " MB"
                temp_header_val.text = _data.temp .. "°C"
                disk_header_val.text = "R: " .. fmt_io(_data.disk_read) .. " | W: " .. fmt_io(_data.disk_write)
            end
        end
    }
end

function sysmon.toggle_popup()
    if sysmon.popup and sysmon.popup.visible then
        sysmon.popup.visible = false
    else
        create_popup()
    end
end

-- Timer
gears.timer {
    timeout = 2,
    autostart = true,
    call_now = true,
    callback = update_data
}

-- Attach signals
sysmon.widget:connect_signal("mouse::enter", function()
    if not sysmon.popup then create_popup() end
    sysmon.popup.visible = true
end)
sysmon.widget:connect_signal("mouse::leave", function()
    if sysmon.popup then sysmon.popup.visible = false end
end)

return sysmon
