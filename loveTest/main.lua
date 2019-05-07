function love.load()
    grid = {}
    size = 20
    for x = 1, size, 1 do
        grid[x] = {}
        for y = 1, size, 1 do
            grid[x][y] = true
        end
    end
    grid[2][1] = nil
    grid[20][19] = nil
    boxSize = 25

    love.window.setMode(size * boxSize, size * boxSize, {})
end

function love.draw()
    -- Draw Board
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, size * boxSize, size * boxSize)
    -- Draw blocked fields
    love.graphics.setColor(0, 0, 0)
    for x = 1, size, 1 do
        for y = 1, size, 1 do
            if grid[x][y] == nil then
                love.graphics.rectangle("fill", (x - 1) * boxSize, (y - 1) * boxSize, boxSize, boxSize)
            end
        end
    end
end

function love.update()
    
end