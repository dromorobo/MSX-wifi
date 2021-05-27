-- a simple http server

-- restart server if needed
if http_srv ~= nil then
    http_srv:close()
end
http_srv=net.createServer(net.TCP)

http_srv:listen(80,function(conn)
  conn:on("receive", function(client,payload) 
    -- first find GET or POST
    if string.find(payload, "GET")
    then
      -- method is GET, extract uri, and be sure to check syntax
      uri = ""
      if string.find(payload, "GET /")
      then
        if string.find(payload, "HTTP/")
        then
          uri = string.sub(payload,string.find(payload,"GET /")
                  +5,string.find(payload,"HTTP/")-2)
        end
      end
      
      if uri == "" 
      then 
        -- nothing found, assume default = index.html
        tgtfile = "index.html" 
      else
        tgtfile = uri
      end
       
      -- Check for .html or .ico or .png
      if (string.find(tgtfile, ".html")
          or string.find(tgtfile, ".ico")
          or string.find(tgtfile, ".png") ~= nil)
      then
        local f = file.open(tgtfile,"r")
        if f ~= nil 
        then
          client:send(file.read())
          file.close()
        end
      else
        client:send("<html>"..tgtfile.." not found - 404 error.<BR><a href='index.html'>Home</a><BR>")
      end

    else
      -- no GET so assume POST, find parameters
      -- expected parameter is [ssid] and [password]        
      fssid={string.find(payload,"ssid=")}
      
      if fssid[2]~=nil
      then    
        foundssid=string.sub(payload,string.find(payload,"ssid=")
            +5,string.find(payload,"&password=")-1)
        foundpwd=string.sub(payload,string.find(payload,"password=")
            +9,string.find(payload,"&mode=")-1)
        foundmode=string.sub(payload,string.find(payload,"mode=")
            +5)

        -- Write the result in wifi.cfg
        file.open("wifi.cfg","w+")
        file.write(foundssid .. "\n")
        file.write(foundpwd .. "\n")
        if foundmode == "server"
        then
          file.write("server\n")
        else
          file.write("client\n")
        end
        file.close()
        
        -- Assume the request can be OK-ed
        conn:send('HTTP/1.0 200 OK\n')
        conn:send('Server: MSX HTTP\n')
        conn:send('\n')
        conn:send('\n')
        
        f = nil
        tgtfile = nil
        collectgarbage()
      end
    end
  end)

  conn:on("sent",function(conn) conn:close() end)

end)