local dimensions = _G.SIZE
local Settings = {
    xPosition = 0,
    xGoal = 0,
    scrollPosition = 0,
    scrollGoal = 0,
    scrollSpeed = 0.15,
    scrollHeight = 0.8,
    active = false,
    justOpened = false,

    buttons = { -- set in .init()
        exit = false, 
    },
    
    graphics = {
        backgroundTiles = {},
        backgroundCanvas = love.graphics.newCanvas(960, 1080),
        backgroundTileRate = 0.6,
        backgroundTileProgress = 0,
        currentTilePos = 0,
        tileFrequency = 10,
    },

    data = {
        isFullscreen = false,

        masterVolume = 0.5,
        musicVolume = 1,
        sfxVolume = 1,

        oldWindowSize = {0,0}
    },
    __global = true
}

function Settings.init()
    Asset.loadImage("mainpath/settings/settings_background.png")
    Asset.loadImage("mainpath/settings/settings_exit_button.png")
    Asset.loadImage("mainpath/settings/settings_checkbox.png")
    Asset.loadImage("mainpath/settings/settings_checkbox_selected.png")
    Asset.loadImage("mainpath/settings/settings_container.png")
    Asset.loadImage("mainpath/settings/settings_slider.png")

    Settings.buttons.exit = Classes.gui_GuiElement.newButton(Asset.image.settings_exit_button, 0, 0, 0, 0, .5, .5, nil)

    Settings.buttons.audioSettings = Classes.gui_GuiElement.newContainer(Asset.image.settings_container, 0, 0, 0, 0, 0, 0)
        Settings.buttons.audioSettings.elements.masterSound = Classes.gui_GuiElement.newSlider(Asset.image.settings_slider, Asset.image.settings_checkbox_selected, 0, 0, 0, 0, 0, 0)
        Settings.buttons.audioSettings.elements.masterSound.trText = "100"
        Settings.buttons.audioSettings.elements.masterSound.lText = "MASTER"
        Settings.buttons.audioSettings.elements.masterSound.tlText = "0"
        Settings.buttons.audioSettings.elements.masterSound.cursorPosition = Settings.data.masterVolume

        Settings.buttons.audioSettings.elements.musicSound = Classes.gui_GuiElement.newSlider(Asset.image.settings_slider, Asset.image.settings_checkbox_selected, 0, 0, 0, 0, 0, 0)
        Settings.buttons.audioSettings.elements.musicSound.trText = "100"
        Settings.buttons.audioSettings.elements.musicSound.lText = "MUSIC"
        Settings.buttons.audioSettings.elements.musicSound.tlText = "0"
        Settings.buttons.audioSettings.elements.musicSound.cursorPosition = Settings.data.musicVolume

        Settings.buttons.audioSettings.elements.sfxSound = Classes.gui_GuiElement.newSlider(Asset.image.settings_slider, Asset.image.settings_checkbox_selected, 0, 0, 0, 0, 0, 0)
        Settings.buttons.audioSettings.elements.sfxSound.trText = "100"
        Settings.buttons.audioSettings.elements.sfxSound.lText = "EFFECTS"
        Settings.buttons.audioSettings.elements.sfxSound.tlText = "0"
        Settings.buttons.audioSettings.elements.sfxSound.cursorPosition = Settings.data.sfxVolume

    
    Settings.buttons.graphicsSettings = Classes.gui_GuiElement.newContainer(Asset.image.settings_container, 0, 0, 0, 0, 0, 0)
        Settings.buttons.graphicsSettings.elements.fullscreen = Classes.gui_GuiElement.newSelectionBox(Asset.image.empty, Asset.image.settings_checkbox, Asset.image.settings_checkbox_selected, {"Fullscreen"}, dimensions[1]/1.25, dimensions[2]/1.25, dimensions[1]/10, dimensions[2]/10, 1, 1, 0.5, 0.5, nil, true)
        Settings.buttons.graphicsSettings.elements.fullscreen.align = "RIGHT"
        Settings.buttons.graphicsSettings.elements.fullscreen.textScale = 0.75
        Settings.buttons.graphicsSettings.elements.fullscreen.multiSelect = true


    for _, element in pairs(Settings.buttons) do
        element.isSetting = true
        if element.elements then
            for _, e2 in pairs(element.elements) do
                e2.isSetting = true
            end
        end
    end
end

function Settings.toggle(state)
    Settings.active = state or not Settings.active
    Settings.xGoal = Settings.active and 1 or 0
    Classes.gui_GuiElement.activeTextbox = nil
end

local gpush, gpop, draw, setColor, gprint = _G.drawStuff()
function Settings.sDraw()
    if Settings.xPosition > 0.01 then
        setColor(0,0,0,Settings.xPosition*0.6)
        love.graphics.rectangle("fill", 0, 0, dimensions[1], dimensions[2])
        setColor(1,1,1,1)

        local width, height = dimensions[2]/9*16, dimensions[2]
        local xOfs = -width*(1-Settings.xPosition)
        local yOfs = -height * Settings.scrollPosition

        Settings.buttons.exit.x = height*0.084 + xOfs
        Settings.buttons.exit.y = height*0.084 + yOfs
        Settings.buttons.exit.sx = height*0.1
        Settings.buttons.exit.sy = Settings.buttons.exit.sx

        Settings.buttons.audioSettings.x = height*0.1 + xOfs
        Settings.buttons.audioSettings.y = height*0.284 + yOfs
        Settings.buttons.audioSettings.sx = height*0.7
        Settings.buttons.audioSettings.sy = height*0.4

            Settings.buttons.audioSettings.elements.masterSound.x = height*0.235 + xOfs
            Settings.buttons.audioSettings.elements.masterSound.y = height*0.35 + yOfs
            Settings.buttons.audioSettings.elements.masterSound.sx = height * 0.55
            Settings.buttons.audioSettings.elements.masterSound.sy = height * 0.05
            Settings.buttons.audioSettings.elements.masterSound.padding = height * 0.025
            Settings.buttons.audioSettings.elements.masterSound.tText = tostring(math.floor(Settings.buttons.audioSettings.elements.masterSound.cursorPosition * 100))
            
            Settings.buttons.audioSettings.elements.musicSound.x = height*0.235 + xOfs
            Settings.buttons.audioSettings.elements.musicSound.y = height*0.475 + yOfs
            Settings.buttons.audioSettings.elements.musicSound.sx = height * 0.55
            Settings.buttons.audioSettings.elements.musicSound.sy = height * 0.05
            Settings.buttons.audioSettings.elements.musicSound.padding = height * 0.025
            Settings.buttons.audioSettings.elements.musicSound.tText = tostring(math.floor(Settings.buttons.audioSettings.elements.musicSound.cursorPosition * 100))

            Settings.buttons.audioSettings.elements.sfxSound.x = height*0.235 + xOfs
            Settings.buttons.audioSettings.elements.sfxSound.y = height*0.6 + yOfs
            Settings.buttons.audioSettings.elements.sfxSound.sx = height * 0.55
            Settings.buttons.audioSettings.elements.sfxSound.sy = height * 0.05
            Settings.buttons.audioSettings.elements.sfxSound.padding = height * 0.025
            Settings.buttons.audioSettings.elements.sfxSound.tText = tostring(math.floor(Settings.buttons.audioSettings.elements.sfxSound.cursorPosition * 100))

        Settings.buttons.graphicsSettings.x = height*0.1 + xOfs
        Settings.buttons.graphicsSettings.y = height*0.8 + yOfs
        Settings.buttons.graphicsSettings.sx = height*0.7
        Settings.buttons.graphicsSettings.sy = height*0.5

            Settings.buttons.graphicsSettings.elements.fullscreen.x = height*0.175 + xOfs
            Settings.buttons.graphicsSettings.elements.fullscreen.y = height*0.875 + yOfs
            Settings.buttons.graphicsSettings.elements.fullscreen.checkScale = height*0.05

        


        -- draw the background canvas
        love.graphics.setCanvas(Settings.graphics.backgroundCanvas)
        love.graphics.clear(29/255,19/255,64/255)
        love.graphics.setColor(58/255,41/255,112/255)
        local csx, csy = Settings.graphics.backgroundCanvas:getDimensions()
        for _, tile in pairs(Settings.graphics.backgroundTiles) do

            local px, py, d  = csx * tile[1], csy * tile[2] - Settings.scrollPosition/Settings.scrollHeight*500, csy / 10 * tile[3]
            love.graphics.polygon("fill", {px - d, py, px, py + d, px + d, py, px, py - d})
        end
        love.graphics.setCanvas()

        gpush()
            setColor(1,1,1,1)
            
            
            draw(Settings.graphics.backgroundCanvas, dimensions[2]/9*8 * Settings.xPosition, 0, 0, width/2, height, 1, 0)

            draw(Asset.image.settings_background, dimensions[2]/9*8 * Settings.xPosition, 0, 0, width, height, 1, 0)
            
            gprint("SETTINGS", height*0.8 + xOfs, height*0.05 + yOfs, 0, nil, height*0.075, 1, 0)
            gprint("EXIT", height*0.135 + xOfs, height*0.084 + yOfs, 0, nil, height*0.05, 0, 0.5)

            gprint("AUDIO", height*0.075 + xOfs, height*0.225 + yOfs, 0, nil, height*0.05, 0, 0.5)
            gprint("GRAPHICS", height*0.075 + xOfs, height*0.75 + yOfs, 0, nil, height*0.05, 0, 0.5)


            for _, button in pairs(Settings.buttons) do
                button:draw(true)
            end
        gpop()
    end
end

local mouse, keyboard = Mouse, Keyboard
function Settings.sUpdate(dt)
    -- shortcut to toggle options (bad place? dunno, too tired to check)
    if (keyboard.isDown("lctrl") and keyboard.justPressed["o"]) or (keyboard.justPressed["escape"] and Settings.active) then
        Settings.toggle()
        
    end
    
    local dampening = 4/dt/40 -- used for tweens
    Settings.xPosition = (Settings.xPosition * dampening + Settings.xGoal)/(dampening+1)
    Settings.scrollPosition = (Settings.scrollPosition * dampening + Settings.scrollGoal)/(dampening+1)

    if Settings.active then
        -- Scrolling
        if math.abs(mouse.scrollDirection) > 0 and mouse.x <= dimensions[2]/9*8 then
            if mouse.x <= dimensions[2]/9*8 then
                Settings.scrollGoal = math.clamp(Settings.scrollGoal + Settings.scrollSpeed * mouse.scrollDirection, 0, Settings.scrollHeight)
            end
        end

        -- update background canvas
        Settings.graphics.backgroundTileProgress = Settings.graphics.backgroundTileProgress + dt
        if Settings.graphics.backgroundTileProgress >= Settings.graphics.backgroundTileRate then
            Settings.graphics.backgroundTileProgress = Settings.graphics.backgroundTileProgress - Settings.graphics.backgroundTileRate
            Settings.graphics.backgroundTiles[#Settings.graphics.backgroundTiles+1] = {Settings.graphics.currentTilePos/Settings.graphics.tileFrequency, 1, 0, 1}
            Settings.graphics.currentTilePos = (Settings.graphics.currentTilePos + 3) % (Settings.graphics.tileFrequency+1)
        end
        for i, tile in pairs(Settings.graphics.backgroundTiles) do
            tile[3] = tile[3] + tile[4] * dt
            tile[4] = tile[4] - 0.2 * dt
            if tile[3]<0 then
                Settings.graphics.backgroundTiles[i] = nil
            end
        end

        for _, button in pairs(Settings.buttons) do
            button:update(dt)
        end
        
        -- update buttons,
        Settings.buttons.exit.goalSize = Settings.buttons.exit:getHover() and 1.2 or 1
        if Settings.buttons.exit:getClick() or ((mouse.clicked and mouse.x > dimensions[2]/9*8) and not Settings.justOpened) then
            Settings.buttons.exit.currentSize = 0.8
            Settings.toggle(false)
        end
        Settings.justOpened = false


        
        
        
        Settings.data.masterVolume = Settings.buttons.audioSettings.elements.masterSound.cursorPosition
        Settings.data.musicVolume = Settings.buttons.audioSettings.elements.musicSound.cursorPosition
        Settings.data.sfxVolume = Settings.buttons.audioSettings.elements.sfxSound.cursorPosition
    end

    -- update window if needed
    if (Settings.buttons.graphicsSettings.elements.fullscreen:getSelection() and true) ~= Settings.data.isFullscreen then
        if Settings.data.isFullscreen == false then
            Settings.data.oldWindowSize = {love.graphics.getDimensions()}
        end
        Settings.data.isFullscreen = Settings.buttons.graphicsSettings.elements.fullscreen:getSelection() and true or false
        local wx, wy, display = love.window.getPosition()
        local dsx, dsy = love.window.getDesktopDimensions(display)
        love.window.setMode( Settings.data.oldWindowSize[1], Settings.data.oldWindowSize[1], {fullscreen = Settings.data.isFullscreen, resizable = true, display = display, vsync = false})
    end

    if keyboard.justPressed["f11"] then
        Settings.buttons.graphicsSettings.elements.fullscreen.selectedBoxes = Settings.data.isFullscreen and {} or {1}
    end
end

return Settings