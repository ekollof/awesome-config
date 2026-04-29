--[[
    Notification history widget.

    Captures all naughty notifications into an in-memory ring buffer (last 100).
    Provides:
      - A wibar bell indicator with unread count badge.
      - A searchable popup (Super+Shift+i) listing past notifications.

    Case-insensitive search filters on both title and text.
    Shows the last 15 notifications by default; search narrows the list.
--]]

local awful        = require("awful")
local wibox        = require("wibox")
local gears        = require("gears")
local naughty      = require("naughty")
local beautiful    = require("beautiful")
local dpi          = require("beautiful.xresources").apply_dpi

-- ---------------------------------------------------------------------------
-- History storage
-- ---------------------------------------------------------------------------
local MAX_HISTORY     = 100
local VISIBLE_ROWS    = 15
local history         = {}
local unread_count    = 0
local popup_visible   = false
local filtered_start  = 1
local filter_text     = ""
local popup_obj       = nil
local rows_container  = nil
local indicator_widget = nil
local keygrabber      = nil

-- ---------------------------------------------------------------------------
-- Capture notifications (monkey-patch naughty.notify)
-- ---------------------------------------------------------------------------
local _naughty_notify = naughty.notify
naughty.notify = function(args)
    table.insert(history, 1, {
        title     = args.title or "Notification",
        text      = args.text or "",
        timestamp = os.time(),
    })
    if #history > MAX_HISTORY then table.remove(history) end
    unread_count = unread_count + 1
    update_indicator()
    return _naughty_notify(args)
end

-- ---------------------------------------------------------------------------
-- Helper: update wibar indicator
-- ---------------------------------------------------------------------------
function update_indicator()
    if not indicator_widget then return end
    local icon = "󰂚"
    if unread_count > 0 then
        indicator_widget:set_markup(
            string.format("<span foreground='%s'>%s</span> <span foreground='%s' font='%s'>%d</span>",
                beautiful.fg_normal or "#ffffff",
                icon,
                beautiful.bg_urgent or "#ff0000",
                beautiful.font or "sans 8",
                unread_count
            )
        )
    else
        indicator_widget:set_markup(
            string.format("<span foreground='%s'>%s</span>",
                beautiful.fg_normal or "#ffffff",
                icon
            )
        )
    end
end

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
local function format_time(ts)
    return os.date("%H:%M", ts)
end

local function escape_markup(s)
    if not s then return "" end
    return s:gsub("&", "&amp;")
             :gsub("<", "&lt;")
             :gsub(">", "&gt;")
end

local function truncate(s, len)
    if not s then return "" end
    s = s:gsub("%s+", " ")
    if #s > len then
        return s:sub(1, len - 3) .. "..."
    end
    return s
end

local function matches_filter(entry, query)
    if not query or query == "" then return true end
    query = query:lower()
    local title_match = (entry.title or ""):lower():find(query, 1, true)
    local text_match  = (entry.text or ""):lower():find(query, 1, true)
    return title_match ~= nil or text_match ~= nil
end

local function get_filtered_history()
    if not filter_text or filter_text == "" then
        return history
    end
    local result = {}
    for _, entry in ipairs(history) do
        if matches_filter(entry, filter_text) then
            table.insert(result, entry)
        end
    end
    return result
end

-- ---------------------------------------------------------------------------
-- Build popup rows
-- ---------------------------------------------------------------------------
local function build_rows()
    if not rows_container then return end
    rows_container:reset()

    -- Filter header
    if filter_text and filter_text ~= "" then
        rows_container:add(wibox.widget {
            {
                {
                    markup = string.format(
                        "<span foreground='%s' font='%s'>Filter: %s</span>",
                        beautiful.fg_urgent or "#aaaaaa",
                        beautiful.font or "sans 9",
                        escape_markup(filter_text)
                    ),
                    widget = wibox.widget.textbox,
                },
                left   = dpi(8),
                right  = dpi(8),
                top    = dpi(4),
                bottom = dpi(2),
                widget = wibox.container.margin,
            },
            bg     = beautiful.bg_focus or "#222222",
            widget = wibox.container.background,
        })
    end

    local filtered = get_filtered_history()
    local total = #filtered
    if total == 0 then
        rows_container:add(wibox.widget {
            markup = "<span foreground='" .. (beautiful.fg_normal or "#ffffff") .. "'>No notifications</span>",
            align  = "center",
            valign = "center",
            widget = wibox.widget.textbox,
        })
        return
    end

    -- Clamp start index
    if filtered_start > total then filtered_start = total end
    if filtered_start < 1 then filtered_start = 1 end

    for i = filtered_start, math.min(filtered_start + VISIBLE_ROWS - 1, total) do
        local entry = filtered[i]
        local time_str = format_time(entry.timestamp)
        local title_str = escape_markup(truncate(entry.title, 40))
        local text_str  = escape_markup(truncate(entry.text, 60))

        local row = wibox.widget {
            {
                {
                    markup = string.format(
                        "<span foreground='%s' font='%s'>%s</span>  <b>%s</b>  %s",
                        beautiful.fg_urgent or "#aaaaaa",
                        beautiful.font or "sans 8",
                        time_str,
                        title_str,
                        text_str
                    ),
                    widget = wibox.widget.textbox,
                },
                left   = dpi(8),
                right  = dpi(8),
                top    = dpi(4),
                bottom = dpi(4),
                widget = wibox.container.margin,
            },
            bg     = (i % 2 == 0) and (beautiful.bg_normal or "#000000")
                                  or  (beautiful.bg_focus  or "#111111"),
            widget = wibox.container.background,
        }

        rows_container:add(row)
    end
end

-- ---------------------------------------------------------------------------
-- Create / rebuild popup
-- ---------------------------------------------------------------------------
local function ensure_popup()
    if popup_obj and popup_obj.valid then return end

    rows_container = wibox.layout.fixed.vertical()

    popup_obj = awful.popup {
        widget = wibox.widget {
            {
                rows_container,
                forced_width  = dpi(600),
                forced_height = dpi(400),
                widget = wibox.container.constraint,
            },
            layout = wibox.layout.fixed.vertical,
        },
        bg           = beautiful.bg_normal or "#000000",
        border_width = dpi(1),
        border_color = beautiful.border_focus or "#333333",
        shape        = gears.shape.rounded_rect,
        ontop        = true,
        visible      = false,
        screen       = awful.screen.focused(),
    }

    -- Close on mouse leave (with grace period)
    local leave_timer
    popup_obj:connect_signal("mouse::leave", function()
        leave_timer = gears.timer.start_new(0.3, function()
            hide_popup()
            return false
        end)
    end)
    popup_obj:connect_signal("mouse::enter", function()
        if leave_timer then
            leave_timer:stop()
            leave_timer = nil
        end
    end)
end

-- ---------------------------------------------------------------------------
-- Position popup near mouse / screen center
-- ---------------------------------------------------------------------------
local function position_popup()
    if not popup_obj then return end
    local s = awful.screen.focused()
    local geo = s.geometry
    local pw, ph = popup_obj.width, popup_obj.height
    local mx, my = mouse.coords().x, mouse.coords().y

    local x = math.max(geo.x + dpi(10), math.min(mx - pw // 2, geo.x + geo.width - pw - dpi(10)))
    local y = math.max(geo.y + dpi(10), math.min(my - ph // 2, geo.y + geo.height - ph - dpi(10)))

    popup_obj.x = x
    popup_obj.y = y
end

-- ---------------------------------------------------------------------------
-- Key handling (old-style awful.keygrabber.run callback)
-- ---------------------------------------------------------------------------
local function has_mod(mod_table, name)
    for _, m in ipairs(mod_table) do
        if m == name then return true end
    end
    return false
end

local function is_printable(key)
    return #key == 1 and key:match("[%w%p%s]")
end

local function start_keygrabber()
    if keygrabber then return end
    keygrabber = awful.keygrabber.run(function(mod, key, event)
        if event == "release" then return true end

        if key == "Escape" or key == "q" then
            hide_popup()
            return false
        elseif key == "Up" then
            if filtered_start > 1 then
                filtered_start = filtered_start - 1
                build_rows()
            end
        elseif key == "Down" then
            local filtered = get_filtered_history()
            if filtered_start + VISIBLE_ROWS - 1 < #filtered then
                filtered_start = filtered_start + 1
                build_rows()
            end
        elseif key == "Page_Up" then
            filtered_start = math.max(1, filtered_start - VISIBLE_ROWS)
            build_rows()
        elseif key == "Page_Down" then
            local filtered = get_filtered_history()
            filtered_start = math.min(math.max(1, #filtered - VISIBLE_ROWS + 1), filtered_start + VISIBLE_ROWS)
            build_rows()
        elseif key == "BackSpace" then
            if #filter_text > 0 then
                filter_text = filter_text:sub(1, -2)
                filtered_start = 1
                build_rows()
            end
        elseif key == "k" and has_mod(mod, "Control") then
            history = {}
            filter_text = ""
            filtered_start = 1
            unread_count = 0
            update_indicator()
            build_rows()
            naughty.notify({ title = "History", text = "Notification history cleared." })
        elseif is_printable(key) and not has_mod(mod, "Control") then
            filter_text = filter_text .. key
            filtered_start = 1
            build_rows()
        end
        return true
    end)
end

local function stop_keygrabber()
    if keygrabber then
        awful.keygrabber.stop(keygrabber)
        keygrabber = nil
    end
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------
function show_popup()
    ensure_popup()
    popup_obj.screen = awful.screen.focused()
    position_popup()
    popup_obj.visible = true
    popup_visible = true
    unread_count = 0
    update_indicator()
    filtered_start = 1
    filter_text = ""
    build_rows()
    start_keygrabber()
end

function hide_popup()
    popup_visible = false
    if popup_obj then popup_obj.visible = false end
    stop_keygrabber()
end

function toggle_popup()
    if popup_visible then
        hide_popup()
    else
        show_popup()
    end
end

-- ---------------------------------------------------------------------------
-- Wibar indicator factory
-- ---------------------------------------------------------------------------
local function create_indicator()
    indicator_widget = wibox.widget.textbox()
    indicator_widget.font = beautiful.font or "sans 11"
    update_indicator()

    indicator_widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then -- left click
            toggle_popup()
        end
    end)

    return indicator_widget
end

-- ---------------------------------------------------------------------------
-- Module exports
-- ---------------------------------------------------------------------------
return {
    create  = create_indicator,
    show    = show_popup,
    hide    = hide_popup,
    toggle  = toggle_popup,
}
