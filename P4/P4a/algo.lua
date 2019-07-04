dofile("include/Class.lua")
dofile("include/fifo.lua")

Node = {}
local Node_mt = Class(Node_mt)

function Node:new(state)
    return setmetatable({
        action = nilm,
        parent = nil,
        state = state,
        actions = {}
    }, Node_mt)
end

Action = {}
local Action_mt = Class(Action_mt)

function Action:new()
    return setmetatable({
        name = "",
        params = {},
        preconds = {},
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

ACTIONS = {}

function ReplaceParams(action, objs)
    assert(#action.params == #objs)
    local ret = Action:new()
    ret.name = action.name
    ret.params = objs
    ret.preconds = initState(action.preconds)
    ret.effects = initState(action.effects)
    for k, param in pairs(action.params) do
        local obj = objs[k]
        for key, precond in pairs(ret.preconds) do
            ret.preconds[key] = string.gsub(precond, param, obj)
        end

        for key, effect in pairs(ret.effects) do
            ret.effects[key] = string.gsub(effect, param, obj)
        end
    end

    return ret
end

function GetActions(action, objs)
    local ret = {}

    local depth = #action.params
    local objList = {} -- {{a, b}, {a, c}, {b, a} ... }
    for i = 1, depth do
        if i == 1 then -- so we have a basis
            for _, obj in pairs(objs) do
                table.insert(objList, {obj})
            end
        else
            local newObjList = {}
            for _, cur in pairs(objList) do
                for _, obj in pairs(objs) do
                    if not contains(cur, obj) then
                        local copied = copy(cur)
                        table.insert(copied, obj)
                        table.insert(newObjList, copied)
                    end
                end
            end
            objList = newObjList
        end
    end

    for _, objs in pairs(objList) do
        table.insert(ret, ReplaceParams(action, objs))
    end

    return ret
end

function InitActions(domain, problem)
    for _, action in pairs(domain.acts) do
        local combined = GetActions(action, problem.objs[1])
        --print(action.name .. ":" .. stringify(combined))
        ACTIONS = concat(ACTIONS, combined)
        --print(#ACTIONS)
    end
end

function initState(state)
    local ret = {}
    for _, v in pairs(state) do
        if type(v) == 'table' then
            if v[1] == 'not' then
                local cur = "-" .. v[2][1]
                for _, p in pairs(v[2][2]) do
                    cur = cur .. " " .. p
                end
                table.insert(ret, cur)
            else
                local cur = v[1]
                for _, p in pairs(v[2]) do
                    cur = cur .. " " .. p
                end
                table.insert(ret, cur)
            end
        end
    end
    return ret
end

function ProgressionPlanning(problem)
    assert(#ACTIONS > 0)
    local goal = initState(problem.goal[1]) -- {on a b}, {on b c}
    local init = Node:new(initState(problem.init[1]))
    init.actions = GetDoableActions(init.state, ACTIONS)
    --print("Init: " .. stringify(init))

    local explored = {}
    explored[stringify(init.state)] = true

    local q = FIFO:new()
    q:push(init)

    while not q:empty() do
        local cur = q:pop()
        --print("Cur: " .. stringify(cur.state))
        --print("Actions:")
        for _, action in pairs(cur.actions) do
            --print(action.name .. stringify(action.params))
            local next = Node:new(doEffects(cur.state, action.effects))
            --print("Next: " .. stringify(next.state))

            if not explored[stringify(next)] then
                next.parent = cur
                next.action = action
                if isGoal(next.state, goal) then
                    --print("Found Goal: " .. stringify(next.state))
                    return next
                end

                next.actions = GetDoableActions(next.state, ACTIONS)
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

    for _, v in pairs(goal) do
        if not check[stringify(v)] then
            return false
        end
    end
    return true
end

function allPrecondsTrue(action, state)
    --print(stringify(state))
    for _, precond in pairs(action.preconds) do
        if not contains(state, precond) then
            return false
        end
    end
    return true
end

function GetDoableActions(state, actions)
    local ret = {}
    for _, action in pairs(actions) do
        if allPrecondsTrue(action, state) then
            table.insert(ret, action)
        end
    end
    return ret
end

function doEffects(state, effects)
    local ret = {}
    local done = {}
    for _, v in pairs(state) do
        local negated = negate(v)
        if not contains(effects, negate(v)) then
            table.insert(ret, v)
        else
            done[stringify(negate(v))] = true
        end
    end

    for _, effect in pairs(effects) do
        if not done[stringify(effect)] then
            table.insert(ret, effect)
        end
    end

    return ret
end

function negate(c)
    local neg = ""
    if string.find(c, "-") == 1 then --first position "-"
        neg = string.gsub(c, "-", "")
    else
        neg = "-" .. c
    end
    return neg
end

function contains(t, e)
    for _,v in pairs(t) do
        if v == e then
            return true
        end
    end
    return false
end

function copy(t)
    local new = {}
    for k, v in pairs(t) do
        new[k] = v
    end
    return new
end

function concat(t1, t2)
    local t3 = copy(t1)
    for _,v in pairs(t2) do
        table.insert(t3, v)
    end
    return t3
end

function concatUnique(t1, t2)
    local t3 = {}
    local check = {}
    for i = 1, #t1 + #t2 do
        local cur = i <= #t1 and t1[i] or t2[i - #t1]
        local stringed = stringify(cur)
        if not check[stringed] then
            check[stringed] = true
            table.insert(t3, cur)
        end
    end
    return t3
end