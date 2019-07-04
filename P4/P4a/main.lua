dofile("include/pddl.lua")
dofile("P4a/algo.lua")

-- {domain = blocksworld.pddl, problem = pb3.pddl}
local read = readspec()

-- {name, reqs, const, preds, acts}
local domain = read.domain

-- {pname, dname, objs, init, goal}
local problem = read.problem

--print(stringify(initState(problem.init[1])))
--print(#GetActions(domain.acts[2], {"a", "b", "c"}))
InitActions(domain, problem)
local goal = ProgressionPlanning(problem)
while goal.parent ~= nil do
   print(goal.action.name .. " " .. stringify(goal.action.params))
   goal = goal.parent
end