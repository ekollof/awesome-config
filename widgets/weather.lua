-------------------------------------------------
-- Weather Widget based on the WeatherAPI
-- https://weatherapi.com/
--
-- @author Pavel Makhov
-- @copyright 2020 Pavel Makhov
-- @copyright 2024 André Jaenisch
-------------------------------------------------
local awful = require("awful")
local watch = require("awful.widget.watch")
local json = require("json")
local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local HOME_DIR = os.getenv("HOME")
local WIDGET_DIR = HOME_DIR .. '/.config/awesome/widgets'
local GET_FORECAST_CMD = [[bash -c "curl -s --show-error -X GET '%s'"]]

local SYS_LANG = os.getenv("LANG"):sub(1, 2)
if SYS_LANG == "C" or SYS_LANG == "C." then
    SYS_LANG = "en"
end

local function show_warning(message, locale)
    naughty.notify {
        preset = naughty.config.presets.critical,
        title = locale and locale.warning_title or "Weather Widget",
        text = message
    }
end

local function get_locale(data)
  local lang = gears.filesystem.file_readable(
    WIDGET_DIR .. "/weather-locale/" .. data .. ".lua"
  ) and data or "en"

  local locale = require("widgets.weather-locale." .. lang)

  if data ~= lang then
    show_warning(
      string.format("Your language (%s) is not supported yet. Language set to English", data),
      locale
    )
  end

  return locale
end

local warning_shown = false
local tooltip = awful.tooltip {
    mode = 'outside',
    preferred_positions = {'bottom'}
}

local weather_popup = awful.popup {
    ontop = true,
    visible = false,
    shape = gears.shape.rounded_rect,
    border_width = 1,
    maximum_width = 400,
    offset = {y = 5},
    hide_on_right_click = true,
    widget = {}
}

local icon_map = {
    [1000] = "clear-sky", [1003] = "few-clouds", [1006] = "scattered-clouds",
    [1009] = "scattered-clouds", [1030] = "mist", [1063] = "rain",
    [1066] = "snow", [1069] = "rain", [1072] = "snow", [1087] = "thunderstorm",
    [1114] = "snow", [1117] = "snow", [1135] = "mist", [1147] = "mist",
    [1150] = "snow", [1153] = "snow", [1168] = "snow", [1171] = "snow",
    [1180] = "rain", [1183] = "rain", [1186] = "rain", [1189] = "rain",
    [1192] = "rain", [1195] = "rain", [1198] = "rain", [1201] = "rain",
    [1204] = "snow", [1207] = "snow", [1210] = "snow", [1213] = "snow",
    [1216] = "snow", [1219] = "snow", [1222] = "snow", [1225] = "snow",
    [1237] = "snow", [1240] = "rain", [1243] = "rain", [1246] = "rain",
    [1249] = "snow", [1252] = "snow", [1255] = "snow", [1258] = "snow",
    [1261] = "snow", [1264] = "snow", [1273] = "thunderstorm",
    [1276] = "thunderstorm", [1279] = "thunderstorm", [1282] = "thunderstorm"
}

local function celsius_to_fahrenheit(c) return c * 9 / 5 + 32 end
local function fahrenheit_to_celsius(f) return (f - 32) * 5 / 9 end

local function gen_temperature_str(temp, fmt_str, show_other_units, units)
    local temp_str = string.format(fmt_str, temp)
    local s = temp_str .. '°' .. (units == 'metric' and 'C' or 'F')
    if (show_other_units) then
        local temp_conv, units_conv
        if (units == 'metric') then
            temp_conv = celsius_to_fahrenheit(temp)
            units_conv = 'F'
        else
            temp_conv = fahrenheit_to_celsius(temp)
            units_conv = 'C'
        end
        s = s .. ' ' .. '(' .. string.format(fmt_str, temp_conv) .. '°' .. units_conv .. ')'
    end
    return s
end

local function uvi_index_color(uvi)
    local color = '#a3be8c'
    if uvi >= 3 and uvi < 6 then color = '#ebcb8b'
    elseif uvi >= 6 and uvi < 8 then color = '#d08770'
    elseif uvi >= 8 and uvi < 11 then color = '#bf616a'
    elseif uvi >= 11 then color = '#b48ead' end
    return '<span weight="bold" foreground="' .. color .. '">' .. uvi .. '</span>'
end

local function worker(user_args)
    local args = user_args or {}
    local lang = args.lang or SYS_LANG
    local locale = get_locale(lang)
    local coordinates = args.coordinates
    local api_key = args.api_key
    local font_name = args.font_name or (beautiful.font and beautiful.font:gsub("%s%d+$", "") or "sans")
    local units = args.units or 'metric'
    local time_format_12h = args.time_format_12h
    local both_units_widget = args.both_units_widget or false
    local icon_pack_name = args.icons or 'weather-underground-icons'
    local icons_extension = args.icons_extension or '.png'
    local show_forecast_on_hover = args.show_forecast_on_hover or false
    local show_daily_forecast = args.show_daily_forecast or false
    local show_hourly_forecast = args.show_hourly_forecast or false
    local location_name = args.location or nil
    local timeout = args.timeout or 120
    local ICONS_DIR = WIDGET_DIR .. '/weather-icons/' .. icon_pack_name .. '/'

    if not coordinates or not api_key then
        show_warning(locale.parameter_warning .. (not coordinates and '<b>coordinates</b>' or '') .. (not api_key and ', <b>api_key</b> ' or ''), locale)
        return wibox.widget.textbox("Weather API Error")
    end

    weather_popup.border_color = beautiful.bg_focus or "#333333"

    local weather_api_url = 'https://api.weatherapi.com/v1/forecast.json?q=' .. coordinates[1] .. ',' .. coordinates[2] .. '&key=' .. api_key .. '&units=' .. units .. '&lang=' .. lang .. '&days=3'

    local widget_instance = wibox.widget {
        {
            {
                {
                    { id = 'icon', resize = true, widget = wibox.widget.imagebox },
                    valign = 'center', widget = wibox.container.place,
                },
                { id = 'txt', text = "---", widget = wibox.widget.textbox },
                layout = wibox.layout.fixed.horizontal,
            },
            left = 4, right = 4, layout = wibox.container.margin
        },
        shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 4) end,
        widget = wibox.container.background,
        set_image = function(self, path) self:get_children_by_id('icon')[1].image = path end,
        set_text = function(self, text) self:get_children_by_id('txt')[1].text = text end,
        is_ok = function(self, is_ok_val)
            local icon = self:get_children_by_id('icon')[1]
            icon:set_opacity(is_ok_val and 1 or 0.2)
            icon:emit_signal('widget:redraw_needed')
            if not is_ok_val then self:set_text("N/A") end
        end
    }

    local current_weather_widget = wibox.widget {
        {
            { { id = 'icon', resize = true, forced_width = 128, forced_height = 128, widget = wibox.widget.imagebox }, align = 'center', widget = wibox.container.place },
            { id = 'description', font = font_name .. ' 10', align = 'center', widget = wibox.widget.textbox },
            forced_width = 128, layout = wibox.layout.align.vertical
        },
        {
            { id = 'temp', font = font_name .. ' 36', widget = wibox.widget.textbox },
            { id = 'feels_like_temp', align = 'center', font = font_name .. ' 9', widget = wibox.widget.textbox },
            { id = 'precip', font = font_name .. ' 9', widget = wibox.widget.textbox },
            { id = 'rain', font = font_name .. ' 9', widget = wibox.widget.textbox },
            spacing = 4, layout = wibox.layout.fixed.vertical
        },
        {
            { id = 'wind', font = font_name .. ' 9', widget = wibox.widget.textbox },
            { id = 'humidity', font = font_name .. ' 9', widget = wibox.widget.textbox },
            { id = 'uv', font = font_name .. ' 9', widget = wibox.widget.textbox },
            { id = 'sunrise', font = font_name .. ' 9', widget = wibox.widget.textbox },
            { id = 'sunset', font = font_name .. ' 9', widget = wibox.widget.textbox },
            expand = 'inside', layout = wibox.layout.align.vertical
        },
        forced_width = 340, layout = wibox.layout.flex.horizontal,
        update = function(self, weather, astro)
            local day_night = weather.is_day == 0 and "-night" or ""
            self:get_children_by_id('icon')[1]:set_image(ICONS_DIR .. icon_map[weather.condition.code] .. day_night .. icons_extension)
            self:get_children_by_id('temp')[1]:set_text(gen_temperature_str(weather.temp_c, '%.0f', false, units))
            self:get_children_by_id('feels_like_temp')[1]:set_text(locale.feels_like .. gen_temperature_str(weather.feelslike_c, '%.0f', false, units))
            self:get_children_by_id('description')[1]:set_text(weather.condition.text)
            self:get_children_by_id('wind')[1]:set_markup(locale.wind .. '<b>' .. weather.wind_kph .. 'km/h (' .. weather.wind_dir .. ')</b>')
            self:get_children_by_id('humidity')[1]:set_markup(locale.humidity .. '<b>' .. weather.humidity .. '%</b>')
            self:get_children_by_id('uv')[1]:set_markup(locale.uv .. uvi_index_color(weather.uv))
            self:get_children_by_id('precip')[1]:set_markup(locale.precip .. '<b>' .. (weather.precip_mm or 0) .. 'mm</b>')
            local rain_chance = astro and tonumber(astro.daily_chance_of_rain) or 0
            self:get_children_by_id('rain')[1]:set_markup(rain_chance > 0 and (locale.rain .. '<b>' .. rain_chance .. '%</b>') or '')
            if astro then
                self:get_children_by_id('sunrise')[1]:set_markup(locale.sunrise .. '<b>' .. (astro.sunrise or '—') .. '</b>')
                self:get_children_by_id('sunset')[1]:set_markup(locale.sunset .. '<b>' .. (astro.sunset or '—') .. '</b>')
            end
        end
    }

    local daily_forecast_widget = {
        forced_width = 300, layout = wibox.layout.flex.horizontal,
        update = function(self, forecast)
            for i = 0, #self do self[i] = nil end
            for i, day in ipairs(forecast) do
                if i > 3 then break end
                table.insert(self, wibox.widget {
                    { text = locale.days[os.date('%a', tonumber(day.date_epoch))], align = 'center', font = font_name .. ' 9', widget = wibox.widget.textbox },
                    { { { image = ICONS_DIR .. icon_map[day.day.condition.code] .. icons_extension, resize = true, forced_width = 48, forced_height = 48, widget = wibox.widget.imagebox }, align = 'center', layout = wibox.container.place },
                      { text = day.day.condition.text, font = font_name .. ' 8', align = 'center', forced_height = 50, widget = wibox.widget.textbox }, layout = wibox.layout.fixed.vertical },
                    { { text = gen_temperature_str(day.day.mintemp_c, '%.0f', false, units), align = 'center', font = font_name .. ' 9', widget = wibox.widget.textbox },
                      { text = gen_temperature_str(day.day.maxtemp_c, '%.0f', false, units), align = 'center', font = font_name .. ' 9', widget = wibox.widget.textbox },
                      { markup = '<span foreground="#89b4fa">' .. (day.day.daily_chance_of_rain or 0) .. '%</span>', align = 'center', font = font_name .. ' 8', widget = wibox.widget.textbox }, layout = wibox.layout.fixed.vertical },
                    spacing = 8, layout = wibox.layout.fixed.vertical
                })
            end
        end
    }

    local function update_widget(widget, stdout, stderr)
        if stderr ~= '' or stdout == '' or stdout:match("^<") then
            if not warning_shown and stderr ~= '' then show_warning(stderr, locale); warning_shown = true end
            widget:is_ok(false)
            return
        end
        warning_shown = false
        widget:is_ok(true)
        local result = json.decode(stdout)
        if not result or not result.current then return end
        local astro = result.forecast and result.forecast.forecastday and result.forecast.forecastday[1] and result.forecast.forecastday[1].astro or nil
        local day_night = result.current.is_day == 0 and "-night" or ""
        widget:set_image(ICONS_DIR .. icon_map[result.current.condition.code] .. day_night .. icons_extension)
        widget:set_text(gen_temperature_str(result.current.temp_c, '%.0f', both_units_widget, units))
        tooltip:add_to_object(widget)
        tooltip.text = result.current.condition.text .. ' | ' .. locale.wind .. result.current.wind_kph .. 'km/h | ' .. locale.humidity .. result.current.humidity .. '%'
        current_weather_widget:update(result.current, astro)
        local final_widget = { layout = wibox.layout.fixed.vertical, spacing = 16 }
        if location_name then table.insert(final_widget, wibox.widget { text = location_name, align = 'center', font = font_name .. ' 11', widget = wibox.widget.textbox }) end
        table.insert(final_widget, current_weather_widget)
        if show_daily_forecast then daily_forecast_widget:update(result.forecast.forecastday); table.insert(final_widget, daily_forecast_widget) end
        table.insert(final_widget, wibox.widget { markup = '<span foreground="#888888" font="' .. font_name .. ' 8">' .. locale.updated .. os.date('%H:%M') .. '</span>', align = 'center', widget = wibox.widget.textbox })
        weather_popup:setup({ { final_widget, margins = 10, widget = wibox.container.margin }, bg = beautiful.bg_normal or "#111111", widget = wibox.container.background })
    end

    widget_instance:buttons(gears.table.join(awful.button({}, 1, function()
        if weather_popup.visible then widget_instance:set_bg('#00000000'); weather_popup.visible = false
        else widget_instance:set_bg(beautiful.bg_focus); weather_popup:move_next_to(mouse.current_widget_geometry); weather_popup.visible = true end
    end)))

    widget_instance:connect_signal("mouse::enter", function() if show_forecast_on_hover then widget_instance:set_bg(beautiful.bg_focus); weather_popup:move_next_to(mouse.current_widget_geometry); weather_popup.visible = true end end)
    widget_instance:connect_signal("mouse::leave", function() if show_forecast_on_hover then widget_instance:set_bg('#00000000'); weather_popup.visible = false end end)

    watch(string.format(GET_FORECAST_CMD, weather_api_url), timeout, update_widget, widget_instance)
    return widget_instance
end

return setmetatable({}, {__call = function(_, ...) return worker(...) end})
