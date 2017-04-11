_addon.version = '0.4.0'
_addon.name = 'LanSend'
_addon.command = 'lansend'
_addon.author = 'Otoiroha'

-------------
-- Overview--
-------------

-- playerA --- account1 --- PC_HOST1
-- playerB -|                  |
-- playerC -|                {UDP}
--                             |
-- playerD --- account2 --- PC_HOST2
-- playerE -|     |
--              {send}
--                |
-- playerF --- account3
-- playerG -|

-------------
-- defines --
-------------
DEFAULT_SETTINGS = {} -- if not found settings.xml, set this tbl
DEFAULT_PORT = 25846

-------------
-- statics --
-------------
s_config = require 'config' -- config lib
s_settings = s_config.load(DEFAULT_SETTINGS) -- load settings by settings.xml

s_players = {} -- players info
s_h2a = {} -- host to account, this account manage Host's UDP socket.

s_socket = require 'socket' -- socket lib
s_udp = nil                 -- UDP socket
s_port = DEFAULT_PORT       -- UDP port

s_bRecvLoop = false -- receiver loop flag

---------------
-- functions --
---------------
windower.register_event('load',function ()

  if ( s_settings.port ~= nil ) then s_port = s_settings.port end -- load port from settings
  if ( s_settings.players ~= nil ) then s_players = s_settings.players end -- load players info from settings
  
  for i, v in pairs(s_players) do
    -- name and acc reset to lower
    v.name = v.name:lower()
    v.acc  = v.acc:lower()
    -- v.host = v.host:lower() -- host name isn't reset
    -- 1st account in Host manage the Host's UDP socket.
    if (s_h2a[v.host] == nil) then
      s_h2a[v.host] = v.acc
    end
  end
  
  -- wait player login
  local p = windower.ffxi.get_player()
  repeat
    p = windower.ffxi.get_player()
    coroutine.sleep(2)
  until p ~= nil
  
  -- logined player's account check, if player's account registed [h2a], UDP socket open.
  for i, v in pairs(s_players) do
    if ( p.name:lower() == v.name and s_h2a[v.host] == v.acc ) then
      s_udp = socket.udp()         -- UDP socket open
      s_udp:setsockname("*", s_port) -- set port
      s_udp:settimeout(0)          -- time out 0 -> no bind func
      windower.send_command("LanSend RecvLoop") -- UDP tranfeered Data Recv Loop
      break
    end
  end
  
end) -- load end

windower.register_event('unload', function()
  if ( s_udp ) then s_udp:close() end  -- UDP close
end) -- unload end

windower.register_event('addon command',function (...)
  -- get args
  local argstr = table.concat({...}, ' ')
  if ( argstr == nil ) then return end
  -- split args
  local args = split(argstr, ' ')
  
  -- "RecvLoop" called in load, this call Endress Func{RecvMessageLoop()}. So, 1 of register_event loop Endress.
  if ( not bRecvLoop ) and args[1] == 'RecvLoop' then
    RecvMessageLoop()
  else
    -- -- LANSEND SEND PROCESS -- --
    -- get target and myself info
    local target = {}
    local myself = {}
    for i, v in pairs(s_players) do
      if ( args[1]:lower() == v.name ) then target = v end
      if ( windower.ffxi.get_player().name:lower() == v.name ) then myself = v end
    end
    
    -- if target's host is same my host, use {send}
    if ( target.host == myself.host ) then
      windower.send_command( "send " .. argstr )
      
    -- if my acc isn't registed [h2a] acc, use {send} to [h2a] acc, " send Hoge lansend argstr"
    elseif ( s_h2a[myself.host] ~= myself.acc ) then
      -- this process can't know [h2a] acc's logined player, so send all player in [h2a] acc...
      for i, v in pairs(s_players) do
        if ( s_h2a[myself.host] == v.acc ) then
          windower.send_command( "send " .. v.name .. " lansend " .. argstr )
        end
      end
    
    -- my acc is resiged [h2a] acc, and target isn't same host, use UDP to send.
    elseif ( target.host ~= nil ) then
      s_udp:sendto(argstr, socket.dns.toip(target.host), s_port )
    end
  end
end) -- register_event end

-- -- LANSEND RECV PROCESS -- --
-- This loop func receive UDP string, to send {send} received string.
function RecvMessageLoop()
  bRecvLoop = true
  while true do -- data recv loop
    local data, err = s_udp:receive()
    if data ~= nil and not err then
      -- if get udp data, send {send} the data.
      windower.send_command( "send " .. data )
    end
    coroutine.sleep(0.01) -- 100FPS
  end
end -- RecvMessageLoop end

-- string splitter
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
end -- split end
