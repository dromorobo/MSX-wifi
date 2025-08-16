PROGRAM Upload9600;

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

VAR Toets,
    inputchar   : char;
    Filename    : String[32];
    InputLine,
    OutputLine  : String[255];
    InputFile   : Text;
    i,c         : Integer;
    isendofline : BOOLEAN;

BEGIN
  IF TestDriver=TRUE THEN
  BEGIN
    Write(char(12));
    Set_Speed (6,6); {9600 baud}
    InitRS232;

    { Read filename }
    Writeln('FileName: ');
    Readln(FileName);
    Assign(InputFile, FileName);
    Reset(InputFile);

    { First tell ESP to open the file for writing }
    SendString('file.open("');
    SendString(FileName);
    SendString('", "w")');

    { Read lines and send them to ESP }
    REPEAT
      {Clear all characters }
      InputLine := '';

      c := 1;
      isendofline := FALSE;

      { Read one line }
      { First, trim anything that is not printable }
      REPEAT
          Read(InputFile, inputchar);
      UNTIL ((inputchar >= char(32)) OR EOF(InputFile));

      { Then, read the rest of the line until CR or LF }
      WHILE (inputchar >= char(32))
      DO
      BEGIN
        InputLine := InputLine + inputchar;
        Read(InputFile, inputchar)
      END;

      WriteLn(InputLine);
      { Write one line, add command and delimeters, to Serial/ESP }
      IF Length(InputLine) > 0
      THEN BEGIN
             OutputLine := 'file.writeline([[' + InputLine + ']])';
             { SendString(OutputLine);}
             FOR i := 1 TO Length(OutputLine)
             DO SendChar(OutputLine[i]);
             SendCRLF;
           END
    UNTIL Eof(InputFile);

    { Close file local and on ESP }
    Close(InputFile);
    SendString('file.close()'); SendChar(char(13));
  END
  ELSE WriteLn ('*** RS232 driver not found!',char(7));
END.
