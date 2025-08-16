PROGRAM Ebps;

VAR tParm : String[10];
    tspeed,
    index            : Integer;

BEGIN
  Writeln('0 = 859372, 1 = 346520, 2 = 231014, 3 = 115200, 4 = 57600, 5 = 38400, 6 = 31250, 7 = 19200, 8 = 9600, 9 = 4800 : ');
  Readln(tspeed);
  Val(tParm, tspeed, index);

  { Set UART to target bps ; assume it is there at IO-port 0x06 and 0x07}
  IF ((0 <= tspeed) AND (tspeed <= 9))
  THEN out(6,tParm)
END.