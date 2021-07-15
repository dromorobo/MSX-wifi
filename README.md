# MSX-wifi
MSX wifi (ESP8266 via RS232)

Add a wifi interface to an MSX computer, using an original MSX modem or serial cartridge such as the Philips NMS1250 or NMS121x and connect an ESP8266 SoC to it. It requires some soldering to connect the ESP to a modem cartridge, for a serial cartridge this is optional. If you don't like the hardware part at all, you could buy a BadCat Wifi interface for MSX; this interface already has an ESP8266 onboard. Basically any interface with a uart will do, but preferably one that is supported by Erik Maas' Fossil driver, because that makes it easier to use existing apps and to develop your own programs.

This project is still under development, but it works already: http server and client, https client, domain lookup, even mdns/bonjour works, which means that your MSX will automatically pop up in Finder or Explorer on PC's/Macs. 

The things an MSX can do with this ESP2866 SoC are endless... 

... so stay tuned for updates.

WHAT YOU NEED - Hardware
- Serial Interface
  - NMS1250 modem cartridge or other, and an ESP8266 SoC (ESP01) and 5V adapter (or level shifters) to connect 3.3V ESP to the uart (Z8530, 8251, 8250 or 16550, depending on cartridge), or
  - BadCat Wifi MSX cartridge, which already has an onboard ESP8266
- MSX computer
  - Any MSX1 or MSX2 with MSX DOS will do
  - (optional) MSX cartridge that can do SD-cards; not required, but makes life easier
- PC/Mac with a USB-serial interface (to connect the ESP and flash it with a new firmware)

WHAT YOU NEED - Software for ESP
- NodeMCU firmware (with tmr, http, uart, mdns modules)

WHAT YOU NEED - Software for MSX
- Fossil driver from Erik Maas (See: https://hansotten.file-hunter.com/software/)
- Turbo Pascal 3.0 (See: http://pascal.hansotten.com/delphi/turbo-pascal-on-cpm-msx-dos-and-ms-dos/)
- any MSX terminal program that recognizes the interface you use (e.g. ERIX)

WHAT YOU NEED - Software for PC/Mac
- NodeMCU flasher, or pyflasher to flash the firmware on the ESP
- ESPlorer to upload Lua files to the ESP 
 
PREPARE - Serial Interface, choose whatever interface you have
- NMS1250 interface
  - (optional) remove all modem components from NMS1250
  - Prepare the ESP (see below)
  - connect ESP8266 with 5V adapter or level shifters to Z8530
- NMS121x interface
  - Prepare the ESP (see below)
  - connect ESP8266, either internally - same as with modem cartridge - or externally (not decribed here)
- BadCat Wifi interface
  - open cartridge, and
  - Prepare the ESP (see below) 

PREPARE - ESP
- Build NodeMCU firmware using a PC/Mac (See <https://nodemcu.readthedocs.io/en/release/>).
- Connect the ESP to a PC/Mac using a USB-Serial interface, and
  - Flash ESP8266 with NodeMCU firmware
  - Copy Lua files to ESP flash filesystem, using ESPlorer

PREPARE - MSX
- Download Erik Maas'Fossil driver for MSX
- Install Fossil driver, put FOSLIB.INC in a location where Turbo Pascal can find it
- (optionally) Prepare MSX to do Lua uploads to the ESP (this only necessary if you want to develop/change Lua files using your MSX)
  - On MSX compile ESP.PAS, UPL9600.PAS and UPL115K.PAS using Turbo Pascal 3.0 (messages off); you may want to change the bitrate first in the source code (it is "hardcoded" in the current version)
  - Use UPLxxxx.COM to upload files (*.lua, *.htm and help.hlp) to the ESP

Start MSX and configure Wifi on ESP
- Initially the ESP creates its own Wifi AP. You can connect to this AP using a browser. Changing the wifi setting can be done via a config.html to be found via \<http://192.168.4.1/config.htm>, the password is "12345678" (lose the quotes).
- When you have connected to the ESP wifi config page:
  - fill in ssid, password and leave client "empty".
  - information will be stored on ESP, so next start of ESP will ensure reconnect. (Please Note: password of wifi network is stored in clear text)
  
USAGE
- Start MSX, install Fossil driver and Run ESP.COM with one of the following commands

or
- Start your terminal program, and type one of the following commands

- Commands
  - <b>help</b>
    Show a list of commands
    
  - <b>show ip</b>
    Shows current ip, netmask and gateway
  
  - <b>show speed</b>
    Shows bps rate of serial interface, both running and startup-speed
    
  - <b>set speed \<bps\></b>
    Sets the startup-speed. Will be active after next restart

  - <b>set stop</b>
    Enables interrupt of startup sequence to allow access to Lua, by creating a file stop.cfg. Will be active after restart. Can be disabled by removing stop.cfg from the ESP file system
  
  - <b>show stop</b>
    Shows the status of startup sequence, ON is active (i.e. a file stop.cfg exists on the file system), and OFF is inactive

  - <b>whois \<host\></b>
    DNS resolve of host
    example "whois www.google.com"
  
  - <b>get http://\<host\>/\<file\></b>
    Open HTTP connection to \<host\> and get \<file\>
    example "fetch http://msx.org"
   
  - <b>get https://\<host\>/\<file\></b>
    Open HTTPS connection to \<host\> and get \<file\>
    example "fetch https://www.bliekiepedia.nl"
   
  - <b>start telnet</b>
    Start telnet daemon

  - <b>stop telnet</b>
    Stop telnet daemon

  - <b>restart</b>
    Restarts ESP
