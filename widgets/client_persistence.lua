--[[
    Client persistence widget.

    Saves/restores window placement across AwesomeWM restarts.
    Matches existing X clients by window ID (stable across restarts).
    Falls back to current screen if the saved output is disconnected.

    State file: ~/.cache/awesome/client_state.json
--]]

local awful = require("awful")
local gears = require("gears")

local persistence = {
    state = {},
    state_file = os.getenv("HOME") .. "/.cache/awesome/client_state.json",
    _save_timer = nil,
}

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function get_output_name(s)
    if not s then return nil end
    for name, _ in pairs(s.outputs) do
        return name
    end
    return nil
end

local function write_state()
    local json = require("json")
    local ok, encoded = pcall(json.encode, persistence.state)
    if not ok then return end
    gears.filesystem.make_parent_directories(persistence.state_file)
    local f = io.open(persistence.state_file, "w")
    if f then
        f:write(encoded)
        f:close()
    end
end

-- Debounced save: coalesces rapid-fire tag/screen changes into one disk write.
local function schedule_save()
    if persistence._save_timer then
        persistence._save_timer:stop()
    else
        persistence._save_timer = gears.timer({ timeout = 1 })
        persistence._save_timer:connect_signal("timeout", function()
            persistence._save_timer:stop()
            write_state()
        end)
    end
    persistence._save_timer:start()
end

-- ---------------------------------------------------------------------------
-- Load / Save / Record / Forget
-- ---------------------------------------------------------------------------

function persistence.load()
    local f = io.open(persistence.state_file, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local ok, data = pcall(require("json").decode, content)
    if ok and type(data) == "table" then
        persistence.state = data
    end
end

function persistence.save_now()
    if persistence._save_timer then
        persistence._save_timer:stop()
    end
    write_state()
end

function persistence.record(c)
    if not c.valid or not _G._persistence_enabled then return end

    -- Don't record fullscreen or maximized windows, as restoring them
    -- can cause race conditions with focus/grabbing.
    if c.fullscreen or c.maximized then return end

    local tags = {}
    for _, t in ipairs(c:tags()) do
        table.insert(tags, t.name)
    end

    persistence.state[tostring(c.window)] = {
        class                = c.class,
        instance             = c.instance,
        name                 = c.name,
        output               = get_output_name(c.screen),
        tags                 = tags,
        floating             = c.floating,
        maximized            = c.maximized,
        maximized_horizontal = c.maximized_horizontal,
        maximized_vertical   = c.maximized_vertical,
        fullscreen           = c.fullscreen,
        x                    = c.x,
        y                    = c.y,
        width                = c.width,
        height               = c.height,
    }

    schedule_save()
end

function persistence.forget(c)
    persistence.state[tostring(c.window)] = nil
    schedule_save()
end

-- ---------------------------------------------------------------------------
-- Restore
-- ---------------------------------------------------------------------------

function persistence.restore(c)
    if not _G._persistence_enabled then return end
    local saved = persistence.state[tostring(c.window)]
    if not saved then return end

    -- Find the screen that has the saved output name.
    local target_screen = nil
    if saved.output then
        for s in screen do
            if s.outputs[saved.output] then
                target_screen = s
                break
            end
        end
    end

    -- If the output is missing (undocked), keep the window on the
    -- screen it was initially placed on by the WM.
    if not target_screen then
        target_screen = c.screen
    end

    -- Move to the correct screen.
    if target_screen and target_screen ~= c.screen then
        c:move_to_screen(target_screen)
    end

    -- Restore tags by name (tag indices may shift across restarts).
    if _G._persistence_tags_enabled and saved.tags and #saved.tags > 0 then
        local s = c.screen
        if s then
            local target_tags = {}
            for _, t in ipairs(s.tags) do
                for _, saved_name in ipairs(saved.tags) do
                    if t.name == saved_name then
                        table.insert(target_tags, t)
                        break
                    end
                end
            end
            if #target_tags > 0 then
                c:tags(target_tags)
            end
        end
    end

    -- Restore layout state.
    if saved.floating ~= nil then
        c.floating = saved.floating
    end

    -- Restore geometry for floating windows (delay so tiling settles first).
    if saved.floating and saved.x and saved.y and saved.width and saved.height then
        gears.timer.delayed_call(function()
            if c.valid and c.floating then
                c:geometry({
                    x      = saved.x,
                    y      = saved.y,
                    width  = saved.width,
                    height = saved.height,
                })
            end
        end)
    end

    -- Remove the entry so a second manage (e.g. restart loop) doesn't move
    -- the window again.
    persistence.state[tostring(c.window)] = nil
    schedule_save()
end

-- ---------------------------------------------------------------------------
-- Bulk save on exit
-- ---------------------------------------------------------------------------

function persistence.save_all()
    if not _G._persistence_enabled then return end
    for _, c in ipairs(client.get()) do
        persistence.record(c)
    end
    persistence.save_now()
end

-- ---------------------------------------------------------------------------
-- Periodic background save (covers crashes where exit signal never fires)
-- ---------------------------------------------------------------------------

gears.timer {
    timeout   = 30,
    autostart = true,
    callback  = function()
        if not _G._persistence_enabled then return end
        for _, c in ipairs(client.get()) do
            persistence.record(c)
        end
        persistence.save_now()
    end
}

return persistence
