-- FIFO
FIFO = {}
local FIFO_mt = Class(FIFO)

function FIFO:new()
    return setmetatable({q = {}},FIFO_mt)
end

function FIFO:pop()
    if self:empty() then
        print("no entries!")
    end

    return table.remove(self.q, 1)
end

function FIFO:push(n)
    table.insert(self.q, n)
end

function FIFO:empty()
    return #self.q == 0
end