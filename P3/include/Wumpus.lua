dofile("include/Class.lua")

Field = {}
local Field_mt = Class(Field)

function Field:new(visited, player)
    return setmetatable({
        visited = visited and 1 or 0,
        stench = 0,
        breeze = 0,
        glitter = 0,
        player = player and 1 or 0
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
            grid[x][y] = Field:new(isStartPos, isStartPos)
        end
    end

    return setmetatable({
        grid = grid,
        score = 0,
        rotation = 0
    }, Wumpus_mt)
end