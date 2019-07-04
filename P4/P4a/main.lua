dofile("include/pddl.lua")
dofile("P4a/algo.lua")

-- {domain = blocksworld.pddl, problem = pb3.pddl}
local read = readspec(true)

-- {name, reqs, const, preds, acts}
local domain = read.domain

-- {pname, dname, objs, init, goal}
local problem = read.problem
print(stringify(problem.init))
print(stringify(problem.goal))
ProgressionPlanning(problem)