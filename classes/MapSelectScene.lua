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

        particleLayer1 = false,

        loadedSelection = 0,
        loadedSong = false,
        rawTime = 0,
        loadedSongVolume = 0,
        loadedBackground = false,
        adjustedSongTime = 0,
        midSampleTime = 0,

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

        draw = function(self)

            local width, height = dimensions[1], dimensions[2]
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
                        gprint("       " .. map[2], width/2+height/10, height*.305, d45*(i-1) - d45*(self.selectedDifficultyTween-1), nil, height/25, 0, 0.5)
                        setColor(1,1,1,1)
                        gprint("       " .. map[2], width/2+height/10, height*.3, d45*(i-1) - d45*(self.selectedDifficultyTween-1), nil, height/25, 0, 0.5)
                    end
                end
            gpop(); gpush()
                setColor(0,0,0,1)
                gprint("?.??", width/2+height*.16, height*.3, 0, nil, height/40, 1, 0.5)  
            gpop(); gpush()
                setColor(1,1,1,1)
                draw(asset.image.map_select_info_panel, width/2+height/10, height, 0, height*.4, height*.4, 0, 1)
                draw(asset.image.map_select_scroll_background, width/2-height/2, 0, 0, height*.6, height)
                
                -- draw the menu map list
                local ofx, ofy = width/2 - height/2, height/5
                for i = clamp(self.selectedSong - 3, 1, #self.mapList), clamp(self.selectedSong + 5, 1, #self.mapList) do
                    local button = self.mapList[i]
                    if button then
                        button.sx, button.sy = height/5*3, height/5
                        button.x = ofx
                        button.y = ofy + button.sy*(i-1) - button.sy*(self.selectedSongTween-1)
                        button:draw(self.pulseSize)
                    end
                end
                setColor(1,1,1,1)
                draw(asset.image.map_select_song_top, ofx, ofy - height/5*(self.selectedSongTween), 0, height/5*3, height/5)
            gpop(); gpush()
                setColor(1,1,1,1)
                --draw(asset.image.map_select_filter_box, width/2-height/2, 0, 0, height*.6, height*.2)
                
                for i, v in ipairs(self.mapList[self.selectedSong].maps[self.selectedDifficulty]) do
                    --print(i, v)
                end

                -- draw map info
                local durationString = self.loadedSong and generateTimestamp(self.mapList[self.selectedSong].maps[self.selectedDifficulty][10]-self.mapList[self.selectedSong].maps[self.selectedDifficulty][9], false, true) or "??:??"
                gprint(self.mapList[self.selectedSong].songName, width/2+height*0.115, height*.675, 0, nil, height*.035, 0, 0)
                gprint("Duration: ".. durationString, width/2+height*0.115, height*.8, 0, nil, height*.025, 0, 0)
                gprint("Approach Rate: "..(math.floor(self.mapList[self.selectedSong].maps[self.selectedDifficulty][5])).." sec", width/2+height*0.115, height*.825, 0, nil, height*.025, 0, 0)
                gprint("Timing Pity: "..(math.floor(self.mapList[self.selectedSong].maps[self.selectedDifficulty][4]*100)).."%", width/2+height*0.115, height*.85, 0, nil, height*.025, 0, 0)
                gprint("HP Drain: "..(math.floor(self.mapList[self.selectedSong].maps[self.selectedDifficulty][5]*100)).."%", width/2+height*0.115, height*.875, 0, nil, height*.025, 0, 0)
                local numNotes = self.mapList[self.selectedSong].maps[self.selectedDifficulty][8]
                local numDrops = self.mapList[self.selectedSong].maps[self.selectedDifficulty][7]
                gprint(numNotes..(numNotes==1 and" move | " or " moves | ")..numDrops..(numDrops==1 and" drop" or " drops"), width/2+height*0.115, height*.9, 0, nil, height*.025, 0, 0)
            gpop(); gpush()
                setColor(204/255,215/255,1,1)
                gprint("["..self.mapList[self.selectedSong].maps[self.selectedDifficulty][2].."]", width/2+height*0.115, height*.62, 0, nil, height*.05, 0, 0)
                gprint("Song by "..self.mapList[self.selectedSong].artist, width/2+height*0.115, height*.725, 0, nil, height*.025, 0, 0)
                gprint("Map by "..self.mapList[self.selectedSong].maps[self.selectedDifficulty][3], width/2+height*0.115, height*.75, 0, nil, height*.025, 0, 0)
            gpop(); gpush()
                setColor(0,0,0,1)
                for i, v in ipairs(self.transitionCells) do
                   love.graphics.rectangle("fill", width/10*i, height, -width/10, -v[2]) 
                end

                love.graphics.rectangle("fill", 0, 0, width, height*self.loadingTransitionPos)
            gpop()
        end,

        update = function(self, dt)
            local dampening = 3/dt/40 -- used for tweens

            if self.loadedSong then
                self.adjustedSongTime = self.loadedSong:tell()
            end

            -- check inputs
            if math.abs(Mouse.scrollDirection) > 0 then
                self.timeSinceSelectionChanged = 0
                if Mouse.x < dimensions[1]/2 + dimensions[2]/10 then
                    self.selectedSong = self.selectedSong + Mouse.scrollDirection
                else
                    self.selectedDifficulty = self.selectedDifficulty + Mouse.scrollDirection
                end
            end

            if self.mapList[self.selectedSong] and self.mapList[self.selectedSong]:getClick() then
                print("start game")
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

                if button then
                    local hover = button:getHover()
                    if i ~= self.selectedSong and not hover then
                        button.glow = 0.5
                    elseif hover then
                        button.glow = .75
                        if button:getClick() then
                            self.selectedSong = i
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

            if self.loadedSong and not self.loadedSong:isPlaying() then
                self:updateMapPreview()
            end
            
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

            if self.inTransition then
                self.transitionTime = self.transitionTime + dt
                for i, v in ipairs(self.transitionCells) do
                    if self.transitionTime >= i/15 then
                        v[1] = v[1] + dt*16
                        v[2] = v[2] + v[1] * love.graphics.getHeight() / 600
                    end
                end
            end

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
        "skinpath/map_select/map_select_background_sparkle.png"
    }) do
        asset.loadImage(path)
    end
end

local function customDraw(self, pulseSize)
    local width, height = dimensions[1], dimensions[2]
    gpush()
        setColor(1,1,1,1)
        draw(self.image, self.x, self.y, 0, self.sx*self.currentSize, self.sy*self.currentSize, self.ox, self.oy)    
        gprint(self.songName or "", self.x + (self.sx*self.currentSize/20), self.y + (self.sx*self.currentSize/20), 0, nil, self.sy*self.currentSize*0.15)
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
            local sy = self.sy*self.currentSize*0.7
            local sx = sy*4/3
            draw(self.thumbnail, self.x + (self.sx*self.currentSize) - (self.sx*self.currentSize/20), self.y + (self.sy*self.currentSize) - (self.sx*self.currentSize/20), 0, sx, sy, 1, 1)
        end
    gpop()
end

-- Constructor for editor scene objects
function Scene.new()
    local newScene = setmetatable({}, Scene)
    
    -- add the scene to the current list
    newScene.id = #Scene.activeScenes+1
    Scene.activeScenes[#Scene.activeScenes+1] = newScene

    -- load related assets, if applicable
    loadAssets()

    newScene.transitionCells = {{0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}}
    newScene.mapList = IO.getSongs( customDraw, asset.image.map_select_song_bg, asset.image.map_select_song_glow ) -- KEEP THIS LINE
    newScene.loadedBackground = asset.image.main_menu_default_background

    newScene.particleLayer1 = Classes.gui_Particle.newContainer()

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