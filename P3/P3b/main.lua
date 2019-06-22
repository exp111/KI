dofile("include/Wumpus.lua")
dofile("P3b/algo.lua")

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

    cnf = CNF:new()
    addRule(cnf, {x = 1, y = 1}, size) --init startpos
    local percept = wumpus:getPercept(wumpus.player.pos)
    local xy = wumpus.player.pos.x .. wumpus.player.pos.y
    cnf:tell({percept.breeze == 1 and "b" .. xy or "-b" .. xy})
    cnf:tell({percept.stench == 1 and "s" .. xy or "-s" .. xy})

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
        love.graphics.print(danger.wumpus, 200, barPosY + 30)
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
        addRule(cnf, wumpus.player.pos, size)
        local percept = wumpus:getPercept(wumpus.player.pos)
        local xy = wumpus.player.pos.x .. wumpus.player.pos.y
        cnf:tell({percept.breeze == 1 and "b" .. xy or "-b" .. xy})
        cnf:tell({percept.stench == 1 and "s" .. xy or "-s" .. xy})
    end

    if key == 'a' then--key == 'l' or key == 'r' or key == 'f' then
        print("#rules: " .. #cnf.rules)
        danger = checkForDanger()
    end
end

CNF = {}
local CNF_mt = Class(CNF)

function CNF:new()
    return setmetatable({
        rules = {}
        }, CNF_mt)
end

function CNF:tell(rule) -- clauses: {"x", "y", "-x"}
    table.insert(self.rules, rule)
end

function CNF:ask(alpha)
    --print("Rules: " .. stringify(self.rules))
    --print("Alpha: " .. negate(alpha))
    return PLResolution(self.rules, {{negate(alpha)}})
end

-- b22 <=> p12 v p21 v p23 v p32
-- (b22 => p12 v p21 v p23 v p32) n (p12 v p21 v p23 v p32 => b22)
-- (-b22 v p12 v p21 v p23 v p32) n (-(p12 v p21 v p23 v p32) v b22)
-- (-b22 v p12 v p21 v p23 v p32) n ((-p12 n -p21 n -p23 n -p32) v b22)
-- (-b22 v p12 v p21 v p23 v p32) n (-p12 v b22) n (-p21 v b22) n (-p23 v b22) n (-p32 v b22)
function addRule(cnf, pos, size)
    local arr = {{pos.x, pos.y - 1}, {pos.x - 1, pos.y}, {pos.x + 1, pos.y}, {pos.x, pos.y + 1}}
    local xy = pos.x .. pos.y
    local ruleB = {"-b" .. xy}
    local ruleS = {"-s" .. xy}
    cnf:tell({"b" .. xy, "-p" .. xy}) -- if there's no smell there is no pit on the same tile
    cnf:tell({"s" .. xy, "-w" .. xy}) -- if there's no smell there is no pit on the same tile
    for _, v in pairs(arr) do
        if v[1] >= 1 and v[1] <= size and v[2] >= 1 and v[2] <= size then
            local v12 = v[1] .. v[2]
            table.insert(ruleB, "p" .. v12)
            table.insert(ruleS, "w" .. v12)
            cnf:tell({"b" .. xy, "-p" .. v12})
            cnf:tell({"s" .. xy, "-w" .. v12})
        end
    end
    cnf:tell(ruleB)
    cnf:tell(ruleS)
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
        ret.wumpus = (cnf:ask("-w" .. xy) and "No " or (cnf:ask("w" .. xy) and "" or "Maybe ")) .. "Wumpus ahead"
        ret.pit = (cnf:ask("-p" .. xy) and "No " or (cnf:ask("p" .. xy) and "" or "Maybe ")) .. "Pit ahead"
    end
    return ret
end

--local c = CNF:new()
--addRule(c, {x = 1, y = 1}, 4)
--addRule(c, {x = 1, y = 2}, 4)
--addRule(c, {x = 2, y = 1}, 4)
--c:tell({"-b22"})
--c:tell({"-b11"})
--c:tell({"-b12"})
--c:tell({"b21"})
--c:tell({"-p11"})
--c:tell({"-p22"})
--print(stringify(c.rules))
--print(c:ask("p31")) --true

--c = CNF:new()
--addRule(c, {x = 1, y = 1}, 4)
--addRule(c, {x = 2, y = 1}, 4)
--c:tell({"b11"})
--c:tell({"-b21"})
--print(c:ask("p12")) --should be true