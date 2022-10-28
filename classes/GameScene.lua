local Scene Scene = {
    -- prototype instance for a game scene
    prototype = {
        --- instance vars
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

        draw = function(self)
            self.field.position = love.graphics.getWidth()/2
            self.field:draw(self.song.currentTime)

            
        end,

        update = function(self, dt)
            if self.song then
                self.song:update(dt)
            end

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
        end,

    },

    activeScenes = {},
    assets = {}
}
Scene.__index = Scene.prototype

local function sortNotes(song)
    local sorted = {}

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
    newScene.song = Classes.game_song.new() -- TEMP

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