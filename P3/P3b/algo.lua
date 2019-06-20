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

function containsClauses(t1, t2)
    local check = {}
    for i = 1, #t1 + #t2 do
        local cur = i <= #t1 and t1[i] or t2[i - #t1]
        local stringed = stringify(cur)
        if check[stringed] then
            return true
        end
        check[stringed] = true
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
    --print("Clauses: " .. stringify(clauses))
    while #clauses > 1 do
        local new = {}
        for i = 1, #clauses do
            local ci = clauses[i]
            for j = i + 1, #clauses do
                local cj = clauses[j]
                --print("i: " .. i .. ", j: " .. j .. ", Ci: " .. stringify(ci) .. ", Cj: " .. stringify(cj))
                local resolvents = PLResolve(ci, cj)
                --print("Resolvents: " .. stringify(resolvents))
                if containsEmpty(resolvents) then return true end
                new = concatUnique(new, resolvents)
            end
        end
        --print("new: " .. stringify(new))
        --print("clauses: " .. stringify(clauses))
        if containsClauses(new, clauses) then return false end -- new ⊆ kb
        clauses = {}
        clauses = concat(clauses, new)
        clauses = concat(clauses, alpha)
    end
    return false
end

function PLResolve(ci, cj)
    local ret = {}
    --print("PLResolve: ci: " .. stringify(ci) .. ", cj: " .. stringify(cj))
    for k,v in pairs(ci) do
        local con = concat(ci, cj)
        --print("k: " .. k .. ", cur: " .. v)
        local neg = negate(v)
        
        if contains(cj, neg) then --search for opposite clause
            --print("Resolved: " .. v)
            con = remove(con, v)
            con = remove(con, neg)
            --print(stringify(con))
            table.insert(ret, con)
        end
    end
    return ret
end

function negate(c)
    local neg = ""
    if string.find(c, "-") then
        neg = string.gsub(c, "-", "")
    else
        neg = "-" .. c
    end
    return neg
end

--KB = {{"x", "y"}, {"-x"}}
--ALPHA = {{"-y"}}
--print(PLResolution(KB, ALPHA))

--KB = {{"-p21", "b11"}, {"-b11", "p12", "p21"}, {"-p12", "b11"}, {"-b11"}}
--ALPHA = {{"-p12"}}
--print(PLResolution(KB, ALPHA))