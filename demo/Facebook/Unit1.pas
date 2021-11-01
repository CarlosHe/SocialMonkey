unit Unit1;

{
  For this example is important you to read all APIs documentations:

  https://developers.facebook.com/docs/graph-api/overview

  Make sure you are able to use the services:

  https://developers.facebook.com
}

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,

  System.Net.HttpClient,
  System.Net.URLClient,
  System.Net.HttpClientComponent,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Objects,

  SocialMonkey.Components.BaseProvider,
  SocialMonkey.Components.FacebookProvider,
  SocialMonkey.Components.Manager,
  SocialMonkey.Types,
  SocialMonkey.Contracts.SocialUser,
  SocialMonkey.Two.SocialUser

{$IFDEF MSWINDOWS}
    ,
  System.Win.Registry,

  Winapi.WinINet,
  Winapi.Windows,
  Winapi.ShellAPI
{$IFEND};

type
  TLocalUserR = record
  private
    FId: string;
    FName: string;
    FEmail: string;
    FToken: string;
    FUrlAvatar: string;
    { private declarations }
  public
    property Id: string read FId write FId;
    property Token: string read FToken write FToken;
    property Name: string read FName write FName;
    property Email: string read FEmail write FEmail;
    property UrlAvatar: string read FUrlAvatar write FUrlAvatar;

    procedure Clear;
    { public declarations }
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FLocalUser: TLocalUserR;
    SocialMonkeyManager: TSocialMonkeyManager;
    SocialMonkeyFacebookProvider: TSocialMonkeyFacebookProvider;

    function GetProfilePicture: TStream;

    procedure SetWebBrowserPermissions;
    procedure SocialMonkeyResult(AAction: TActionSocial; ASocialUser: ISocialUser);
    procedure DoAfterLogin;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}


procedure TForm1.Button1Click(Sender: TObject);
begin
  SocialMonkeyManager.Driver('facebook').SocialUser(SocialMonkeyResult);
end;

procedure TForm1.DoAfterLogin;
begin
  SetWebBrowserPermissions;
  Memo1.Lines.Clear;
  TThread.CreateAnonymousThread(
    procedure
    var
      LMStream: TStream;
    begin
      try
        try
          if (FLocalUser.Id.Trim.IsEmpty) then
            raise Exception.Create('Not logged');

          // Here you can do your own roles to validate the login

          TThread.Synchronize(TThread.CurrentThread,
            procedure
            begin
              Memo1.Lines.Add('Id: ' + FLocalUser.Id);
              Memo1.Lines.Add('Token: ' + FLocalUser.Token);
              Memo1.Lines.Add('Name: ' + FLocalUser.Name);
              Memo1.Lines.Add('Email: ' + FLocalUser.Email);
              Memo1.Lines.Add('UrlAvatar: ' + FLocalUser.UrlAvatar);
            end);

          LMStream := GetProfilePicture;
          try
            TThread.Synchronize(TThread.CurrentThread,
              procedure
              begin
                Image1.Bitmap.LoadFromStream(LMStream);
              end);
          finally
            FreeAndNil(LMStream);
          end;
        except
          on E: Exception do
          begin
            TThread.Synchronize(TThread.CurrentThread,
              procedure
              begin
                ShowMessage(E.Message);
              end);
          end;
        end;
      finally
        FLocalUser.Clear;
      end;
    end).Start;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FLocalUser.Clear;
  SocialMonkeyManager := TSocialMonkeyManager.Create(nil);
  SocialMonkeyFacebookProvider := TSocialMonkeyFacebookProvider.Create(nil);

  {
    To see/change the default values, take a look on:
    SocialMonkey.Providers.FacebookProvider.TSocialMonkeyFacebookProvider.Create
  }

  SocialMonkeyFacebookProvider.ClientId := 'ClientId'; // Your Client ID
  SocialMonkeyFacebookProvider.ClientSecret := 'ClientSecret'; // Your Client Secret
  SocialMonkeyManager.AddDriver('facebook', SocialMonkeyFacebookProvider.Provider);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(SocialMonkeyManager);
  FreeAndNil(SocialMonkeyFacebookProvider);
end;

function TForm1.GetProfilePicture: TStream;
var
  LNetCli: TNetHTTPClient;
  LResponse: IHTTPResponse;
begin
  Result := TMemoryStream.Create;
  Result.Position := 0;
  try
    LNetCli := TNetHTTPClient.Create(nil);
    try
      LResponse := LNetCli.Get(FLocalUser.UrlAvatar, Result, nil);

      if LResponse.StatusCode <> 200 then
        raise Exception.Create(LResponse.StatusText);
    finally
      FreeAndNil(LNetCli);
    end;
  except
    FreeAndNil(Result);
    raise ;
  end;
end;

procedure TForm1.SetWebBrowserPermissions;
{$IFDEF MSWINDOWS}
var
  lpEntryInfo: PInternetCacheEntryInfo;
  hCacheDir: LongWord;
  dwEntrySize: LongWord;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  { DeleteIECache }
  dwEntrySize := 0;

  FindFirstUrlCacheEntry(nil, TInternetCacheEntryInfo(nil^), dwEntrySize);

  GetMem(lpEntryInfo, dwEntrySize);

  if dwEntrySize > 0 then
    lpEntryInfo^.dwStructSize := dwEntrySize;

  hCacheDir := FindFirstUrlCacheEntry(nil, lpEntryInfo^, dwEntrySize);

  if hCacheDir <> 0 then
  begin
    repeat
      DeleteUrlCacheEntry(lpEntryInfo^.lpszSourceUrlName);
      FreeMem(lpEntryInfo, dwEntrySize);
      dwEntrySize := 0;
      FindNextUrlCacheEntry(hCacheDir, TInternetCacheEntryInfo(nil^),
        dwEntrySize);
      GetMem(lpEntryInfo, dwEntrySize);
      if dwEntrySize > 0 then
        lpEntryInfo^.dwStructSize := dwEntrySize;
    until not FindNextUrlCacheEntry(hCacheDir, lpEntryInfo^, dwEntrySize);
  end;
  { hCacheDir<>0 }
  FreeMem(lpEntryInfo, dwEntrySize);

  FindCloseUrlCache(hCacheDir)
{$ENDIF}
end;

procedure TForm1.SocialMonkeyResult(AAction: TActionSocial;
ASocialUser: ISocialUser);
begin
  SetWebBrowserPermissions;
  FLocalUser.Clear;
  case AAction of
    TActionSocial.Canceled:
      begin
        TThread.Queue(nil,
          procedure
          begin
            ShowMessage('The operation was canceled!');
          end);

      end;
    TActionSocial.Allowed:
      begin
        TThread.Queue(nil,
          procedure
          var
            LSocialUser: TSocialUser;
          begin
            LSocialUser := TSocialUser(ASocialUser);
            FLocalUser.Id := LSocialUser.Id;
            FLocalUser.Token := LSocialUser.Token;
            FLocalUser.Name := LSocialUser.Name;
            FLocalUser.Email := LSocialUser.Email;
            FLocalUser.UrlAvatar := LSocialUser.Avatar;

            DoAfterLogin;
          end);
      end;
    TActionSocial.Denied:
      begin
        TThread.Queue(nil,
          procedure
          begin
            ShowMessage('The operation was rejected!');
          end);

      end;
  end;
end;

{ TLocalUserR }

procedure TLocalUserR.Clear;
begin
  Id := EmptyStr;
  Token := EmptyStr;
  Name := EmptyStr;
  Email := EmptyStr;
  UrlAvatar := EmptyStr;
end;

end.
