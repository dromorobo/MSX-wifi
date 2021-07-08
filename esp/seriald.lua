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
    -- return s:match'^[\s]*(.*?)[\s]*$' or ''
    return s:match"^[%s]*(.-)[%s]*$" or ''
  end

  function split(str, pat)
     local t = {}  -- NOTE: use {n = 0} in Lua-5.0
     local fpat = "(.-)" .. pat
     local last_end = 1
     local s, e, cap = str:find(fpat, 1)
     while s do
        if s ~= 1 or cap ~= "" then
           table.insert(t, cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
     end
     if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
     end
     return t
  end

  function split_parms(str)
     return split(str,' ')
  end

  function split_url(str)
     --return split(str,'(.*?)[:][\/][\/](.*?)[\/](.*?)[:](.*?)$')
     return split(str,':\/\/')
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

      local elements = split_parms(data)

      data = trim(data)
      
      local i = 1
      while (elements[i] ~= nil)
      do
        uwriteln(elements[i])
        i = i+1
      end
      
      if (string.match(elements[1],"show") ~= nil)
      then
        if (string.match(elements[2],"ip") ~= nil)
        then
          ip, nm, gw = wifi.sta.getip()
          if ip ~= nil
          then
            uwriteln(ip .. " " .. nm .. " " .. gw)
          else
            uwriteln("no ip address")
          end

        elseif (string.match(elements[2], "speed") ~= nil)
        then
          -- Let's see if there is a config file for serial
          if file.exists("serial.cfg")
          then
            file.open("serial.cfg")
            line = file.readline()
            uwriteln("Startup speed = " .. line .. "\r")
            file.close()
          else
            uwriteln("Startup speed = default")
          end
          
        elseif (string.match(elements[2], "version") ~= nil)
        then 
          uwriteln(VERSION)

        elseif (string.match(elements[2], "buflength") ~= nil)
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

      elseif (string.match(elements[1], "set") ~= nil)
      then
        if (string.match(elements[2], "speed") ~= nil)
        then
          speed = string.sub(what, 7)
          if speed ~= nil
          then -- Write the result in seial.cfg
            file.open("serial.cfg","w+")
            file.write(tostring(speed) .. "\n")
            file.close()
          end
        end

      elseif (string.match(elements[1], "whois") ~= nil)
      then
        if (elements[2] ~= nil)
        then
          uwriteln("name: " .. elements[2] .. ".")
          net.dns.resolve(trim(elements[2]), function(sk, ip)
	        if (ip ~= nil)
            then uwriteln(ip)
            else uwriteln("host not found")
            end
          end)
        end

      elseif (string.match(elements[1], "restart") ~= nil)
      then
        node.restart()

      elseif (string.match(elements[1], "readchar") ~= nil)
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

      elseif (string.match(elements[1], "readbuffer") ~= nil)
      then
        if (buffer ~= nil)
        then
          uwriteln(buffer)
          buffer = nil
        end

      elseif (string.match(elements[1], "clearbuffer") ~= nil)
      then
        buffer = nil

      elseif (string.match(elements[1], "start") ~= nil)
      then
        if (string.match(elements[2], "telnet") ~= nil)
        then
          local tn = require("telnetd")
          tn.open(what)
        end

      elseif (string.match(elements[1], "stop") ~= nil)
      then
        if (string.match(elements[2], "telnet") ~= nil)
        then
          if tn ~= nil
          then
            tn.close(what)
          end
        end

      elseif (string.match(elements[1], "get") ~= nil)
      then
        local url = split_url(elements[2])
        local protocol = url[1]
        
        local uri = split(url[2], '\/')
        local host = uri[1]
        local item = uri[2]

        if (item == nil)
        then
          item = "/"
        end
        

        if (string.match(protocol, "https") ~= nil)
        then
          conn = tls.createConnection()
          port = 443
        elseif (string.match(protocol, "http") ~= nil) -- open HTTP conneciton
        then
          conn = net.createConnection(net.TCP, 0)
          port = 80
        else
          conn = nil
          port = 0
        end

        -- test
        uwriteln("protocol: " .. protocol)
        uwriteln("host: " .. host)
        uwriteln("port: " .. port)
        uwriteln("item: "   .. item)
        --
        
        if (conn ~= nil)
        then
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
            request = "GET " .. item .. " HTTP/1.1\r\nHost: " .. url[2] .. "\r\n\r\n"
            conn:send(request)
          end)

          -- Start connection
          conn:connect(port,trim(host))
        end
  
      elseif (string.find(elements[1], "AT") ~= nil)
      then
        result = "OK"
        slen = string.len(elements[1])
        if (slen > 2)
        then
          what = string.sub(elements[1], 3)
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

      elseif (string.match(elements[1], "help") ~= nil)
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

      elseif (string.match(elements[1], "stop") ~= nil)
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
