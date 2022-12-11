local dimensions = _G.SIZE
local Settings = {
    xPosition = 0,
    xGoal = 0,
    scrollPosition = 0,
    scrollGoal = 0,
    scrollSpeed = 0.15,
    scrollHeight = 2,
    active = false,

    buttons = { -- set in .init()
        exit = false, 
    },
    
    graphics = {
        backgroundTiles = {{0, 1, 0, 1},{1/5, 1, 0, 1},{2/5,1,0,1},{3/5,1,0,1},{4/5,1,0,1},{1,1,0,1}},
        backgroundCanvas = love.graphics.newCanvas(960, 1080),
        backgroundTileRate = 0.3,
        backgroundTileProgress = 0
    },

    __global = true
}

function Settings.init()
    Asset.loadImage("mainpath/settings/settings_background.png")
    Asset.loadImage("mainpath/settings/settings_exit_button.png")

    Settings.buttons.exit = Classes.gui_GuiElement.newButton(Asset.image.settings_exit_button, 0, 0, 0, 0, .5, .5, nil)
    Settings.buttons.exit.isSetting = true
end

function Settings.toggle(state)
    Settings.active = state or not Settings.active
    Settings.xGoal = Settings.active and 1 or 0
    Classes.gui_GuiElement.activeTextbox = nil
end

local gpush, gpop, draw, setColor, gprint = _G.drawStuff()
function Settings.sDraw()
    if Settings.xPosition > 0.01 then
        local width, height = dimensions[2]/9*16, dimensions[2]
        local xOfs = -width*(1-Settings.xPosition)
        local yOfs = -height * Settings.scrollPosition

        Settings.buttons.exit.x = height*0.084 + xOfs
        Settings.buttons.exit.y = height*0.084 + yOfs
        Settings.buttons.exit.sx = height*0.1
        Settings.buttons.exit.sy = Settings.buttons.exit.sx

        
        -- draw the background canvas
        love.graphics.setCanvas(Settings.graphics.backgroundCanvas)
        love.graphics.clear(29/255,19/255,64/255)
        love.graphics.setColor(58/255,41/255,112/255)
        local csx, csy = Settings.graphics.backgroundCanvas:getDimensions()
        for _, tile in pairs(Settings.graphics.backgroundTiles) do

            local px, py, d  = csx * tile[1], csy * tile[2] - Settings.scrollPosition/Settings.scrollHeight*300, csy / 10 * tile[3]
            love.graphics.polygon("fill", {px - d, py, px, py + d, px + d, py, px, py - d})
        end
        love.graphics.setCanvas()

        gpush()
            setColor(1,1,1,1)
            
            
            draw(Settings.graphics.backgroundCanvas, dimensions[2]/9*8 * Settings.xPosition, 0, 0, width/2, height, 1, 0)

            draw(Asset.image.settings_background, dimensions[2]/9*8 * Settings.xPosition, 0, 0, width, height, 1, 0)
            
            gprint("SETTINGS", height*0.8 + xOfs, height*0.05 + yOfs, 0, nil, height*0.075, 1, 0)
            gprint("EXIT", height*0.135 + xOfs, height*0.084 + yOfs, 0, nil, height*0.05, 0, 0.5)
        
            for _, button in pairs(Settings.buttons) do
                button:draw()
            end
        gpop()
    end
end

local mouse, keyboard = Mouse, Keyboard
function Settings.update(dt)
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
            Settings.graphics.backgroundTiles[#Settings.graphics.backgroundTiles+1] = {math.random(0,10)/10, 1, 0, 1}
        end
        for i, tile in pairs(Settings.graphics.backgroundTiles) do
            tile[2] = tile[2] - 0.025 * dt
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
        if Settings.buttons.exit:getClick() then
            Settings.buttons.exit.currentSize = 0.8
            Settings.toggle(false)
        end
    end
end

return Settings