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

function copy(t)
    local newT = {}
    for k,v in pairs(t) do
        newT[k] = v
    end
    return newT
end

function concat(t1, t2)
    local t3 = copy(t1)
    for _,v in pairs(t2) do
        table.insert(t3, v)
    end
    return t3
end

function concatUnique(t1, t2)
    local t3 = copy(t1)
    local check = {}
    for _,v in pairs(t2) do
        if not check[v] then
            check[v] = true
            table.insert(t3, v)
        end
    end
    return t3
end

function containsClauses(t1, t2)
    for _,v in pairs(t2) do
        if contains(t1, v) then
            return true
        end
    end
    return false
end

function contains(t, e)
    for _,v in pairs(t) do
        if v == e then
            return true
        end
    end
    return false
end

function containsEmpty(t)
    for _,v in pairs(t) do
        if not v[1] then 
            return true
        end
    end
    return false
end

function remove(t, e)
    local new = copy(t)
    local off = 0
    for i = 1, #new do
        local cur = i - off
        if new[cur] == e then
            table.remove(new, cur)
            off = off + 1
        end
    end
    return new
end

function PLResolution(kb, alpha)
    local clauses = concat(kb, alpha) -- kb ∧ ¬α
    --print("Clauses: " .. dump(clauses))
    while #clauses > 1 do
        local new = {}
        for i = 1, #clauses do
            local ci = clauses[i]
            for j = i + 1, #clauses do
                local cj = clauses[j]
                --print("i: " .. i .. ", j: " .. j .. ", Ci: " .. dump(ci) .. ", Cj: " .. dump(cj))
                local resolvents = PLResolve(ci, cj)
                --print("Resolvents: " .. dump(resolvents))
                if containsEmpty(resolvents) then return true end
                new = concatUnique(new, resolvents)
                if containsClauses(new, kb) then return false end -- new ⊆ kb
            end
        end
        clauses = {}
        clauses = concat(clauses, new)
        clauses = concat(clauses, alpha)
    end
    return false
end

function PLResolve(ci, cj)
    local con = concat(ci, cj)
    --print("PLResolve: " .. dump(con))
    local ret = {}
    for k, v in pairs(con) do
        --print("k: " .. k .. ", cur: " .. v)
        local neg = ""
        if string.find(v, "-") then
            neg = string.gsub(v, "-", "")
        else
            neg = "-" .. v
        end
        if contains(cj, neg) then --search for opposite clause
            --print("Resolved: " .. v)
            con = remove(con, v)
            con = remove(con, neg)
            print(dump(con))
            table.insert(ret, con)
        end
    end
    return ret
end

--KB = {{"x", "y"}, {"-x"}}
--ALPHA = {{"-y"}}
--print(PLResolution(KB, ALPHA))