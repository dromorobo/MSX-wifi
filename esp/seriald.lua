-- seriald.lua
-- Reads and interprets lines from uart and acts upon the content

-- Setup uart, make permanent (last '1' makes permanent))
-- (uart,bps,databits,parity,stopbits,echo,permanent = 1)

local VERSION = "0.11"
local CR  = "\r\n"       -- Return (CRLF)
local command = nil

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

  function doit(data)
    data = string.lower(trim(data))
    local elements = split_parms(data)
          
    if (string.match(elements[1],"show") ~= nil)
    then
      if (elements[2] ~= nil) 
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

        elseif (string.match(elements[2], "stop") ~= nil)
        then 
          if file.exists("stop.cfg")
          then
            uwriteln("stop is ON")
          else
            uwriteln("stop is OFF")
          end
        else
          uwriteln("Nothing to show")
        end
      end
      
    elseif (string.match(elements[1], "set") ~= nil)
    then
      if (elements[2] ~= nil)
      then
        if (string.match(elements[2], "speed") ~= nil)
        then
          if (elements[3] ~= nil)
          then -- Write the result in seial.cfg
            file.open("serial.cfg","w+")
            file.write(tostring(trim(elements[3])) .. "\n")
            file.close()
          end
        elseif (string.match(elements[2], "stop") ~= nil)
        then
          file.open("stop.cfg","w+")
          file.write("stop\n")
          file.close()
        end
      else
        uwriteln("Nothing to set")
      end
      
    elseif (string.match(elements[1], "whois") ~= nil)
    then
      if (elements[2] ~= nil)
      then
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

    elseif (string.match(elements[1], "start") ~= nil)
    then
      if (elements[2] ~= nil)
      then
        if (string.match(elements[2], "telnet") ~= nil)
        then
          local tn = require("telnetd")
          tn.open()
        end
      end
      
    elseif (string.match(elements[1], "stop") ~= nil)
    then
      if (elements[2] ~= nil)
      then
        if (string.match(elements[2], "telnet") ~= nil)
        then
          if (tn ~= nil)
          then
            tn.close()
          end
        end
      end
      
    elseif (string.match(elements[1], "get") ~= nil)
    then
      if (elements[2] ~= nil)
      then
        local url = split_url(elements[2])
        local protocol = url[1]
        local uri = url[2]
        
        if (protocol ~= nil)
        then
          if (string.match(protocol, "http") ~= nil)
          then
            if (string.match(protocol, "https") ~= nil)
            then
              conn = tls.createConnection()
              port = 443
            else
              conn = net.createConnection(net.TCP, 0)
              port = 80
            end
          else
            conn = nil
            port = 0
          end

          if (uri ~= nil)
          then -- split uri into host / item
            local urix = split(uri, '\/')
            local host = urix[1]
            local item = urix[2]
  
            if (item == nil)
            then
              item = "/"
            end
          
            if (conn ~= nil)
            then
              conn:on("receive", function(sck, c)
                uwrite(c)
              end)

              -- In case of connection send request
              conn:on("connection", function(sck, c)
                local request = "GET " .. item .. " HTTP/1.1\r\nHost: " .. url[2] .. "\r\n\r\n"
                conn:send(request)
              end)

              -- Start connection
              conn:connect(port,trim(host))
            else
              uwriteln("Nothing to get")
            end
          end
        end
      end
      
    elseif (string.find(data, "atz") ~= nil)
    then
      uwriteln("OK")
  
    elseif (string.find(data, "atd") ~= nil)
    then
      if (string.find(data, "atdt") ~= nil)
      then
        host, port = string.match(data, 'atdt\"(.-):(.-)\"')
      else
        host, port = string.match(data, 'atd\"(.-):(.-)\"')
      end
              
      if (port == nil)
      then 
        port = 23
      else
        port = tonumber(port)
      end
          
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
          uart.on("data", 0, createCallbackcmd(data), 0)
        end, 0)

        -- start connection
        conn:connect(port, host)
        result = nil
      else
        result="ERROR"
      end
        
      if (result ~= nil)
      then
        uwriteln(result)
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
          
    elseif (data == "")
    then 
      uwriteln("")
  
    else 
      uwriteln("ERROR")
    end  
  end

  function createCallbackcmd(data)
    return function(data)
        if (data == "\r")
        then
          uwrite(CR)
          if (command ~= nil)
          then
            doit(command)
          end
          command = nil
        elseif (data == "\b")
          then
            uwrite("\b \b")
            if (command ~= nil)
            then
              if (string.len(command) > 1)
              then -- drop the last character from command
                command = string.sub(command, 1, -2)
              else
                command = nil
              end
            end
          else
            uwrite(data)
            if (command == nil) 
            then
              command = data
            else
              command = command .. data
            end
          end
        end
      end
  
uart.on("data", 0, createCallbackcmd(data), 0)
