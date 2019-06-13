dofile("include/Class.lua")

Field = {}
local Field_mt = Class(Field)

function Field:new(queen)
    return setmetatable({queen = queen and 1 or 0, h = 0}, Field_mt)
end

Queens = {}
local Queens_mt = Class(Queens)
function Queens:new(initialState)
    -- Init Grid
    local grid = {}
    for x = 1, #initialState do
        grid[x] = {}
        for y = 1, #initialState do
            grid[x][y] = Field:new(initialState[x] == y)
        end
    end

    return setmetatable({
        initialState = initialState,
        transisionModel = transition,
        grid = grid,
        fit = 1e30
    }, Queens_mt)
end

function Queens:hits(pos)
    local count = 0
    for i = 1, #self.grid do
        --Horizontal
        if pos.x ~= i and self.grid[i][pos.y].queen == 1 then
            count = count + 1
        end
        --Vertical
        if pos.y ~= i and self.grid[pos.x][i].queen == 1 then
            count = count + 1
        end

        local diagX = i + pos.x - pos.y
        --Diagonal from top left
        if diagX > 0 and diagX <= #self.grid then
            if pos.x ~= diagX and self.grid[diagX][i].queen == 1 then
                count = count + 1
            end
        end
        
        --Diagonal from bottom left
        local reverseDiagY = #self.grid - i + 1
        local reverseDiagX = i + pos.x - (#self.grid - pos.y + 1)
        if reverseDiagX > 0 and reverseDiagX <= #self.grid and reverseDiagY > 0 and reverseDiagY <= #self.grid then
            if pos.x ~= reverseDiagX and self.grid[reverseDiagX][reverseDiagY].queen == 1 then
                count = count + 1
            end
        end
    end
    return count
end

function Queens:fitness()
    local hList = {}
    local max = 0
    for i = 1, #self.grid do
        hList[i] = self:hits({x = i, y = self.initialState[i]})
        max = max + hList[i]
    end
    return {hList = hList, max = max}
end

function Queens:heuristic()
    local fit = self:fitness()
    self.fit = fit.max
    for x = 1, #self.grid do
        for y = 1, #self.grid do
            self.grid[x][y].h = self:hits({x = x, y = y}) - fit.hList[x] + fit.max
        end
    end
end

function Queens:transition(a,b)
    self.grid[a.x][a.y].queen = 0
    self.grid[b.x][b.y].queen = 1
end

function Queens:action(a,b)
    self:transition(a,b)
    self:heuristic()
end