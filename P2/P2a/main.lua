dofile("include/Queens.lua")

queens = nil
function love.load()
    queens = Queens:new({1,1,1,1,1,1,1,1})
    queens:heuristic()
    size = #queens.grid
    boxSize = 100
    queenImg = love.graphics.newImage("Queen.png")
    queenImgFactor = boxSize / queenImg:getHeight()
    love.window.setMode(size * boxSize, size * boxSize, {})
end

function love.draw()
    for x = 1, size do
        for y = 1, size do
            if (x + y) % 2 == 0 then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.741, 0.765, 0.78)
            end
            love.graphics.rectangle("fill", (x - 1) * boxSize, (y - 1) * boxSize, boxSize, boxSize)
            if queens.grid[x][y].queen == 1 then
                love.graphics.draw(queenImg, (x - 1) * boxSize, (y - 1) * boxSize, 0, queenImgFactor)
            end
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(queens.grid[x][y].h, (x - 1) * boxSize, (y - 1) * boxSize)
        end
    end
end

function love.update()
end

function love.keypressed(key)
    if key == 'a' then
        queens:action({x = 1, y = 1}, {x = 1, y = 5})
    end
    if key == 's' then
        queens:action({x = 2, y = 1}, {x = 1, y = 6})
    end
end