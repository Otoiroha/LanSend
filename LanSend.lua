_addon.version = '0.2.0'
_addon.name = 'LanSend'
_addon.command = 'lansend'
_addon.author = 'Otoiroha'

config = require 'config'
defaults = {}
settings = config.load(defaults)

socket = require 'socket'

bRecvLoop = false

windower.register_event('load',function ()
  port = 0
  if ( settings.port ~= nil ) then port = settings.port end
  players = {}
  if ( settings.players ~= nil ) then players = settings.players end
  
  h2p = {}
  p2h = {}
  for i, v in pairs(players) do
    if (h2p[v.host] == nil) then
      h2p[v.host] = v.name
      p2h[v.name] = v.host
    end
  end
  
  repeat
    p = windower.ffxi.get_player()
    coroutine.sleep(2)
  until p ~= nil
  
  if (p2h[p.name] ~= nil) then
    udp = socket.udp()
    udp:setsockname("*", port)
    udp:settimeout(0)
    windower.send_command("LanSend RecvLoop")
  end
end)

windower.register_event('unload', function()
  if ( udp ) then udp:close() end
end)

windower.register_event('addon command',function (...)
  local argstr = table.concat({...}, ' ')
  if ( argstr == nil ) then return end
  local args = split(argstr, ' ')
  if ( not bRecvLoop ) and args[1] == 'RecvLoop' then
    RecvMessageLoop()
  else
    -- if local, use send
    local target = ""
    local myHost = ""
    for i, v in pairs(players) do
      if ( args[1] == v.name ) then target = v.host end
      if ( windower.ffxi.get_player().name == v.name ) then myHost = v.host end
    end
    if ( target == myHost ) then
      windower.send_command( "send " .. argstr )
    elseif ( p2h[windower.ffxi.get_player().name] == nil ) then
      windower.send_command( "send " .. h2p[myHost] .. " lansend " .. argstr )
    else
      udp:sendto(argstr, socket.dns.toip(target), port )
    end
  end
end)

function RecvMessageLoop()
  bRecvLoop = true
  while true do
    local data, err = udp:receive()
    if data ~= nil and not err then
      windower.send_command( "send " .. data )
    end
    coroutine.sleep(0.01)
  end
end

function split(msg, match)
  if msg == nil then return '' end
  local length = msg:len()
  local splitarr = {}
  local u = 1
  while u <= length do
    local nextanch = msg:find(match,u)
    if nextanch ~= nil then
      splitarr[#splitarr+1] = msg:sub(u,nextanch-match:len())
      if nextanch~=length then
        u = nextanch+match:len()
      else
        u = length
      end
    else
      splitarr[#splitarr+1] = msg:sub(u,length)
      u = length+1
    end
  end
  return splitarr
end
