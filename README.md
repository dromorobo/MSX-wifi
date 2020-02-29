# MSX-wifi
MSX wifi (ESP8266 via RS232)

Add a wifi interface to an MSX computer, using a modified NMS1250 modem cartridge. 
All modem specific components have been removed and an ESP8266 with a 5V adapter
has been connected directly to the Z8530 chip (basically this works also for other
modem cartridges and RS232 cartridges).

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

PREPARATION

Prepare ESP
- flash ESP8266 with NodeMCU firmware
- copy lua files to ESP flash filesystem
- rename setup.lua to init.lua to ensure automatic startup

Prepare NMS1250 interface
- (optional) remove all modem components form NMS1250
- connect ESP8266 with 5V adapter or level shifters to Z8530

Prepare MSX
- On MSX compile ESP.PAS to ESP.COM using Turbo Pascal 3.0 (messages off)
- Download Erik Maas'Fossil driver for MSX

Start MSX and configure Wifi on ESP
- Initially the ESP creates its own Wifi AP. You can connect to this AP 
  using a browser. Changing the wifi setting can be done via a config.html
  to be found via \<http://192.168.4.1/config.html\>, the password is
  \<12345678\
- Wwhen you have connected to the ESP wifi config page:
  - fill in ssid, password and leave client "empty".
  - information will be stored on ESP in wifi.cfg, so next start of ESP will
    ensure reconnect. (Please Note: password of wifi network is stored in 
    clear text in wifi.cfg!!!)
  
USAGE
- Start MSX in MSX-DOS
- Install Fossil driver by running DRIVER.COM (MSX will end up in BASIC)
- Go back to MSX-DOS
- Run ESP.COM wit one of the following commands

- Commands
  - ESP get ip
  - ESP get netmask
  - ESP whois \<host\>
    (example ESP whois www.google.com)
    
