dofile("Class.lua")

-- FIFO
FIFO = {}
local FIFO_mt = Class(FIFO)

function FIFO:new()
    return setmetatable({q = {}},FIFO_mt)
end

function FIFO:pop()
    if (#self.q == 0) then
        print("no entries!")
    end

    return table.remove(self.q, 1)
end

function FIFO:push(n)
    table.insert(self.q, n)
end

-- LIFO
LIFO = {}
local LIFO_mt = Class(LIFO)

function LIFO:new()
    return setmetatable({q = {}},LIFO_mt)
end

function LIFO:pop()
    if (#self.q == 0) then
        print("no entries!")
    end

    return table.remove(self.q)
end

function LIFO:push(n)
    table.insert(self.q, n)
end

-- PRIO

local shit = FIFO:new()
shit:push(1)
shit:push(2)
print(shit:pop())