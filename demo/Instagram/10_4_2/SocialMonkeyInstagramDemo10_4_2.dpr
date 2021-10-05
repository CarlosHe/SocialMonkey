program SocialMonkeyInstagramDemo10_4_2;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in '..\Unit1.pas' {Form1};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;

  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
