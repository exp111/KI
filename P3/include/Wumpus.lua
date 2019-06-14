dofile("include/Class.lua")

Field = {}
local Field_mt = Class(Field)

function Field:new(visited)
    return setmetatable({
        visited = visited and 1 or 0,
        stench = 0,
        breeze = 0,
        glitter = 0,
        }, Field_mt)
end

Player = {}
local Player_mt = Class(Player)

function Player:new(pos)
    return setmetatable({
        pos = pos,
        rotation = 0
        }, Field_mt)
end

Wumpus = {}
local Wumpus_mt = Class(Wumpus)

function Wumpus:new(startPos, size)
    -- Init Grid
    local grid = {}
    for x = 1, size do
        grid[x] = {}
        for y = 1, size do
            local isStartPos = startPos.x == x and startPos.y == y
            grid[x][y] = Field:new(isStartPos)
        end
    end

    return setmetatable({
        grid = grid,
        score = 0,
        player = Player:new(startPos)
    }, Wumpus_mt)
end

function Wumpus:move(pos)
    self.player.pos = pos
    self.grid[pos.x][pos.y].visited = 1
end