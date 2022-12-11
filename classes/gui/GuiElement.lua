local mouse = Mouse
local dimensions = _G.SIZE

----------------- GuiElement ------------------
local GuiElement = {
    elements = {},

    activeTextbox = nil,

    __global = true
}


function GuiElement.newCharacter( t )
    if GuiElement.activeTextbox then
        GuiElement.activeTextbox:newCharacter( t )
    end
end

-- prototype GuiElement
GuiElement.__index = {
    x = 0, y = 0;
    sx = 0, sy = 0;
    ox = 0, oy = 0;
    image = nil,
    color = {1, 1, 1, 1}
}

-- instance methods
function GuiElement.__index:getHover()
    local mx, my = mouse.getPosition()
    local tx, ty = self.x - (self.sx * self.ox), self.y - (self.sy * self.oy)
    local bx, by = tx + self.sx, ty + self.sy
    return mx >= tx and my >= ty and mx <= bx and my <= by and (not (Settings.active and mx <= dimensions[2]/9*8) or self.isSetting)
end

function GuiElement.__index:getClick()
    return mouse.clicked and self:getHover() 
end

local gpush, gpop, draw, setColor, gprint = drawStuff()
function GuiElement.__index:draw()
    local width, height = dimensions[1], dimensions[2]
    gpush()
        setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 1)
        draw(self.image, self.x, self.y, 0, self.sx*self.currentSize, self.sy*self.currentSize, self.ox, self.oy)
    gpop()
end

function GuiElement.__index:update(dt)
    -- pass
end

function GuiElement.new(image, x, y, sx, sy, ox, oy, color)
    local newElement = setmetatable({
        image = image, color = color;
        x = x, y = y;
        sx = sx, sy = sy;
        ox = ox, oy = oy;
    }, GuiElement)
    
    return newElement
end

----------------- Container -------------------
GuiElement.elements.Container = {
    __index = setmetatable({
        elements = {},
        onScreen = true
    }, GuiElement)
}
local Container = GuiElement.elements.Container

-- instance methods
function Container.__index:update(dt)
    if self.onScreen then
        for _, element in ipairs(self.elements) do
            element:update(dt)
        end       
    end
end

local clamp = math.clamp
function Container.__index:draw()
    local width, height = dimensions[1], dimensions[2]
    
    -- calculate if the body is onscreen
    local tlx, tly = self.x - self.sx * self.ox, self.y - self.sy * self.oy
    local brx, bry = self.x + self.sx * (1-self.ox), self.y + self.sy * (1-self.oy)
    self.onScreen = (clamp(tlx, 0, width) == tlx and clamp(tly, 0, height) == tly) or (clamp(brx, 0, width) == brx and clamp(bry, 0, height) == bry)

    if self.onScreen then
        print("RENDERING")

        gpush()
            setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 1)
            draw(self.image, self.x, self.y, 0, self.sx, self.sy, self.ox, self.oy)
        gpop()
        for _, element in ipairs(self.elements) do
            element:draw()
        end
    end
end

function Container.__index:addElement( e )
    self.elements[#self.elements+1] = e
end

function GuiElement.newContainer(image, x, y, sx, sy, ox, oy, color)
    local newContainer = setmetatable({
        image = image, color = color;
        x = x, y = y;
        sx = sx, sy = sy;
        ox = ox, oy = oy;
        elements = {}
    }, GuiElement.elements.Container)

    return newContainer
end

----------------- Button -------------------
GuiElement.elements.Button = {
    __index = setmetatable({
        dampening = 2,
        currentSize = 1; goalSize = 1
    }, GuiElement)
}
local Button = GuiElement.elements.Button

-- instance methods
function Button.__index:update(dt)
    local dampening = self.dampening / dt / 40
    self.currentSize = (self.currentSize * dampening + self.goalSize)/(dampening+1)
end

function GuiElement.newButton(image, x, y, sx, sy, ox, oy, color)
    local newButton = setmetatable({
        image = image, color = color;
        x = x, y = y;
        sx = sx, sy = sy;
        ox = ox, oy = oy
    }, GuiElement.elements.Button)

    return newButton
end


----------------- 0-1 Slider --------------------
GuiElement.elements.Slider = {
    __index = setmetatable({
        cursorPosition = 0.5, -- 0.0 - 1.0
        padding = 15,       -- pixels,
        selected = false,
        tlText = "TLEFT", tText = "TOP", trText = "TRIGHT";
        blText = "BLEFT", bText = "BOTTOM", brText = "BRIGHT";

        cursor = nil        
    }, GuiElement)
}
local Slider = GuiElement.elements.Slider

-- instance methods
function Slider.__index:update(dt)
    if mouse.dragging then
        if self:getClick() then
            self.selected = true
        end
    else
        self.selected = false
    end

    if self.selected then
        local minPos = self.x + self.padding - self.sx*self.ox
        local maxPos = self.x + self.sx - self.padding - self.sx*self.ox

        local ratio = (mouse.x - minPos) / (maxPos - minPos)

        self.cursorPosition = math.clamp(ratio, 0, 1)
    end
end

function Slider.__index:draw()
    local width, height = dimensions[1], dimensions[2]
    local ofsX, ofsY = self.ox*self.sx, self.oy*self.sy
    gpush()
        setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 1)
        draw(self.image, self.x, self.y, 0, self.sx, self.sy, self.ox, self.oy)
        draw(self.cursor, self.x + self.padding + (self.sx - self.padding*2)*self.cursorPosition - ofsX, self.y+self.sy/2 - ofsY, 0, self.sy, self.sy, 0.5,0.5)
        
        gprint(self.tlText, self.x - ofsX, self.y - ofsY, 0, nil, self.sy/2, 0, 1)
        gprint(self.trText, self.x + self.sx - ofsX, self.y - ofsY, 0, nil, self.sy/2, 1, 1)
        gprint(self.tText, self.x + self.sx/2 - ofsX, self.y - ofsY, 0, nil, self.sy/2, 0.5, 1)
        gprint(self.blText, self.x - ofsX, self.y + self.sy - ofsY, 0, nil, self.sy/2, 0, 0)
        gprint(self.brText, self.x + self.sx - ofsX, self.y + self.sy - ofsY, 0, nil, self.sy/2, 1, 0)
        gprint(self.bText, self.x + self.sx/2 - ofsX, self.y + self.sy - ofsY, 0, nil, self.sy/2, 0.5, 0)
    gpop()
end

function GuiElement.newSlider(image, cursor, x, y, sx, sy, ox, oy, padding, color)
    local newSlider = setmetatable({
        image = image, cursor = cursor, color = color;
        x = x, y = y, padding = padding;
        sx = sx, sy = sy;
        ox = ox, oy = oy
    }, GuiElement.elements.Slider)

    return newSlider
end



----------------- Selection Slider --------------------
GuiElement.elements.SelectionSlider = {
    __index = setmetatable({
        cursorPosition = 0.5, -- 0.0 - 1.0
        cursorSelection = 1,
        selections = {},
        padding = 15,       -- pixels,
        selected = false,
        tlText = "TLEFT", tText = "TOP", trText = "TRIGHT";
        blText = "BLEFT", bText = "BOTTOM", brText = "BRIGHT";

        cursor = nil        
    }, GuiElement)
}
local SelectionSlider = GuiElement.elements.SelectionSlider

-- instance methods
function SelectionSlider.__index:update(dt)
    if mouse.dragging then
        if self:getClick() then
            self.selected = true
        end
    else
        if self.selected then
            self.cursorPosition = math.floor(self.cursorPosition*(#self.selections-1)+0.5)/(#self.selections-1)
            self.cursorSelection = math.floor(self.cursorPosition * (#self.selections-1)+0.5)+1
            self.selected = false
        end
    end

    if self.selected then
        local minPos = self.x + self.padding - self.sx*self.ox
        local maxPos = self.x + self.sx - self.padding - self.sx*self.ox

        local ratio = (mouse.x - minPos) / (maxPos - minPos)

        self.cursorPosition = math.clamp(ratio, 0, 1)
    end
end

function SelectionSlider.__index:draw()
    local width, height = dimensions[1], dimensions[2]
    local ofsX, ofsY = self.ox*self.sx, self.oy*self.sy
    gpush()
        setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 1)
        draw(self.image, self.x, self.y, 0, self.sx, self.sy, self.ox, self.oy)
        draw(self.cursor, self.x + self.padding + (self.sx - self.padding*2)*self.cursorPosition - ofsX, self.y+self.sy/2 - ofsY, 0, self.sy, self.sy, 0.5,0.5)
        
        for i = 1, #self.selections do
            gprint(self.selections[i], self.x + self.padding + (self.sx - self.padding*2)*((i-1)/(#self.selections-1)) - ofsX, self.y - ofsY, 0, nil, self.sy/2, 0.5, 1)
        end

        gpop()
end

function SelectionSlider.__index:getSelection() 
    return self.selections[self.cursorSelection]
end

function GuiElement.newSelectionSlider(image, cursor, selections, x, y, sx, sy, ox, oy, padding, color)
    local newSlider = setmetatable({
        image = image, cursor = cursor, color = color;
        x = x, y = y, padding = padding;
        sx = sx, sy = sy;
        ox = ox, oy = oy;
        selections = selections or {}
    }, GuiElement.elements.SelectionSlider)

    return newSlider
end

---------------- Selection Box ---------------------
GuiElement.elements.SelectionBox = {
    __index = setmetatable({
        cursorSelection = 1,
        selections = {},
        selectedBoxes = {},
        padX = 50, -- pixels
        padY = 50, -- pixels
        textScale = 0.5,
        align = "CENTER",

        multiSelect = false,

        checkScale = 50, -- pixels (ugh)
        checkBackground = nil, -- add default images later ??
        cursor = nil
    }, GuiElement)
}
local SelectionBox = GuiElement.elements.SelectionBox

local abs = math.abs
function SelectionBox.__index:update(dt)
    if mouse.clicked then
        local ofsX, ofsY = self.ox*self.sx, self.oy*self.sy
        for i, checkBox in ipairs(self.selections) do
            local x = self.x + self.padX + (self.sx-2*self.padX)*checkBox:getX() - ofsX
            local y = self.y + self.padY + (self.sy-2*self.padY)*checkBox:getY() - ofsY

            if abs(mouse.x - x) <= self.checkScale/2 and abs(mouse.y - y) <= self.checkScale/2 and (not (Settings.active and mouse.x <= dimensions[2]/9*8) or self.isSetting) then
                if self.multiSelect then
                    -- checkbox
                    self.selectedBoxes[i] = not self.selectedBoxes[i] or nil
                else
                    -- selection box
                    self.selectedBoxes = {[i]=true}
                end
            end
        end    
    end
end

function SelectionBox.__index:draw()
    local width, height = dimensions[1], dimensions[2]
    local ofsX, ofsY = self.ox*self.sx, self.oy*self.sy
    gpush()
        setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 1)
        draw(self.image, self.x, self.y, 0, self.sx, self.sy, self.ox, self.oy)
        
        for i, checkBox in ipairs(self.selections) do
            local px = self.x + self.padX + (self.sx-2*self.padX)*checkBox:getX() - ofsX
            local py = self.y + self.padY + (self.sy-2*self.padY)*checkBox:getY() - ofsY
            
            draw(checkBox:getBackground(), px, py, 0, self.checkScale, self.checkScale, 0.5, 0.5)

            if self.selectedBoxes[i] then
                draw(checkBox:getCursor(), px, py, 0, self.checkScale, self.checkScale, 0.5, 0.5)
            end

            if self.align == "RIGHT" then
                gprint(checkBox:getText(), px+self.checkScale/1.5, py, 0, nil, self.checkScale*self.textScale, 0, 0.5)
            elseif self.align == "LEFT"  then
                gprint(checkBox:getText(), px-self.checkScale/1.5, py, 0, nil, self.checkScale*self.textScale, 1, 0.5)                
            elseif self.align == "TOP" then
                gprint(checkBox:getText(), px, py-self.checkScale/1.5, 0, nil, self.checkScale*self.textScale, 0.5, 1)
            elseif self.align == "BOTTOM" then
                gprint(checkBox:getText(), px, py+self.checkScale/1.5, 0, nil, self.checkScale*self.textScale, 0.5, 0)
            elseif self.align == "CENTER" then
                gprint(checkBox:getText(), px, py, 0, nil, self.checkScale*self.textScale, 0.5, 0.5)
            end
        end
    gpop()
end

-- gets the boolean selected value of x, or finds the first selected element
function SelectionBox.__index:getSelection(x)
    if x then
        return self.selectedBoxes[x] or false
    end

    for i, _ in pairs(self.selectedBoxes) do
        return i
    end
    return false
end

function SelectionBox.__index:setSelection(x, value, reset)
    if not self.multiSelect or reset then
        self.selectedBoxes = {[x] = true}
    else
        self.selectedBoxes[x] = value
    end
end

-- baby CheckBox class 
-- employers, if you're reading this,
-- i really have little explanation, it was just a fun exercise in formatting
local CheckBox CheckBox = {__index = {
      --x,      y,      text,  background,  cursor
        0,      0,      "",    nil,         nil,
        getX = function(self) return self[1] end,
        getY = function(self) return self[2] end,
        getText = function(self) return self[3] end,
        getBackground = function(self) return self[4] end,
        getCursor = function(self) return self[5] end},
    new = function(x, y, text, bg, c) return setmetatable({x, y, text, bg, c}, CheckBox) end}


function GuiElement.newSelectionBox(background, checkBackground, cursor, selections, x, y, sx, sy, rows, cols, ox, oy, color, vertical)
    local newSelectionBox = setmetatable({
        image = background, checkBackground = checkBackground, cursor = cursor, color = color;
        x = x, y = y, sx = sx, sy = sy;
        ox = ox, oy = oy;
        rows = rows, cols = cols;
        selections = selections or {}
    }, GuiElement.elements.SelectionBox)

    local cRow, cCol = 0, 0
    for i, selectionText in ipairs(newSelectionBox.selections) do
        -- CheckBox positions are normalized
        local xPos = cols == 1 and 0.5 or 1/(cols-1)*cCol
        local yPos = rows == 1 and 0.5 or 1/(rows-1)*cRow
        
        newSelectionBox.selections[i] = CheckBox.new(xPos, yPos, selectionText, checkBackground, cursor)

        if vertical then
            cRow = cRow + 1
            if cRow >= rows then
                cRow = 0
                cCol = cCol + 1
            end
        else
            cCol = cCol + 1
            if cCol >= cols then
                cCol = 0
                cRow = cRow + 1
            end
        end
    end 

    return newSelectionBox
end

------------------------- Textbox (ugh) ----------------------------
local keyboard = Keyboard
GuiElement.elements.Textbox = {
    __index = setmetatable({
        text = "",
        defaultText = "example",
        textSize = 0.8,
        maxLength = 1, -- 0.0 - 1.0
        textColor = {1,1,1,1},
        align = "CENTER",
        cursorTime = 0,
        blinkRate = 1,
        backspaceThreshold = 0.5,
        backspaceRepeatRate = 0.05,
        backspaceProgress = 0,
        allowedChars = "ALL", -- ALL, NUMBER
        minValue = 0, ---math.huge,
        maxValue = 100 --math.huge
    }, GuiElement),

    charSets = {
        ALL = ExistList(" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.!?@#$%^&*()[]{}-=_+~<>;:'\""),
        NUMBER = ExistList("0123456789.-")
    }
}
local Textbox = GuiElement.elements.Textbox

-- instance methods
function Textbox.__index:update(dt)
    if mouse.clicked then
        if self:getHover() then
            -- textbox was selected
            GuiElement.activeTextbox = self
        elseif self == GuiElement.activeTextbox then
            -- textbox was deselected
            GuiElement.activeTextbox = nil
            self.cursorTime = 0
            if self.allowedChars == "NUMBER" then
                self.text = tostring(math.clamp(tonumber(self.text) or 0, self.minValue, self.maxValue))
            end
        end
    end

    if self == GuiElement.activeTextbox then
        self.cursorTime = self.cursorTime + dt
        
        if keyboard.justPressed.backspace then self:backspace() end

        if keyboard.timeDown.backspace > self.backspaceThreshold then
            local newProgress = keyboard.timeDown.backspace % self.backspaceRepeatRate
            if newProgress < self.backspaceProgress then
                self:backspace()
            end
            self.backspaceProgress = newProgress
        end
    end
end

function Textbox.__index:draw()
    local width, height = dimensions[1], dimensions[2]
    local ofsX, ofsY = self.sx * self.ox, self.sy * self.oy
    gpush()
        setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 1)
        draw(self.image, self.x, self.y, 0, self.sx, self.sy, self.ox, self.oy)
    
        local blinkRatio = self.cursorTime % self.blinkRate

        local displayText = (blinkRatio < self.blinkRate/2 and GuiElement.activeTextbox == self) and self.text .. "|" or self.text

        setColor(self.textColor[1], self.textColor[2], self.textColor[3], self.textColor[4] or 1)

        if self.align == "LEFT" then
            gprint(displayText, self.x + self.sy*(1-self.textSize)/2 - ofsX, self.y + self.sy/2 - ofsY, 0, nil, self.sy*self.textSize, 0, 0.5)
            if #self.text == 0 then
                setColor(self.textColor[1], self.textColor[2], self.textColor[3], (self.textColor[4] or 1)/2)
                gprint(self.defaultText, self.x + self.sy*(1-self.textSize)/2 - ofsX, self.y + self.sy/2 - ofsY, 0, nil, self.sy*self.textSize, 0, 0.5)
            end
        elseif self.align == "RIGHT" then
            gprint(displayText, self.x + self.sx - self.sy*(1-self.textSize)/2 - ofsX, self.y + self.sy/2 - ofsY, 0, nil, self.sy*self.textSize, 1, 0.5)
            if #self.text == 0 then
                setColor(self.textColor[1], self.textColor[2], self.textColor[3], (self.textColor[4] or 1)/2)
                gprint(self.defaultText, self.x + self.sx - self.sy*(1-self.textSize)/2 - ofsX, self.y + self.sy/2 - ofsY, 0, nil, self.sy*self.textSize, 1, 0.5)
            end
        elseif self.align == "CENTER" then
            gprint(displayText, self.x + self.sx/2 - ofsX, self.y + self.sy/2 - ofsY, 0, nil, self.sy*self.textSize, 0.5, 0.5)            
            if #self.text == 0 then
                setColor(self.textColor[1], self.textColor[2], self.textColor[3], (self.textColor[4] or 1)/2)
                gprint(self.defaultText, self.x + self.sx/2 - ofsX, self.y + self.sy/2 - ofsY, 0, nil, self.sy*self.textSize, 0.5, 0.5)            
            end
        end
    gpop()
end

function Textbox.__index:newCharacter( c )
    local newText = self.text .. c
    local length = getTextWidth(newText) / getTextHeight() * (self.sy*self.textSize) / self.maxLength
    local numberPass = (self.allowedChars ~= "NUMBER" or tonumber(newText)) or newText == "-"

    if numberPass and Textbox.charSets[self.allowedChars] and Textbox.charSets[self.allowedChars][c] and length < self.sx - self.sy*(1-self.textSize) then
        self.text = newText
        self.cursorTime = 0
    end
end

function Textbox.__index:backspace()
    self.text = self.text:sub(1, #self.text-1)
    self.cursorTime = 0
end

function GuiElement.newTextbox(image, defaultText, x, y, sx, sy, ox, oy, color)
    local newTextbox = setmetatable({
        image = image, color = color;
        x = x, y = y;
        sx = sx, sy = sy;
        ox = ox, oy = oy;
        text = defaultText
    }, GuiElement.elements.Textbox)

    return newTextbox
end

return GuiElement