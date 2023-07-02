# MSX-wifi
MSX wifi (ESP8266 via RS232)

Add a wifi interface to an MSX computer, using an original MSX modem or serial cartridge such as the Philips NMS1250 or NMS121x and connecting an ESP8266 SoC to it. It requires some soldering to connect the ESP to a modem cartridge, for a serial cartridge this is optional. If you don't like the hardware part at all, you could buy a BadCat Wifi interface for MSX; this interface already has an ESP8266 onboard. Basically any interface with a uart will do, but preferably one that is supported by Erik Maas' Fossil driver, because that makes it easier to use existing apps and to develop your own programs.

This project is still under development, but it works already: http server, http client, telnet client, telnet server, whois domain lookup, and - in the future - https client, ftp client, just to name a few, and mdns/bonjour (i.e. your MSX will automatically pop up in Finder or Explorer on PC's/Macs).

The things an MSX can do with this ESP2866 SoC are endless... 

... so stay tuned for updates.

<b> WHAT YOU NEED - Hardware</b>
- MSX cartridge with UART / Serial Interface, such as:
  - NMS1250, NMS121x, MT Telcom II, or
  - BadCat Wifi MSX cartridge (this one already has an onboard ESP8266)
- ESP8266 SoC (ESP01) and 5V adapter (or level shifters) to connect 3.3V ESP to the uart
- MSX computer
  - MSX2 with MSX DOS2 is preferred; you can make it work on an MSX1, but - depending on the interface you have - results may vary (and it may not be very usable on an MSX1) 
  - (optional) MSX cartridge that can do SD-cards; not required, but makes life easier
- PC/Mac with a USB interface
- USB/Serial cable/interface to connect the ESP to your PC/Mac

<b>WHAT YOU NEED - Software for ESP</b>
- NodeMCU firmware (see https://nodemcu.readthedocs.io/en/release/getting-started/ on how to build and flash it)

<b>WHAT YOU NEED - Software for MSX</b>
- Fossil driver from Erik Maas (See: https://hansotten.file-hunter.com/software/)
- Turbo Pascal 3.0 (See: http://pascal.hansotten.com/delphi/turbo-pascal-on-cpm-msx-dos-and-ms-dos/)
- Any MSX terminal program that recognizes the interface you use, for example
  - If you have an MSX2: ERIX, MODRS, CACIS or
  - If you have RS232 BASIC for your interface: _COMTERM, or
  - TERM.PAS - in this repository - is a very simple Terminal Program, written in Pascal

<b>WHAT YOU NEED - Software for PC/Mac</b>
- NodeMCU flasher, or pyflasher to flash the firmware on the ESP (for details on starting with the ESP see https://nodemcu.readthedocs.io/en/release/getting-started/)
- ESPlorer to upload Lua-files from this Github-repository to the ESP (https://esp8266.ru/esplorer/)
 
<b>PREPARE - ESP</b>
- Build NodeMCU firmware and flash it using a PC/Mac
- Connect the ESP to a PC/Mac using a USB-Serial interface, and
  - Flash ESP8266 with NodeMCU firmware
  - Copy Lua files to ESP flash filesystem, using ESPlorer

<b>PREPARE - Serial Interface</b> choose whatever interface you have
- NMS1250 interface
  - connect ESP8266 with 5V adapter or level shifters to Z8530
- MT Telcom II interface
  - connect ESP8266 with 5V adapter or level shifters to 8251
- NMS121x interface
  - connect ESP8266, either internally - same as with modem cartridge - or externally (not described here)
- BadCat Wifi interface
  - open cartridge, and
  - Prepare the ESP (described above)

<b>PREPARE - MSX</b>
- Install your Terminal program and - if required - install Fossil driver, and put FOSLIB.INC in a location where Turbo Pascal can find it
- (optionally) Prepare MSX to do Lua uploads to the ESP (this only necessary if you want to develop/change Lua files using your MSX)
  - On MSX compile ESP.PAS, UPL9600.PAS and UPL115K.PAS using Turbo Pascal 3.0 (messages off); if you prefer another bps rate, you must change the bitrate in the source code
  - Use UPLxxxx.COM to upload files (*.lua, *.htm and help.hlp) to the ESP

<b>USAGE</b>
- Start MSX

- Run Fossil driver (depending on your terminal program) and 
- Run your terminal program

- You can type in any of the following commands (characters are echoed back by the ESP; if you see "garbage" when you type, probably the bps-rate is incorrect, try setting a different speed; if you do not see anything, the ESP may not be connected properly).

  - <b>help</b>
    Show a list of commands
    
  - <b>set wifi \<ssid\> \<password\></b>
    Set wifi configuration

  - <b>show wifi</b>
    Show wifi configuration

  - <b>show ip</b>
    Shows current ip, netmask and gateway
  
  - <b>show speed</b>
    Shows bps rate of serial interface, both running and startup-speed
    
  - <b>set speed \<bps\></b>
    Sets the startup-speed. Will be active after next restart

  - <b>whois \<host\></b>
    DNS resolve of host
    example "whois www.google.com"

  - <b>ping \<host\></b>
    Sends five echo requests to host (fqdn or ip)
  
  - <b>get http://\<host\>/\<file\></b>
    Open HTTP connection to \<host\> and get \<file\>
    example "get http://msx.org"
   
  - <b>start telnet</b>
    Start telnet server to accept <i>incoming</i> telnet-connections

  - <b>stop telnet</b>
    Stop telnet server

  - <b>restart</b>
    Restarts ESP

  - <b>ATZ</b>
    Shows OK

  - <b>ATDT"host:port"</b>
    Opens a telnet client connection to host on port
