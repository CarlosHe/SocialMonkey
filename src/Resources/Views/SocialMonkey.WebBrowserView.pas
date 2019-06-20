unit SocialMonkey.WebBrowserView;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Effects, FMX.WebBrowser, System.Net.URLClient,
  SocialMonkey.Types;

type
  TSocialMonkeyWebBrowserView = class(TForm)
    RecBackgroundWebBrowser2: TRectangle;
    ShadowEffectWebBrowser1: TShadowEffect;
    PathWebBrowserClose: TPath;
    LayoutWebBrowser: TLayout;
    RecBackgroundWebBrowser1: TRectangle;
    WebBrowse: TWebBrowser;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PathWebBrowserCloseClick(Sender: TObject);
    procedure PathWebBrowserCloseTap(Sender: TObject; const Point: TPointF);
    procedure WebViewDidFinishLoad(ASender: TObject);
  private
    { Private declarations }
    FClosing: Boolean;
    FAuthUrl: string;
    FOnWebViewClose: TOnCloseSocialWebBrowser;
    procedure CloseWebView(AAction: TActionSocial; const ACode: string = '');
    function ContainsParam(AParamArray: TArray<TNameValuePair>; AParamName: string): Boolean;

    procedure SetAuthUrl(const Value: string);
    procedure SetOnWebViewClose(const Value: TOnCloseSocialWebBrowser);
    procedure DoWebViewClose(AAction: TActionSocial; const ACode: string = '');
  public
    { Public declarations }
    property AuthUrl: string read FAuthUrl write SetAuthUrl;
    property OnWebViewClose: TOnCloseSocialWebBrowser read FOnWebViewClose write SetOnWebViewClose;
  end;

var
  SocialMonkeyWebBrowserView: TSocialMonkeyWebBrowserView;

implementation

{$R *.fmx}

procedure TSocialMonkeyWebBrowserView.CloseWebView(AAction: TActionSocial; const ACode: string);
begin
  if not FClosing then
  begin
    FClosing := True;
    Close;
    DoWebViewClose(AAction, ACode);
  end;
end;

function TSocialMonkeyWebBrowserView.ContainsParam(AParamArray: TArray<TNameValuePair>; AParamName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(AParamArray) to High(AParamArray) do
  begin
    if AParamArray[I].Name = AParamName then
      Result := True;
    Break;
  end;
end;

procedure TSocialMonkeyWebBrowserView.DoWebViewClose(AAction: TActionSocial; const ACode: string);
begin
  if Assigned(FOnWebViewClose) then
    FOnWebViewClose(AAction, ACode);
end;

procedure TSocialMonkeyWebBrowserView.FormClose(Sender: TObject; var Action: TCloseAction);
var
  LJs: string;
begin
  {TODO -oIgorBastos -cTemporario : criar regra de logout para o provider}
  LJs := 'javascript:(function(){var d = new Date();var name="c_user";var ' +
    'domain=".facebook.com";var path="/";var expires = ";expires="+d;document.'
    + 'cookie = name + "=" +( ( path ) ? ";path=" + path : "") +( ( domain ) ? '
    + '";domain=" + domain : "" ) +";expires="+expires;location.reload();})();';

  WebBrowse.EvaluateJavaScript(LJs);

  Action := TCloseAction.caFree;
end;

procedure TSocialMonkeyWebBrowserView.FormCreate(Sender: TObject);
begin
  FClosing := False;
{$IF Defined(MSWINDOWS) or Defined(MACOS)}
  WindowState:= TWindowState.wsMaximized
{$ENDIF}
end;

procedure TSocialMonkeyWebBrowserView.PathWebBrowserCloseClick(Sender: TObject);
begin
{$IF Defined(MSWINDOWS) or Defined(MACOS)}
  CloseWebView(TActionSocial.Canceled);
{$ENDIF}
end;

procedure TSocialMonkeyWebBrowserView.PathWebBrowserCloseTap(Sender: TObject; const Point: TPointF);
begin
{$IF Defined(ANDROID) or Defined(IOS64) or Defined(IOS32)}
  CloseWebView(TActionSocial.Canceled);
{$ENDIF}
end;

procedure TSocialMonkeyWebBrowserView.SetAuthUrl(const Value: string);
begin
  FAuthUrl := Value;
  WebBrowse.Navigate(FAuthUrl)
end;

procedure TSocialMonkeyWebBrowserView.SetOnWebViewClose(const Value: TOnCloseSocialWebBrowser);
begin
  FOnWebViewClose := Value;
end;

procedure TSocialMonkeyWebBrowserView.WebViewDidFinishLoad(ASender: TObject);
var
  LURI: TURI;
begin
  if FClosing then
    exit;
  LURI := TURI.Create(WebBrowse.URL);
  if ContainsParam(LURI.Params, 'code') then
  begin
    WebBrowse.Stop;
    CloseWebView(TActionSocial.Allowed, LURI.ParameterByName['code']);
  end;

  if (ContainsParam(LURI.Params, 'error')) and (LURI.ParameterByName['error'] = 'access_denied') then
  begin
    WebBrowse.Stop;
    CloseWebView(TActionSocial.Denied);
  end;

end;

end.
