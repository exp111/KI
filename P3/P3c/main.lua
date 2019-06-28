dofile("include/Wumpus.lua")
dofile("P3c/algo.lua")

function love.load()
    --math.randomseed(os.time())
    math.randomseed(1337)

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

    horn = Horn:new()
    tellHornPercept({x = 1, y = 1})
    initHorn(horn, size)

    danger = checkForDanger()
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
    local percept = wumpus:getPercept(wumpus.player.pos)
    local perceptString = string.format("Percept: [%s %s %s %s %s] (Stench, Breeze, Glitter, Bump, Scream)", 
        percept.stench == 1 and 'S' or 'N',
        percept.breeze == 1 and 'B' or 'N',
        percept.glitter == 1 and 'G' or 'N',
        percept.bump == 1 and 'B' or 'N',
        percept.scream == 1 and 'S' or 'N'
    )
    love.graphics.print(perceptString, 10, barPosY + 15)
    love.graphics.print("Action: (F, L, R, G, S or C)?", 10, barPosY + 30)
    love.graphics.print(eventText, 10, barPosY + 45)

    if danger.wumpus ~= nil then
        love.graphics.setColor(danger.wumpusColor)
        love.graphics.print(danger.wumpus, 200, barPosY + 30)
        love.graphics.setColor(danger.pitColor)
        love.graphics.print(danger.pit, 200, barPosY + 45)
    end
end

function love.update()
end

function love.keypressed(key)
    local nextPos = getNextPos()
    local needToAdd = false
    if wumpus.grid[nextPos.x] ~= nil and wumpus.grid[nextPos.x][nextPos.y] ~= nil and wumpus.grid[nextPos.x][nextPos.y].visited == 0 then
        needToAdd = true
    end
    eventText = wumpus:action(key)
    if wumpus.player.dead == 1 or wumpus.finished == 1 then
        return
    end
    if needToAdd and key == 'f' then
        tellHornPercept(nextPos)
    end

    if key == 'f' or key == 'r' or key == 'l' then
        danger = checkForDanger()
    end
end

Horn = {}
local Horn_mt = Class(Horn)

function Horn:new()
    return setmetatable({
        rules = {}
        }, Horn_mt)
end

function Horn:tell(premise, conclusion) -- clauses: {A, B => C}
    table.insert(self.rules, HC:new(premise, conclusion))
end

function Horn:tellClause(hc)
    table.insert(self.rules, hc)
end

function Horn:ask(q)
    return PLFCEntails(self.rules, q)
end

HC = {}
local HC_mt = Class(HC_mt)

function HC:new(premise, conclusion)
    return setmetatable({
        premise = premise or {},
        conclusion = conclusion
    }, HK_mt)
end

function tellHornPercept(pos)
    local percept = wumpus:getPercept(pos)
    if percept.stench == 1 then
        horn:tell({},'s' .. pos.x .. pos.y)
    else
        horn:tell({}, '-s' .. pos.x .. pos.y)
    end
    if percept.breeze == 1 then
        horn:tell({},'b' .. pos.x .. pos.y)
    else
        horn:tell({},'-b' .. pos.x .. pos.y)
    end
end

function initHorn(horn, size)
    for x = 1, size do
        for y = 1, size do
            local pos = { x = x, y = y }
            local sur = getSurroundingFields(pos, size)
            addRule(horn, sur, pos)
        end        
    end
end

function addRule(horn, sur, center)
    local sense = {'s', 'b'}
    local concl = {'w', 'p'}

    for i = 1, #sense do 
        for x = 1, #sur do
            local h = HC:new()
            h.conclusion = concl[i] .. sur[x]
            table.insert(h.premise , sense[i] .. center.x .. center.y)

            for y = 1, #sur do -- s11, -s21 => w12; s22, -s21, -s32, -s12 => w23
                if y ~= x then
                    table.insert(h.premise , '-' .. sense[i] .. sur[y])                    
                end
            end
            horn:tellClause(h)
        end
    end
end

function getSurroundingFields(pos, size)
    local sur = {}
    
    if pos.y + 1 <= size then
        table.insert(sur, pos.x .. pos.y + 1)
    end
    if pos.y - 1 >= 1 then        
        table.insert(sur, pos.x .. pos.y - 1)
    end
    if pos.x + 1 <= size then
        table.insert(sur, pos.x + 1 .. pos.y)
    end
    if pos.x - 1 >= 1 then
        table.insert(sur, pos.x - 1 .. pos.y)
    end
    return sur
end

function getNextPos()
    local delta = wumpus:getDelta(wumpus.player.rotation)
    local nextPos = { x = wumpus.player.pos.x + delta.x, y = wumpus.player.pos.y + delta.y }
    return nextPos
end

function checkForDanger()
    local ret = {}
    local nextPos = getNextPos()
    if nextPos.x >= 1 and nextPos.x <= size and nextPos.y >= 1 and nextPos.y <= size then
        local xy = nextPos.x .. nextPos.y
        local wumpus = horn:ask("w" .. xy)
        local pit = horn:ask("p" .. xy)
        ret.wumpus = (wumpus and "" or "Maybe ") .. "Wumpus ahead"
        ret.wumpusColor = wumpus and {1, 0, 0} or {0, 0, 0} 
        ret.pit = (pit and "" or "Maybe ") .. "Pit ahead"
        ret.pitColor = pit and {1, 0, 0} or {0, 0, 0}
    end
    return ret
end