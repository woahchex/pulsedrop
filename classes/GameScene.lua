local Scene Scene = {
    -- prototype instance for a game scene
    prototype = {
        --- instance vars
        activeNote = nil,
        activePiece = nil,
        id = 0,
        field = false,
        song = nil,
        notes = {},

        -- internally used
        timesLoaded = {},

        --- methods
        destroy = function(self)
            Scene.activeScenes[self.id] = nil
        end,
    },

    activeScenes = {},
    assets = {}
}
Scene.__index = Scene.prototype

function Scene.prototype:update(dt)
    if self.song then
        self.song:update(dt)
    end

    self.field:update(dt)

    local currentSec = math.ceil(self.song.currentTime)

    -- send notes from this second to the Field for rendering
    for i = currentSec, currentSec+9 do
        if not self.timesLoaded[i] and self.notes[i] then
            self.timesLoaded[i] = true 
            for _, note in pairs(self.notes[i]) do
                self.field:addNote(note)
            end
        end
    end

    -- LOGIC CHECKS FOR NOTES

    -- temporary check for drop input:
    local dropFrame = Keyboard.justPressed["w"]
    local holdFrame = Keyboard.justPressed["lshift"]
    local leftFrame = Keyboard.justPressed["a"]
    local rightFrame = Keyboard.justPressed["d"]
    local rotateCCWFrame = Keyboard.justPressed["left"]
    local rotateCWFrame = Keyboard.justPressed["right"]
    local rotate180Frame = Keyboard.justPressed["up"]
    
    local leftHold = Keyboard.isDown("a")
    local rightHold = Keyboard.isDown("d")

    local legalMovement = leftFrame or rightFrame or rotateCWFrame or rotateCCWFrame or rotate180Frame
    local anyMovement = legalMovement or dropFrame or holdFrame

    if self.activePiece then
        if holdFrame then
            self.activePiece:hold()
        end
        if leftFrame then
            self.activePiece:frameLeft()
        end
        if rightFrame then
            self.activePiece:frameRight()
        end
        if rotateCWFrame then
            self.activePiece:rotateCW()
        end
        if rotateCCWFrame then
            self.activePiece:rotateCCW()
        end
        if rotate180Frame then
            self.activePiece:rotate180()
        end

        -- held buttons
        self.activePiece:holdLeft(leftHold, dt)
        self.activePiece:holdRight(rightHold, dt)

        
    end

    if self.activePiece then
        self.activePiece:update(dt)
    end

    if self.activeNote and self.activePiece and (anyMovement or not self.activePiece.overlap or leftHold or rightHold) then
        -- calculate piece collision
        self.activePiece:updateCollision(self.activeNote)
    end

    local okTime = self.song:getTimingStrictness("OK")
    local currentTime = self.song.currentTime
    local bestTime, bestDropTime = 3, 10
    local bestNote, bestDrop
    for i = currentSec-1, currentSec+5 do
        if self.notes[i] then
            for index, note in pairs(self.notes[i]) do
                local approachRate = note:getApproachRate()
                local noteTime = note:getTime()
                local timeToHit = noteTime - currentTime
                local relativePosition = timeToHit/approachRate

                local difference = math.abs(timeToHit)

                if note:getType() == "DROP" and timeToHit >= -okTime then
                    if difference < bestDropTime and not note:getUsed() then
                        bestDrop = note
                        bestDropTime = difference
                    end
                end

                if difference < bestTime then
                    bestTime = difference
                    bestNote = note
                end
            end
        end
    end

    -- bestDrop, bestDropTime are for only drops
    -- bestNote, bestTime are for all notes


    -- if the player moves on a valid move note
    if legalMovement and bestNote and bestNote:getType()=="MOVE" and math.abs(bestTime) <= okTime then
        bestNote:setCompleted(true)
        bestNote:setUsed(true)
    end

    if dropFrame and bestDrop and math.abs(bestDropTime) <= okTime and self.activePiece.dropDebounce <= 0 then
        --print(bestTime, bestNote:getFieldIndex())
        self.activePiece:fillNote(self.activeNote)
        print(bestDropTime)
        self.field.transparencyTracker[self.activeNote:getFieldIndex()] = 1
    elseif dropFrame and self.activePiece then
        self.activePiece.renderTileOffset = 0.5
        self.activePiece.dropDebounce = 0.3
    end

    if bestDrop then
        if self.activeNote and self.activeNote ~= bestDrop then
            self.activeNote:setActive(false)
        end

        if self.activeNote ~= bestDrop then
            self.activeNote = bestDrop
            bestDrop:setActive(true)
            -- set up the new piece, etc
            local carryDirection = self.activePiece and self.activePiece.direction or 1
            local carryLeft = self.activePiece and self.activePiece.leftHoldTime or 0
            local carryRight = self.activePiece and self.activePiece.rightHoldTime or 0
            self.activePiece = Classes.game_Piece.new(bestDrop:getPieceId(), bestDrop:getAltPieceId())
            self.activePiece.direction = leftHold and -1 or 1
            self.activePiece.leftHoldTime = carryLeft
            self.activePiece.rightHoldTime = carryRight
        end
    else -- not bestDrop
        self.activePiece = nil
    end


    
end

function Scene.prototype:draw()
    self.field.position = love.graphics.getWidth()/2
    self.field:draw(self.song.currentTime, self.activePiece)
end


local function sortNotes(song)
    local sorted = {}

    -- this loop fixes the coloration of all MOVE notes.
    -- it is written BADLY and should be fixed later
    local lastDrop = 1
    for i, note in ipairs(song.notes) do
        if note:getType()=="MOVE" then
            local j = i
            repeat
                j = j + 1
            until not song.notes[j] or song.notes[j]:getType() == "DROP"

            if song.notes[j] then
                note:setPieceId(song.notes[j]:getAltPieceId())
            end
        end
    end

    for _, note in ipairs(song.notes) do
        local sec = math.ceil(note[2])
        sorted[sec] = sorted[sec] or {}
        sorted[sec][#sorted[sec]+1] = note
    end

    return sorted
end

----- Asset loading bit
local loadedAssets = false
local function loadAssets()
    if not loadedAssets then
        loadedAssets = true
        -- load scene assets into memory (Scene.assets{})
    end
end


-- Constructor for game scene 
function Scene.new()
    local newScene = setmetatable({}, Scene)
    
    -- add the scene to the current list
    newScene.id = #Scene.activeScenes+1
    Scene.activeScenes[#Scene.activeScenes+1] = newScene


    -- load other stuff
    newScene.field = Classes.game_Field.new()
    newScene.song = Classes.game_Song.compile( love.filesystem.read("assets/design/exampleMap.chex") )

    newScene.notes = sortNotes(newScene.song)

    -- load related assets, if applicable
    loadAssets()

    return newScene
end

-- Draw method for the CLASS. Handles drawing for all active scenes.
function Scene.draw()
    for _, scene in pairs(Scene.activeScenes) do
        scene:draw()
    end  
end

-- Update method for the CLASS. Handles updates for all active scenes.
function Scene.update(dt)
    
    for _, scene in pairs(Scene.activeScenes) do
        scene:update(dt)
    end    
end

return Scene