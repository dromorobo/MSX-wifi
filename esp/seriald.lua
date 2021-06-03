-- seriald.lua
-- Reads and interprets lines from uart and acts upon the content

-- Setup uart, make permanent (last '1' makes permanent))
-- (uart,bps,databits,parity,stopbits,echo,permanent = 1)

-- When '\r' is received, read data and process

local VERSION = "0.09"
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

function uwriteln(s)
  uart.write(0, s)
  uart.write(0, CR)
end

function uwrite(s)
  uart.write(0, s)
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
          uwriteln(ip .. " " .. nm .. " " .. gw)
        end

      elseif (string.find(data, "speed") ~= nil)
      then
        -- Let's see if there is a config file for serial
        if file.exists("serial.cfg")
        then
          file.open("serial.cfg")
          line = file.readline()
          uwriteln("Startup = " .. line .. "\r")
          file.close()
        end
	uart.write(0, "Running = " .. BPS .. "\r")

      elseif (string.find(data, "version") ~= nil)
      then 
        uwriteln(VERSION)

      elseif (string.find(data, "buflength") ~= nil)
      then
        if (buffer ~= nil)
        then
          uwriteln(tostring(string.len(buffer)))
        else
          uart.write(0, "0")
        end

      else
        uwriteln("Nothing to show")
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

    elseif (string.find(data, "whois ") ~= nil)
    then
      what = string.sub(data, 7)
      what = trim(what)
      if (what ~= nil)
      then
        net.dns.resolve(what, function(sk, ip)
	  if (ip ~= nil)
          then uwriteln(ip)
          else uwriteln("host not found")
          end
        end)
      end

    elseif (string.find(data, "restart") ~= nil)
    then
      node.restart()

    elseif (string.find(data, "readchar") ~= nil)
    then
      if (buffer ~= nil)
      then
        uwrite(string.sub(buffer,1,1))
        if (string.len(buffer)>1)
        then
          buffer = string.sub(buffer,2)
        else
          buffer = nil
        end
      else
        uwriteln("Nothing to read")
      end

    elseif (string.find(data, "readbuffer") ~= nil)
    then
      if (buffer ~= nil)
      then
        uwriteln(buffer)
        buffer = nil
      end

    elseif (string.find(data, "clearbuffer") ~= nil)
    then
      buffer = nil

    elseif (string.find(data, "start ") ~= nil)
    then
      what = string.sub(data, 7)
      what = trim(what)
      if (what ~= nil)
      then
        if (string.find(data, "telnet") ~= nil)
        then
          local tn = require("telnetd")
          tn.open(what)
        end
      end

    elseif (string.find(data, "stop") ~= nil)
    then
      what = string.sub(data, 6)
      what = trim(what)
      if (what ~= nil)
      then
        if (string.find(data, "telnet") ~= nil)
        then
          if tn ~= nil
          then
            tn.close(what)
          end
        end
      end

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

        uwriteln(what)

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
	        -- if buffer == nil
	        -- then
	        --   buffer = c
	        -- else
	        --   buffer = buffer .. c
	        -- end
	        uwrite(c)
          end)

          -- In case of connection send request
          conn:on("connection", function(sck, c)
            request = "GET " .. item .. " HTTP/1.1\r\nHost: " .. host .. "\r\n\r\n"
            conn:send(request)
          end)

          -- Start connection
          uwriteln(host .. " : " .. port)
          conn:connect(port,host)
        end
      end
  
    elseif (string.find(data, "AT") ~= nil)
    then
      result = "OK"
      slen = string.len(data)
      if (slen > 2)
      then
        what = string.sub(data, 3)
        what = trim(what)
        if (string.find(what, "DT") ~= nil)
        then -- (AT) DT "<host>:<port>"
          what = string.sub(what, 3)
          what = trim(what)
          if (string.find(what, "\"") ~= nil)
          then -- (AT DT) "<host>:<port>"
            what = string.sub(what,2)
            ploc = string.find(what, "\"")
            if (ploc ~= nil)
            then -- (AT DT ") <host>:<port> (")
              slen = string.len(what)
              what = string.sub(what, 1, slen-1)  
            end
            
            ploc = string.find(what, ":")
            if (ploc ~= nil)
            then
              port = string.sub(what, ploc+1)
              host = string.sub(what, 1, ploc-1)
            else
              port = 23
              host = what
            end
          end

          uwriteln("Host: " .. host)
          uwriteln("Port: " .. port)
          
          if (host ~= nil)
          then
	        if (port == 22)
            then
              conn = tls.createonnection()  
            else
              conn = net.createConnection(net.TCP, 0)
            end

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
	          uwriteln("NO CARRIER")
              uart.on("data")
              uart.on("data", "\r", createCallbackcmd(data), 0)
              end, 0)

            -- start connection
            conn:connect(port, host)
            result = nil
          else
            result="ERROR"
          end
        end
        if (result ~= nil)
        then
          uwriteln(result)
        end
      end

    elseif (string.find(data, "help") ~= nil)
    then
      if file.exists("help.hlp")
      then
        file.open("help.hlp")
        line = file.readline()
        while (line ~= nil)
        do
          uwrite(line)
          line = file.readline()
        end
        file.close()
      end

    elseif (string.find(data, "stop") ~= nil)
    then
      file.open("stop.cfg","w+")
      file.write("stop\n")
      file.close()
          
    elseif (data == "")
    then 
      uwriteln("")

    else 
      uwriteln("ERROR")
    end  
  end
end

uart.on("data", "\r", createCallbackcmd(data), 0)
