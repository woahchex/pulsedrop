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
        startAR = 2,

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
        events = {

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
        math.random(4)==1 and "DROP" or math.random(1,3)>1 and "MOVE" or "MOVE",
        i * 0.54545454545,
        2,
        math.random(1,5) == 1 and math.random(1,7) or selectedPiece,
        0,
        deepCopy(tabOptions[selectedPiece]),
        selectedPiece -- hold piece
    ))

    --table.insert(Song.__index.notes, {math.random(2)==1 and "DROP" or "MOVE", i*0.5, math.random(1,3), selectedPiece, 0, false, tabOptions[selectedPiece]})
end

-- Constructor
function Song.new(notes, events, parameters)
    notes = notes or nil
    events = events or {}
    parameters = parameters or {general = {}, meta = {}, difficulty = {}}

    local newSong = setmetatable({}, Song)
    
    newSong.bpm = parameters.general.BPM or 120
    newSong.offset = parameters.general.StartOffset or 0
    newSong.notes = notes
    newSong.events = events
    newSong.timingStrictness = parameters.meta.TimingDifficulty or 1
    newSong.approachRate = parameters.meta.ApproachRate or 2

    -- precalculate the approach rate of each note
    for i, note in ipairs(notes) do
        note:setApproachRate(note:getARMultiplier() * newSong.approachRate)
    end

    for i, event in ipairs(events) do
        if type(event[4])=="number" then
            local stopTime = events[i+1] and events[i+1][1] or math.huge

            for j, note in ipairs(notes) do
                if note:getTime() >= event[1] and note:getTime() < stopTime then
                    note:setApproachRate(note:getARMultiplier() * event[4])
                elseif note:getTime() >= stopTime then
                    break
                end
            end
        end
    end

    

    return newSong
end


----- MAPFILE READING

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end
-- from PiL2 20.4

local function trimSplit(input, d)
    d = d or "%s"
    local out={}
    for str in string.gmatch(input, "([^"..d.."]+)") do
            table.insert(out, tonumber(str) or trim(str))
    end
    return out
end

local function generateParameterTable( text )
    local out = {}

    local p = 0
    local s = 1
    repeat
        s = p+1
        while p < text:len() and text:sub(p, p) ~= "[" do
            p = p + 1
        end
        local parameterName = trim(text:sub(s, p-1))
        
        s = p + 1
        while p < text:len() and text:sub(p, p) ~= "]" do
            p = p + 1
        end
        local parameterValue = trim(text:sub(s, p-1))
        
        parameterValue = tonumber(parameterValue) or parameterValue
        
        out[parameterName] = parameterValue

    until p >= text:len()

    return out
end

local function getParameters( text, keyword )
    local p = 0
    local s = 0
    while text:sub(p, p+keyword:len()+1) ~= "@" .. keyword .. ":" do
        p = p + 1
        if p >= text:len() then return false end
    end
    s = p+keyword:len()+2

    while text:sub(p, p) ~= ";" do
        p = p + 1
        if p >= text:len() then return false end
    end

    return generateParameterTable( text:sub(s, p-1) )
end

local function generateMatrix( text )
    local out = {}

    local p = 0
    local s = 1
    repeat
        while p < text:len() and text:sub(p, p) ~= "[" do
            p = p + 1
        end
        s = p + 1

        while p < text:len() and text:sub(p, p) ~= "]" do
            p = p + 1
        end

        local lineText = text:sub(s, p-1)
        local line = {}

        for i = 1, lineText:len() do
            line[#line+1] = (lineText:sub(i, i) ~= " ")
        end

        out[#out+1] = line

    until p >= text:len()

    return out
end

local function getEvents( text )
    local p = 0
    local s = 0
    local keyword = "EVENTS"
    while text:sub(p, p+keyword:len()+1) ~= "@" .. keyword .. ":" do
        p = p + 1
        if p >= text:len() then return false end
    end
    s = p+keyword:len()+2

    while text:sub(p, p+2) ~= "END" do
        p = p + 1
        if p >= text:len() then return false end
    end

    local eventStringList = trimSplit(text:sub(s, p-1), ";")

    local out = {}

    for _, v in pairs(eventStringList) do
        local n = trimSplit(v, ",")
        if #n>0 then
            out[#out+1] = n
        end
    end

    return out
end

local tetrisTranslation = {I = 1, J = 2, L = 3, S = 4, Z = 5, T = 6, O = 7}
local function getNotes( text )
    local noteClass = Classes.game_Note
    local p = 0
    local s = 0
    local keyword = "NOTES"
    local term = "@" .. keyword .. ":"
    while text:sub(p, p+keyword:len()+1) ~= term do
        p = p + 1
        if p >= text:len() then return false end
    end
    s = p+keyword:len()+2

    while text:sub(p, p+2) ~= "END" do
        p = p + 1
        if p >= text:len() then return false end
    end

    local noteStringList = trimSplit(text:sub(s, p-1), ";")
    local out = {}

    for i, v in ipairs(noteStringList) do
        if v:len() ~= 0 then
            local noteVals = trimSplit( v, "," )

            -- we initialize the note with its approach multiplier, then generate the rate with events
                if noteVals[2] == "D" then
                -- drop note
                local grid = generateMatrix(noteVals[6])
                out[#out+1] = noteClass.new("DROP", noteVals[1], noteVals[3], tetrisTranslation[noteVals[4]], nil, grid, tetrisTranslation[noteVals[5]])
            else
                -- move note
                -- color is set later
                out[#out+1] = noteClass.new("MOVE", noteVals[1], noteVals[3], 0, nil, nil, 0)
            end

        end
    end

    return out
end

function Song.compile( text )
    
    local generalParameters = getParameters(text, "GENERAL")
    local metaParameters = getParameters(text, "META")

    local notes = getNotes( text )
    local events = getEvents( text )

    local songParameters = {
        general = generalParameters,
        meta = metaParameters,
    }

    return Song.new(notes, events, songParameters)
end

function Song.compileInfo( text )
    
    local generalParameters = getParameters(text, "GENERAL")
    local metaParameters = getParameters(text, "META")

    local notes = getNotes( text )
    local events = getEvents( text )

    local songParameters = {
        general = generalParameters,
        meta = metaParameters
    }

    return notes, events, songParameters
end




return Song