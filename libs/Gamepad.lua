local activeGamepad
local Gamepad = {
    
    buttonDown = setmetatable({},{
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

    leftAxis = {0, 0},
    rightAxis = {0, 0},

    __global = true
}

function Gamepad.update(dt)
    for key, _ in pairs(Gamepad.buttonDown) do
        Gamepad.timeDown[key] = Gamepad.timeDown[key] + dt
    end
    activeGamepad = activeGamepad or love.joystick.getJoysticks()[1]
    
    if not activeGamepad then return end


    Gamepad.leftAxis[1] = activeGamepad:getGamepadAxis("leftx")
    Gamepad.leftAxis[2] = activeGamepad:getGamepadAxis("lefty")

    Gamepad.rightAxis[1] = activeGamepad:getGamepadAxis("rightx")
    Gamepad.rightAxis[2] = activeGamepad:getGamepadAxis("righty")
end

function Gamepad.postUpdate(dt)
    for k, _ in pairs(Gamepad.justPressed) do
        Gamepad.justPressed[k] = nil
    end
end

function Gamepad.isDown(key)
    return Gamepad.buttonDown[key]
end

function love.gamepadpressed(joystick, button)
    Gamepad.justPressed[button] = true
    Gamepad.buttonDown[button] = true
    activeGamepad = joystick
end

function love.gamepadreleased(joystick, button)
    Gamepad.buttonDown[button] = nil
    Gamepad.timeDown[button] = nil
end

return Gamepad