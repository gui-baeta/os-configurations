-- gradual-pause.lua
-- This script implements a gradual fade-out when pausing and fade-in when unpausing in mpv.
-- It responds to ALL pause/unpause events regardless of trigger method.
-- Fixed version to handle MPV state restoration properly.

local mp = require 'mp'
local options = require 'mp.options'

local opts = {
    fade_out_duration = 0.45,   -- Duration of fade-out in seconds (slightly longer)
    fade_in_duration = 0.3,     -- Duration of fade-in in seconds
    steps = 12,                 -- Number of volume steps for smooth transition
    logarithmic_fade = true,    -- Use logarithmic fading for more natural sound
}

options.read_options(opts)

local original_volume = 100
local pause_position = nil
local fade_timer = nil
local is_fading = false
local script_handling_pause = false

-- Save the current volume
function save_volume()
    original_volume = mp.get_property_number("volume", 100)
end

-- Save the current playback position
function save_position()
    pause_position = mp.get_property_number("time-pos")
end

-- Apply logarithmic adjustment to volume level
function log_adjust(volume_level, is_fade_out)
    if not opts.logarithmic_fade then
        return volume_level
    end
    
    if is_fade_out then
        -- Logarithmic fade-out (slower at the beginning)
        return volume_level * volume_level / original_volume
    else
        -- Logarithmic fade-in (faster at the beginning)
        return original_volume - (original_volume - volume_level) * (original_volume - volume_level) / original_volume
    end
end

-- Handle fade out when pausing
function fade_out_and_pause()
    if is_fading then return end
    is_fading = true
    
    -- Save current volume before starting fade
    save_volume()
    
    -- Save current playback position
    save_position()
    
    -- Temporarily disable our pause handler to avoid recursion
    script_handling_pause = true
    
    local step_time = opts.fade_out_duration / opts.steps
    local vol_step = original_volume / opts.steps
    local current_step = 0
    
    fade_timer = mp.add_periodic_timer(step_time, function()
        current_step = current_step + 1
        
        -- Calculate new volume with logarithmic adjustment
        local linear_volume = original_volume - (vol_step * current_step)
        local new_volume = math.max(log_adjust(linear_volume, true), 0)
        mp.set_property("volume", new_volume)
        
        -- When fade is complete, actually pause the player
        if current_step >= opts.steps then
            fade_timer:kill()
            -- We're doing the actual pause operation ourselves
            mp.set_property_bool("pause", true)
            
            -- IMPORTANT FIX: Restore the volume after pausing
            -- This ensures MPV doesn't save state with volume at 0
            mp.set_property("volume", original_volume)
            
            is_fading = false
            
            -- Re-enable the pause property observer after a brief delay
            mp.add_timeout(0.1, function()
                script_handling_pause = false
            end)
        end
    end)
end

-- Handle fade in when unpausing
function unpause_and_fade_in()
    if is_fading then return end
    is_fading = true
    
    -- Restore the position we were at when we started fading out
    if pause_position ~= nil then
        mp.set_property_number("time-pos", pause_position)
    end
    
    -- Temporarily disable our pause handler to avoid recursion
    script_handling_pause = true
    
    -- Make sure volume starts at 0
    mp.set_property("volume", 0)
    
    -- Unpause immediately (audio will be silent at first)
    mp.set_property_bool("pause", false)
    
    local step_time = opts.fade_in_duration / opts.steps
    local vol_step = original_volume / opts.steps
    local current_step = 0
    
    fade_timer = mp.add_periodic_timer(step_time, function()
        current_step = current_step + 1
        
        -- Calculate new volume with logarithmic adjustment
        local linear_volume = vol_step * current_step
        local new_volume = math.min(log_adjust(linear_volume, false), original_volume)
        mp.set_property("volume", new_volume)
        
        -- When fade is complete, restore volume and reset
        if current_step >= opts.steps then
            fade_timer:kill()
            mp.set_property("volume", original_volume)
            is_fading = false
            
            -- Re-enable the pause property observer
            mp.add_timeout(0.1, function()
                script_handling_pause = false
            end)
        end
    end)
end

-- Handle pause property changes (from any source)
function on_pause_change(name, value)
    -- Skip if we're the ones changing the pause state
    if script_handling_pause then
        return
    end
    
    -- Cancel any active fade
    if fade_timer then
        fade_timer:kill()
        fade_timer = nil
    end
    
    if value then
        -- Something just paused the player - fade out
        fade_out_and_pause()
    else
        -- Something just unpaused the player - fade in
        unpause_and_fade_in()
    end
end

-- Clean up any running timers when the file is closed or player exits
function cleanup()
    if fade_timer then
        fade_timer:kill()
    end
end

-- Register event handlers
mp.observe_property("pause", "bool", on_pause_change)
mp.register_event("end-file", cleanup)
mp.register_event("shutdown", cleanup)

-- Log that the script has been loaded
mp.msg.info("Gradual pause/unpause script loaded")
