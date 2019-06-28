function canDoAction(domain, problem, action, parameter)
    local action = getAction(domain, action)
    assert(#action.params == #parameter, string.format("Given %d Parameter for action \'%s\' with %d Parameter", #parameter, action.name, #action.params))
    print(dump(action.preconds))

    return checkPreconds(problem, action, parameter)
end

function checkPreconds(problem, action, parameter)
    local lop
    for _, cond in pairs(action.preconds) do
        if not lop then -- first loop is lop
            lop = cond
        else -- then the conditions
            print(cond)
            if true then --TODO: condTrue
                if lop == "or" then
                    return true
                end
            else
                if lop == "and" then
                    return false
                end   
            end
        end
    end
    return true
end

function getAction(domain, action)
    for _, act in pairs(domain.acts) do
        print(act.name)
        if act.name == action then
            return act
        end
    end
end