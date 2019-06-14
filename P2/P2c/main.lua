dofile("include/Queens.lua")

function love.load()
    queens = Queens:new({1,1,1,1,1,1,1,1})
    queens:heuristic()
    size = #queens.grid
    boxSize = 100
    queenImg = love.graphics.newImage("Queen.png")
    queenImgFactor = boxSize / queenImg:getHeight()
    love.window.setMode(size * boxSize, size * boxSize, {})

    solutions = {}
    currSolution = 0
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

function Backtrack(assignment, csp, i)
    if #assignment == 8 then
        return assignment
    end

    for j = 1, 8 do
        table.insert(assignment, j)
        --print("lvl: " .. #assignment .. " j: " .. j)
        local queen = Queens:new2(assignment, 8)
        queen:heuristic()
        if queen.fit == 0 then
            --print("lvl: " .. #assignment .. " j: " .. j)
            local result = Backtrack(assignment, csp, i)
            if result ~= false then
                return assignment
            end
        end
        table.remove(assignment)
    end
    return false
end

function love.keypressed(key)
    if key == 'a' then
        local new = Backtrack({}, {}, 0)
        if new ~= false then
        queens = Queens:new(new)
        end
        print(#solutions)
    end
    if key == 's' then
        currSolution = currSolution + 1
        if currSolution >= #solutions then
            currSolution = #solutions > 0 and 1 or 0
        end
        if currSolution ~= 0 then
            queens = solutions[currSolution]
            print(currSolution)
        end
    end
end