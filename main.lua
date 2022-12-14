-- hello :)

--love.graphics.setDefaultFilter( "linear", "linear", 1 )

_G.Classes = {} local Classes = Classes
_G.Libs = {} local Libs = Libs
_G.SIZE = {love.graphics.getDimensions()}

local fps = 0
local FRAMELIMIT = 144
local frameTime = 0

require("assets.design.HelperFunctions")

_G.activeScene = 0
---- test functions
function testLoad()
    _G.activeScene = Classes.StartMenuScene.new()
end


function testDraw()

end

function testUpdate(dt)

end


function love.load()
    local classes = {
        "GameScene", "TestScene", "StartMenuScene", "MapSelectScene",
        "editor/Field", "game/Field",
        "game/Note", "game/Piece",
        "game/Song",
        "gui/GuiElement", "gui/Logo", "gui/Particle"
    }
    local libs = {"IO", "Mouse", "Keyboard", "Gamepad", "Source2", "Settings", "Asset", "Tetris"}


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

    IO.init(); Settings.init();
    Asset.loadFont("skinpath/editor_font.ttf")

    testLoad()
end


--------- the following functions should be complete

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
        frameTime = frameTime + dt
        
		if frameTime >= 1/FRAMELIMIT and love.graphics and love.graphics.isActive() then
            frameTime = frameTime - 1/FRAMELIMIT
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			love.graphics.present()
		end

        if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

        local settings = Settings or {data={}}

		if love.timer then love.timer.sleep(settings.data.isFocused and 1/1000 or 1/30) end
	end
end



function love.draw()
    _G.SIZE[1], _G.SIZE[2] = love.graphics.getDimensions()

    if _G.SIZE[1] < _G.SIZE[2] then
        love.window.setMode(_G.SIZE[2], _G.SIZE[2], {resizable=true})
    end

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

    -- settings stuff
    Settings.sDraw()

    -- debug info
    love.graphics.push()
    love.graphics.setColor(1,1,1,.5)
    fps = love.timer.getFPS()
    drawText("" .. tostring(math.floor(collectgarbage('count'))) .. "kB | " .. math.floor(fps+0.5).." FPS", love.graphics.getWidth()-10, love.graphics.getHeight(), 0, nil, 16, 1, 1)
    love.graphics.pop()

    testDraw()
end


function love.update(dt)
    fps = 1/dt
    if dt > .5 then return end
    dt = dt * 5
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
    Settings.sUpdate(dt)

    testUpdate(dt)

    -- for updates that reset frame-by-frame events
    for _, postUpdateFunc in pairs(postUpdateList) do
        postUpdateFunc(dt)
    end

    
end

function love.focus( focus )
    if Settings then
        Settings.data.isFocused = focus
    end
end