-- serial_srv.lua
-- Reads and interprets lines from uart and acts upon the content

-- Setup uart, make permanent (last '1' makes permanent))
-- (uart,bps,databits,parity,stopbits,echo,permanent = 1)

-- uart.setup(0,2400,8,0,1,0,1)

-- When '\r' is received, read data and process

local VERSION = "0.01a"
local EOT = 0x04         -- EOT = End of Transmission

local http_buffer = nil

function trim(s)
  -- trim all heading non-alphanumeric characters
  pt_start = string.find(s, "%w")
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

uart.on("data", "\r",
  function(data)
    if (string.find(data, "get ") ~= nil)
    then
      what = string.sub(data, 5)
      trim(what)
      if (string.find(what, "version") ~= nil)
      then
        uart.write(0, VERSION)
        uart.write(0, EOT)
        
      elseif (string.find(data, "ip") ~= nil)
      then
        ip, nm = wifi.sta.getip()
        if ip ~= nil
        then
          uart.write(0, ip)
          uart.write(0, EOT) 
        else
          uart.write(0, "nil")
          uart.write(0, EOT)
        end
    
      elseif (string.find(data, "netmask") ~= nil)
      then
        ip, nm = wifi.sta.getip()
        if nm ~= nil
        then
          uart.write(0, nm)
          uart.write(0, EOT)
        else
          uart.write(0, "nil")
          uart.write(0, EOT)
        end -- nm ~= nil
      end

    elseif (string.find(data, "whois ") ~= nil)
    then 
      fqdn = string.sub(data, 7)
      fqdn = trim(fqdn)
      if (fqdn ~= nil)
      then
        net.dns.resolve(fqdn, function(sk, ip)
          if (ip ~= nil) 
          then 
            uart.write(0,ip)
          else 
            uart.write(0,"host not found")
          end
          uart.write(0, EOT)
        end)
      end

    elseif (string.find(data, "http ") ~= nil)
    then 
      local uri = string.sub(data, 6)
      local code = nil

      uri = trim(uri)
      if (uri ~= nil)
      then
        http.get("http://" .. uri, nil, function(code, data)
          if (code < 0) then
            print("HTTP request failed")
          else
            uart.write(0,data)
            uart.write(0, EOT)
          end
        end)
      end                            
    else 
      uart.write(0, "Incorrect Command")
      uart.write(0, EOT)
    end  
  end, 0)
