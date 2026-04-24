--[[
    Memory widget with hover popup.
    Shows RAM usage in the wibar; popup shows RAM breakdown, ZFS ARC stats
    (Linux /proc or FreeBSD sysctl), and top-10 processes by RSS.

    Usage:
        local mem = require("widgets.mem")
        -- mem.widget  : textbox (provided to lain.widget.mem settings)
        -- mem.icon    : imagebox
        -- call mem.attach(icon, widget) after creation to wire hover signals
--]]

local wibox  = require("wibox")
local awful  = require("awful")
local gears  = require("gears")
local lain   = require("lain")
local markup = require("lain.util").markup
local dpi    = require("beautiful.xresources").apply_dpi

-- ZFS and Disk Stats availability ---------------------------------------
local _zfs_arcstats = "/proc/spl/kstat/zfs/arcstats"
local _zfs_linux    = io.open(_zfs_arcstats, "r") ~= nil
local _zfs_freebsd  = (not _zfs_linux) and (function()
    local f = io.popen("sysctl -n kstat.zfs.misc.arcstats.size 2>/dev/null")
    if not f then return false end
    local v = f:read("*l"); f:close()
    return v ~= nil
end)()
local _zfs_available = _zfs_linux or _zfs_freebsd

local _proc_diskstats = "/proc/diskstats"
local _diskstats_available = io.open(_proc_diskstats, "r") ~= nil

local _zfs_keys = {
    "size", "c", "c_max",
    "hits", "misses",
    "mru_size", "mfu_size", "anon_size", "metadata_size",
    "compressed_size", "uncompressed_size",
    "l2_size", "l2_hits", "l2_misses",
}

local function fetch_zfs(callback)
    if not _zfs_available then callback(nil); return end

    local function parse(t)
        if not t.size then callback(nil); return end
        local function mb(v) return math.floor((v or 0) / 1048576) end
        local hits, misses = (t.hits or 0), (t.misses or 0)
        local total    = hits + misses
        local hitratio = total > 0 and string.format("%.1f%%", hits / total * 100) or "n/a"
        local compr    = (t.uncompressed_size or 0) > 0
            and string.format("%.2fx", t.uncompressed_size / t.compressed_size)
            or "n/a"
        local l2h, l2m = (t.l2_hits or 0), (t.l2_misses or 0)
        local l2total  = l2h + l2m
        local l2ratio  = l2total > 0 and string.format("%.1f%%", l2h / l2total * 100) or nil
        callback({
            size = mb(t.size), target = mb(t.c), max = mb(t.c_max),
            mru  = mb(t.mru_size), mfu = mb(t.mfu_size),
            anon = mb(t.anon_size), meta = mb(t.metadata_size),
            hitratio = hitratio, compr = compr,
            l2size = mb(t.l2_size or 0), l2ratio = l2ratio,
        })
    end

    if _zfs_linux then
        awful.spawn.easy_async_with_shell("cat " .. _zfs_arcstats, function(out)
            local t = {}
            for key, val in out:gmatch("(%w+)%s+%d+%s+(%d+)") do t[key] = tonumber(val) end
            parse(t)
        end)
    else
        local keys_arg = table.concat((function()
            local r = {}
            for _, k in ipairs(_zfs_keys) do
                table.insert(r, "kstat.zfs.misc.arcstats." .. k)
            end
            return r
        end)(), " ")
        awful.spawn.easy_async_with_shell("sysctl -e " .. keys_arg .. " 2>/dev/null", function(out)
            local t = {}
            for line in out:gmatch("[^\n]+") do
                local k, v = line:match("kstat%.zfs%.misc%.arcstats%.(%w+)=(%d+)")
                if k and v then t[k] = tonumber(v) end
            end
            parse(t)
        end)
    end
end

local _stats_last = {}
local _time_last = 0
local _disk_io_last = nil

local function fetch_disk_io(callback)
    if not _diskstats_available then callback(nil); return end
    
    awful.spawn.easy_async_with_shell("cat " .. _proc_diskstats, function(out)
        local stats_now = {}
        for line in out:gmatch("[^\n]+") do
            local dev, s_read, s_write = line:match("%s*%d+%s+%d+%s+(%S+)%s+%d+%s+%d+%s+(%d+)%s+%d+%s+%d+%s+%d+%s+(%d+)")
            if dev and (s_read ~= "0" or s_write ~= "0") then
                stats_now[dev] = { r = tonumber(s_read), w = tonumber(s_write) }
            end
        end

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
        callback({ read = total_r, write = total_w })
    end)
end

local function fetch_procs(callback)
    awful.spawn.easy_async_with_shell(
        "ps -axo rss,comm 2>/dev/null | sort -rn | awk 'NR<=10 {printf \"%s %s\\n\", $1, $2}'",
        function(out)
            local procs = {}
            for rss, name in out:gmatch("(%d+)%s+(%S+)") do
                table.insert(procs, { name = name, mb = math.floor(tonumber(rss) / 1024) })
            end
            callback(procs)
        end)
end

-- Widget -----------------------------------------------------------------

local mem = {
    icon   = nil,   -- set by caller after require()
    widget = nil,   -- set below via lain
}

local _now_last  = {}
local _proc_last = {}
local _zfs_last  = nil

mem.lain = lain.widget.mem({
    settings = function()
        _now_last = mem_now
        local beautiful = require("beautiful")
        local usage = string.format("%5d", mem_now.used)
        widget:set_markup(markup.font(beautiful.font, " " .. usage .. "MB "))
    end
})
mem.widget = mem.lain.widget

local function build_popup_widget()
    local beautiful = require("beautiful")
    local m = _now_last
    if not m or not m.total then return nil end

    local function row(label, value, label_w)
        return wibox.widget {
            { markup = markup.fontfg(beautiful.font, beautiful.fg_normal .. "99", label),
              widget = wibox.widget.textbox, forced_width = label_w or dpi(120) },
            { markup = markup.fontfg(beautiful.font, beautiful.fg_normal, value),
              widget = wibox.widget.textbox },
            layout = wibox.layout.fixed.horizontal,
        }
    end
    local function section(label)
        return wibox.widget {
            markup = markup.fontfg(beautiful.font, beautiful.fg_normal .. "88", label),
            widget = wibox.widget.textbox,
        }
    end
    local function separator()
        return wibox.widget {
            markup = markup.fontfg(beautiful.font, beautiful.fg_normal .. "44",
                "─────────────────────────────"),
            widget = wibox.widget.textbox,
        }
    end

    local layout = wibox.widget {
        row("RAM used",  string.format("%d MB / %d MB (%d%%)", m.used, m.total, m.perc)),
        row("Cache",     string.format("%d MB", m.cache)),
        row("Buffers",   string.format("%d MB", m.buf)),
        row("Swap used", string.format("%d MB / %d MB", m.swapused, m.swap)),
        layout = wibox.layout.fixed.vertical, spacing = dpi(4),
    }
    local outer = wibox.widget { layout, layout = wibox.layout.fixed.vertical, spacing = dpi(6) }

    -- Disk I/O section
    if _diskstats_available then
        outer:add(separator())
        if _disk_io_last then
            local function fmt(kb)
                if kb >= 1024 then return string.format("%.1f MB/s", kb / 1024)
                else               return string.format("%.1f KB/s", kb) end
            end
            local d = _disk_io_last
            local drows = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = dpi(4) }
            drows:add(section("💽  Disk I/O"))
            drows:add(row("Read",  fmt(d.read)))
            drows:add(row("Write", fmt(d.write)))
            outer:add(drows)
        end
    end

    -- ZFS section
    if _zfs_available then
        outer:add(separator())
        if _zfs_last then
            local z = _zfs_last
            local zrows = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = dpi(4) }
            zrows:add(section("🗄  ZFS ARC"))
            zrows:add(row("ARC size",    string.format("%d MB  (target %d MB, max %d MB)", z.size, z.target, z.max)))
            zrows:add(row("  MRU",       string.format("%d MB", z.mru)))
            zrows:add(row("  MFU",       string.format("%d MB", z.mfu)))
            zrows:add(row("  anon",      string.format("%d MB", z.anon)))
            zrows:add(row("  metadata",  string.format("%d MB", z.meta)))
            zrows:add(row("Hit ratio",   z.hitratio))
            zrows:add(row("Compression", z.compr))
            if z.l2size > 0 then zrows:add(row("L2ARC", string.format("%d MB", z.l2size))) end
            outer:add(zrows)
        else
            outer:add(wibox.widget {
                markup = markup.fontfg(beautiful.font, beautiful.fg_normal .. "66", "loading…"),
                widget = wibox.widget.textbox,
            })
        end
    end

    -- Process list section
    outer:add(separator())
    local prows = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = dpi(2) }
    prows:add(section("📋  top processes"))
    if #_proc_last > 0 then
        for _, p in ipairs(_proc_last) do
            prows:add(row(p.name, string.format("%d MB", p.mb), dpi(180)))
        end
    else
        prows:add(wibox.widget {
            markup = markup.fontfg(beautiful.font, beautiful.fg_normal .. "66", "loading…"),
            widget = wibox.widget.textbox,
        })
    end
    outer:add(prows)

    return wibox.container.margin(outer, dpi(10), dpi(10), dpi(8), dpi(8))
end

-- Popup ------------------------------------------------------------------

local _popup       = nil
local _popup_timer = nil

local function refresh()
    local pending = 3
    local function done()
        pending = pending - 1
        if pending == 0 then
            local nw = build_popup_widget()
            if nw and _popup then _popup.widget = nw end
        end
    end
    fetch_procs(function(p) _proc_last = p; done() end)
    fetch_zfs(function(z)   _zfs_last  = z; done() end)
    fetch_disk_io(function(d) _disk_io_last = d; done() end)
end

function mem.popup_show()
    if _popup then return end
    local w = build_popup_widget()
    if not w then return end
    local beautiful = require("beautiful")
    local s  = awful.screen.focused()
    local wb = s.mywibox
    local px = math.min(mouse.coords().x, s.geometry.x + s.geometry.width - dpi(320))
    local py = wb and (wb.y + wb.height + dpi(8)) or dpi(30)
    _popup = awful.popup {
        widget = w, x = px, y = py,
        bg = beautiful.bg_normal, border_width = dpi(1), border_color = beautiful.border_focus,
        ontop = true, visible = true, screen = s,
    }
    refresh()
    _popup_timer = gears.timer { timeout = 2, autostart = true, callback = refresh }
end

function mem.popup_hide()
    if _popup_timer then _popup_timer:stop(); _popup_timer = nil end
    if _popup then _popup.visible = false; _popup = nil end
    _proc_last = {}
    _zfs_last  = nil
end

-- Wire hover signals to icon + widget
function mem.attach(icon, widget_tb)
    icon:connect_signal("mouse::enter", mem.popup_show)
    icon:connect_signal("mouse::leave", mem.popup_hide)
    widget_tb:connect_signal("mouse::enter", mem.popup_show)
    widget_tb:connect_signal("mouse::leave", mem.popup_hide)
end

return mem
