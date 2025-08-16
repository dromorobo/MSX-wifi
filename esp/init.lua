-- setup.lua (init.lua)

local VERSION = "0.10"
local BPS = 115200 -- Standard speed of serial interface

function launch()
  -- Launch telnetd
  if file.exists("telnetd.cfg")
  then
    tn = require("telnetd")
    tn:open()
    result = ""
  end
  
  -- Launch seriald
  if file.exists("seriald.lc")
  then
    dofile("seriald.lc")
  elseif file.exists("seriald.lua")
  then
    dofile("seriald.lua")
  end 
end

-- Let's see if there is a config file for serial
if file.exists("serial.cfg")
then
  file.open("serial.cfg")
  line = file.readline()
  BPS = tonumber(line)
  file.close()
end

uart.setup(0,BPS,8,0,1,1)

-- If a file <stop.cfg> exists abort, otherwise launch code.
if not(file.exists("stop.cfg"))
then launch()
end
