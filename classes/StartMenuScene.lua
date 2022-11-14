local asset = Asset
local dimensions = _G.SIZE
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

        inTransition = false,
        transitionGoal = "",
        transitionTime = 0,
        transitionCells = {},



        --- methods
        destroy = function(self)
            Scene.activeScenes[self.id] = nil
        end,

        draw = function(self)
            local width, height = dimensions[1], dimensions[2]
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

                -- outside menu stuff
                draw(asset.image.main_menu_right_body_border, width/2+height/2, 0, 0, height*0.3, height, 0, 0)
                draw(asset.image.main_menu_left_body_border, width/2-height/2, 0, 0, height*0.3, height, 1, 0)

                -- draw the body of the menu
                draw(asset.image.main_menu_body, width/2, height/2, 0, height, height, 0.5, 0.5)
            gpop()

            -- draw the logo
            self.logo:draw(0.5, 0.7)
            
            -- menu buttons
            self.editButton:draw()
            self.startButton:draw()
            self.optionsButton:draw()

            gpush()
                setColor(0,0,0,1)
                for i, v in ipairs(self.transitionCells) do
                   love.graphics.rectangle("fill", width/10*i, height, -width/10, -v[2]) 
                end
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
                if self.transitionTime > 2 then
                    local oldScene = _G.activeScene
                    _G.activeScene = Classes[self.transitionGoal].new()
                    oldScene:destroy()
                end
            end

            local d = 20 / dt / 40
            self.bgScale = (self.bgScale * d + 1)/(d+1)
            if Mouse.clicked then 
                self.logo:pulse()
                self.bgScale = 1.025
            end

            local width, height = dimensions[1], dimensions[2]

            self.logo:update(dt)
            self.logo.pixelWidth = love.graphics.getHeight()*0.4
            self.logo.position.x = love.graphics.getWidth()/2
            self.logo.position.y = love.graphics.getHeight()*0.3

            -- update button locations
            if self.optionsButton:getHover() then
                self.optionsButton.goalSize = 1.1
                self.optionsButton.rotation = self.optionsButton.rotation + dt
            else
                self.optionsButton.goalSize = 1
            end
            self.optionsButton.currentSize = self.optionsButton:getClick() and 0.9 or self.optionsButton.currentSize
            self.optionsButton:update(dt)
            self.optionsButton.x = width/2+height*0.3
            self.optionsButton.y = height*0.6
            self.optionsButton.sx = height/5
            self.optionsButton.sy = height/5

            if self.startButton:getClick() and not self.inTransition then
                self.inTransition = true
                self.transitionGoal = "MapSelectScene"
            end
            self.startButton.goalSize = self.startButton:getHover() and 1.1 or 1
            self.startButton.currentSize = self.startButton:getClick() and 0.9 or self.startButton.currentSize
            self.startButton:update(dt)
            self.startButton.x = width/2
            self.startButton.y = height*0.6
            self.startButton.sx = height/5
            self.startButton.sy = height/5

            self.editButton.goalSize = self.editButton:getHover() and 1.1 or 1
            self.editButton.currentSize = self.editButton:getClick() and 0.9 or self.editButton.currentSize
            self.editButton:update(dt)
            self.editButton.x = width/2-height*0.3
            self.editButton.y = height*0.6
            self.editButton.sx = height/5
            self.editButton.sy = height/5
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
        "skinpath/main_menu/main_menu_body.png",
        "skinpath/main_menu/main_menu_default_background.png",
        "skinpath/main_menu/main_menu_right_body_border.png",
        "skinpath/main_menu/main_menu_left_body_border.png",
        "skinpath/main_menu/main_menu_button_overlay.png",
        "skinpath/main_menu/main_menu_play_button.png",
        "skinpath/main_menu/main_menu_play_button_background.png",
        "skinpath/main_menu/main_menu_edit_button_background.png",
        "skinpath/main_menu/main_menu_play_button_overlay.png",
        "skinpath/main_menu/main_menu_edit_button_overlay.png",
        "skinpath/main_menu/main_menu_settings_button.png",
        "skinpath/main_menu/main_menu_settings_button_background.png",
        "skinpath/main_menu/main_menu_editor_button.png",
        "skinpath/main_menu/main_menu_button_trail.png",

    }) do
        asset.loadImage(path)
    end
end

local customDraw = function(self)
    local width, height = dimensions[1], dimensions[2]
    love.graphics.push()
    setColor(1,1,1,1)
    drawText(self.text, self.x, self.y - math.abs(1-self.currentSize)*self.sy*7, 0, nil, self.sy*0.2, 0.5, 0.5, 0, 0, true)
    draw(asset.image.main_menu_button_trail, self.x, self.y + math.abs(1-self.currentSize)*self.sy*8.25, 0, self.sx*self.currentSize, self.sy*self.currentSize/2, self.ox, self.oy)    
    draw(self.image, self.x, self.y, 0, self.sx*self.currentSize, self.sy*self.currentSize, self.ox, self.oy)    
    draw(self.icon, self.x - (1-self.currentSize)*self.sy, self.y + (1-self.currentSize)*self.sy, (self.rotation or 0), self.sx*self.currentSize, self.sy*self.currentSize, self.ox, self.oy, nil, nil, true)
    draw(self.overlay, self.x, self.y, 0, self.sx*self.currentSize, self.sy*self.currentSize, self.ox, self.oy)
    love.graphics.pop()
end

-- Constructor for editor scene objects
function Scene.new()
    local newScene = setmetatable({}, Scene)
    
    -- add the scene to the current list
    newScene.id = #Scene.activeScenes+1
    Scene.activeScenes[#Scene.activeScenes+1] = newScene

    -- load related assets, if applicable
    loadAssets()

    newScene.startButton = Classes.gui_Button.new(asset.image.main_menu_play_button_background, 0, 0, 0, 0, 0.5, 0.5)
        --newScene.startButton.color = {.2,1,.2}
        newScene.startButton.draw = customDraw
        newScene.startButton.overlay = asset.image.main_menu_play_button_overlay
        newScene.startButton.icon = asset.image.main_menu_play_button
        newScene.startButton.text = "PLAY"
    newScene.editButton = Classes.gui_Button.new(asset.image.main_menu_edit_button_background, 0, 0, 0, 0, 0.5, 0.5)
        --newScene.editButton.color = {1,.75,0}
        newScene.editButton.draw = customDraw
        newScene.editButton.overlay = asset.image.main_menu_edit_button_overlay
        newScene.editButton.icon = asset.image.main_menu_editor_button
        newScene.editButton.text = "CREATE"
    newScene.optionsButton = Classes.gui_Button.new(asset.image.main_menu_settings_button_background, 0, 0, 0, 0, 0.5, 0.5)
        --newScene.optionsButton.color = {1, 0.4, 0.4}
        newScene.optionsButton.draw = customDraw
        newScene.optionsButton.overlay = asset.image.main_menu_button_overlay
        newScene.optionsButton.icon = asset.image.main_menu_settings_button
        newScene.optionsButton.rotation = 0
        newScene.optionsButton.text = "SETTINGS"
    newScene.logo = Classes.gui_Logo.new()

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