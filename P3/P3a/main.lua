dofile("include/Wumpus.lua")
function math.clamp(low, n, high) return math.min(math.max(n, low), high) end

function love.load()
    math.randomseed(os.time())

    wumpus = Wumpus:new({x = 1, y = 1}, 4)
    size = #wumpus.grid
    boxSize = 100
    barSize = 65
    love.window.setMode(size * boxSize, size * boxSize + barSize, {})

    playerImg = love.graphics.newImage("Player.png")
    playerImgFactor = (boxSize / 2) / playerImg:getHeight()
    playerImgWidth = playerImg:getWidth() / 2
    playerImgHeight = playerImg:getHeight() / 2

    eventText = ""

    grey = {0.741, 0.765, 0.78}
    halfPi = math.pi / 2
    twoPi = math.pi * 2
end

function love.draw()
    love.graphics.setBackgroundColor(grey)
    -- Grid
    for x = 1, size do
        for y = 1, size do
            local cur = wumpus.grid[x][y]
            -- Draw Field
            local boxPos = { x = (x - 1) * boxSize, y = (y - 1) * boxSize}
            if cur.visited == 1 then
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", boxPos.x, boxPos.y, boxSize, boxSize)
                -- TODO: draw other stuff
            else
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("fill", boxPos.x, boxPos.y, boxSize, boxSize)
            end
            love.graphics.setColor(grey)
            love.graphics.rectangle("line", boxPos.x, boxPos.y, boxSize, boxSize)
            if x == wumpus.player.pos.x and y == wumpus.player.pos.y then
                love.graphics.draw(playerImg, boxPos.x + boxSize / 2, boxPos.y + boxSize / 2, 
                wumpus.player.rotation, playerImgFactor, playerImgFactor, playerImgWidth, playerImgHeight)
            end
        end
    end
    -- Other Stuff (Score etc)
    local barPosY = size * boxSize
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Score: " .. wumpus.score, 10, barPosY)
    local percept = wumpus:getPercept(wumpus.player.pos, wumpus.player.rotation)
    local perceptString = string.format("Percept: [%s %s %s %s %s] (Stench, Breeze, Glitter, Bump, Scream)", 
        percept.stench == 1 and 'S' or 'N',
        percept.breeze == 1 and 'B' or 'N',
        percept.glitter == 1 and 'G' or 'N',
        percept.bump == 1 and 'B' or 'N',
        percept.scream == 1 and 'S' or 'N'
    )
    love.graphics.print(perceptString, 10, barPosY + 15) -- TODO: this
    love.graphics.print("Action: (F, L, R, G, S or C)?", 10, barPosY + 30)
    love.graphics.print(eventText, 10, barPosY + 45)
end

function love.update()
end

function love.keypressed(key)
    wumpus:action(key)
    
    if key == 'l' then -- LEFT
        wumpus.player.rotation = wumpus.player.rotation - halfPi
        if wumpus.player.rotation < 0 then
            wumpus.player.rotation = wumpus.player.rotation + twoPi
        end
        eventText = "Turned left"
    end
    if key == 'r' then -- RIGHT
        wumpus.player.rotation = wumpus.player.rotation + halfPi
        if wumpus.player.rotation > twoPi then
            wumpus.player.rotation = wumpus.player.rotation - twoPi
        end
        eventText = "Turned right"
    end
    if key == 'f' then -- FORWARD
        local delta = wumpus:getDelta(wumpus.player.rotation)
        local newPos = {x = wumpus.player.pos.x + delta.x, y = wumpus.player.pos.y + delta.y}
        if newPos.x >= 1 and newPos.x <= size and newPos.y >= 1 and newPos.y <= size then
            local result = wumpus:move(newPos)
            if result == 0 then
                eventText = "Moved forward"
            end
            if result == 1 then
                eventText = "The wumpus ate you"
                wumpus:action('w')
            end
            if result == 2 then
                eventText = "You fell down a pit"
                wumpus:action('p')
            end
        else
            eventText = "Can't move"
        end
    end
    if key == 'g' then -- GRAB
        if wumpus.grid[wumpus.player.pos.x][wumpus.player.pos.y].gold == 1 then
            eventText = "Grabbed Gold"
            wumpus.player.hasGold = 1
            wumpus.grid[wumpus.player.pos.x][wumpus.player.pos.y].gold = 0
        else
            eventText = "No Gold"
        end
    end
    if key == 's' then -- TODO: SHOOT
        eventText = "Shot Arrow"
    end
    if key == 'c' then -- TODO: c
        
    end
end