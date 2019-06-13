dofile("include/Queens.lua")
dofile("include/prio.lua")

Individual = {state = {}, fitness = 0}
function mutate(x)
    if math.random(10) < 3 then
        x[math.random(#x)] = math.random(#x)
    end
    return x
end

function reproduce(x, y)
    local c = math.random(#x.initialState)
    local child = {}
    for i = 1, #x.initialState do
        if i <= c then
            table.insert(child, x.initialState[i])
        else
            table.insert(child, y.initialState[i])
        end
    end
    return child
end

function compare(a,b)
    return a.fit < b.fit
end

function randomState(n)
    local state = {}
    for i = 1, n do
        table.insert(state, math.random(n))
    end
    return state
end

function geneticAlgorithm(population)
    local newPopulation = PRIO:new(compare)
    local n = #population.q / 2 --Remove last ones cuz fuck them
    for j = 1, n, 2 do
        local x = population:pop()
        local y = population:pop()
        local child = reproduce(x, y)
        local child1 = Queens:new(mutate(child))
        child1:heuristic()
        local child2 = Queens:new(mutate(child))
        child2:heuristic()
        newPopulation:push(child1)
        newPopulation:push(child2)

        if j ~= n then
            newPopulation:push(x)
            newPopulation:push(y)
        end
    end
    return newPopulation
end

function love.load()
    queens = Queens:new({1,1,1,1,1,1,1,1})
    queens:heuristic()
    size = #queens.grid
    boxSize = 100
    queenImg = love.graphics.newImage("Queen.png")
    queenImgFactor = boxSize / queenImg:getHeight()
    love.window.setMode(size * boxSize, size * boxSize, {})

    math.randomseed(os.time())

    population = PRIO:new(compare)
    for i = 1, 10 do
        local cur = Queens:new(randomState(size))
        cur:heuristic()
        population:push(cur)
    end

    queens = population:pop()
    population:push(queens)
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
        for i = 1, 100 do
            population = geneticAlgorithm(population)
            queens = population:peek()
        end
        print("Size: " .. population.q:Size())
        print(queens.fit)
    end
end