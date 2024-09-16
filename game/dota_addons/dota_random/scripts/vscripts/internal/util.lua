function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

function Round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

function TableConcatExclude(t1,t2,t3)
  for i=1,#t2 do
    if t3[t2[i]] == nil then
      t1[#t1+1] = t2[i]
    end
  end
  return t1
end

function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
     t2[k] = v
  end
  return t2
end

function TableConcat(t1,t2)
  for i=1,#t2 do
    t1[#t1+1] = t2[i]
  end
  return t1
end

function TableConcat3(t1,t2,t3)
  for i=1,#t2 do
    t1[#t1+1] = t2[i]
  end
  for i=1,#t3 do
    t1[#t1+1] = t3[i]
  end
  return t1
end

function TableContains(tab, val)
  for index, value in ipairs(tab) do
      if value == val then
          return true, index
      end
  end
  return false
end
