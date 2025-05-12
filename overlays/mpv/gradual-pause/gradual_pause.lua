-- gradual-pause.lua - Implements volume fade when pausing/unpausing in mpv
local mp = require 'mp'
local options = require 'mp.options'

local opts = {
    fade_out_duration = 0.45,   -- Duration of fade-out in seconds
    fade_in_duration = 0.3,     -- Duration of fade-in in seconds
    steps = 12,                 -- Number of volume steps for smooth transition
    logarithmic_fade = true,    -- Use logarithmic fading for more natural sound
}

-- Read options with explicit script name
options.read_options(opts, "gradual_pause")

local original_volume = 50
local pause_position = nil
local fade_timer = nil
local is_fading = false
local script_handling_pause = false

-- Reset timer to prevent conflicts
function reset_timer()
    if fade_timer then
        fade_timer:kill()
        fade_timer = nil
    end
end

-- Save the current volume
function save_volume()
    original_volume = mp.get_property_number("volume", original_volume)
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
    -- Set our state flags
    is_fading = true
    script_handling_pause = true
    
    -- Save current volume and position
    save_volume()
    save_position()
    
    -- Cancel any existing timer before creating a new one
    reset_timer()
    
    -- IMPORTANT FIX: First ensure we're unpaused before starting fade
    -- This prevents MPRIS/external tools from causing an abrupt pause
    mp.set_property_bool("pause", false)
    
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
            fade_timer = nil
            
            -- We're doing the actual pause operation ourselves
            mp.set_property_bool("pause", true)
            
            -- Restore the volume after pausing -
            --  without this, mpv might start with 0 volume if user exited after pausing
            mp.set_property("volume", original_volume)
            
            -- Reset our flags with a slight delay
            mp.add_timeout(0.1, function()
                is_fading = false
                script_handling_pause = false
            end)
        end
    end)
end

-- Handle fade in when unpausing
function unpause_and_fade_in()
    -- Set our state flags
    is_fading = true
    script_handling_pause = true
    
    -- Cancel any existing timer before creating a new one
    reset_timer()
    
    -- Restore the position we were at when we started fading out
    if pause_position ~= nil then
        mp.set_property_number("time-pos", pause_position)
    end
    
    -- Save current volume in case it changed while paused
    save_volume()
    
    -- Volume to 0, and Unpause
    mp.set_property("volume", 0)
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
            fade_timer = nil
            mp.set_property("volume", original_volume)
            
            -- Reset our flags with a slight delay
            mp.add_timeout(0.1, function()
                is_fading = false
                script_handling_pause = false
            end)
        end
    end)
end

-- Handle key press directly (bypassing MPV's pause property)
function handle_pause_key()
    -- If we're currently fading, ignore the key press
    if is_fading then
        return true
    end
    
    local is_paused = mp.get_property_bool("pause")
    
    if is_paused then
        unpause_and_fade_in()
    else
        fade_out_and_pause()
    end
    
    -- Return true to prevent default handler
    return true
end

-- Handle pause property changes (from any source)
function on_pause_change(name, value)
    -- Skip if we're the ones changing the pause state
    if script_handling_pause then
        return true
    end
    
    -- If we're currently fading, ignore external pause changes
    if is_fading then
        return true
    end
    
    if value then
        mp.set_property_bool("pause", false)
        -- Something just paused the player - fade out
        fade_out_and_pause()
    else
        -- Something just unpaused the player - fade in
        unpause_and_fade_in()
    end

    return true
end

-- Clean up when the file is closed or player exits
function cleanup()
    reset_timer()
    is_fading = false
    script_handling_pause = false
end

-- Direct bindings to override default behavior
mp.add_forced_key_binding("space", "gradual_pause_space", handle_pause_key)
mp.add_forced_key_binding("p", "gradual_pause_p", handle_pause_key)

-- Register event handlers
mp.observe_property("pause", "bool", on_pause_change)
mp.register_event("end-file", cleanup)
mp.register_event("shutdown", cleanup)

-- Initialize state
reset_timer()
is_fading = false
script_handling_pause = false
