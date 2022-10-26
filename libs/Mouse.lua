local Mouse = {
    x = 0, y = 0,               -- Mouse screen position. Constantly updates
    speed = 0,                  -- Mouse magnitude for a given frame. Constantly updates
    clicked = false,            -- Set to true for one frame each mouse click
    doubleClicked = false,      -- Set to true for one frame each double click
    dragging = true,            -- Returns true if the mouse is being held.
    dragStart = {x = 0, y = 0}, -- Last position the mouse clicked at
    dragTime = 0,

    __global = true
}


function Mouse.update(dt)
    local x, y = love.mouse.getPosition()
    Mouse.speed = math.sqrt((Mouse.x - x)^2 + (Mouse.y - y)^2)
    Mouse.x = x
    Mouse.y = y
end


function Mouse.postUpdate(dt)
    Mouse.clicked = false
    Mouse.doubleClicked = false

    Mouse.dragging = love.mouse.isDown(1)
    if Mouse.dragging then
        Mouse.dragTime = Mouse.dragTime + dt
    else
        Mouse.dragTime = 0
    end
end


function Mouse.draw()
    
end


function love.mousepressed(x, y, button, istouch, presses)
    Mouse.clicked = true
    Mouse.clickButton = button
    Mouse.x = x
    Mouse.y = y
    Mouse.dragStart.x = x
    Mouse.dragStart.y = y
    Mouse.isTouchInput = istouch
    Mouse.doubleClicked = presses == 2
end


return Mouse