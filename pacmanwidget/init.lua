local wibox   = require("wibox")
local awful   = require("awful")
local beautiful = require("beautiful")
local markup  = require("lain.util").markup

local pacman = {
    tooltip_text = "Checking for updates...",
    ---@type gears.timer|nil
    timer        = nil,
}

local CMD  = "bash -c 'checkupdates 2>/dev/null; yay -Qua 2>/dev/null'"
local GLYPH = "󰏖"

function pacman.create()
    local widget = wibox.widget {
        markup = markup.fontfg(beautiful.font, beautiful.fg_normal, " " .. GLYPH .. " 0 "),
        widget = wibox.widget.textbox,
    }

    awful.tooltip({
        objects        = { widget },
        timer_function = function() return pacman.tooltip_text end,
    })

    local _, t = awful.widget.watch(CMD, 300, function(_, stdout)
        local repo_pkgs, aur_pkgs = {}, {}

        for line in stdout:gmatch("[^\n]+") do
            if line:match("%(AUR%)") then
                aur_pkgs[#aur_pkgs + 1] = line:gsub("%s*%(AUR%)%s*$", "")
            elseif line ~= "" then
                repo_pkgs[#repo_pkgs + 1] = line
            end
        end

        local total = #repo_pkgs + #aur_pkgs

        widget:set_markup(markup.fontfg(beautiful.font, beautiful.fg_normal,
            " " .. GLYPH .. " " .. total .. " "))

        local lines = { string.format("Repo: %d  AUR: %d", #repo_pkgs, #aur_pkgs) }
        if #repo_pkgs > 0 then
            lines[#lines + 1] = "\n<b>Repo</b>"
            for _, p in ipairs(repo_pkgs) do lines[#lines + 1] = p end
        end
        if #aur_pkgs > 0 then
            lines[#lines + 1] = "\n<b>AUR</b>"
            for _, p in ipairs(aur_pkgs) do lines[#lines + 1] = p end
        end
        pacman.tooltip_text = table.concat(lines, "\n")
    end)

    pacman.timer = t
    return widget
end

function pacman.hook()
    if pacman.timer then
        pacman.timer:emit_signal("timeout")
    end
end

return pacman
