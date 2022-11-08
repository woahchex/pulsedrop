-- hello :)

math.randomseed(os.time())

_G.Classes = {} local Classes = Classes
_G.Libs = {} local Libs = Libs

-- negative sx and sy values do default behavior; positive values are pixel measurements
-- ox and oy values between 0 and 1 will be treated as a ratio to image size (anchor point)
_G.drawImage = function(drawable, x, y, r, sx, sy, ox, oy, kx, ky, ignoreSnap)
    love.graphics.draw(
        drawable,
        ignoreSnap and (x or 0) or math.floor(x or 0), ignoreSnap and (y or 0) or math.floor(y or 0), r,
        sx and (sx < 0 and -sx or 1 / drawable:getWidth() * sx),
        sy and (sy < 0 and -sy or 1 / drawable:getHeight() * sy),
        ox and (ox <= 1 and drawable:getWidth() * ox or ox),
        oy and (oy <= 1 and drawable:getHeight() * oy or oy),
        kx, ky   
    )
end

_G.drawText = function(text, x, y, r, sx, sy, ox, oy, kx, ky, ignoreSnap)
    if sx and not sy then
        sy = sx / (Libs.Asset.currentFont:getWidth(text)/Libs.Asset.currentFont:getHeight())
    elseif sy and not sx then
        sx = sy * (Libs.Asset.currentFont:getWidth(text)/Libs.Asset.currentFont:getHeight())
    end
    love.graphics.print(
        text,
        ignoreSnap and (x or 0) or math.floor(x or 0), ignoreSnap and (y or 0) or math.floor(y or 0), r,
        sx and (sx < 0 and -sx or 1 / Libs.Asset.currentFont:getWidth(text) * sx),
        sy and (sy < 0 and -sy or 1 / Libs.Asset.currentFont:getHeight() * sy),
        ox and (ox <= 1 and Libs.Asset.currentFont:getWidth(text) * ox or ox),
        oy and (oy <= 1 and Libs.Asset.currentFont:getHeight() * oy or oy),
        kx, ky   
    )    
end

function _G.drawStuff()
    return love.graphics.push,
           love.graphics.pop,
           drawImage,
           love.graphics.setColor,
           drawText
end
_G.activeScene = 0
---- test functions
function testLoad()
    _G.activeScene = Classes.StartMenuScene.new()
    testLogo = Classes.gui_Logo.new()
end

function testDraw()

end

function testUpdate(dt)
    
end


function love.load()
    local classes = {
        "GameScene", "EditorScene", "StartMenuScene", "MapSelectScene",
        "editor/Field", "game/Field",
        "game/Note", "game/Piece",
        "game/Song",
        "gui/Logo", "gui/Button",
    }
    local libs = {"Mouse", "Keyboard", "Gamepad", "Asset", "Tetris"}


    for _, lib in ipairs(libs) do
        formatName = lib:gsub("/", "_")
        Libs[formatName] = require("libs/" .. lib)
        if Libs[formatName].__global then
            _G[formatName] = Libs[formatName]
        end
    end

    local formatName = nil
    for _, class in ipairs(classes) do
        formatName = class:gsub("/", "_")
        Classes[formatName] = require("classes/"..class)
        if Classes[formatName].__global then
            _G[formatName] = Classes[formatName]
        end
    end

    Asset.loadFont("skinpath/font.ttf")

    testLoad()
end


--------- the following functions should be complete

function love.draw()
    -- Make sure every class which has a draw function draws
        for name, lib in pairs(Libs) do
            if lib.draw then
                lib.draw()
            end
        end

        for name, class in pairs(Classes) do
        if class.draw then
            class.draw()
        end
    end

    -- debug info
    love.graphics.push()
    love.graphics.setColor(1,1,1,.5)
    drawText("Pulse Drop debug version", love.graphics.getWidth()-10, love.graphics.getHeight(), 0, nil, 16, 1, 1)
    love.graphics.pop()

    testDraw()
end


function love.update(dt)
    if dt > .5 then return end
    --dt=dt*500
    local postUpdateList = {}
    -- Make sure every class which has an update function updates
    for name, lib in pairs(Libs) do
        if lib.update then
            lib.update(dt)
        end
        if lib.postUpdate then
            postUpdateList[#postUpdateList+1] = lib.postUpdate
        end
    end

    for name, class in pairs(Classes) do
        if class.update then
            class.update(dt)
        end
    end

    testUpdate(dt)

    -- for updates that reset frame-by-frame events
    for _, postUpdateFunc in pairs(postUpdateList) do
        postUpdateFunc(dt)
    end

end