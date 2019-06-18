unit SocialMonkey.WebView;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.WebBrowser, FMX.Effects, System.Net.URLClient,
  SocialMonkey.Types;

type
  TSocialMonkeyWebView = class(TFrame)
    RecBackground: TRectangle;
    PathClose: TPath;
    RecBackground2: TRectangle;
    ShadowEffect1: TShadowEffect;
    procedure PathCloseClick(Sender: TObject);
    procedure PathCloseTap(Sender: TObject; const Point: TPointF);
  private
    FWebView: TWebBrowser;
    FAuthUrl: string;
    FClosing: Boolean;
    FOnClose: TOnCloseSocialWebBrowser;
    procedure WebViewDidFinishLoad(ASender: TObject);
    function ContainsParam(AParamArray: TArray<TNameValuePair>; AParamName: string): Boolean;
    procedure SetAuthUrl(const Value: string);
    procedure Close(AAction: TActionSocial; const ACode: string = '');
    procedure DoClose(AAction: TActionSocial; const ACode: string = '');
    procedure SetOnClose(const Value: TOnCloseSocialWebBrowser);
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Show; override;
    property AuthUrl: string read FAuthUrl write SetAuthUrl;
    property OnClose: TOnCloseSocialWebBrowser read FOnClose write SetOnClose;

  end;

implementation

{$R *.fmx}
{ TSocialMonkeyWebView }

procedure TSocialMonkeyWebView.Close(AAction: TActionSocial; const ACode: string = '');
begin
  if not FClosing then
  begin
    FClosing := True;
    DoClose(AAction, ACode);
    FWebView.Parent := nil;
    Parent := nil;
    FreeAndNil(FWebView);
    Self.Free;
  end;
end;

function TSocialMonkeyWebView.ContainsParam(AParamArray: TArray<TNameValuePair>; AParamName: string): Boolean;
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

constructor TSocialMonkeyWebView.Create(AOwner: TComponent);
begin
  inherited;
  FWebView := TWebBrowser.Create(nil);
  FWebView.Align := TAlignLayout.Client;
  FWebView.Margins.Left := 35;
  FWebView.Margins.Right := 35;
  FWebView.Margins.Top := 55;
  FWebView.Margins.Bottom := 35;
  FWebView.Parent := Self;
  FWebView.OnDidFinishLoad := WebViewDidFinishLoad;
  FClosing := False;
end;

destructor TSocialMonkeyWebView.Destroy;
begin

  inherited;
end;

procedure TSocialMonkeyWebView.DoClose(AAction: TActionSocial; const ACode: string);
begin
  if Assigned(FOnClose) then
    TThread.CreateAnonymousThread(
      procedure
      begin
        FOnClose(AAction, ACode);
      end).Start;
end;

procedure TSocialMonkeyWebView.PathCloseClick(Sender: TObject);
begin
{$IF Defined(MSWINDOWS) or Defined(MACOS)}
  Self.Close(TActionSocial.Canceled);
{$ENDIF}
end;

procedure TSocialMonkeyWebView.PathCloseTap(Sender: TObject; const Point: TPointF);
begin
{$IF Defined(ANDROID) or Defined(IOS64) or Defined(IOS32)}
  Self.Close(TActionSocial.Canceled);
{$ENDIF}
end;

procedure TSocialMonkeyWebView.SetAuthUrl(const Value: string);
begin
  FAuthUrl := Value;
  FWebView.Navigate(FAuthUrl)
end;

procedure TSocialMonkeyWebView.SetOnClose(const Value: TOnCloseSocialWebBrowser);
begin
  FOnClose := Value;
end;

procedure TSocialMonkeyWebView.Show;
begin
  inherited;
  Self.Parent := Screen.ActiveForm;
end;

procedure TSocialMonkeyWebView.WebViewDidFinishLoad(ASender: TObject);
var
  LURI: TURI;
begin
  if FClosing then
    exit;
  LURI := TURI.Create(FWebView.URL);
  if ContainsParam(LURI.Params, 'code') then
  begin
    FWebView.Stop;
    Self.Close(TActionSocial.Allowed, LURI.ParameterByName['code']);
  end;

  if (ContainsParam(LURI.Params, 'error')) and (LURI.ParameterByName['error'] = 'access_denied') then
  begin
    FWebView.Stop;
    Self.Close(TActionSocial.Denied);
  end;

end;

end.
