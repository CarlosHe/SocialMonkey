﻿unit Unit1;

{
  For this example is important you to read all APIs documentations:

 https://developers.facebook.com/docs/instagram-basic-display-api/reference/refresh_access_token

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

  SocialMonkey.Components.BaseProvider,
  SocialMonkey.Components.InstagramProvider,
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
  TLocalUser = class
  private
    FName: string;
    FEmail: string;
    FUrlAvatar: string;
    FId: string;
    FToken: string;
    procedure SetEmail(const Value: string);
    procedure SetId(const Value: string);
    procedure SetName(const Value: string);
    procedure SetToken(const Value: string);
    procedure SetUrlAvatar(const Value: string);
    { private declarations }
  protected
    { protected declarations }
  public
    property Id: string read FId write SetId;
    property Token: string read FToken write SetToken;
    property Name: string read FName write SetName;
    property Email: string read FEmail write SetEmail;
    property UrlAvatar: string read FUrlAvatar write SetUrlAvatar;
    { public declarations }
  published
    { published declarations }
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FLocalUser: TLocalUser;
    FSocialMonkeyManager: TSocialMonkeyManager;
    FSocialMonkeyProvider: TSocialMonkeyInstagramProvider;

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
  FSocialMonkeyManager.Driver('instagram').SocialUser(SocialMonkeyResult);
end;

procedure TForm1.DoAfterLogin;
begin
  SetWebBrowserPermissions;
  Memo1.Lines.Clear;
  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        try
          if not Assigned(FLocalUser) then
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
        FreeAndNil(FLocalUser);
      end;
    end).Start;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FLocalUser := nil;
  FSocialMonkeyManager := TSocialMonkeyManager.Create(nil);
  FSocialMonkeyProvider := TSocialMonkeyInstagramProvider.Create(nil);

  {
    To see/change the default values, take a look on:
    SocialMonkey.Providers.InstagramProvider.TSocialMonkeyFacebookProvider.Create

  }

  FSocialMonkeyProvider.ClientId := 'ClientId'; // Your Client ID
  FSocialMonkeyProvider.ClientSecret := 'ClientSecret'; // Your Client Secret
  FSocialMonkeyManager.AddDriver('instagram', FSocialMonkeyProvider.Provider);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSocialMonkeyManager);
  FreeAndNil(FSocialMonkeyProvider);
  FreeAndNil(FLocalUser);
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
  FreeAndNil(FLocalUser);
  case AAction of
    TActionSocial.Canceled:
      begin
        TThread.Queue(nil,
          procedure
          begin
            ShowMessage('Operação foi cancelada!');
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
            FLocalUser := TLocalUser.Create;
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
            ShowMessage('Operação foi rejeitada!');
          end);

      end;
  end;
end;

{ TLocalUser }

procedure TLocalUser.SetEmail(const Value: string);
begin
  FEmail := Value;
end;

procedure TLocalUser.SetId(const Value: string);
begin
  FId := Value;
end;

procedure TLocalUser.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TLocalUser.SetToken(const Value: string);
begin
  FToken := Value;
end;

procedure TLocalUser.SetUrlAvatar(const Value: string);
begin
  FUrlAvatar := Value;
end;

end.
