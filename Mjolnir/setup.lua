os.exit = core.exit

-- TODO: figure out how core.pcall and core.reload should work and where they should go (maybe in objc)?
-- core.pcall(core.reload)

function core.runstring(s)
  local fn, err = load("return " .. s)
  if not fn then fn, err = load(s) end
  if not fn then return tostring(err) end

  local str = ""
  local results = table.pack(pcall(fn))
  for i = 2,results.n do
    if i > 2 then str = str .. "\t" end
    str = str .. tostring(results[i])
  end
  return str
end

function core._loadmodule(dotname)
  local requirepath = 'ext.' .. dotname:gsub('%.', '_') .. '.init'
  local mod = require(requirepath)

  local keys = {}
  for key in string.gmatch(dotname, "%a+") do
    table.insert(keys, key)
  end

  local t = _G[keys[1]]
  table.remove(keys, 1)
  local lastkey = keys[#keys]
  keys[#keys] = nil

  for _, k in ipairs(keys) do
    local intermediate = t[k]
    if intermediate == nil then
      intermediate = {}
      t[k] = intermediate
    end
    t = intermediate
  end

  t[lastkey] = mod
end

function core._unloadmodule(dotname)
  local fn = load(dotname.." = nil")
  fn()
end

local rawprint = print
function print(...)
  rawprint(...)
  local vals = table.pack(...)

  for k = 1, vals.n do
    vals[k] = tostring(vals[k])
  end

  -- using table.concat here is safe, because we just stringified all the values
  local str = table.concat(vals, "\t") .. "\n"
  core._logmessage(str)
end

function core.reload()
  print "okie"
end