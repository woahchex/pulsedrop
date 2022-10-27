--- A song object holds the sound and note data for a beatmap.
-- constructed from a file and used by GameScenes
local Song = {
    -- prototype
    __index = {
        -- instance vars
        currentTime = 0,
        notes = {
            -- TEST VALUES
            {"MOVE", 0.5},
            {"MOVE", 0.6},
        },

        -- methods
        update = function(self, dt)
            -- update instance var with song time here
        end
    }
}

-- Constructor
function Song.new()
    local newSong = setmetatable({}, Song)
    
    return newSong
end

return Song