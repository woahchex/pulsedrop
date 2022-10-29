--- A song object holds the sound and note data for a beatmap.
-- constructed from a file and used by GameScenes
local Song = {
    -- prototype
    __index = {
        -- instance vars
        currentTime = 0,

        startBpm = 120,
        startOffset = 0,

        bpm = 0,
        offset = 0,

        notes = {
            -- TEST VALUES
            -- Note type, note time, approach rate, pieceAssociation, fieldIndex (traceback)
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

for i = 1, 100000 do
    local tab = {true,true,true,true,true,true,true,true,true,true}
    tab[math.random(1,10)]=false
    table.insert(Song.__index.notes, {math.random(2)==1 and "DROP" or "MOVE", i*0.5, 2, i%7+1, 0, {tab,tab,tab,tab}})
end

-- Constructor
function Song.new()
    local newSong = setmetatable({}, Song)
    

    newSong.bpm = newSong.startBpm
    newSong.offset = newSong.startOffset
    return newSong
end

return Song