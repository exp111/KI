dofile("include/Class.lua")
dofile("include/fifo.lua")

Node = {}
local Node_mt = Class(Node_mt)

function Node:new(state)
    return setmetatable({
        state = state,
        actions = {}
    }, Node_mt)
end

Action = {}
local Action_mt = Class(Action_mt)

function Action:new()
    return setmetatable({
        name = "",
        a.params = {},
        a.preconds = {}
        effects = {},
    }, Action_mt)
end

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

function ProgressionPlanning(problem)
    local goal = problem.goal -- {on, {a, b}}, {on, {b, c}}
    local init = Node:new(problem.init[1])
    init.actions = GetDoableActions(init.state)
    --print("Init: " .. stringify(init))

    local explored = {}
    explored[stringify(init.state)] = true

    local q = FIFO:new()
    q:push(init)

    while not q:empty() do
        local cur = q:pop()
        for _, v in pairs(cur.actions) do
            local next = Node:new(doEffects(cur.state, v.effects))

            if not explored[stringify(next)] then
                if isGoal(next.state, goal) then
                    return true
                end

                next.actions = GetDoableActions(next.state)
                --TODO: add path
                q:push(next)
            end
        end
    end
    return false
end

function isGoal(state, goal) --basically Goal € State
    local check = {}
    for _, v in pairs(state) do
        check[stringify(v)] = true
    end

    for _, v in pairs(state) do
        if not check[stringify(v)] then
            return false
        end
    end
    return true
end

function allPrecondsTrue(action, state)
    --TODO: allPrecondsTrue
    return true
end

function GetDoableActions(state, actions)
    local ret = {}
    for _, v in pairs(actions) do
        if allPrecondsTrue(v, state) do
            table.insert(ret, v)
        end
    end
    return ret
end

function doEffects(state, effects)
    --TODO: doEffects
end