function initInit(init)
    local ret = {}
    for _, v in pairs(init) do
        if v[1] == "on-table" then
            table.insert(ret, {"on", {v[2][1], "T"}})
        elseif v[1] == "clear" then
            table.insert(ret, {"clear", {v[2][1]}})
        end
    end
    return ret
end

function ProgressionPlanning(problem)
    local goal = problem.goal -- {on, {a, b}}, {on, {b, c}}
    local init = initInit(problem.init[1])
    --print("Init: " .. stringify(init))
    local q = FIFO:new()
    q:push(init)
    while not q:empty() do
        local cur = q:pop()
        if subsetOf(goal, cur) then return true end

        return false
    end
end

function move(state)
    local newState = {}

    return newState
end

function subsetOf(t1, t2) -- t1 is a subset of t2
    local check = {}
    for _, v in pairs(t2) do
        check[stringify(v)] = true
    end
    for _, v in pairs(t1) do
        if check[stringify(v)] ~= true then
            --print("Not subset bcuz: " .. stringify(v))
            return false
        end
    end
    return true
end