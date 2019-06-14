dofile("include/Wumpus.lua")

function love.load()
    wumpus = Wumpus:new({x = 1, y = 1}, 4)
    size = #wumpus.grid
    boxSize = 100
    barSize = 50
    love.window.setMode(size * boxSize, size * boxSize + barSize, {})

    playerImg = love.graphics.newImage("Player.png")
    playerImgFactor = (boxSize / 2) / playerImg:getHeight()
    playerImgWidth = playerImg:getWidth() / 2
    playerImgHeight = playerImg:getHeight() / 2

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
            if cur.player == 1 then
                love.graphics.draw(playerImg, boxPos.x + boxSize / 2, boxPos.y + boxSize / 2, 
                wumpus.rotation, playerImgFactor, playerImgFactor, playerImgWidth, playerImgHeight)
            end
        end
    end
    -- Other Stuff (Score etc)
    local barPosY = size * boxSize
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Score: " .. wumpus.score, 10, barPosY)
    love.graphics.print("Percept: " .. "TODO", 10, barPosY + 15) -- TODO: this
    love.graphics.print("Action: (F, L, R, G, S or C)?", 10, barPosY + 30)
end

function love.update()
end

function love.keypressed(key)
    if key == 'l' then
        wumpus.rotation = wumpus.rotation - halfPi
        if wumpus.rotation < 0 then
            wumpus.rotation = wumpus.rotation + twoPi
        end
    end
    if key == 'r' then
        wumpus.rotation = wumpus.rotation + halfPi
        if wumpus.rotation > twoPi then
            wumpus.rotation = wumpus.rotation - twoPi
        end
    end
end