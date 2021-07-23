-- setup.lua (init.lua)

local VERSION = "0.05"
SSID   = "dmr_"..node.chipid()
PWD    = "12345678"
MODE   = "server"

local BPS = 9600 -- Standard speed of serial interface

function launch()
  -- Launch existing servers
  if file.exists("seriald.lua")
  then
    dofile("seriald.lua")
  end

  if file.exists("httpd.lua")
  then
    dofile("httpd.lua")
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

-- Let's see if there is a config file for serial
if file.exists("serial.cfg")
then
  file.open("serial.cfg")
  line = file.readline()
  BPS = tonumber(line)
  file.close()
end

if (BPS~=1200 and BPS~=2400 and BPS~=9600 and BPS~=19200 and BPS~=115200) 
then
  BPS=9600
end

uart.setup(0,BPS,8,0,1,1)

-- Assume we are connected. If a file <stop.cfg> exists abort, otherwise launch code.
if not(file.exists("stop.cfg"))
then launch()
end
