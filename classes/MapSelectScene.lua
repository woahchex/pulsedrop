local asset = Asset
local draw, gprint = drawImage, drawText
local gpush, gpop, setColor = love.graphics.push, love.graphics.pop, love.graphics.setColor
local Scene Scene = {
    -- This is the prototype instance for a scene object.
    prototype = {
        --- instance vars
        id = 0,
        logo = nil,
        startButton = nil,
        bgScale = 1,

        loadingIn = true,
        loadingTransitionPos = 1,
        loadingTransitionSpeed = 2,
        inTransition = false,
        transitionGoal = "",
        transitionTime = 0,
        transitionCells = {},

        --- methods
        destroy = function(self)
            Scene.activeScenes[self.id] = nil
        end,

        draw = function(self)
            local width, height = love.graphics.getDimensions()
            gpush()
                love.graphics.setColor(1,1,1,1)
                -- first, draw the background image
                local iWidth, iHeight = asset.image.main_menu_default_background:getDimensions()
                local iRatio = iWidth/iHeight

                local scaleByWidth = false
                if iRatio < width/height then
                    scaleByWidth = true
                end
                draw(asset.image.main_menu_default_background, width/2, height/2, 0, (scaleByWidth and width or height*iRatio)*self.bgScale, (scaleByWidth and width/iRatio or height)*self.bgScale, 0.5, 0.5)
                
                -- draw the menu background stuff
                draw(asset.image.map_select_right_decoration, width/2+height/10, 0, 0, height*.2, height)
                draw(asset.image.map_select_difficulty_wheel, width/2+height/10, height*.3, 0, height/5, height/5, 0.5, 0.5)
                draw(asset.image.map_select_info_panel, width/2+height/10, height, 0, height*.4, height*.4, 0, 1)
                draw(asset.image.map_select_scroll_background, width/2-height/2, 0, 0, height*.6, height)
                draw(asset.image.map_select_filter_box, width/2-height/2, 0, 0, height*.6, height*.2)
                
            gpop()    

            gpush()
                setColor(0,0,0,1)
                for i, v in ipairs(self.transitionCells) do
                   love.graphics.rectangle("fill", width/10*i, height, -width/10, -v[2]) 
                end

                love.graphics.rectangle("fill", 0, 0, width, height*self.loadingTransitionPos)
            gpop()
        end,

        update = function(self, dt)
            if self.inTransition then
                self.transitionTime = self.transitionTime + dt
                for i, v in ipairs(self.transitionCells) do
                    if self.transitionTime >= i/15 then
                        v[1] = v[1] + dt*16
                        v[2] = v[2] + v[1] * love.graphics.getHeight() / 600
                    end
                end
            end

            if self.loadingIn then
                self.loadingTransitionPos = self.loadingTransitionPos - self.loadingTransitionSpeed * dt
                self.loadingTransitionSpeed = self.loadingTransitionSpeed - 2*dt

                if self.loadingTransitionPos <= 0 then
                    self.loadingIn = false
                end
            end
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
        "skinpath/main_menu/main_menu_default_background.png",
        "skinpath/map_select/map_select_scroll_background.png",
        "skinpath/map_select/map_select_filter_box.png",
        "skinpath/map_select/map_select_difficulty_wheel.png",
        "skinpath/map_select/map_select_right_decoration.png",
        "skinpath/map_select/map_select_info_panel.png",
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

    newScene.transitionCells = {{0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}}

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