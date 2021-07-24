# MSX-wifi
MSX wifi (ESP8266 via RS232)

Add a wifi interface to an MSX computer, using an original MSX modem or serial cartridge such as the Philips NMS1250 or NMS121x and connecting an ESP8266 SoC to it. It requires some soldering to connect the ESP to a modem cartridge, for a serial cartridge this is optional. If you don't like the hardware part at all, you could buy a BadCat Wifi interface for MSX; this interface already has an ESP8266 onboard. Basically any interface with a uart will do, but preferably one that is supported by Erik Maas' Fossil driver, because that makes it easier to use existing apps and to develop your own programs.

This project is still under development, but it works already: http server, http client, telnet client, telnet server, whois domain lookup, and - in the future - https client, ftp client, just to name a few, and mdns/bonjour (i.e. your MSX will automatically pop up in Finder or Explorer on PC's/Macs).

The things an MSX can do with this ESP2866 SoC are endless... 

... so stay tuned for updates.

WHAT YOU NEED - Hardware
- MSX cartridge with UART / Serial Interface, such as:
  - NMS1250 modem cartridge, 
  - NMS121x serial adapter
  - MT Telcom II (not supported by Fossil Driver)
  - BadCat Wifi MSX cartridge (this one already has an onboard ESP8266)
- ESP8266 SoC (ESP01) and 5V adapter (or level shifters) to connect 3.3V ESP to the uart
- MSX computer
  - MSX2 with MSX DOS2 is preferred, but MSX1 will do 
  - (optional) MSX cartridge that can do SD-cards; not required, but makes life easier
- PC/Mac with a USB-serial interface (to connect the ESP and flash it with a new firmware)
- USB/Serial interface to connect the ESP to your PC/Mac

WHAT YOU NEED - Software for ESP
- NodeMCU firmware (see https://nodemcu.readthedocs.io/en/release/getting-started/ on how to build and flash it)

WHAT YOU NEED - Software for MSX
- Fossil driver from Erik Maas (See: https://hansotten.file-hunter.com/software/)
- Turbo Pascal 3.0 (See: http://pascal.hansotten.com/delphi/turbo-pascal-on-cpm-msx-dos-and-ms-dos/)
- Any MSX terminal program that recognizes the interface you use, for example
  - ERIX
  - MODRS
  - If you have RS232 BASIC for your interface: _COMTERM, or
  - ESP.COM - in this repository - is a very simple Terminal Program, written in Pascal

WHAT YOU NEED - Software for PC/Mac
- NodeMCU flasher, or pyflasher to flash the firmware on the ESP
- ESPlorer to upload Lua-files from this Github-repository to the ESP 
 
PREPARE - Serial Interface, choose whatever interface you have
- NMS1250 interface
  - Prepare the ESP (see below)
  - connect ESP8266 with 5V adapter or level shifters to Z8530
- MT Telcom II interface
  - Prepare the ESP (see below)
  - connect ESP8266 with 5V adapter or level shifters to 8251
- NMS121x interface
  - Prepare the ESP (see below)
  - connect ESP8266, either internally - same as with modem cartridge - or externally (not described here)
- BadCat Wifi interface
  - open cartridge, and
  - Prepare the ESP (see below) 

PREPARE - ESP
- Build NodeMCU firmware and flash it using a PC/Mac
- Connect the ESP to a PC/Mac using a USB-Serial interface, and
  - Flash ESP8266 with NodeMCU firmware
  - Copy Lua files to ESP flash filesystem, using ESPlorer

PREPARE - MSX
- Install Fossil driver, put FOSLIB.INC in a location where Turbo Pascal can find it
- (optionally) Prepare MSX to do Lua uploads to the ESP (this only necessary if you want to develop/change Lua files using your MSX)
  - On MSX compile ESP.PAS, UPL9600.PAS and UPL115K.PAS using Turbo Pascal 3.0 (messages off); if you prefer another bps rate, you must change the bitrate in the source code
  - Use UPLxxxx.COM to upload files (*.lua, *.htm and help.hlp) to the ESP

USAGE
- Start MSX

- Connect the ESP to your home Wifi network (you only need to do this once)
  - Initially the ESP creates its own Wifi Access Point (named "dmr_xxxxxx"). You can connect to this Access Point with any browser on your PC/Mac. The password is "12345678" without the quotes. 
  - After you connect, browse to the configuration page of the ESP at \<http://192.168.4.1/config.htm> and fill in ssid (i.e. the name of your wifi network at home), password and leave client/server "empty".
  - The information will be stored on ESP, so the ESP automatically reconnect when restarted (Please Note: password of your wifi network is stored in clear text).
  
- Run Fossil driver (depending on your terminal program) and 
- Run your terminal program

- You can type in any of the following commands (characters are echoed back by the ESP; if you see "garbage" when you type, probably the bps-rate is incorrect, try setting a different speed; if you do not see anything, the ESP may not be connected properly).

  - <b>help</b>
    Show a list of commands
    
  - <b>show ip</b>
    Shows current ip, netmask and gateway
  
  - <b>show speed</b>
    Shows bps rate of serial interface, both running and startup-speed
    
  - <b>set speed \<bps\></b>
    Sets the startup-speed. Will be active after next restart

  - <b>set stop</b>
    Disables automatic startup of the Lua code on the ESP. Will be active after restart. You can then command the ESP via its built-in Lua commands. If you want to automatically start the Lua code again you must remove the file "stop.cfg" from the ESP file system (use: file.remove("stop.cfg") in Lua).
  
  - <b>show stop</b>
    Shows the status of startup sequence, ON is active (i.e. a file stop.cfg exists on the file system), and OFF is inactive

  - <b>whois \<host\></b>
    DNS resolve of host
    example "whois www.google.com"
  
  - <b>get http://\<host\>/\<file\></b>
    Open HTTP connection to \<host\> and get \<file\>
    example "get http://msx.org"
   
  - <b>get https://\<host\>/\<file\></b>
    Open HTTPS connection to \<host\> and get \<file\>
    example "get https://www.bliekiepedia.nl"
   
  - <b>start telnet</b>
    Start telnet daemon

  - <b>stop telnet</b>
    Stop telnet daemon

  - <b>restart</b>
    Restarts ESP

  - <b>ATZ</b>
    Shows OK

  - <b>ATDT"host:port"</b>
    Opens a telnet client connection to host on port
