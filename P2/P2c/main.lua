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

function love.keypressed(key)
    if key == 'a' then
        local new = Backtracking(size)
        if #new > 0 then
        --queens = Queens:new(new)
        end
        print(#new)
        solutions = new
    end
    if key == 's' then
        currSolution = currSolution + 1
        if currSolution >= #solutions then
            currSolution = #solutions > 0 and 1 or 0
        end
        if currSolution ~= 0 then
            queens = Queens:new(solutions[currSolution])
            print(currSolution)
        end
    end
end

function Backtracking(max)
    local ret = Backtrack({{}}, max)
    table.remove(ret, 1) -- last wip assignment is still in queue
    return ret
end

function Backtrack(assignment, max)
    local cur = assignment[1] -- current wip is always in front
    if #cur == max then
        local curCopy = copy(cur)
        table.insert(assignment, curCopy)
        return assignment
    end

    for j = 1, max do
        local cur = assignment[1]
        table.insert(cur, j) -- try new state
        local queen = Queens:new2(cur, max)
        queen:heuristic()
        if queen.fit == 0 then -- valid
            Backtrack(assignment, max) -- no need to add cuz everything is pointered
        end
        table.remove(cur) -- remove the state so we can do a new one -> if it was valid solution is already added else fuck it
    end
    return assignment
end

function copy(t)
    local newT = {}
    for k, v in pairs(t) do
        newT[k] = v
    end
    return newT
end