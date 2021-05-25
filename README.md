# MSX-wifi
MSX wifi (ESP8266 via RS232)

Add a wifi interface to an MSX computer, using an ESP8266 SoC. This is a very sophisticated low-cost solution that uses a serial interface to communicate with the host. It is easy to make a cartridge yourself: you just have to modify an MSX modem cartridge, such as the Philips NMS1250, but basically any modem or serial cartridge will do (*). I used an NMS1250, where I removed all modem specific components and connecting the ESP8266 with a 5V adapter directly to the Z8530 uart.

Another solution is to buy a BadCat Wifi MSX cartridge. This cartridge also uses an ESP8266. You need to re-flash it with NodeMCU firmware.

(*) preferably one that is supported by Erik Maas' Fossil driver, because that makes it easier to develop your own programs.

This is still under development, but it works already... http server and client, https client, domain lookup, even mdns works, meaning your MSX will automatically turn op in Finder or Explorer... so stay tuned for updates.

Hardware
- NMS1250 modem cartridge (or other. MSX DOS only if supported by Fossil Driver)
- MSX computer
- ESP8266
- 5V adapter (or level shifters) to connect 3.3V ESP to Z8530 (or 8251, depending on cartridge)

or
- BadCat Wifi MSX cartridge

Software for ESP
- NodeMCU firmware (with tmr, http, uart, mdns modules)
- Lua sources to be put on filesystem of ESP

Software for MSX
- Fossil driver from Erik Maas
- Turbo Pascal 3.0
- Sample program ESP.PAS to send commands
- UPLOAD.PAS to upload Lua files to the ESP on the MSX

or
- a terminal program that recognizes the interface you use

PREPARATION

Prepare NMS1250 interface
- (optional) remove all modem components form NMS1250
- connect ESP8266 with 5V adapter or level shifters to Z8530 (or 8251, depending on cartridge)

Prepare ESP
- Build NodeMCU firmware (how this is done is not described here, but there is lots of info available; pleas take a look at NodeMCU docs ar <https://nodemcu.readthedocs.io/en/release/>.
- Flash ESP8266 with NodeMCU firmware
- (optional) Copy lua files to ESP flash filesystem

Prepare MSX
- On MSX compile ESP.PAS to ESP.COM using Turbo Pascal 3.0 (messages off)
- On MSX compile UPLOAD.PAS to UPLOAD.COM using Turbo Pascal 3.0 (messages off)
- Download Erik Maas'Fossil driver for MSX
- Install Fossil driver
- Use UPLOAD.COM to upload all Lua files to the ESP (if not done earlier in preparing the ESP)

Start MSX and configure Wifi on ESP
- Initially the ESP creates its own Wifi AP. You can connect to this AP using a browser. Changing the wifi setting can be done via a config.html to be found via \<http://192.168.4.1/config.html\>, the password is "12345678" (loose the quotes).
- When you have connected to the ESP wifi config page:
  - fill in ssid, password and leave client "empty".
  - information will be stored on ESP in wifi.cfg, so next start of ESP will ensure reconnect. (Please Note: password of wifi network is stored in clear text in wifi.cfg!!!)
  
USAGE
- Start MSX, install Fossil driver and Run ESP.COM with one of the following commands

or
- Start your terminal program, and type one of the following commands

- Commands
  - <b>help</b>
    Show a list of commands
    
  - <b>show ip</b>
  
  - <b>show netmask</b>
  
  - <b>show speed</b>
    Shows bps rate of serial interface, both running and startup-speed
    
  - <b>set speed \<bps\></b>
    Sets the startup-speed. Will be active after next restart
  
  - <b>whois \<host\></b>
    DNS resolve of host
    example "whois www.google.com"
  
  - <b>fetch http://\<host\>/\<file\></b>
    Open HTTP connection to \<host\> and get \<file\>
    example "fetch http://msx.org"
   
  - <b>fetch https://\<host\>/\<file\></b>
    Open HTTPS connection to \<host\> and get \<file\>
    example "fetch https://www.bliekiepedia.nl"
   
  - <b>show buflength</b>
    Show number of characters in receive buffer
  
  - <b>readchar</b>
    Read next charaxter in receive buffer
    
  - <b>readbuffer</b>
    Read the whole buffer at once
   
  - <b>clearbuffer</b>
    Clear buffer, size will be 0

  - <b>restart</b>
    Restarts ESP
