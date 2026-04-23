local wibox     = require("wibox")
local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")
local markup    = require("lain.util").markup
local dpi       = require("beautiful.xresources").apply_dpi

-- ---------------------------------------------------------------------------
-- Distro detection
-- Read /etc/os-release once at load time to pick the right update commands.
-- Supported families:
--   arch   – checkupdates (pacman-contrib) + yay/paru for AUR
--   debian – apt list --upgradable (Ubuntu, Linux Mint, Debian, Pop!_OS, …)
-- ---------------------------------------------------------------------------
local function detect_distro()
    local f = io.open("/etc/os-release", "r")
    if not f then return "unknown" end
    local content = f:read("*a")
    f:close()
    -- Check ID and ID_LIKE fields
    local id      = (content:match('\nID="?([^"\n]+)"?')      or ""):lower()
    local id_like = (content:match('\nID_LIKE="?([^"\n]+)"?') or ""):lower()
    local combined = id .. " " .. id_like
    if combined:find("arch") or combined:find("cachyos") or
       combined:find("endeavour") or combined:find("garuda") or
       combined:find("artix") or combined:find("manjaro") then
        return "arch"
    elseif combined:find("debian") or combined:find("ubuntu") or
           combined:find("mint") or combined:find("pop") or
           combined:find("elementary") or combined:find("linuxmint") then
        return "debian"
    end
    return "unknown"
end

local DISTRO = detect_distro()

local pacman = {
    repo_pkgs  = {},
    aur_pkgs   = {},
    ---@type gears.timer|nil
    timer      = nil,
    _widget    = nil,  -- stored for hook refresh
    distro     = DISTRO,
}

local GLYPH = "󰏖"

-- Per-distro commands.
-- Arch: checkupdates + yay/paru for AUR — output is "name old -> new" per line.
-- Debian/Ubuntu/Mint: LANG=C apt-get -s upgrade — output includes "Inst pkgname
--   [oldver] (newver ...)" lines for each package that would actually be upgraded.
--   This correctly excludes phased updates and held packages (unlike `apt list
--   --upgradable` which shows everything in the cache regardless).
local CMD_REPO, CMD_AUR
if DISTRO == "arch" then
    CMD_REPO = "checkupdates 2>/dev/null"
    CMD_AUR  = "yay -Qua 2>/dev/null"
elseif DISTRO == "debian" then
    -- Simulate upgrade without root or network. LANG=C ensures English output
    -- for reliable parsing regardless of the user's locale.
    CMD_REPO = "LANG=C apt-get -s upgrade 2>/dev/null"
    CMD_AUR  = ""  -- no AUR equivalent on Debian/Ubuntu
else
    CMD_REPO = ""
    CMD_AUR  = ""
end

-- Popup state
local popup_obj = nil

local function popup_hide()
    if popup_obj then popup_obj.visible = false; popup_obj = nil end
end

local function popup_show(anchor_widget)
    if popup_obj then return end
    local repo = pacman.repo_pkgs
    local aur  = pacman.aur_pkgs
    if #repo == 0 and #aur == 0 then return end

    local rows = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = dpi(2) }

    local function section_header(text)
        rows:add(wibox.widget {
            markup = markup.fontfg(beautiful.font, beautiful.fg_focus, "<b>" .. text .. "</b>"),
            widget = wibox.widget.textbox,
        })
    end

    local function pkg_row(line)
        -- line format: "pkgname oldver -> newver"
        local name, oldver, newver = line:match("^(%S+)%s+(%S+)%s+%->%s+(%S+)")
        if name then
            rows:add(wibox.widget {
                {
                    markup = markup.fontfg(beautiful.font, beautiful.fg_normal, name),
                    widget = wibox.widget.textbox,
                    forced_width = dpi(180),
                },
                {
                    markup = markup.fontfg(beautiful.font, beautiful.fg_normal .. "88", oldver .. " → "),
                    widget = wibox.widget.textbox,
                    forced_width = dpi(140),
                },
                {
                    markup = markup.fontfg(beautiful.font, beautiful.fg_normal, newver),
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.fixed.horizontal,
            })
        else
            rows:add(wibox.widget {
                markup = markup.fontfg(beautiful.font, beautiful.fg_normal, line),
                widget = wibox.widget.textbox,
            })
        end
    end

    if #repo > 0 then
        section_header(string.format("Repo  (%d)", #repo))
        for _, p in ipairs(repo) do pkg_row(p) end
    end
    if #aur > 0 then
        if #repo > 0 then
            rows:add(wibox.widget {  -- spacer
                markup = " ", widget = wibox.widget.textbox,
            })
        end
        section_header(string.format("AUR/PPA  (%d)", #aur))
        for _, p in ipairs(aur) do pkg_row(p) end
    end

    local s  = awful.screen.focused()
    local wb = s.mywibox
    local mouse_x = mouse.coords().x
    local py = wb and (wb.y + wb.height + dpi(8)) or dpi(30)
    local popup_w = dpi(440)
    local px = math.min(mouse_x, s.geometry.x + s.geometry.width - popup_w - dpi(8))

    popup_obj = awful.popup {
        widget       = wibox.container.margin(rows, dpi(10), dpi(10), dpi(8), dpi(8)),
        x            = px,
        y            = py,
        bg           = beautiful.bg_normal,
        border_width = dpi(1),
        border_color = beautiful.border_focus,
        ontop        = true,
        visible      = true,
        screen       = s,
    }
end

-- Parse a single "Inst" line from `apt-get -s upgrade` output.
-- Format examples:
--   Inst bash [5.1-6ubuntu1] (5.1-6ubuntu1.1 Ubuntu:22.04 [amd64])
--   Inst linux-headers-generic (5.15.0.94.91 Ubuntu:22.04 [amd64])
-- Returns a "name old -> new" string, or nil if the line isn't an Inst line.
local function parse_apt_inst_line(line)
    local name = line:match("^Inst (%S+)")
    if not name then return nil end
    local oldver = line:match("%[([^%]]+)%]")          -- bracketed = current ver
    local newver = line:match("%((%S+)")               -- first token inside parens
    if newver then
        if oldver then
            return name .. " " .. oldver .. " -> " .. newver
        else
            return name .. " (new) -> " .. newver
        end
    end
    return name  -- fallback: just the name
end

local function update_widget(widget)
    -- On unknown/unsupported distros do nothing
    if CMD_REPO == "" then return end

    -- Run both commands, collect results, then update
    awful.spawn.easy_async_with_shell(CMD_REPO, function(repo_out)
        local finish = function(aur_out)
            local repo_pkgs, aur_pkgs = {}, {}
            for line in repo_out:gmatch("[^\n]+") do
                if line ~= "" then
                    if DISTRO == "debian" then
                        local parsed = parse_apt_inst_line(line)
                        if parsed then repo_pkgs[#repo_pkgs + 1] = parsed end
                    else
                        repo_pkgs[#repo_pkgs + 1] = line
                    end
                end
            end
            if aur_out then
                for line in aur_out:gmatch("[^\n]+") do
                    if line ~= "" then aur_pkgs[#aur_pkgs + 1] = line end
                end
            end
            pacman.repo_pkgs = repo_pkgs
            pacman.aur_pkgs  = aur_pkgs

            -- Display: "N" if no AUR, "N+M" if both
            local label
            if #aur_pkgs > 0 then
                label = string.format("%d+%d", #repo_pkgs, #aur_pkgs)
            else
                label = tostring(#repo_pkgs)
            end
            widget:set_markup(markup.fontfg(beautiful.font, beautiful.fg_normal,
                " " .. GLYPH .. " " .. label .. " "))
        end

        if CMD_AUR ~= "" then
            awful.spawn.easy_async_with_shell(CMD_AUR, function(aur_out)
                finish(aur_out)
            end)
        else
            finish(nil)
        end
    end)
end

function pacman.create()
    local widget = wibox.widget {
        markup = markup.fontfg(beautiful.font, beautiful.fg_normal, " " .. GLYPH .. " … "),
        widget = wibox.widget.textbox,
    }
    pacman._widget = widget

    widget:connect_signal("mouse::enter", function() popup_show(widget) end)
    widget:connect_signal("mouse::leave", popup_hide)

    -- Initial update + periodic timer
    update_widget(widget)
    local t = gears.timer {
        timeout   = 300,
        autostart = true,
        callback  = function() update_widget(widget) end,
    }
    pacman.timer = t

    return widget
end

function pacman.hook()
    -- Called by pacman hook after package operations
    if pacman._widget then
        update_widget(pacman._widget)
    end
end

return pacman
