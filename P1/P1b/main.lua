dofile("include/p1utils.lua")

function love.load()
    -- Init Grid
    grid = {}
    size = 20
    visited = {}
    for x = 1, size, 1 do
        grid[x] = {}
        visited[x] = {}
        for y = 1, size, 1 do
            grid[x][y] = Node:new({x=x,y=y}, nil, nil, 0)
            visited[x][y] = false
        end
    end
    boxSize = 25

    love.window.setMode(size * boxSize, size * boxSize, {})

    grid[10][1] = nil
    grid[10][2] = nil
    grid[10][3] = nil
    grid[10][4] = nil
    grid[10][5] = nil
    grid[10][6] = nil
    grid[10][7] = nil
    grid[10][8] = nil
    grid[10][9] = nil
    grid[10][10] = nil
    grid[9][10] = nil
    grid[8][10] = nil
    grid[7][10] = nil
    grid[6][10] = nil
    grid[5][10] = nil
    grid[17][10] = nil
    grid[17][11] = nil
    grid[17][12] = nil
    grid[17][13] = nil
    grid[17][14] = nil
    grid[17][15] = nil
    grid[17][16] = nil
    grid[17][17] = nil
    grid[17][18] = nil
    grid[17][19] = nil
    grid[17][20] = nil
    gStart = {x=1,y=1}
    gEnd = {x=20, y=20}
end

function love.draw()
    local node = AStar(gStart, gEnd)
    -- Draw Board
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, size * boxSize, size * boxSize)
    -- Draw blocked & visited fields
    for x = 1, size, 1 do
        for y = 1, size, 1 do
            if grid[x][y] == nil then
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("fill", (x - 1) * boxSize, (y - 1) * boxSize, boxSize, boxSize)
            end

            if visited[x][y] == true then
                love.graphics.setColor(255, 0, 0)
                love.graphics.rectangle("fill", (x - 1) * boxSize, (y - 1) * boxSize, boxSize, boxSize)
            end
        end
    end
    -- Draw Start
    love.graphics.setColor(0, 0, 255)
    love.graphics.rectangle("fill", (gStart.x - 1) * boxSize, (gStart.y - 1) * boxSize, boxSize, boxSize)
    -- Draw End
    love.graphics.setColor(0, 255, 0)
    love.graphics.rectangle("fill", (gEnd.x - 1) * boxSize, (gEnd.y - 1) * boxSize, boxSize, boxSize)
    -- Draw Path
    love.graphics.setColor(0, 0, 0)
    while node ~= nil do
        love.graphics.rectangle("line", (node.status.x - 1) * boxSize, (node.status.y - 1) * boxSize, boxSize, boxSize)
        node = node.parent
    end
end

function love.update()
    
end

function equals(a, b)
    return a.x == b.x and a.y == b.y
end

function contains(t, node)
    for _,v in pairs(t) do
        if node == v then
            return true
        end
    end
    return false
end

function GetPath(node) -- TODO: finish this
	local ret = ""
    local total = 0
	while node.parent ~= nil do
        local cur = "{x:" .. node.status.x .. ",y:"..node.status.y.."},"
        ret = cur .. ret  
        total = total + 1
		node = node.parent

		if node.parent == nil then
			ret = ret .. " = " .. total
		end
	end

	return ret
end

function GetNeighbours(status)
    local ret = {}
    if grid[status.x - 1] ~= nil then
        table.insert(ret, grid[status.x - 1][status.y])
    end
    if grid[status.x + 1] ~= nil then
        table.insert(ret, grid[status.x + 1][status.y])
    end
    -- No need to check those because they should exist (as the nodes should exist)
    table.insert(ret, grid[status.x][status.y - 1])
    table.insert(ret, grid[status.x][status.y + 1])
    
    return ret
end

function c(s, v)
    return math.abs(s.status.x - v.status.x) + math.abs(s.status.y - v.status.y)
end

function h(s,goal)
    return math.sqrt(math.pow(s.status.x - goal.x, 2) + math.pow(s.status.y - goal.y,2))
end

function AStar(start, goal) --TODO: draw the shit
    --Init
    local open = PRIO:new(function(a,b) return a.value + a.h > b.value + b.h end)
    local closed = {}
    open:push(grid[start.x][start.y])
    
    while open:empty() == false do
        local s = open:pop()
        --print("x:" .. s.status.x .. ", y:" .. s.status.y .. ", val:" .. s.value)
        if equals(s.status, goal) then
            return s
        end

        closed[s] = true
        for _,v in pairs(GetNeighbours(s.status)) do
            --print("Neighbour: x:" .. v.status.x .. ", y:" .. v.status.y .. ", val:" .. v.value)
            visited[v.status.x][v.status.y] = true
            if v ~= nil then
                local contained = contains(open.q:GetAsTable(), v)
                if closed[v] == nil then
                    if contained == false then
                        --print("Setting high")
                        v.value = 1e309
                        v.parent = nil
                        v.h = 0
                    end
                end
                -- UpdateVertex(s,s')
                if s.value + c(s, v) < v.value then
                    v.value = s.value + c(s,v)
                    v.h = h(v,goal)
                    v.parent = s
                    if contained == false then
                        --print("Pushed v")
                        open:push(v)
                    end
                end
                -- end
            end
        end
    end
    return nil
end