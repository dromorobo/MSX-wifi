-- serial_srv.lua
-- Reads and interprets lines from uart and acts upon the content

-- Setup uart, make permanent (last '1' makes permanent))
-- (uart,bps,databits,parity,stopbits,echo,permanent = 1)

-- When '\r' is received, read data and process

local VERSION = "0.03"
local BPS = 9600         -- Speed of serial interface
local EOT = 0x04         -- EOT = End of Transmission
local what = ""
local buffer = nil

function trim(s)
  -- trim all heading spaces characters
  pt_start = string.find(s, "^%s")
  if pt_start ~= nil
  then
    s = string.sub(s, pt_start)
  end
            
  -- trim all trailing control characters
  pt_start = string.find(s, "%c")
  if pt_start ~= nil
  then
    s = string.sub(s, 1, pt_start-1)
  end
            
  -- trim all trailing spaces characters
  -- assuming all heading spaces have 
  -- already been removed
  pt_start = string.find(s, "%s")
  if pt_start ~= nil
  then
    s = string.sub(s, 1, pt_start-1)
  end
  return s
end

-- Let's see if there is a config file for serial
if file.exists("serial.cfg")
then
  file.open("serial.cfg")
  line = trim(file.readline())
  BPS = tonumber(line)
  file.close()
end

if (BPS~=1200 and BPS~=2400 and BPS~=9600 and BPS~=19200) 
then
  BPS=9600
end

uart.setup(0,BPS,8,0,1,0,1)

uart.on("data", "\r",
  function(data)
    if (string.find(data, "get ") ~= nil)
    then
      what = string.sub(data, 5)
      trim(what)
      if (string.find(what, "ip") ~= nil)
      then
        ip, nm = wifi.sta.getip()
        if ip ~= nil
        then
          uart.write(0, ip)
        else
          uart.write(0, "nil")
        end
        uart.write(0, EOT) 
    
      elseif (string.find(data, "netmask") ~= nil)
      then
        ip, nm = wifi.sta.getip()
        if nm ~= nil
        then
          uart.write(0, nm)
        else
          uart.write(0, "nil")
        end
        uart.write(0, EOT)

      elseif (string.find(data, "speed") ~= nil)
      then
        -- Let's see if there is a config file for serial
        if file.exists("serial.cfg")
        then
          file.open("serial.cfg")
          line = trim(file.readline())
          uart.write(0, "Startup = " .. line .. "\n\r")
          file.close()
        end
        uart.write(0, "Running = " .. BPS .. "\n\r")
        uart.write(0, EOT)    
      end

    elseif (string.find(data, "set ") ~= nil)
    then
      what = string.sub(data, 5)
      if (string.find(what, "speed ") ~= nil)
      then
        speed = string.sub(what, 7)
        if speed ~= nil
        then -- Write the result in seial.cfg
          file.open("serial.cfg","w+")
          file.write(tostring(speed) .. "\n")
          file.close()
        end
      end
      uart.write(0, EOT)

    elseif (string.find(data, "whois ") ~= nil)
    then 
      what = string.sub(data, 7)
      what = trim(what)
      if (what ~= nil)
      then
        net.dns.resolve(what, function(sk, ip)
          if (ip ~= nil) 
          then uart.write(0,ip)
          else uart.write(0,"host not found")
          end
        end)
      end
      uart.write(0, EOT)

    elseif (string.find(data, "restart") ~= nil)
    then 
      uart.write(0, EOT)
      node.restart()
    
    elseif (string.find(data, "show ") ~= nil)
    then
      what = string.sub(data, 6)
      what = trim(what)
      if (what ~= nil)
      then
        if (string.find(data, "version") ~= nil)
        then 
          uart.write(0, VERSION)

        elseif (string.find(data, "buflength") ~= nil)
        then
          if (buffer ~= nil)
          then
            uart.write(0, tostring(string.len(buffer)))
          else
            uart.write(0, "0")
          end
        else
          uart.write(0, "Syntax Error")
        end
      else
        uart.write(0, "Nothing to show")
      end
      uart.write(0, EOT)
  
    elseif (string.find(data, "readchar") ~= nil)
    then
      if (buffer ~= nil)
      then
        uart.write(0, string.sub(buffer,1,1))
        if (string.len(buffer)>1)
        then
          buffer = string.sub(buffer,2)
        else
          buffer = nil
        end
      else
        uart.write(0, "Nothing to read")
      end
      uart.write(0, EOT)

    elseif (string.find(data, "readbuffer") ~= nil)
    then
      if (buffer ~= nil)
      then
        uart.write(0, buffer)
        buffer = nil
      else
        uart.write(0, "Nothing to read")
      end
      uart.write(0, EOT)

    elseif (string.find(data, "clearbuffer") ~= nil)
    then
      buffer = nil
      uart.write(0, EOT)

    elseif (string.find(data, "open ") ~= nil)
    then 
      sloc = string.find(data, " ")
      what = trim(string.sub(data, sloc+1))
      if (string.find(what, "http://") ~= nil)
      then
        what = string.sub(what, 8)
        sloc = string.find(what, "/")
        if (sloc ~= nil)
        then
          host = string.sub(what, 1, sloc-1)
          item = string.sub(what,sloc)
          item = trim(item)
          print(item)
        else
          host = what
          item = "/"
        end

        host = trim(host)

        if (host ~= nil)
        then
          -- open connection
          conn = net.createConnection(net.TCP, 0)

          conn:on("receive", function(sck, c)
            if buffer == nil 
            then
              buffer = c
            else
              buffer = buffer .. c
            end
          end)

          -- In case of connection send request
          conn:on("connection", function(sck, c)
            request = "GET " .. item .. " HTTP/1.1\r\nHost: " .. host .. "\r\n\r\n"
            conn:send(request)
          end)

          -- Start connection
          conn:connect(80,host)
        end    
      end
      uart.write(0, EOT)
    
    elseif (string.find(data, "help") ~= nil)
    then
      if file.exists("help.hlp")
      then
        file.open("help.hlp")
        line = file.readline()
        while (line ~= nil)
        do
          uart.write(0, line)
          uart.write(0, "\r")    -- compensate for LF to LFCR
          line = file.readline()
        end
        file.close()
      end 
      uart.write(0, EOT)
              
    else 
      uart.write(0, "Error 21")
      uart.write(0, EOT)
    end  
  end, 0)
