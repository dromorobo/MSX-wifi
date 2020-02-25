-- serial_srv.lua
-- Reads and interprets lines from uart and acts upon the content

-- Setup uart, make permanent (last '1' makes permanent))
-- (uart,bps,databits,parity,stopbits,echo,permanent = 1)

-- uart.setup(0,2400,8,0,1,0,1)

-- When '\r' is received, read data and process
uart.on("data", "\r",
  function(data)
    if (string.find(data, "getip") ~= nil)
    then
      ip, nm = wifi.sta.getip()
      if ip ~= nil
      then
        uart.write(0, ip)
        uart.write(0, 0x04)  -- EOT = End of Transmission
      else
        uart.write(0, "nil")
        uart.write(0, 0x04)  -- EOT = End of Transmission
      end -- ip ~= nil
    
    elseif (string.find(data, "getmask") ~= nil)
      then
        ip, nm = wifi.sta.getip()
        if nm ~= nil
        then
          uart.write(0, nm)
          uart.write(0, 0x04)  -- EOT = End of Transmission
        else
          uart.write(0, "nil")
          uart.write(0, 0x04)  -- EOT = End of Transmission
        end -- nm ~= nil

    elseif (string.find(data, "whois ") ~= nil)
      then -- find the "who"
        len = string.len(data)
        pt_start, pt_end = string.find(data,"whois ")
        if pt_start < len
        then
          -- remove "whois " and trim
          who = string.sub(data,pt_end+1)
          
          if (who ~= nil)
          then

            -- trim all heading non-alphanumeric characters
            pt_start = string.find(who, "%w")
            if pt_start ~= nil
            then
              who = string.sub(who, pt_start)
            end
            
            -- trim all trailing control characters
            pt_start = string.find(who, "%c")
            if pt_end ~= nil
            then
              who = string.sub(who, 1, pt_start-1)
            end
            
            -- trim all trailing spaces characters
            -- assuming all heading spaces have 
            -- already been removed
            pt_start = string.find(who, "%s")
            if pt_start ~= nil
            then
              who = string.sub(who, 1, pt_start-1)
            end

            net.dns.resolve(who, function(sk, ip)
              if (ip ~= nil) 
              then uart.write(0,ip)
              else uart.write(0,"host not found")
              end
              uart.write(0, 0x04)  -- EOT = End of Transmission
            end)
                      
          else
            uart.write(0, "wrong parameter")
            uart.write(0, 0x04)  -- EOT = End of Transmission
          end -- (who ~= nil)
        else
          uart.write(0, "parameter missing")
          uart.write(0, 0x04)  -- EOT = End of Transmission
        end -- len>6
    else 
      uart.write(0, "Incorrect Command")
      uart.write(0, 0x04)  -- EOT = End of Transmission
    end  
  end, 0)
