# MSX-wifi
MSX wifi (ESP8266 via RS232)

Add a wifi interface to an MSX computer, using a modified NMS1250 modem cartridge. 
All modem specific components have been removed and an ESP8266 with a 5V adapter
has been connected directly to the Z8530 chip (basicaly this works also for other
modem cartridges and RS232 cartridges.

Hardware
- NMS1250 modem cartridge (or other)
- MSX computer
- ESP8266 with NodeMCU firmware
- 5V adapter (or level shifters) to connect 3.3V ESP to Z8530

Software for ESP
- NodeMCU firmware (with tmr, http, uart, mdns modules)
- Lua sources to be put on filesystem of ESP

Software for MSX
- Fossil driver from Erik Maas
- Turbo Pascal 3.0
- Sample program ESP.PAS to send commands

Preparation:
- modify NMS1250 interface: connect ESP8266 with 5V adapter to Z8530
- flash ESP8266 with NodeMCU firmware
- copy lua files to ESP flash filesystem
- rename setup.lua to init.lua to ensure automatic startup

- On MSX compile ESP.PAS to ESP.COM using Turbo Pascal 3.0 (messages off)
- Download Fossil driver for MSX

- Initially the ESP creates its own Wifi AP. You can connect to this AP 
  using a browser. Changing the wifi setting can be done via a config.html
  to be found via <http://192.168.4.1/config.html> when you have connected
  to the ESP wifi.
- fill in ssid, password and leave client "empty".
- information will be stored on ESP in wifi.cfg, so next start of ESP will
  ensure reconnect. (Please Note: password of wifi network is stored in 
  clear text in wifi.cfg!!!)
  
Usage
- Start MSX
- Go to MSX-DOS
- Install Fossil driver by running DRIVER.COM
- Go back to MSX-DOS (from MSX Basic)
- Run ESP.COM

- commands
  - ESP getip
  - ESP getmask
  - ESP whois <host>
    (example ESP whois www.google.com)
    
