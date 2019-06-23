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

function contains(t, e)
    for _,v in pairs(t) do
        if v == e then
            return true
        end
    end
    return false
end


function PLFCEntails(kb, q)
    local count = GetCount(kb) -- count[c]
    local inferred = {} -- inferred[s] is nil/false as default value
    local agenda = InitAgenda(kb)

    while #agenda > 0 do
        local p = table.remove(agenda)
        if p == q then return true end
        if not inferred[p] then
            inferred[p] = true
            for _, c in pairs(kb) do
                if contains(c.premise, p) then -- p in c.premise
                    count[c] = count[c] - 1
                    if count[c] == 0 then
                        table.insert(agenda, c.conclusion)
                    end
                end
            end
        end
    end
    return false
end

function GetCount(kb)
    local ret = {}
    for _, v in pairs(kb) do
        ret[v.id] = #v.premise
    end
    return ret
end

function InitAgenda(kb)
    local ret = {}
    for _,v in pairs(kb) do
        if #v.premise == 0 then
            table.insert(ret, v)
        end
    end
    return ret
end