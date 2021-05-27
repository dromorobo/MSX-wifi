-- serial_srv.lua
-- Reads and interprets lines from uart and acts upon the content

-- Setup uart, make permanent (last '1' makes permanent))
-- (uart,bps,databits,parity,stopbits,echo,permanent = 1)

-- When '\r' is received, read data and process

local VERSION = "0.07"
local BPS = 115200       -- Speed of serial interface
local CR  = "\r\n"       -- Return (CRLF)
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

function createCallbackcmd(data)
  return function(data)
    if (string.find(data, "show ") ~= nil)
    then
      what = string.sub(data, 6)
      trim(what)
      if (string.find(what, "ip") ~= nil)
      then
        ip, nm, gw = wifi.sta.getip()
          if ip ~= nil
          then
            uart.write(0, ip .. " " .. nm .. " " .. gw)
          else
          uart.write(0, "nil")
          end
	  uart.write(0, CR)

      elseif (string.find(data, "speed") ~= nil)
      then
        -- Let's see if there is a config file for serial
        if file.exists("serial.cfg")
        then
          file.open("serial.cfg")
          line = file.readline()
          uart.write(0, "Startup = " .. line .. "\r")
          file.close()
        end
        uart.write(0, "Running = " .. BPS .. "\n\r")
        uart.write(0, CR)    

      elseif (string.find(data, "version") ~= nil)
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
        uart.write(0, "Nothing to show")
      end
      uart.write(0, CR)

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
        uart.write(0, CR)

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
        uart.write(0, CR)
      elseif (string.find(data, "restart") ~= nil)
      then 
        uart.write(0, CR)
        node.restart()
      
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
        uart.write(0, CR)

      elseif (string.find(data, "readbuffer") ~= nil)
      then
        if (buffer ~= nil)
        then
          uart.write(0, buffer)
          buffer = nil
        end
        uart.write(0, CR)

      elseif (string.find(data, "clearbuffer") ~= nil)
      then
        buffer = nil
        uart.write(0, CR)

      elseif (string.find(data, "start ") ~= nil)
      then 
        what = string.sub(data, 7)
        what = trim(what)
        if (what ~= nil)
        then
          if (string.find(data, "telnet") ~= nil)
          then
            telnetd.open(what)
            uart.write(0,"telnet started\n")
          end
        end
        uart.write(0, CR)

      elseif (string.find(data, "get ") ~= nil)
      then 
        what = string.sub(data, 5)
        http = false
        https = false
        if (string.find(what, "https://") ~= nil)
        then
          what = string.sub(what, 9)
          https = true
        elseif (string.find(what, "http://") ~= nil)
        then
           what = string.sub(what, 8)
           http = true
        end
      
        if (http or https)
        then
          sloc = string.find(what, "/")
          if (sloc ~= nil)
          then
            host = string.sub(what, 1, sloc-1)
            item = string.sub(what,sloc)
            item = trim(item)
          else
            host = what
            item = "/"
          end
          host = trim(host)
	
          if (host ~= nil)
          then
            if http
            then -- open HTTP connection
              conn = net.createConnection(net.TCP, 0)
              port = 80
            else -- open HTTPS conneciton
              conn = tls.createConnection()
              port = 443
            end

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
            conn:connect(port,host)
          end    
        end
        uart.write(0, CR)
    
      elseif (string.find(data, "ATZ") ~= nil)
      then
        uart.write(0, "OK")
        uart.write(0, CR)
    
      elseif (string.find(data, "ATDT") ~= nil)
      then
        slen = string.len(data)
        if (slen > 6)
        then
	      what = string.sub(data, 6, slen-2) -- lose ATDT and quotes
	      ploc = string.find(what, ":")
	      if (ploc ~= nil)
	      then
	        port = string.sub(what, ploc+1)
	        host = string.sub(what, 1, ploc-1)
	      else
	        port = 23
	        host = what
	      end

        if (host ~= nil)
        then
          conn = net.createConnection(net.TCP, 0)
          conn:on("receive", function(sck, c)
            uart.write(0, c)
          end)

	      conn:on("connection", function(sck, c)
	        uart.write(0, "CONNECT")
	        uart.write(0, CR)
	        uart.on("data", 0, function(data)
	          conn:send(data)
	        end, 0)
	      end)

	      conn:on("disconnection", function(c)
	        uart.on("data")
            uart.on("data", "\r", createCallbackcmd(data), 0)
	      end, 0)

	      -- start connection
	      conn:connect(port, host)
 
        else
          uart.write(0, "ERROR")
          uart.write(0, CR)
        end
      else 
        uart.write(0, "ERROR")
        uart.write(0, CR)
      end

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
      uart.write(0, CR)
              
    else 
      uart.write(0, CR)
    end  
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

  if (BPS~=1200 and BPS~=2400 and BPS~=9600 and BPS~=19200 and BPS~=115200) 
  then
    BPS=115200
  end
  
uart.setup(0,BPS,8,0,1,0,1)

uart.on("data", "\r", createCallbackcmd(data), 0)
