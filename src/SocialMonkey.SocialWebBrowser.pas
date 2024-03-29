unit SocialMonkey.SocialWebBrowser;

interface

uses
  System.SysUtils,
  System.UITypes,

  FMX.Forms,

  SocialMonkey.Contracts.SocialWebBrowser,
  SocialMonkey.Types,
  //SocialMonkey.WebView,
  SocialMonkey.WebBrowserView;

type
  TSocialWebBrowser = class(TInterfacedObject, ISocialWebBrowser)
  private
    { private declarations }
    FSocialMonkeyWebBrowserView: TSocialMonkeyWebBrowserView;
    FAuthUrl: string;
    FOnBegin: TOnBeginAction;
    FOnFinish: TOnFinishAction;
    FOnAccessCanceled: TOnAccessCanceled;
    FOnAccessAllowed: TOnAccessAllowed;
    FOnAccessError: TOnAccessError;
    FOnAccessDenied: TOnAccessDenied;
  protected
    { protected declarations }
    procedure DoBegin;
    procedure DoFinish;
    procedure DoAccessCanceled;
    procedure DoAccessAllowed(ACode: string);
    procedure DoAccessDenied;
    procedure DoAccessError(ACode: string);

    procedure OpenWebView;
    procedure WebViewClose(AAction: TActionSocial; ACode: string);
  public
    { public declarations }
    constructor Create; virtual;
    destructor Destroy; override;

    function OnBegin(AOnBegin: TOnBeginAction): ISocialWebBrowser;
    function OnFinish(AOnFinish: TOnFinishAction): ISocialWebBrowser;
    function OnAccessCanceled(AAccessCanceled: TOnAccessCanceled): ISocialWebBrowser;
    function OnAccessAllowed(AOnAccessAllowed: TOnAccessAllowed): ISocialWebBrowser;
    function OnAccessError(AOnAccessError: TOnAccessError): ISocialWebBrowser;
    function OnAccessDenied(AOnAccessDenied: TOnAccessDenied): ISocialWebBrowser;
    function Execute(AAuthUrl: string): ISocialWebBrowser;
  published
    { published declarations }
  end;

implementation

{ TSocialWebBrowser }

constructor TSocialWebBrowser.Create;
begin
  FOnBegin := nil;
  FOnFinish := nil;
  FOnAccessCanceled := nil;
  FOnAccessAllowed := nil;
  FOnAccessError := nil;
  FOnAccessDenied := nil;
end;

destructor TSocialWebBrowser.Destroy;
begin

  inherited;
end;

procedure TSocialWebBrowser.DoAccessAllowed(ACode: string);
begin
  if Assigned(FOnAccessAllowed) then
    FOnAccessAllowed(ACode);
end;

procedure TSocialWebBrowser.DoAccessCanceled;
begin
  if Assigned(FOnAccessCanceled) then
    FOnAccessCanceled;
end;

procedure TSocialWebBrowser.DoAccessDenied;
begin
  if Assigned(FOnAccessDenied) then
    FOnAccessDenied;
end;

procedure TSocialWebBrowser.DoAccessError(ACode: string);
begin
  if Assigned(FOnAccessError) then
    FOnAccessError(ACode);
end;

procedure TSocialWebBrowser.DoBegin;
begin
  if Assigned(FOnBegin) then
    FOnBegin;
end;

procedure TSocialWebBrowser.DoFinish;
begin
  if Assigned(FOnFinish) then
    FOnFinish;
end;

function TSocialWebBrowser.Execute(AAuthUrl: string): ISocialWebBrowser;
begin
  Result := Self;
  FAuthUrl := AAuthUrl;
  OpenWebView;
end;

function TSocialWebBrowser.OnAccessAllowed(AOnAccessAllowed: TOnAccessAllowed): ISocialWebBrowser;
begin
  Result := Self;
  FOnAccessAllowed := AOnAccessAllowed;
end;

function TSocialWebBrowser.OnAccessDenied(AOnAccessDenied: TOnAccessDenied): ISocialWebBrowser;
begin
  Result := Self;
  FOnAccessDenied := AOnAccessDenied;
end;

function TSocialWebBrowser.OnAccessError(
  AOnAccessError: TOnAccessError): ISocialWebBrowser;
begin
  Result := Self;
  FOnAccessError := AOnAccessError;
end;

function TSocialWebBrowser.OnBegin(AOnBegin: TOnBeginAction): ISocialWebBrowser;
begin
  Result := Self;
  FOnBegin := AOnBegin;
end;

function TSocialWebBrowser.OnAccessCanceled(AAccessCanceled: TOnAccessCanceled): ISocialWebBrowser;
begin
  Result := Self;
  FOnAccessCanceled := AAccessCanceled;
end;

function TSocialWebBrowser.OnFinish(AOnFinish: TOnFinishAction): ISocialWebBrowser;
begin
  Result := Self;
  FOnFinish := AOnFinish;
end;

procedure TSocialWebBrowser.OpenWebView;
begin
  FSocialMonkeyWebBrowserView := TSocialMonkeyWebBrowserView.Create(nil);
  FSocialMonkeyWebBrowserView.AuthUrl := FAuthUrl;
  FSocialMonkeyWebBrowserView.OnWebViewClose := WebViewClose;
  DoBegin;
{$IF Defined(ANDROID) or Defined(IOS64) or Defined(IOS32)}
  FSocialMonkeyWebBrowserView.LayoutWebBrowser.Parent := Screen.ActiveForm;
{$ENDIF}
{$IF Defined(MSWINDOWS) or Defined(MACOS)}
  FSocialMonkeyWebBrowserView.Show();
{$ENDIF}
end;

procedure TSocialWebBrowser.WebViewClose(AAction: TActionSocial; ACode: string);
begin
  case AAction of
    TActionSocial.Canceled:
      DoAccessCanceled;
    TActionSocial.Allowed:
      DoAccessAllowed(ACode);
    TActionSocial.Denied:
      DoAccessDenied;
    TActionSocial.Error:
      DoAccessError(ACode);
  end;
  DoFinish;
end;

end.
