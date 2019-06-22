dofile("include/Class.lua")

Field = {}
local Field_mt = Class(Field)

function Field:new(visited, pit)
    return setmetatable({
        visited = visited and 1 or 0,
        stench = 0,
        breeze = 0,
        glitter = 0,
        gold = 0,
        pit = pit,
        wumpus = 0,
        wumpusDead = 0
        }, Field_mt)
end

Player = {}
local Player_mt = Class(Player)

function Player:new(pos)
    return setmetatable({
        pos = pos,
        rotation = 0,
        hasGold = 0,
        arrows = 1,
        dead = 0
        }, Field_mt)
end

Wumpus = {}
local Wumpus_mt = Class(Wumpus)

halfPi = math.pi / 2
twoPi = math.pi * 2

function Wumpus:new(startPos, size)
    -- Init Grid
    local grid = {}
    local hasGold = 0
    local hasWumpus = 0
    for x = 1, size do
        grid[x] = {}
        for y = 1, size do
            local isStartPos = startPos.x == x and startPos.y == y
            local isPit = not isStartPos and math.random(10) <= 2 and 1 or 0
            grid[x][y] = Field:new(isStartPos, isPit)
        end
    end

    -- Gold
    local gold = {x = math.random(size), y = math.random(size)}
    grid[gold.x][gold.y].gold = 1

    local wumpus
    repeat
        wumpus = {x= math.random(size), y = math.random(size)}
    until wumpus.x ~= startPos.x and wumpus.y ~= startPos.y
    grid[wumpus.x][wumpus.y].wumpus = 1

    local scoreBoard = {
        f = 1,
        l = 1,
        r = 1,
        g = 1,
        s = 11,
        c = 1,
        p = 1000, --Pit
        w = 1000 --Wumpus
    }

    return setmetatable({
        grid = grid,
        score = 0,
        player = Player:new(startPos),
        scoreBoard = scoreBoard,
        startPos = startPos,
        scream = 0,
        finished = 0
    }, Wumpus_mt)
end

function Wumpus:move(pos)
    self.player.pos = pos
    self.grid[pos.x][pos.y].visited = 1
    if self.grid[pos.x][pos.y].wumpus == 1 and self.grid[pos.x][pos.y].wumpusDead == 0 then
        self.player.dead = 1
        return 1
    end
    if self.grid[pos.x][pos.y].pit == 1 then
        self.player.dead = 1
        return 2
    end
    return 0 -- 0 if ok, 1 if wumpus, 2 if pit
end

function Wumpus:action(key)
    if wumpus.player.dead == 1 then
        return "You're dead"
    end
    if wumpus.finished == 1 then
        return "You already climbed out"
    end
    
    -- Reset
    self.player.bump = 0
    self.scream = 0
    
    if key == 'l' then -- LEFT
        self:addScore(-1)
        wumpus:rotate(-halfPi)
        return "Turned left"
    end
    if key == 'r' then -- RIGHT
        self:addScore(-1)
        wumpus:rotate(halfPi)
        return "Turned right"
    end
    if key == 'f' then -- FORWARD
        self:addScore(-1)
        local result = wumpus:forward()
        if result == -1 then
            return "Can't move"
        end
        if result == 0 then
           return "Moved forward"
        end
        if result == 1 then
            self:addScore(-1000)
            return "The wumpus ate you"
        end
        if result == 2 then
            self:addScore(-1000)
            return "You fell down a pit"
        end
    end
    if key == 'g' then -- GRAB
        self:addScore(-1)
        if wumpus.grid[wumpus.player.pos.x][wumpus.player.pos.y].gold == 1 then
            wumpus.player.hasGold = 1
            wumpus.grid[wumpus.player.pos.x][wumpus.player.pos.y].gold = 0
            return "Grabbed Gold"
        else
            return "No Gold"
        end
    end
    if key == 's' then -- SHOOT
        if wumpus:shoot() then
            self:addScore(-11) --TODO: 10 for shooting the arrow AND 1 for action?
            return "Shot Arrow"
        else
            self:addScore(-1) --TODO: is this a valid action
            return "No Arrows"
        end
    end
    if key == 'c' then -- CLIMB
        self:addScore(-1)
        if wumpus.player.pos.x == wumpus.startPos.x and wumpus.player.pos.y == wumpus.startPos.y then
            if wumpus.player.hasGold == 1 then
                self:addScore(1000)
            end
            self.finished = 1
            
            return "Climbed out of the cave"
        else
            return "Can't climb from here"
        end
    end

    return "Unknown Key"
end

function Wumpus:addScore(val)
    self.score = self.score + val
end

function Wumpus:getDelta(rotation)
    local delta = {}
    delta.x = ((rotation / halfPi) % 2 == 0) and 0 or 1 --remove y
    delta.y = delta.x == 0 and 1 or 0 --remove x
    delta.x = delta.x == 1 and (rotation % twoPi > halfPi and -1 or 1) or 0
    delta.y = delta.y == 1 and (rotation % twoPi == 0 and -1 or 1) or 0
    return delta
end

function Wumpus:forward()
    local delta = self:getDelta(self.player.rotation)
    local newPos = {x = self.player.pos.x + delta.x, y = self.player.pos.y + delta.y}
    if newPos.x >= 1 and newPos.x <= #self.grid and newPos.y >= 1 and newPos.y <= #self.grid then
        local result = self:move(newPos)
        return result
    else
        self.player.bump = 1
        return -1
    end
end

function Wumpus:getPercept(pos)
    local percept = {breeze = 0, stench = 0, glitter = 0, bump = 0, scream = 0}
    if pos.x < 1 or pos.x > #self.grid or pos.y < 1 or pos.y > #self.grid then --invalid pos
        return percept
    end
    for i = -1, 1, 2 do
        local newPos = {x = pos.x + i, y = pos.y + i}
        if newPos.x >= 1 and newPos.x <= #self.grid then
            if self.grid[newPos.x][pos.y].wumpus == 1 then
                percept.stench = 1
            end
            if self.grid[newPos.x][pos.y].pit == 1 then
                percept.breeze = 1
            end
        end

        if newPos.y >= 1 and newPos.y <= #self.grid then
            if self.grid[pos.x][newPos.y].wumpus == 1 then
                percept.stench = 1
            end
            if self.grid[pos.x][newPos.y].pit == 1 then
                percept.breeze = 1
            end
        end
    end
    percept.glitter = self.grid[pos.x][pos.y].gold == 1 and 1 or 0
    percept.breeze = percept.breeze == 1 and 1 or self.grid[wumpus.player.pos.x][wumpus.player.pos.y].pit == 1 and 1 or 0
    percept.stench = percept.stench == 1 and 1 or self.grid[wumpus.player.pos.x][wumpus.player.pos.y].wumpus == 1 and 1 or 0
    percept.scream = self.scream
    percept.bump = self.player.bump
    return percept
end

function Wumpus:rotate(rad)
    self.player.rotation = wumpus.player.rotation + rad
    if self.player.rotation < 0 then
        self.player.rotation = self.player.rotation + twoPi
    end
    if self.player.rotation > twoPi then
        self.player.rotation = self.player.rotation - twoPi
    end
end

function Wumpus:shoot()
    if self.player.arrows <= 0 then
        return false 
    end

    self.player.arrows = self.player.arrows - 1

    local delta = self:getDelta(self.player.rotation)
    local arrowPos = { x = self.player.pos.x + delta.x, y = self.player.pos.y + delta.y }
    while arrowPos.x >= 1 and arrowPos.x <= #self.grid and arrowPos.y >= 1 and arrowPos.y <= #self.grid do
        if self.grid[arrowPos.x][arrowPos.y].wumpus == 1 and self.grid[arrowPos.x][arrowPos.y].wumpusDead == 0 then
            self.scream = 1
            self.grid[arrowPos.x][arrowPos.y].wumpusDead = 1
            break 
        end
        arrowPos.x = arrowPos.x + delta.x
        arrowPos.y = arrowPos.y + delta.y
    end

    return true
end