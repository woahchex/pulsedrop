local Keyboard = {
    
    keyDown = setmetatable({},{
        __index = function() 
            return false 
        end
    }),

    justPressed = setmetatable({},{
        __index = function() 
            return false 
        end
    }),

    timeDown = setmetatable({},{
        __index = function() 
            return 0 
        end
    }),

    __global = true
}

function Keyboard.update(dt)
    for key, _ in pairs(Keyboard.keyDown) do
        Keyboard.timeDown[key] = Keyboard.timeDown[key] + dt
    end
end

function Keyboard.postUpdate(dt)
    for k, _ in pairs(Keyboard.justPressed) do
        Keyboard.justPressed[k] = nil
    end
end

function Keyboard.isDown(key)
    return Keyboard.keyDown[key]
end

function love.keypressed(key, scanCode, isRepeat)
    Keyboard.justPressed[key] = true
    Keyboard.keyDown[key] = true
end

function love.keyreleased(key, scanCode, isRepeat)
    Keyboard.keyDown[key] = nil
    Keyboard.timeDown[key] = nil
end

return Keyboard