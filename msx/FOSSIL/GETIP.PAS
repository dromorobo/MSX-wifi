PROGRAM DEMO_RSdriver;

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

VAR data:byte;

BEGIN
  IF TestDriver=TRUE THEN
  BEGIN
    Set_Speed (4,4); {2400 bps}
    InitRS232;
    SendString('getip');
    SendByte(13);

    REPEAT
      data:=RecByte;
      Write(char(data))
    UNTIL (data = 13);
    DeInitRS232;
  END
  ELSE WriteLn ('*** Wifi adapter not found!',char(7));
END.

