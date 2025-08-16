PROGRAM Ebps;

{$I FOSLIB.INC}
{
PROCEDURE ChPut (Ch:char);
FUNCTION ToetsDruk:boolean;
FUNCTION ScanKey:char;
FUNCTION TestDriver:boolean;
PROCEDURE Fossil (FosFunc:byte);
PROCEDURE SendString (MyString:Str80);
PROCEDURE InitRS232;
PROCEDURE DeInitRS232;
PROCEDURE SendChar (karakter:Char);
PROCEDURE SendByte (mybyte:byte);
FUNCTION RXready:boolean;
FUNCTION RecByte:byte;
FUNCTION RecChar:char;
PROCEDURE Hook_ChPut (on,echo:boolean);
PROCEDURE Hook_KeyBoard (on:boolean);
PROCEDURE Set_Speed (rx,tx:byte);
PROCEDURE SendCRLF;
}

VAR cParm, tParm, rParm : String[10];
    rLine               : String[40];
    cspeed, tspeed,
    i, index            : Integer;

BEGIN
  IF TestDriver=TRUE
  THEN
    BEGIN
      {Get current speed}
      Writeln('Current speed (3=1200, 4=2400, 6=9600, 7=19200, 9=57600, 11=115200: ');
      Readln(cspeed);
      Writeln('Target speed (3=1200, 4=2400, 6=9600, 7=19200, 9=57600, 11=115200: ');
      Readln(tspeed);
      Val(cParm, cspeed, index);
      Val(tParm, tspeed, index);

      CASE cspeed OF
        3  : Set_Speed(3,3);
        4  : Set_Speed(4,4);
        6  : Set_Speed(6,6);
        7  : Set_Speed(7,7);
        9  : Set_Speed(9,9);
        11 : Set_Speed(11,11);
        ELSE BEGIN
               Writeln('Invalid current speed... setting 115200');
               Set_Speed(11,11);
             END;
      END;

      CASE tspeed OF
        3  : rParm := '1200';
        4  : rParm := '2400';
        6  : rParm := '9600';
        7  : rParm := '19200';
        9  : rParm := '57600';
        11 : rParm := '115200';
        ELSE BEGIN
               WriteLn('Invalid target speed... setting 115200');
               rParm := '115200';
             END
      END;

      InitRS232;

      { Tell ESP to target bps }
      rLine := 'uart.setup(0,'
                           + rParm
                           + ',8 ,uart.PARITY_NONE ,uart.STOPBITS_1  1)';
      FOR i:= 1 TO Length(rLine)
      DO SendChar(rLine[i]);
      SendCRLF;
    END
  ELSE WriteLn('*** RS232 driver not found!',char(7));
END.
