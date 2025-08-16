HELP - advanced usage

The ESP, when it is loaded with the Lua files in this repository will automatically start \<init.lua\> (simply put: \<init.lua\> in NodeMCU acts like an \<autoexec,bat\> in MSX DOS).

To enable the uploading of new Lua-files, this startup process can be interrupted. What this does is, after setting the configured bps-rate, it will drop back to the command line so that it will listen to Lua commands. (if you do not interrupt the startup, then the ESP will not listen to the commands necessary to upload files; what you will see in ESPlorer is a message saying that the ESP is not responding).

The relevant commands are:

- <b>set stop</b>
  Disables automatic startup of the Lua code on the ESP. Will be active after restart. You can then command the ESP via its built-in Lua commands. If you want to automatically start the Lua code again you must remove the file "stop.cfg" from the ESP file system (use: file.remove("stop.cfg") in Lua).
  
- <b>show stop</b>
  Shows the status of startup sequence, ON is active (i.e. a file stop.cfg exists on the file system), and OFF is inactive.

- <b>restart</b>
  Restarts the ESP.

These commands can be used when it is connected to the MSX (using a terminal program) as well as when it is connected to a PC/Mac (using ESPlorer). In fact, the startup behaviour of the ESP is always the same - as soon as it is powered on - no matter if and where it connected).

How does this work? The \<init.lua\> will check for a file \<stop.cfg\>. If this file exists it will drop to the Lua interface, otherwise it will launch the "command interpreter", hence it will listen to the commands described in the help-file.

Whenever you want to re-enable automatic startup, you have to remove \<stop.cfg\>, using the following Lua command:

- <b>file.remove(\"stop.cfg\")</b>

This will have an effect only after restart, with:

- <b>node.restart()</b>

... more information on Lua commands - and there are many - can be found at https://nodemcu.readthedocs.io/en/release/ .
