-- hello :)
_G.Classes = {} local Classes = Classes
_G.Libs = {} local Libs = Libs

-- negative sx and sy values do default behavior; positive values are pixel measurements
-- ox and oy values between 0 and 1 will be treated as a ratio to image size (anchor point)
_G.drawImage = function(drawable, x, y, r, sx, sy, ox, oy, kx, ky, ignoreSnap)
    love.graphics.draw(
        drawable,
        ignoreSnap and x or math.floor(x), ignoreSnap and y or math.floor(y), r,
        sx and (sx < 0 and -sx or 1 / drawable:getWidth() * sx),
        sy and (sy < 0 and -sy or 1 / drawable:getHeight() * sy),
        ox and (ox <= 1 and drawable:getWidth() * ox or ox),
        oy and (oy <= 1 and drawable:getHeight() * oy or oy),
        kx, ky   
    )
end

---- test functions
function testLoad()
    testScene = Classes.GameScene.new()
    testLogo = Classes.gui_Logo.new()
end

function testDraw()

end

function testUpdate(dt)
    
end


function love.load()
    local classes = {
        "GameScene", "EditorScene",
        "editor/Field", "game/Field",
        "game/song",
        "gui/Logo",
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

    testDraw()
end


function love.update(dt)
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