--- A song object holds the sound and note data for a beatmap.
-- constructed from a file and used by GameScenes
local Song = {
    -- prototype
    __index = {
        -- instance vars
        currentTime = 0,

        startBpm = 120,
        startOffset = 0,
        timingStrictness = 1,

        getTimingStrictness = function(self, type)
            return type == "PERFECT" and 0.05 * self.timingStrictness or
                   type == "GOOD" and 0.1 * self.timingStrictness or
                   type == "OK" and 0.15 * self.timingStrictness
        end,

        bpm = 0,
        offset = 0,

        notes = {
            -- TEST VALUES
            -- Note type, note time, approach rate, pieceAssociation, fieldIndex (traceback), isActive,
            -- [grid]
            --[[{"MOVE", 1, 4, 1,},
            {"MOVE", 2, 4, 1,},
            {"DROP", 3, 2, 1, {
                {true, true, true, true, true, true, false, true, true, true},
                {true, true, true, true, true, true, false, true, true, true},
                {true, true, true, true, true, true, false, true, true, true},
                {true, true, true, true, true, true, false, true, true, true},
            }},]]
            
        },

        -- methods
        update = function(self, dt)
            -- update instance var with song time here
            -- temp:
            self.currentTime = self.currentTime + dt
        end
    }
}

local function deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

local tabOptions = {
    {
        {true, true, true, false, false, false, false, true, true, true},

    },
    {
        {true, true, true, true, true, false, false, true, true, true},
        {true, true, true, true, true, false, true, true, true, true},
        {true, true, true, true, true, false, true, true, true, true}
    },
    {
        {true, true, false, false, true, false, false, true, true, true},
        {true, true, true, false, true, false, true, true, true, true},
        {true, true, true, false, true, false, true, true, true, true}
    },
    {
        {true, true, true, true, false, false, false, true, true, true},
        {true, true, true, true, false, false, true, true, true, true},
    },    
    {
        {true, true, true, false, false, true, true, true, true, true},
        {true, true, true, false, false, true, true, true, true, true},
        {true, true, true, false, true, true, true, true, true, true}
    },
    {
        {true, true, true, true, false, false, false, true, true, true},
        {true, true, true, true, true, false, true, true, true, true},
    }, 
    {
        {true, true, true, true, false, false, true, true, true, true},
        {true, true, true, true, false, false, true, true, true, true},
    }
}
for i = 1, 10000 do
    local selectedPiece = math.random(1,7)

    table.insert(Song.__index.notes, Classes.game_Note.new(
        math.random(2)==1 and "DROP" or "DROP",
        i * .5,
        1.5,
        selectedPiece,
        0,
        deepCopy(tabOptions[selectedPiece]),
        selectedPiece -- hold piece
    ))

    --table.insert(Song.__index.notes, {math.random(2)==1 and "DROP" or "MOVE", i*0.5, math.random(1,3), selectedPiece, 0, false, tabOptions[selectedPiece]})
end

-- Constructor
function Song.new()
    local newSong = setmetatable({}, Song)
    
    newSong.bpm = newSong.startBpm
    newSong.offset = newSong.startOffset
    return newSong
end

return Song