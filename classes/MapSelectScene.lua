local asset = Asset
local dimensions = _G.SIZE
local draw, draw2, gprint = drawImage, drawImage2, drawText
local gpush, gpop, setColor = love.graphics.push, love.graphics.pop, love.graphics.setColor
local clamp = function(x, min, max) return x<min and min or x>max and max or x end

local hat = Libs.Source2.new("assets/sounds/ClosedHat1.wav", "static")

local Scene Scene = {
    -- This is the prototype instance for a scene object.
    prototype = {
        --- instance vars
        id = 0,
        logo = nil,
        startButton = nil,
        bgScale = 1,

        loadingIn = true,
        loadingTransitionPos = 1,
        loadingTransitionSpeed = 2,
        inTransition = false,
        transitionGoal = "",
        transitionTime = 0,
        transitionCells = {},
        timeSinceSelectionChanged = 0,

        backgroundCanvas = false,
        backgroundTileRate = 0.6,
        backgroundTileProgress = 0,
        currentTilePos = 0,
        tileFrequency = 7,
        backgroundTiles = false,

        particleLayer1 = false,

        loadedSelection = 0,
        loadedSong = false,
        rawTime = 0,
        loadedSongVolume = 0,
        loadedBackground = false,
        adjustedSongTime = 0,
        midSampleTime = 0,

        songTitleHolder = false,

        currentBeat = 0,
        currentBPM = 0,
        currentEvent = 1,

        mapList = {},
        selectedSong = 1,
        selectedSongTween = 1,
        selectedDifficulty = 1,
        selectedDifficultyTween = 1,

        pulseSize = 1,

        --- methods
        destroy = function(self)
            Scene.activeScenes[self.id] = nil
        end,

        pulse = function(self)
            self.pulseSize = 1.1
            self.bgScale = 1
            self.currentBeat = self.currentBeat + 1
            
            self.particleLayer1:insert(gui_Particle.new(
                asset.image.map_select_difficulty_wheel_pulse, 
                dimensions[1]/2+dimensions[2]/10, dimensions[2]*.3, 
                -math.rad(45)*(self.selectedDifficultyTween-1), 
                dimensions[2]/5, dimensions[2]/5, 
                .5, .5, 0, 0, 0, 0, dimensions[2]/180, 1, -0.05, 1
            ))


            local color = ((self.tileFrequency-self.currentTilePos)/self.tileFrequency-0.5)/3
            self.backgroundTiles[#self.backgroundTiles+1] = {self.currentTilePos/self.tileFrequency, 1.5, 1, 1, 0, -0.5, 0, 0.085, 50/255+color,30/255+color,102/255+color}
            self.currentTilePos = (self.currentTilePos + 3) % (self.tileFrequency+1)
            

            local loopSize = math.floor(dimensions[1]/dimensions[2]*3)
            for i = 1, loopSize do
                local size = math.random(1,5)*dimensions[2]*.3
                self.particleLayer1:insert(gui_Particle.new(
                    asset.image.map_select_background_glow,
                    math.random(0, dimensions[1]), math.random(0, dimensions[2]), 0,
                    size, size, 0.5, 0.5, 0, 0, 0, 0, -dimensions[2]/400, 1, -0.01, 3
                ))

                self.particleLayer1:insert(gui_Particle.new(
                    asset.image.map_select_background_sparkle,
                    math.random(0, dimensions[1]), math.random(0, dimensions[2]), 0,
                    size/20, size/20, 0.5, 0.5, 0, 0, 0, dimensions[2]/70000, -dimensions[2]/8000, 1, -0.005, 3
                ))
            end
            

            --hat:play()
        end,

        updateMapPreview = function(self)
            local selectedSong = self.mapList[self.selectedSong]
            
            if self.loadedSong then
                self.loadedSong:stop()
            end

            self.loadedSong = Libs.Source2.new("maps/" .. selectedSong.folder .. "/" .. selectedSong.songPath, "stream")
            self.loadedSong:seek(selectedSong.previewTime)
            self.adjustedSongTime = selectedSong.previewTime
            self.loadedSongVolume = 0
            self.loadedSong:setVolume(0)
            self.loadedSong:setPitch(1)
            self.loadedSong:play()
            
            self.songTitleHolder.progress = 0

            self.loadedBackground = love.graphics.newImage("maps/" .. selectedSong.folder .. "/" .. selectedSong.bgPath)

            if not selectedSong.bpmTracker then
                selectedSong.bpmTracker = {{0,1}}
                for i = 1, #selectedSong.bpmEvents, 2 do
                    selectedSong.bpmTracker[#selectedSong.bpmTracker+1] = {selectedSong.bpmEvents[i], selectedSong.bpmEvents[i+1]}
                end 
            end

            self.currentBeat = 0
            self.currentEvent = 1
            self.currentBPM = selectedSong.bpmTracker[1][2]
            
            for i, t in ipairs(selectedSong.bpmTracker) do
                if t[1] >= selectedSong.previewTime then break end
                self.currentBPM = t[2]
                self.currentEvent = i
            end

            

            self.loadedSelection = self.selectedSong
        end,

        transition = function(self, goal)
            Asset.sound.map_click:play()
            self.inTransition = true
            self.transitionGoal = goal
            self.loadedSong:stop()
            print("start game")
        end,

        draw = function(self)
            local width, height = dimensions[1], dimensions[2]

            -- handle the canvas 
            love.graphics.setCanvas(self.backgroundCanvas)
                love.graphics.clear(29/255,19/255,64/255)
                local csx, csy = self.backgroundCanvas:getDimensions()
                for _, tile in pairs(self.backgroundTiles) do
                    love.graphics.setColor(tile[9], tile[10], tile[11])

                    local px, py, d  = csx * tile[1], csy * tile[2], csy / 10 * tile[3]
                    love.graphics.polygon("fill", {px - d, py, px, py + d, px + d, py, px, py - d})
                end
            love.graphics.setCanvas()

            gpush()
                setColor(1,1,1,1)
                -- first, draw the background image
                local iWidth, iHeight = self.loadedBackground:getDimensions()
                local iRatio = iWidth/iHeight

                local scaleByWidth = false
                if iRatio < width/height then
                    scaleByWidth = true
                end
                
                draw(self.loadedBackground, width/2, height/2, 0, (scaleByWidth and width or height*iRatio)*self.bgScale, (scaleByWidth and width/iRatio or height)*self.bgScale, 0.5, 0.5)
                
                
                -- draw the menu background stuff
                draw(asset.image.map_select_right_decoration, width/2+height/10, 0, 0, height*.2, height)
            gpop(); gpush()
                setColor(0,0,0,1-self.loadedSongVolume+.25)
                love.graphics.rectangle("fill", 0, 0, dimensions[1], dimensions[2])
            gpop(); gpush()            
                self.particleLayer1:draw()

                setColor(1,1,1,1)
                local d45 = 0.785398

                draw(asset.image.map_select_wheel_highlight, width/2+height/10, height*.3, 0, height*0.4*self.pulseSize, height*0.1/self.pulseSize, 0, 0.5)
                draw(asset.image.map_select_difficulty_wheel, width/2+height/10, height*.3, -d45*(self.selectedDifficultyTween-1), height/5*self.pulseSize, height/5*self.pulseSize, 0.5, 0.5)
                draw(asset.image.map_select_star_icon, width/2+height*.175, height*.3, 0, height/40, height/40, 0.5, 0.5)
                
                if self.mapList[self.selectedSong].maps then
                    for i = clamp(self.selectedDifficulty - 3, 1, #self.mapList[self.selectedSong].maps), clamp(self.selectedDifficulty + 3, 1, #self.mapList[self.selectedSong].maps) do
                        local map = self.mapList[self.selectedSong].maps[i]
                        setColor(0,0,0,.5)
                        gprint("         " .. map[2], width/2+height/10, height*.305, d45*(i-1) - d45*(self.selectedDifficultyTween-1), nil, height/25, 0, 0.5)
                        setColor(1,1,1,1)
                        gprint("         " .. map[2], width/2+height/10, height*.3, d45*(i-1) - d45*(self.selectedDifficultyTween-1), nil, height/25, 0, 0.5)
                    end
                end
            gpop(); gpush()
                setColor(0,0,0,1)
                gprint("?.??", width/2+height*.16, height*.3, 0, nil, height/40, 1, 0.5)  
            gpop(); gpush()
                setColor(1,1,1,1)
                draw(asset.image.map_select_info_panel, width/2+height/10, height, 0, height*.4, height*.4, 0, 1)
                draw(self.backgroundCanvas, width/2-height/2, 0, 0, height*.6, height)
                draw(asset.image.map_select_scroll_background, width/2-height/2, 0, 0, height*.6, height)
                
                -- draw the menu map list
                local ofx, ofy = width/2 - height/2, height/5
                for i = clamp(self.selectedSong - 3, 1, #self.mapList), clamp(self.selectedSong + 5, 1, #self.mapList) do
                    local button = self.mapList[i]
                    if button then
                        button.sx, button.sy = height/5*3, height/5
                        button.x = ofx
                        button.y = ofy + button.sy*(i-1) - button.sy*(self.selectedSongTween-1)
                        button:draw(self)
                    end
                end
                setColor(1,1,1,1)
                draw(asset.image.map_select_song_top, ofx, ofy - height/5*(self.selectedSongTween), 0, height/5*3, height/5)
            gpop(); gpush()
                setColor(1,1,1,1)

                -- draw map info
                local durationString = self.loadedSong and generateTimestamp(self.mapList[self.selectedSong].maps[self.selectedDifficulty][10]-self.mapList[self.selectedSong].maps[self.selectedDifficulty][9], false, true) or "??:??"
                
                self.songTitleHolder.text = self.mapList[self.selectedSong].songName
                self.songTitleHolder.x, self.songTitleHolder.y = width/2+height*0.115, height*.675
                self.songTitleHolder.sy = height*0.035
                self.songTitleHolder.sx = self.songTitleHolder.sy * 10
                self.songTitleHolder:draw()
                --gprint(self.mapList[self.selectedSong].songName, width/2+height*0.115, height*.675, 0, nil, height*.035, 0, 0)
                gprint("Duration: ".. durationString, width/2+height*0.115, height*.8, 0, nil, height*.025, 0, 0)
                gprint("Approach Rate: "..(math.floor(self.mapList[self.selectedSong].maps[self.selectedDifficulty][5])).." sec", width/2+height*0.115, height*.825, 0, nil, height*.025, 0, 0)
                gprint("Timing Pity: "..(math.floor(self.mapList[self.selectedSong].maps[self.selectedDifficulty][4]*100)).."%", width/2+height*0.115, height*.85, 0, nil, height*.025, 0, 0)
                gprint("HP Drain: "..(math.floor(self.mapList[self.selectedSong].maps[self.selectedDifficulty][5]*100)).."%", width/2+height*0.115, height*.875, 0, nil, height*.025, 0, 0)
                local numNotes = self.mapList[self.selectedSong].maps[self.selectedDifficulty][8]
                local numDrops = self.mapList[self.selectedSong].maps[self.selectedDifficulty][7]
                gprint(numNotes..(numNotes==1 and" move | " or " moves | ")..numDrops..(numDrops==1 and" drop" or " drops"), width/2+height*0.115, height*.9, 0, nil, height*.025, 0, 0)
            gpop(); gpush()
                setColor(204/255,215/255,1,1)
                gprint(""..self.mapList[self.selectedSong].maps[self.selectedDifficulty][2].."", width/2+height*0.115, height*.62, 0, nil, height*.05, 0, 0)
                gprint("Song by "..self.mapList[self.selectedSong].artist, width/2+height*0.115, height*.725, 0, nil, height*.025, 0, 0)
                gprint("Map by "..self.mapList[self.selectedSong].maps[self.selectedDifficulty][3], width/2+height*0.115, height*.75, 0, nil, height*.025, 0, 0)
            gpop(); gpush()
                self.exitButton.x, self.exitButton.y = width/2+height*0.15, height*0.55
                self.exitButton.sx, self.exitButton.sy = height*0.08, height*0.08
                self.exitButton:draw()
                gprint("EXIT", self.exitButton.x+self.exitButton.sx/6 + (self.exitButton.currentSize-1)*40, self.exitButton.y+self.exitButton.sy*0.4, 0, nil, height*.04, 0, 0.5)
            gpop(); gpush()
                setColor(0,0,0,1)
                for i, v in ipairs(self.transitionCells) do
                   love.graphics.rectangle("fill", width/10*i, height, -width/10, -v[2]*height*1.1) 
                end

                love.graphics.rectangle("fill", 0, 0, width, height*self.loadingTransitionPos)
            gpop()
        end,

        update = function(self, dt)

            if self.inTransition then
                self.transitionTime = self.transitionTime + dt*2
                local dampening = 12/dt/40

                for i, v in ipairs(self.transitionCells) do
                    if self.transitionTime >= i/15 then
    
                        v[2] = (v[2]*dampening + 1)/(dampening+1)

                    end
                end
                if self.transitionTime > 2 then
                    local oldScene = _G.activeScene
                    _G.activeScene = Classes[self.transitionGoal].new{}
                    oldScene:destroy()
                end
            end

            local dampening = 3/dt/40 -- used for tweens


            if self.exitButton:getHover() then
                self.exitButton.goalSize = 1.1
                if Mouse.clicked then
                    self.exitButton.currentSize = 0.8
                    self:transition("StartMenuScene")
                end
            else
                self.exitButton.goalSize = 1
            end

            self.exitButton:update(dt)


            if self.loadedSong then
                self.adjustedSongTime = self.loadedSong:tell()
            end

            -- check inputs
            if math.abs(Mouse.scrollDirection) > 0 and not (Settings.active) and not self.inTransition then
                self.timeSinceSelectionChanged = 0
                if Mouse.x < dimensions[1]/2 + dimensions[2]/10 then
                    self.selectedSong = self.selectedSong + Mouse.scrollDirection
                else
                    self.selectedDifficulty = self.selectedDifficulty + Mouse.scrollDirection
                end
                Asset.sound.menu_hover:play()
            end

            if Keyboard.justPressed["escape"] and not Settings.active and not self.inTransition then
                self:transition("StartMenuScene")
            end

            ----------------

            if self.mapList[self.selectedSong] and self.mapList[self.selectedSong]:getClick() and not self.inTransition then
                self:transition("GameScene")
            end

            -- canvas tiles
            for i, tile in pairs(self.backgroundTiles) do
                local wdt = dt/2
                tile[1] = tile[1] + tile[5] * wdt -- vx 
                tile[2] = tile[2] + tile[6] * wdt -- vy
                tile[3] = tile[3] + tile[4] * wdt
                tile[4] = tile[4] - 0.5 * wdt
                tile[5] = tile[5] + tile[7] * wdt -- ax
                tile[6] = tile[6] + tile[8] * wdt -- ay
                
                if tile[3]<0 then
                    self.backgroundTiles[i] = nil
                end
            end

            for i = clamp(self.selectedSong - 3, 1, #self.mapList), clamp(self.selectedSong + 5, 1, #self.mapList) do
                local button = self.mapList[i]

                -- get the thumbnail if it's not loaded
                if not button.thumbnail then
                    local thumbnailPath = "maps/"..button.folder.."/thumbnail.png"
                    local bgPath = "maps/"..button.folder.."/"..button.bgPath
                    if not love.filesystem.getInfo(thumbnailPath) then
                        IO.createThumbnail(bgPath, "maps/"..button.folder.."/thumbnail.png")
                        print("generated new thumbnail")
                    end

                    button.thumbnail = love.graphics.newImage(thumbnailPath)
                end

                if button and not self.inTransition then
                    local hover = button:getHover()
                    
                    if hover ~= button.isHovered and not Settings.active then
                        Asset.sound.menu_hover:play()
                        button.isHovered = hover
                    end

                    

                    if i ~= self.selectedSong and not hover then
                        button.glow = 0.5
                    elseif hover then
                        button.glow = .75
                        if button:getClick() then
                            self.selectedSong = i
                            Asset.sound.menu_click:play()
                        end
                    end
                end
            end

            

            self.selectedSong = clamp(self.selectedSong, 1, #self.mapList)
            if self.mapList[self.selectedSong].maps then
                self.selectedDifficulty = clamp(self.selectedDifficulty, 1, #self.mapList[self.selectedSong].maps)
            end

            -- check for updated map selections
            if self.loadedSelection == 0 or (self.loadedSelection~=self.selectedSong and self.timeSinceSelectionChanged > .5) then
                self:updateMapPreview()
            end

            if self.loadedSong and not self.loadedSong:isPlaying() and not self.inTransition then
                self:updateMapPreview()
            end

            self.songTitleHolder:update(dt)
            
            if math.abs(self.selectedSongTween - self.selectedSong) > 0.001 then
                self.selectedSongTween = (self.selectedSongTween*dampening + self.selectedSong)/(dampening+1)
            end

            local selectedSong = self.mapList[self.selectedSong]
            if self.loadedSong and selectedSong.bpmTracker and self.loadedSelection == self.selectedSong then
               
                
                self.loadedSong:setVolume(self.loadedSongVolume)
                local songTime = self.loadedSong:tell()
                
                self.loadedSongVolume = (self.loadedSongVolume*dampening*4 + 1)/(dampening*4+1)
                local crochet = 60/self.currentBPM
                local startTime = selectedSong.bpmTracker[self.currentEvent][1]
                local endTime = startTime + crochet*self.currentBeat
                
                if songTime >= endTime then
                    self:pulse()
                    while startTime + crochet*self.currentBeat < songTime do
                        self.currentBeat = self.currentBeat + 1
                    end
                end

                if selectedSong.bpmTracker[self.currentEvent+1] and selectedSong.bpmTracker[self.currentEvent+1][1] <= songTime then
                    self.currentEvent = self.currentEvent + 1
                    self.currentBPM = selectedSong.bpmTracker[self.currentEvent][2]
                    self:pulse()
                    self.currentBeat = 0
                end

                --print(self.adjustedSongTime, self.rawTime)
            end

            self.mapList[self.selectedSong].glow = (self.mapList[self.selectedSong].glow*dampening*4 + 1)/(dampening*4+1)
            self.selectedDifficultyTween = (self.selectedDifficultyTween*dampening + self.selectedDifficulty)/(dampening+1)
            self.pulseSize = (self.pulseSize*dampening + 1)/(dampening+1)
            self.bgScale = (self.bgScale*dampening*8 + 1.0075)/(dampening*8+1)

            self.timeSinceSelectionChanged = self.timeSinceSelectionChanged + dt

            if self.loadingIn then
                self.loadingTransitionPos = self.loadingTransitionPos - self.loadingTransitionSpeed * dt
                self.loadingTransitionSpeed = self.loadingTransitionSpeed - 2*dt

                if self.loadingTransitionPos <= 0 then
                    self.loadingIn = false
                end
            end
        end
    },

    activeScenes = {},
    assets = {}
}
Scene.__index = Scene.prototype


----- Asset loading bit
local loadedAssets = false
local function loadAssets()
    if loadedAssets then return end
    local asset = Asset
    loadedAssets = true
    for _, path in ipairs({
        "skinpath/main_menu/main_menu_default_background.png",
        "skinpath/map_select/map_select_scroll_background.png",
        "skinpath/map_select/map_select_filter_box.png",
        "skinpath/map_select/map_select_difficulty_wheel.png",
        "skinpath/map_select/map_select_difficulty_wheel_pulse.png",
        "skinpath/map_select/map_select_right_decoration.png",
        "skinpath/map_select/map_select_info_panel.png",
        "skinpath/map_select/map_select_song_glow.png",
        "skinpath/map_select/map_select_song_bg.png",
        "skinpath/map_select/map_select_song_top.png",
        "skinpath/map_select/map_select_wheel_highlight.png",
        "skinpath/map_select/map_select_star_icon.png",
        "skinpath/map_select/map_select_background_glow.png",
        "skinpath/map_select/map_select_background_sparkle.png",
        "skinpath/map_select/map_select_exit.png"
    }) do
        asset.loadImage(path)
    end

    for _, path in ipairs({
        "soundpath/menu_hover.ogg",
        "soundpath/map_click.ogg",
        "soundpath/menu_click.ogg"
    }) do
        asset.loadSound(path)
    end
    
end

local function customDraw(self, parent)
    local width, height = dimensions[1], dimensions[2]
    gpush()
        setColor(1,1,1,1)
        draw(self.image, self.x, self.y, 0, self.sx*self.currentSize, self.sy*self.currentSize, self.ox, self.oy)    
        gprint(self.displayTitle or "", self.x + (self.sx*self.currentSize/20), self.y + (self.sx*self.currentSize/20), 0, nil, self.sy*self.currentSize*0.15)
    gpop(); gpush()
        setColor(1,1,1,0.5)
        gprint("   " .. (self.artist or "") .. "", self.x + (self.sx*self.currentSize/20), self.y + (self.sx*self.currentSize/8), 0, nil, self.sy*self.currentSize*0.125)
    gpop(); gpush()
        setColor(1, 1, 1, 0.2)
        gprint("#" .. tostring(self.songId), self.x + (self.sx*self.currentSize) - (self.sx*self.currentSize/2.3), self.y + (self.sy*self.currentSize) - (self.sx*self.currentSize/20), 0, nil, self.sy*self.currentSize/5, 1, 1)
    gpop(); gpush()
        setColor(1,1,1, self.glow)
        draw(self.glowImage, self.x, self.y, 0, self.sx*self.currentSize, self.sy*self.currentSize, self.ox, self.oy)        
    gpop(); gpush()
        setColor(0,0,0,.5)
        gprint(tostring(#self.maps).." map"..(#self.maps==1 and "" or "s"), self.x + (self.sx*self.currentSize*.05), self.y + (self.sy*self.currentSize) - (self.sx*self.currentSize/20), 0, nil, self.sy*self.currentSize/8, 0, 1)
    gpop(); gpush()
        if self.thumbnail then
            setColor(self.glow,self.glow,self.glow,1)
            local add = parent.mapList[parent.selectedSong] == self and height/15*(1-parent.pulseSize) or 0
            local sy = self.sy*self.currentSize*0.7 - add
            local sx = sy
            draw(self.thumbnail, self.x + (self.sx*self.currentSize) - (self.sx*self.currentSize/6), self.y + (self.sy*self.currentSize) - (self.sx*self.currentSize/6), 0, sx, sy, 0.5, 0.5)
        end
    gpop()
end

-- Constructor for editor scene objects
function Scene.new(params)
    params = params or {}

    print(params.flag)

    local newScene = setmetatable({}, Scene)
    
    -- add the scene to the current list
    newScene.id = #Scene.activeScenes+1
    Scene.activeScenes[#Scene.activeScenes+1] = newScene

    -- load related assets, if applicable
    loadAssets()

    newScene.transitionCells = {{0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}}
    newScene.mapList = IO.getSongs( customDraw, asset.image.map_select_song_bg, asset.image.map_select_song_glow ) -- KEEP THIS LINE
    newScene.loadedBackground = asset.image.main_menu_default_background
    newScene.selectedSong = math.random(1, #newScene.mapList)
    newScene.particleLayer1 = Classes.gui_Particle.newContainer()
    newScene.songTitleHolder = Classes.gui_GuiElement.newScrollingText(".", 0, 0, 10, 1)
    newScene.songTitleHolder.alwaysActive = true

    newScene.backgroundCanvas = love.graphics.newCanvas(648, 1080)
    newScene.backgroundTiles = {}

    newScene.exitButton = Classes.gui_GuiElement.newButton(Asset.image.map_select_exit, 0, 0, 0, 0, 0.5, 0.5)


    local getWidth = _G.getTextWidth
    local height = _G.getTextHeight()
    -- set up map textboxes based on text length
    for _, button in pairs(newScene.mapList) do
        local text, check = button.songName, false

        while getWidth(text)/height > 11.5 do
            check = true
            text = text:sub(1,#text-1)
        end

        button.displayTitle = text .. (check and "..." or "")
    end


    return newScene
end

-- Draw method for the CLASS. Handles drawing for all active scenes.
function Scene.draw()
    for _, scene in pairs(Scene.activeScenes) do
        scene:draw()
    end
end

-- Update method for the CLASS. Handles updates for all active scenes.
function Scene.update(dt)
    
    for _, scene in pairs(Scene.activeScenes) do
        scene:update(dt)
    end
end

return Scene