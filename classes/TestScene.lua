local dimensions = _G.SIZE
local Scene Scene = {
    -- This is the prototype instance for an editor scene object.
    prototype = {
        --- instance vars
        id = 0,

        --- methods
        destroy = function(self)
            Scene.activeScenes[self.id] = nil
        end,

        draw = function(self)
            self.testSlider:draw()
            print(self.testSlider:getSelection())
        end,

        update = function(self, dt)
            self.testSlider:update(dt)
        end
    },

    activeScenes = {},
    assets = {}
}
Scene.__index = Scene.prototype


----- Asset loading bit
local loadedAssets = false
local function loadAssets()
    if loadedAssets then return end
    local asset = Asset
    loadedAssets = true
    for _, path in ipairs({
        "mainpath/slider_body.png",
        "mainpath/slider_cursor.png"
    }) do
        asset.loadImage(path)
    end
end


-- Constructor for editor scene objects
function Scene.new()
    local newScene = setmetatable({}, Scene)
    
    -- add the scene to the current list
    newScene.id = #Scene.activeScenes+1
    Scene.activeScenes[#Scene.activeScenes+1] = newScene

    -- load related assets, if applicable
    loadAssets()

    newScene.testSlider = Classes.gui_GuiElement.newSelectionSlider(Asset.image.slider_body, Asset.image.slider_cursor, {"Item1", "Item2", "Item3", "Item4"}, dimensions[1]/2, dimensions[2]/2, 400, 40, 0.5, 0.5)


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