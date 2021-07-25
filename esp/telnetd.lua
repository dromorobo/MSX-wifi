--A telnet server   T. Ellison,  June 2019
--luacheck: no unused args
-- adapted by dmr (remove wifi and timer stuff)

local M = {}
local modname = ...
local function telnet_session(socket)
  local node = node
  local stdout

  local function output_CB(opipe)   -- upval: socket
    stdout = opipe
    local rec = opipe:read(1400)
    if rec and #rec > 0 then socket:send(rec) end
    return false -- don't repost as the on:sent will do this
  end

  local function onsent_CB(skt)     -- upval: stdout
    local rec = stdout:read(1400)
    if rec and #rec > 0 then skt:send(rec) end
  end

  local function disconnect_CB(skt) -- upval: socket, stdout
    node.output()
    socket, stdout = nil, nil -- set upvals to nl to allow GC
  end

  node.output(output_CB, 0)
  socket:on("receive", function(_,rec) node.input(rec) end)
  socket:on("sent", onsent_CB)
  socket:on("disconnection", disconnect_CB)
  print(("Welcome to NodeMCU world (%d mem free, %s)"):format(node.heap(), wifi.sta.getip()))
end

function M.open(this, port)

  if (wifi.sta.status() == wifi.STA_GOTIP) 
  then
    print(("Telnet daemon started (%d mem free, %s)"):format(node.heap(), wifi.sta.getip()))
    M.svr = net.createServer(net.TCP, 180)
    M.svr:listen(port or 23, telnet_session)
  end
end

function M.close(this)
  if this.svr
  then
    this.svr:close() 
  end
  package.loaded[modname] = nil
end

return M
