dofile("include/p1utils.lua")

local grid = {}
local size = 20

local blocked = {}
for i = 0, size, 1 do
    blocked[i] = {}
end

function InitGrid()
    for x = 1, size, 1 do
        grid[x] = {}
        for y = 1, size, 1 do
            if blocked[x][y] == nil then --blocked -> just leave it nil
                grid[x][y] = Node:new({x=x,y=y}, nil, nil, 0) --status,nil,parent,value
            end
        end
    end
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
    InitGrid()
    local open = PRIO:new(function(a,b) return a.value + a.h > b.value + b.h end)
    local closed = {}
    open:push(grid[start.x][start.y])
    
    while open:empty() == false do
        local s = open:pop()
        --print("x:" .. s.status.x .. ", y:" .. s.status.y .. ", val:" .. s.value)
        if equals(s.status, goal) then
            return GetPath(s)
        end

        closed[s] = true
        for _,v in pairs(GetNeighbours(s.status)) do
            --print("Neighbour: x:" .. v.status.x .. ", y:" .. v.status.y .. ", val:" .. v.value)
            if v ~= nil then
                local contained = contains(open.q:GetAsTable(), v)
                if closed[v] == nil then
                    if contained == false then
                        --print("Setting high")
                        v.value = 1e309
                        v.parent = nil
                    end
                end
                -- UpdateVertex(s,s')
                if s.value + c(s, v) < v.value then
                    v.value = s.value + c(s,v) 
                    v.h = h(v,goal)
                    v.parent = s
                    -- TODO: maybe remove and re add?
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

blocked[3][1] = true
blocked[5][2] = true
print(AStar({x=1, y=1}, {x=7, y=2}))