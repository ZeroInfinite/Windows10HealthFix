unit Windows10HealthFixUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    SFCButton: TButton;
    DISMButton: TButton;
    LogMemo: TMemo;
    CloseButton: TButton;
    procedure SFCButtonClick(Sender: TObject);
    procedure DISMButtonClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
  private
    { Private declarations }
    function GetDosOutput(CommandLine: string; Work: string = 'C:\'): string;
    procedure RunDosInMemo(DosApp: String; AMemo: TMemo);
  public
    { Public declarations }
  protected
  published
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

function TMainForm.GetDosOutput(CommandLine: string;
  Work: string = 'C:\'): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array [0 .. 255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: string;
  Handle: Boolean;

begin
  Result := '';

  with SA do
  begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;

  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);

  try
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;

    WorkDir := Work;
    Handle := CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine), nil, nil,
      True, 0, nil, PChar(WorkDir), SI, PI);

    CloseHandle(StdOutPipeWrite);

    if Handle then
    begin

      try
        repeat
          WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
          if BytesRead > 0 then
          begin
            Buffer[BytesRead] := #0;
            Result := Result + string(Buffer);
          end;
        until not WasOK or (BytesRead = 0);
        WaitForSingleObject(PI.hProcess, INFINITE);
      finally
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
      end;

    end;

  finally
    CloseHandle(StdOutPipeRead);
  end;
end;

procedure TMainForm.RunDosInMemo(DosApp: String; AMemo: TMemo);
const
  ReadBuffer = 2400;

var
  Security: TSecurityAttributes;
  ReadPipe, WritePipe: THandle;
  start: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Buffer: PChar;
  BytesRead: DWord;
  Apprunning: DWord;

begin
  With Security do
  begin
    nLength := SizeOf(TSecurityAttributes);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;

  if CreatePipe(ReadPipe, WritePipe, @Security, 0) then
  begin
    Buffer := AllocMem(ReadBuffer + 1);
    FillChar(start, SizeOf(start), #0);
    start.cb := SizeOf(start);
    start.hStdOutput := WritePipe;
    start.hStdError := WritePipe;
    start.hStdInput := ReadPipe;
    start.dwFlags := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
    start.wShowWindow := SW_HIDE;

    if CreateProcess(nil, PChar(DosApp), @Security, @Security, True,
      NORMAL_PRIORITY_CLASS, nil, nil, start, ProcessInfo) then
    begin
      repeat
        Apprunning := WaitForSingleObject(ProcessInfo.hProcess, 100);
        Application.ProcessMessages;
      until (Apprunning <> WAIT_TIMEOUT);
      Repeat
        BytesRead := 0;
        ReadFile(ReadPipe, Buffer[0], ReadBuffer, BytesRead, nil);
        Buffer[BytesRead] := #0;
        OemToAnsi(PAnsiChar(Buffer), PAnsiChar(Buffer));
        AMemo.Text := AMemo.Text + String(Buffer);
      until (BytesRead < ReadBuffer);
    end;

    FreeMem(Buffer);
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(ReadPipe);
    CloseHandle(WritePipe);
  end;

end;

procedure TMainForm.CloseButtonClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainForm.DISMButtonClick(Sender: TObject);
const
  cmd: string = 'DISM /Online /Cleanup-Image /RestoreHealth';

begin
  // DISM /Online /Cleanup-Image /RestoreHealth
  SFCButton.Enabled := not SFCButton.Enabled;
  DISMButton.Enabled := not DISMButton.Enabled;
  LogMemo.Clear;
  LogMemo.Lines.Add('Now running => ' + cmd);
  LogMemo.Lines.Add(GetDosOutput(cmd));
  LogMemo.Lines.Add('Completed running => ' + cmd);
  SFCButton.Enabled := not SFCButton.Enabled;
  DISMButton.Enabled := not DISMButton.Enabled;
end;

procedure TMainForm.SFCButtonClick(Sender: TObject);
const
  cmd: string = 'sfc /scannow';

begin
  // sfc /scannow
  SFCButton.Enabled := not SFCButton.Enabled;
  DISMButton.Enabled := not DISMButton.Enabled;
  LogMemo.Clear;
  LogMemo.Lines.Add('Now running => ' + cmd);
  LogMemo.Lines.Add(GetDosOutput(cmd));
  LogMemo.Lines.Add('Completed running => ' + cmd);
  SFCButton.Enabled := not SFCButton.Enabled;
  DISMButton.Enabled := not DISMButton.Enabled;
end;

end.
