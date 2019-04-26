dofile("p1utils.lua")
dofile("Romania-Graph.lua")

local start = "Bu"
local endP = "Ti"

function GetPath(node)
	local ret = ""
	while node.parent ~= nil do
		ret = node.parent.neighbours[node.status] .. " -> " .. node.status .. (ret or "")
		node = node.parent
		if node ~= nil then
			ret =  " -> " .. ret
		end

		if node.parent == nil then
			ret = node.status .. ret
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