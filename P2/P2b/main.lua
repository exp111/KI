dofile("include/Queens.lua")
dofile("include/prio.lua")

function mutate(x)
    if math.random(10) < 3 then
        x[math.random(#x)] = math.random(#x)
    end
    return x
end

function reproduce(x, y)
    local c = math.random(#x.initialState)
    local child1 = {}
    local child2 = {}
    for i = 1, #x.initialState do
        if i <= c then
            table.insert(child1, x.initialState[i])
            table.insert(child2, y.initialState[i])
        else
            table.insert(child2, x.initialState[i])
            table.insert(child1, y.initialState[i])
        end
    end
    return {child1, child2}
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
    local n = #population.q
    for j = 1, n, 2 do
        local x = population:pop()
        local y = population:pop()
        local children = reproduce(x, y)
        local child1 = Queens:new(mutate(children[1]))
        child1:heuristic()
        local child2 = Queens:new(mutate(children[2]))
        child2:heuristic()
        newPopulation:push(child1)
        newPopulation:push(child2)
    end
    newPopulation = selectFittest(newPopulation.q:GetAsTable())

    return newPopulation
end

function selectFittest(pop)
    local val = 0
    local size = #pop

    -- Average Fitness
    for _,v in pairs(pop) do
        val = val + v.fit
    end
    val = val / #pop

    s = 0
    --Stalin Sort
    for i = 1, size do
        if pop[i - s].fit > val then
            table.remove(pop, i - s)
            s = s + 1
        end
    end

    --Fill up (with random duplicates)
    local oldSize = #pop

    while #pop ~= size do
        table.insert(pop, pop[math.random(oldSize)])
    end

    --Heapify again
    local prio = PRIO:new(compare)
    prio.q = prio.q:Heapify(pop, compare)
    return prio
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
        print("Fitness: " .. queens.fit)
    end
end