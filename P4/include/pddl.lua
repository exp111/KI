
----------------------------------------------------------------------------
--  pddl.lua -  a scanner for pddl
--
--  Created: Tue Apr 02 10:46:58 2012
--  Copyright  2009-2010  Alexander Ferrein [alexander.ferrein@gmail.com]
--
----------------------------------------------------------------------------

--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Library General Public License for more details.
--
--  Read the full text in the LICENSE.GPL file in the doc directory.

-----------------------------------------------------------------------------
--  printf -- from the lua wiki page
-----------------------------------------------------------------------------

local printf = 
   function(s,...)
      return io.write(s:format(...))
   end 


-----------------------------------------------------------------------------
-- is -- indent string returns  a string indented by level indent
-- @param indent - integer indicating the depth as indentation 
-----------------------------------------------------------------------------

local function is(indent)
--   print(indent)
   local tab=""
   for i=1,indent-2 do tab=tab .. "  " end
   if indent > 1 then  tab = tab .. "|-" end
   return tab
end

-----------------------------------------------------------------------------
-- traverse - outputs a nested tables with indentation
--    @param t - the table to be printed
--           level - indentation level 
-----------------------------------------------------------------------------

local function traverse(t)
   return travtab(t, 0)
end


local function travtab(t, level)
   if type(t) == "table" then
      level = level + 1
      printf("%s%s\n", is(level), tostring(t))
      for i,v in ipairs(t) do travtab(v, level+1) end
   else
      printf("%s%s\n", is(level), tostring(t))   
   end
end


-----------------------------------------------------------------------------

dofile("include/Class.lua")


lop_table={"and", "or", "not"}
pred_table = {}
obj_table = {}


function get_args(s, ground)
   local t={}
   local match = ""
   if ground then match = "(%w+)" 
   else match = "([?]%a+)" end 
   
   for v in string.gmatch(s, match) do
      table.insert(t, v)
   end	 
   return t
end




function get_predspec(predspec)
   local t={}
   
   local first = string.match(predspec, "[(]:predicates (.+)[)]")
   for pred_decl in string.gmatch(first, "%b()") do
      local pred_name, pred_args = 
	 string.match(pred_decl, "[(]([%w-_]+)%s*(.*)[)]")
      
      table.insert(t, {pred_name, get_args(pred_args)})
      pred_table[pred_name] = get_args(pred_args)
   end
   return t   
end




function get_initspec(predspec)
   local t={}
   
   for pred_decl in string.gmatch(predspec, "%b()") do
      local pred_name, pred_args = 
	 string.match(pred_decl, "[(]([%w-_]+)%s*(.*)[)]")
      local args={}
      for v in string.gmatch(pred_args, "([%a-_]+)") do
	 table.insert(args, v)
      end	 
      table.insert(t, {pred_name, args})
   end
   return t   
end





function ismember(value, set)
   for i,v in pairs(set) do
      if v == value then return i end
   end
   return nil
end




function get_formula(formula, ground)
   local t={}
   
   local first,_,rest = string.match(formula, "[(]([%w-_]+)(%s*)(.*)(%s*)[)]")   
   
   local lop = ismember(first, lop_table)
   if lop ~= nil then
      table.insert(t, lop_table[lop])
      for v in string.gmatch(rest, "%b()") do
	 table.insert(t, get_formula(v, ground))
      end        
   else
      return {first, get_args(rest, ground)}
   end
   return t   
end




function get_action(action_decl)
   local aname,_,_,param,_,_,preconds,_,_,effects=string.match(action_decl, "[(]:action ([%a-_]+)(%s*):parameters(%s*)[(](.+)[)](%s*):precondition(%s*)[(](.+)[)](%s*):effect(%s*)[(](.+)[)](%s*)[)]")
   --   printf("name:[%s]\n, param:[%s]\n, preconds:[%s]\n, effects:[%s]\n", name, param, preconds, effects)
   
   -- table.insert(t, {name=aname})
   -- table.insert(t,  {params=get_args(param)})
   -- table.insert(t,  {precond=get_formula("("..preconds..")")})
   -- table.insert(t,  {effects=get_formula("("..effects..")")})
   return {name=aname, params=get_args(param), preconds=get_formula("("..preconds..")"), effects=get_formula("("..effects..")")}
end

function get_requirements(req_decl)
   local t = {}
   
   local _,req_list,_ = string.match(req_decl, "[(]:requirements(%s*)(.+)(%s*)[)]")
   for req in string.gmatch(req_list, "[:]([%w-_]+)") do
      table.insert(t, req)
   end
   return t
end

function get_objspecs(obj_decl)
   local t = {}

   local _,obj_list = string.match(obj_decl, "[(]:objects(%s*)(.+)(%s*)[)]")
   for obj in string.gmatch(obj_list, "([%a-_]+)") do
      table.insert(t, obj)
      obj_table[obj]=true
   end
   return t
end





function get_domain(def_decl)
   local requirements = {}
   local actions = {}
   local predicates = {}
   local domain_name = nil

   -- delete comments
   def_decl = string.gsub(def_decl,"//([^\n.]*)", "")

   local _, def, _ = string.match(def_decl,"[(]define(%s*)(.+)(%s*)[)]")
   for decl in string.gmatch(def, "%b()") do
      if string.match(decl, "[(](%s*)domain(.+)") then 
	 domain_name = get_domain_name(decl)
      elseif string.match(decl, "[(](%s*):requirements(.+)") then
	 -- printf("REQ: [%s]\n", decl)
	 table.insert(requirements, get_requirements(decl))
      elseif string.match(decl, "[(](%s*):predicates(.+)") then 
	 -- printf("PRED: [%s]\n", decl)
	 table.insert(predicates, get_predspec(decl))
      elseif string.match(decl, "[(](%s*):action(.+)") then
	 -- printf("ACTION: [%s]\n", decl)
      	 table.insert(actions, get_action(decl))
      end     
   end
   return {name=domain_name, reqs=requirements, preds=predicates, acts=actions}
end




function get_problem(def_decl)
   local domain_name 
   local problem_name
   local objects = {}
   local init = {}
   local goal = {}

   -- delete comments
   def_decl = string.gsub(def_decl,"//([^\n.]*)", "")

   local _, def, _ = string.match(def_decl,"[(]define(%s*)(.+)(%s*)[)]")
   for decl in string.gmatch(def, "%b()") do
      if string.match(decl, "[(](%s*)problem(.+)") then 
	 problem_name = get_problem_name(decl)
      elseif string.match(decl, "[(](%s*):domain(.+)") then
	 _,domain_name,_ = string.match(decl, "[(]:domain(%s*)(.+)(%s*)[)]")
      elseif string.match(decl, "[(](%s*):objects(.+)[)]") then 
	 table.insert(objects, get_objspecs(decl))
      elseif string.match(decl, "[(](%s*):init(%s*)(.+)[)]") then
	 local _, _, pred_decl = string.match(decl, "[(](%s*):init(%s*)(.+)[)]")
	 table.insert(init, get_initspec(pred_decl))
      elseif string.match(decl, "[(](%s*):goal(%s*)(.+)[)]") then
	 local _, _, goal_decl = string.match(decl, "[(](%s*):goal(%s*)(.+)[)]")
	 table.insert(goal, get_formula("(" .. goal_decl .. ")", true ))
      end     
   end   
   return {pname = problem_name, dname = domain_name, objs = objects, init = init, goal = goal}
end


function get_domain_name(s)
   _,domain_name = string.match(s, "[(]domain(%s*)(.+)(%s*)[)]")
   return domain_name
end




function get_problem_name(s)
   _,problem_name = string.match(s, "[(]problem(%s*)(.+)(%s*)[)]")
   return problem_name
end




function pretty_print_formula(formula, ground)
   local s = ""
   local conj_or_pred = nil


   for i,v in pairs(formula) do   
      if type(v) == "string" then
	 if ismember(v, lop_table) then
	    s = s .. " " .. v .. " ("
	    conj_or_pred = "c"
	 elseif pred_table[v] ~=nil then
	    s = s .. " " .. v .. " ["
	    conj_or_pred = "p"
	 else
	    s = s .. " " .. v .. " "
	 end
      elseif type(v) == "table" then
	 local ss, conj_or_pred = pretty_print_formula(v)
	 s = s .. ss
      end
   end

   if conj_or_pred == "c" then
      s = s .. ") "
   elseif conj_or_pred == "p" then
      s = s .. "] "
   end
   
   return s, conj_or_pred
end






function pretty_print_domain(domain_decl)
   printf("\ndomain = [%s]\n", domain_decl.name)
   
   -- print requirements
   printf("\nreqs = ")
   local reqs = domain_decl.reqs[1]
   for i,v in pairs (reqs) do
      if i>1 then printf("\t") end
      printf("[%s]\n", v)
   end
   printf("\n")

   printf("preds = ")
   local pred_list = domain_decl.preds[1]
   for i, preds in pairs (pred_list) do
      if i>1 then printf("\t") end
      printf("[%s] ", preds[1])
      for _,args in pairs(preds[2]) do
	 printf("(%s) ", args)
      end
      printf("\n")
   end
   printf("\n")

   local act_list = domain_decl.acts
   for _, acts in pairs(act_list) do
      printf("action = [%s] ", acts.name)
      for _, params in pairs(acts.params) do
	 printf("(%s) ", params)
      end
      printf("\n")
      
      printf("\tPrecond = [%s]\n", pretty_print_formula(acts.preconds) )
      printf("\tEffects = [%s]\n", pretty_print_formula(acts.effects) )
      printf("\n")
   end
end





function pretty_print_problem(problem_decl)
   printf("\nproblem = [%s]\n",  problem_decl.pname)
   printf("\ndomain = [%s]\n",  problem_decl.dname)
   
   
    printf("\nobjects = ")
    for _, v in pairs(problem_decl.objs[1]) do
       printf("[%s] ", v)
    end
    printf("\n")
    
    printf("\ninit = ")
    local init_list = problem_decl.init[1]
    for i, inits in pairs (init_list) do
       if i>1 then printf("\t") end
       printf("[%s] ", inits[1])
       for _,args in pairs(inits[2]) do
	  printf("(%s) ", args)
       end
       printf("\n")
    end
    printf("\n")
    
    printf("goal = [%s]\n", pretty_print_formula(problem_decl.goal) )
end


function readspec(prettyPrint)
    local domain_file = assert(io.open("data/blocksworld.pddl", "r"))
    local problem_file = assert(io.open("data/pb3.pddl", "r"))
    local ddecl = domain_file:read("*all")
    local pdecl = problem_file:read("*all")
   
    local d = get_domain(ddecl)
    local p = get_problem(pdecl)

    if prettyPrint then
        pretty_print_domain(d)
        pretty_print_problem(p)
    end

    return {domain = d, problem = p}
end

   
