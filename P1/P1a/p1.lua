dofile("include/p1utils.lua")
dofile("include/Romania-Graph.lua")

local start = "Bu"
local endP = "Ti"

function GetPath(node)
	local ret = ""
    local total = 0
	while node.parent ~= nil do
		ret = node.parent.neighbours[node.status] .. " -> " .. node.status .. (ret or "")
        total = total + node.parent.neighbours[node.status]
		node = node.parent
		if node ~= nil then
			ret =  " -> " .. ret
		end

		if node.parent == nil then
			ret = node.status .. ret .. " = " .. total
		end
	end

	return ret
end

function MapNeighbours(neighbours)
	local ret = {}
	for k,v in pairs(neighbours) do
		ret[v[1]] = v[2]
	end
	return ret
end

function BFS(graph, start, endP)
    local visited = {}
    local frontier = FIFO:new()
	frontier:push(Node:new(start, MapNeighbours(graph:GetNeighbours(start)), nil))
	while true do
		if frontier:empty() then
			return nil
		end

		local node = frontier:pop()
		visited[node.status] = true
		for k,v in pairs(node.neighbours) do
			if visited[k] == nil then
				local newNode = Node:new(k, MapNeighbours(graph:GetNeighbours(k)), node)
				frontier:push(newNode)
				visited[newNode.status] = true

				if k == endP then
					return GetPath(newNode)
				end
			end
		end
	end
end
print("BFS: " .. BFS(romania, start, endP))

function DFS(graph, start, endP)
    local visited = {}
    local frontier = LIFO:new()
	frontier:push(Node:new(start, MapNeighbours(graph:GetNeighbours(start)), nil))
	while true do
		if frontier:empty() then
			return nil
		end

		local node = frontier:pop()
		visited[node.status] = true
		for k,v in pairs(node.neighbours) do
			if visited[k] == nil then
				local newNode = Node:new(k, MapNeighbours(graph:GetNeighbours(k)), node)
				frontier:push(newNode)
				visited[newNode.status] = true

				if k == endP then
					return GetPath(newNode)
				end
			end
		end
	end
end
print("DFS: " .. DFS(romania, start, endP))

function UCS(graph, start, endP)
    local visited = {}
    local frontier = PRIO:new(function(a,b) return a.value > b.value end)
	frontier:push(Node:new(start, MapNeighbours(graph:GetNeighbours(start))))
	while true do
		if frontier:empty() then
			return nil
		end

		local node = frontier:pop()
		visited[node.status] = true
		for k,v in pairs(node.neighbours) do
            local value = node.value + node.neighbours[k]
			if visited[k] == nil then
				local newNode = Node:new(k, MapNeighbours(graph:GetNeighbours(k)), node, value)
				frontier:push(newNode)
				visited[newNode.status] = true

				if k == endP then
					return GetPath(newNode)
				end
			end
            
            for i = 1, #frontier.q do -- Check if already exists in frontier and has a higher cost
                if frontier.q[i].status == k and frontier.q[i].value > value then
                    frontier.q[i].parent = node
                    frontier.q[i].value = value
                    break
                end
            end
		end
	end
end
print("UCS: " .. UCS(romania, start, endP))