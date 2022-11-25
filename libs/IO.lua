local IO = {
    __global = true
}

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end
-- from PiL2 20.4
local function trimSplit(input, d)
    d = d or "%s"
    local out={}
    for str in string.gmatch(input, "([^"..d.."]+)") do
            table.insert(out, tonumber(str) or trim(str))
    end
    return out
end

function IO.lines( name )
    return love.filesystem.lines( name )
end

local CANVASRATIO = 3/4
local thumbCanvas = love.graphics.newCanvas(120,90)

function IO.createThumbnail( imagePath, thumbnailPath )
    love.graphics.setCanvas(thumbCanvas)
    love.graphics.clear()
    love.graphics.push()
    love.graphics.setColor(1,1,1,1)
    local imageBackground = love.graphics.newImage(imagePath)
    
    local iWidth, iHeight = imageBackground:getDimensions()
    local iRatio = iWidth/iHeight
    
    local scaleByWidth = false
    if iRatio > CANVASRATIO then
        scaleByWidth = true
    end

    drawImage(imageBackground, 60, 45, 0, (not scaleByWidth and 120 or 90*iRatio), (not scaleByWidth and 120/iRatio or 90), 0.5, 0.5)
    love.graphics.pop()
    love.graphics.setCanvas()

    love.filesystem.write(thumbnailPath, "")
    thumbCanvas:newImageData():encode("png", thumbnailPath)
end

function IO.getSongs(customDraw, bg, glow)
    local baseDirectory = "maps"

    -- first, get the map cache

    --[[
        MAP CACHE FORMAT
        SONG ID|!|SONG NAME|!|SONG ARTIST|!|SONG PATH|!|BG PATH|!|PREVIEW TIME|!|TIME, BPM, TIME, BPM|!|#DIFFS
            MAP ID|!|MAP NAME|!|MAPPER|!|TIMING STRICTNESS|!|APPROACH RATE|!|HP DRAIN|!|#DROPS|!|#NOTES|!|START TIME|!|END TIME
    ]]
    if not love.filesystem.getInfo("MAP_CACHE") or love.filesystem.getInfo("NOSAVE_CACHE") then
        love.filesystem.write("MAP_CACHE", "")
    end

    local maps = {}
    local iterator = love.filesystem.lines("MAP_CACHE")

    local line = iterator()
    local idChecks = {}

    while line do
        if line == "" then break end
        
        local unpack = trimSplit(line, "|!|")
        local button = Classes.gui_GuiElement.newButton(bg)
            button.draw = customDraw
            button.glow = 0.5; button.glowImage = glow
            button.songId = unpack[1]
            button.songName = unpack[2]
            button.artist = unpack[3]
            button.folder = unpack[4]
            button.songPath = unpack[5]
            button.bgPath = unpack[6]
            button.previewTime = unpack[7]
            button.path = "maps/"

            idChecks[button.songId] = true
            
            -- alternating - 1: time, 2: bpm, 3: time, 4: bpm, etc
            button.bpmEvents = trimSplit(unpack[8], ",") 

            local mapCount = unpack[9]
            button.maps = {}

            for i = 1, mapCount do
                local mapUnpack = trimSplit( iterator() , "|!|")
                
                -- redundant, but idk what i'm doing with this yet
                button.maps[#button.maps+1] = {
                    mapUnpack[1],
                    mapUnpack[2],
                    mapUnpack[3],
                    mapUnpack[4],
                    mapUnpack[5],
                    mapUnpack[6],
                    mapUnpack[7],
                    mapUnpack[8],
                    mapUnpack[9],
                    mapUnpack[10]
                }
                
            end

        maps[#maps+1] = button
        
    line = iterator()
    end

    -- get files in maps directory
    local songPack = love.filesystem.getDirectoryItems( baseDirectory )
    local thumbCanvas = love.graphics.newCanvas( 120, 90 )
    local canvasRatio = 4/3

    for _, name in ipairs(songPack) do
        local songID = tonumber( trimSplit(name)[1] )
        if not idChecks[songID] then
            -- do a deep read of the song data
            
            local mapsDirectory = baseDirectory .. "/" .. name .. "/maps"
            local mapFiles = love.filesystem.getDirectoryItems( mapsDirectory )
            local songLine = ""
            local mapLines = {}

            local button = Classes.gui_GuiElement.newButton(bg)
                button.draw = customDraw
                button.glow = 0.5; button.glowImage = glow
                button.maps = {}; button.bpmTracker = {{0,1}, {0,0}} -- first values held
                -- other stuff set in for loop

            for i, v in ipairs(mapFiles) do
                print("Initializing\t" .. name .. "\t" .. v)

                local mapText = love.filesystem.read( mapsDirectory .. "/" .. v )
                local notes, events, params = Classes.game_Song.compileInfo( mapText )

                if i == 1 then -- initialize song data
                    local eventString = tostring(params.general.StartOffset) .. "," .. tostring(params.general.BPM)
                    
                    for i, event in ipairs(events) do
                        if tonumber(events[i][5]) then
                            eventString = eventString .. "," .. tostring(events[i][1]) .. "," .. tostring(events[i][5])
                            button.bpmTracker[#button.bpmTracker+1] = {events[i][1], events[i][5]}
                        end
                    end

                    songLine = tostring(params.general.SongID) .. "|!|" ..
                               params.general.Title .. "|!|" ..
                               params.general.Artist .. "|!|" ..
                               name .. "|!|" ..
                               params.general.SongPath .. "|!|" ..
                               params.general.BGPath .. "|!|" .. 
                               params.general.PreviewTime .. "|!|" ..
                               eventString .. "|!|" ..
                               #mapFiles
                    
                    button.songId = params.general.SongID
                    button.songName = params.general.Title
                    button.artist = params.general.Artist
                    button.folder = name
                    button.songPath = params.general.SongPath
                    button.bgPath = params.general.BGPath
                    button.previewTime = params.general.PreviewTime
                    
                    button.bpmTracker[2] = {params.general.StartOffset, params.general.BPM}
                    
                    -- check the thumbnail path
                    local thumbnailPath = baseDirectory .. "/" .. name .. "/thumbnail.png"

                    if not love.filesystem.getInfo(thumbnailPath) and love.filesystem.getInfo(baseDirectory .. "/" .. name .. "/" .. params.general.BGPath) then
                        -- generate a thumbnail
                        print("generating thumbnail")
                        IO.createThumbnail(baseDirectory .. "/" .. name .. "/" .. params.general.BGPath, thumbnailPath)
                    end

                end
                
                local dropCount = 0
                for _, note in ipairs(notes) do
                    if note:getType() == "DROP" then
                        dropCount = dropCount + 1
                    end
                end

                local moveCount = #notes - dropCount


                mapLines[#mapLines+1] = tostring(params.meta.MapID) .. "|!|" ..
                                        params.meta.Difficulty .. "|!|" ..
                                        params.meta.Mapper .. "|!|" ..
                                        tostring(params.meta.TimingDifficulty) .. "|!|" ..
                                        tostring(params.meta.ApproachRate) .. "|!|" ..
                                        tostring(params.meta.HPDrain) .. "|!|" ..
                                        tostring(dropCount) .. "|!|" ..
                                        tostring(moveCount) .. "|!|" ..
                                        tostring(notes[1]:getTime()) .. "|!|" ..
                                        tostring(notes[#notes]:getTime())
                
                button.maps[#button.maps+1] = {
                    params.meta.MapID,
                    params.meta.Difficulty,
                    params.meta.Mapper,
                    params.meta.TimingDifficulty,
                    params.meta.ApproachRate,
                    params.meta.HPDrain,
                    dropCount, moveCount,
                    notes[1]:getTime(),
                    notes[#notes]:getTime()
                } 
            end

            -- add the metadata to the map cache
            love.filesystem.append("MAP_CACHE", songLine .. "\n")

            for _, mapLine in ipairs(mapLines) do
                love.filesystem.append("MAP_CACHE", mapLine .. "\n")
            end

            maps[#maps+1] = button
        else
            -- map already loaded
        end
    end

    return maps -- CHANGE LATER
end

function IO.copyFolder( root, destination )
    local folderName = trimSplit(root, "/")
    folderName = folderName[#folderName]

    local folderItems = love.filesystem.getDirectoryItems(root)

    local copyTarget = destination .. "/" .. folderName
    if not love.filesystem.getInfo(copyTarget) then
        love.filesystem.createDirectory(copyTarget)
    end

    for i, name in ipairs(folderItems) do
        if love.filesystem.getInfo(root.."/"..name).type=="directory" then
            -- it's a folder
            love.filesystem.createDirectory(copyTarget .. "/" .. name)
            IO.copyFolder(root .. "/" .. name, copyTarget)
        else
            -- it's a file
            local origFilename = root.."/"..name
            local copyFilename = copyTarget.."/"..name
            
            local fileData = love.filesystem.read(origFilename)
            love.filesystem.write(copyFilename, fileData)
        end
    end
end

function IO.init()
    -- make a maps folder if it doesn't exist
    if not love.filesystem.getInfo("maps") then
        print("PRE-LOADING DEMO MAPS")
        IO.copyFolder("assets/maps", "")
        love.filesystem.write("MAP_CACHE", "")
    end
end

return IO