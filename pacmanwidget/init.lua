local wibox     = require("wibox")
local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")
local markup    = require("lain.util").markup
local dpi       = require("beautiful.xresources").apply_dpi

local pacman = {
    repo_pkgs  = {},
    aur_pkgs   = {},
    ---@type gears.timer|nil
    timer      = nil,
    _widget    = nil,  -- stored for hook refresh
}

local GLYPH        = "󰏖"
local CMD_REPO     = "checkupdates 2>/dev/null"
local CMD_AUR      = "yay -Qua 2>/dev/null"

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
        section_header(string.format("AUR  (%d)", #aur))
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

local function update_widget(widget)
    -- Run both commands, collect results, then update
    awful.spawn.easy_async_with_shell(CMD_REPO, function(repo_out)
        awful.spawn.easy_async_with_shell(CMD_AUR, function(aur_out)
            local repo_pkgs, aur_pkgs = {}, {}
            for line in repo_out:gmatch("[^\n]+") do
                if line ~= "" then repo_pkgs[#repo_pkgs + 1] = line end
            end
            for line in aur_out:gmatch("[^\n]+") do
                if line ~= "" then aur_pkgs[#aur_pkgs + 1] = line end
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
        end)
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
