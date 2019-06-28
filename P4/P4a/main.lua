dofile("include/pddl.lua")
dofile("include/fifo.lua")
dofile("P4a/algo.lua")

function stringify(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. stringify(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

-- {domain = blocksworld.pddl, problem = pb3.pddl}
local read = readspec(true)

-- {name, reqs, const, preds, acts}
local domain = read.domain

-- {pname, dname, objs, init, goal}
local problem = read.problem
print(stringify(problem.init))
print(stringify(problem.goal))
ProgressionPlanning(problem)