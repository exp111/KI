dofile("include/Class.lua")
dofile("include/heap.lua")

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

function PRIO:peek()
    if self:empty() then
        print("no entries!")
    end

    return self.q:Peek()
end

function PRIO:push(n)
    self.q:Insert(n)
end

function PRIO:empty()
    return self.q:Size() == 0
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