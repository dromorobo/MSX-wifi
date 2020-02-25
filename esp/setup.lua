-- setup.lua (init.lua)
--
-- Test for MSX wifi 
--
-- Setup uart, make permanent (last '1' makes permanent))
-- (uart,bps,databits,parity,stopbits,echo,permanent = 1)
-- uart.setup(0,2400,8,0,1,0,1)

SSID   = "msx_"..node.chipid()
PWD    = "12345678"
MODE   = "server"

function launch()
  -- Launch existing servers
  if file.exists("tcp_srv.lua")
  then
    dofile("tcp_srv.lua")
  end

  if file.exists("udp_srv.lua")
  then
    dofile("udp_srv.lua")
  end
  
  if file.exists("telnet_srv.lua")
  then
    dofile("telnet_srv.lua")
  end

  if file.exists("serial_srv.lua")
  then
    dofile("serial_srv.lua")
  end

  if file.exists("http_srv.lua")
  then
    dofile("http_srv.lua")
  end
end

function isconnected()
  -- Lets see if we are already connected by getting the IP
  if (MODE == "server")
  then
    ipAddr = wifi.ap.getip()
  else
    ipAddr = wifi.sta.getip()
  end

  return( (ipAddr ~= nil) and (ipAddr ~= "0.0.0.0") ) 
end

-- Let's see if there is a config file for wifi
if file.exists("wifi.cfg")
then
  file.open("wifi.cfg")
  SSID = file.readline()
  PWD  = file.readline()
  MODE = file.readline()
  file.close()
  
  -- Remove eol
  SSID = string.sub(SSID, 1, string.len(SSID)-1)
  PWD  = string.sub(PWD, 1, string.len(PWD)-1)
  MODE = string.sub(MODE, 1, string.len(MODE)-1)
end

-- Setup wifi, and connect
wifi.setphymode(wifi.PHYMODE_N)

if (MODE == "server")
then
  wifi.setmode(wifi.STATIONAP)
  wifi.ap.config({ssid=SSID, pwd=PWD})
else
  wifi.setmode(wifi.STATION)
  wifi.sta.config({ssid=SSID, pwd=PWD})
  wifi.sta.connect()
end

-- Assume we are connected, so just run the launch code.
launch()
