dofile("Class.lua")
local Heap = require("heap")

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

-- LIFO
LIFO = {}
local LIFO_mt = Class(LIFO)

function LIFO:new()
    return setmetatable({q = {}},LIFO_mt)
end

function LIFO:pop()
    if self:empty() then
        print("no entries!")
    end

    return table.remove(self.q)
end

function LIFO:push(n)
    table.insert(self.q, n)
end

function LIFO:empty()
    return #self.q == 0
end

-- PRIO
PRIO = {}
local PRIO_mt = Class(PRIO)

function PRIO:new(cmp)
    return setmetatable({q = Heap.new(cmp)},PRIO_mt)
end

function PRIO:pop()
    if self:empty() then
        print("no entries!")
    end

    return self.q:Pop()
end

function PRIO:push(n)
    self.q:Insert(n)
end

function PRIO:empty()
    return self.q:Size() == 0
end

-- Node
Node = {}
local Node_mt = Class(Node)

function Node:new(status, neighbours, parent, value)
    return setmetatable({status = status, neighbours = neighbours, parent = parent, value = value or 0}, Node_mt)
end

-- Dump
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end