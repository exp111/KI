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
        wumpus = 0
        }, Field_mt)
end

Player = {}
local Player_mt = Class(Player)

function Player:new(pos)
    return setmetatable({
        pos = pos,
        rotation = 0,
        hasGold = 0
        }, Field_mt)
end

Wumpus = {}
local Wumpus_mt = Class(Wumpus)

function Wumpus:new(startPos, size)
    -- Init Grid
    local grid = {}
    local hasGold = 0
    local hasWumpus = 0
    for x = 1, size do
        grid[x] = {}
        for y = 1, size do
            local isStartPos = startPos.x == x and startPos.y == y
            local isPit = x ~= 1 and y ~= 1 and math.random(10) <= 2 and 1 or 0
            grid[x][y] = Field:new(isStartPos, isPit)
        end
    end

    -- Gold
    local gold = {x = math.random(size), y = math.random(size)}
    grid[gold.x][gold.y].gold = 1

    local wumpus = {x= math.random(size), y = math.random(size)}
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
        startingPos = startPos
    }, Wumpus_mt)
end

function Wumpus:move(pos)
    self.player.pos = pos
    self.grid[pos.x][pos.y].visited = 1
    if self.grid[pos.x][pos.y].wumpus == 1 then
        return 1
    end
    if self.grid[pos.x][pos.y].pit == 1 then
        return 2
    end
    return 0 -- 0 if ok, 1 if wumpus, 2 if pit
end

function Wumpus:action(key)
    self.score = self.score - (self.scoreBoard[key] or 0)
end

function Wumpus:getDelta(rotation)
    local delta = {}
    delta.x = ((rotation / halfPi) % 2 == 0) and 0 or 1 --remove y
    delta.y = delta.x == 0 and 1 or 0 --remove x
    delta.x = delta.x == 1 and (rotation % twoPi > halfPi and -1 or 1) or 0
    delta.y = delta.y == 1 and (rotation % twoPi == 0 and -1 or 1) or 0
    return delta
end

function Wumpus:getPercept(pos, rotation)
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
    percept.scream = self.grid[pos.x][pos.y].wumpus == 1 and 1 or 0
    local delta = self.getDelta(pos, rotation)
    local newPos = {x = pos.x + delta.x, y = pos.y + delta.y}
    if newPos.x < 1 or newPos.x > size or newPos.y < 1 or newPos.y > size then --OOB
        percept.bump = 1
    end
    return percept
end