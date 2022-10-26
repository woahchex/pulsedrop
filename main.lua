_G.Classes = {} local Classes = Classes
_G.Libs = {} local Libs = Libs

-- negative sx and sy values do default behavior; positive values are pixel measurements
-- ox and oy values between 0 and 1 will be treated as a ratio to image size (anchor point)
_G.drawImage = function(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
    love.graphics.draw(
        drawable,
        math.floor(x), math.floor(y), r,
        sx and (sx < 0 and -sx or 1 / drawable:getWidth() * sx),
        sy and (sy < 0 and -sy or 1 / drawable:getHeight() * sy),
        ox and (ox <= 1 and drawable:getWidth() * ox or ox),
        oy and (oy <= 1 and drawable:getHeight() * oy or oy),
        kx, ky   
    )
end

---- test functions
function testLoad()
    testScene = Classes.EditorScene.new()
    testLogo = Classes.gui_Logo.new()
end

function testDraw()
    testLogo:draw()
end

function testUpdate(dt)
    testLogo:update(dt)
    if Mouse.clicked then
        print("wow")
        testLogo:pulse()
    end
end


function love.load()
    local classes = {
        "GameScene", "EditorScene",
        "editor/Field",
        "gui/Logo",
    }
    local libs = {"Mouse", "Asset"}

    local formatName = nil
    for _, class in ipairs(classes) do
        formatName = class:gsub("/", "_")
        Classes[formatName] = require("classes/"..class)
        if Classes[formatName].__global then
            _G[formatName] = Classes[formatName]
        end
    end

    for _, lib in ipairs(libs) do
        formatName = lib:gsub("/", "_")
        Libs[formatName] = require("libs/" .. lib)
        if Libs[formatName].__global then
            _G[formatName] = Libs[formatName]
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