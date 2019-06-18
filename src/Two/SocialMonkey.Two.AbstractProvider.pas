unit SocialMonkey.Two.AbstractProvider;

interface

uses
  SocialMonkey.Contracts.Provider, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, System.Generics.Collections,
  SocialMonkey.Contracts.SocialUser, SocialMonkey.Types, System.SysUtils, FMX.Dialogs, SocialMonkey.Contracts.SocialWebBrowser,
  SocialMonkey.SocialWebBrowser, SocialMonkey.Two.SocialUser, System.JSON;

type

  TAbstractProvider = class abstract(TInterfacedObject, IProvider)
  private
    { private declarations }
    FSocialWebBrowser: ISocialWebBrowser;
    FSocialUserCallback: TSocialUserCallback<ISocialUser>;
    FHttpRequest: TNetHTTPRequest;
    FHttpClient: TNetHTTPClient;
    FClientId: string;
    FClientSecret: string;
    FRedirectUrl: string;
    FParameters: TArray<string>;
    FScopes: TArray<string>;
    FScopeSeparator: string;
    FStateless: Boolean;
    procedure SetClientId(const Value: string);
    procedure SetClientSecret(const Value: string);
    procedure SetParameters(const Value: TArray<string>);
    procedure SetRedirectUrl(const Value: string);
    procedure SetScopes(const Value: TArray<string>);
    procedure SetScopeSeparator(const Value: string);
    procedure SetHttpClient(const Value: TNetHTTPClient);
    procedure SetHttpRequest(const Value: TNetHTTPRequest);
    procedure SetStateless(const Value: Boolean);
    function GetClientId: string;
    function GetClientSecret: string;
    function GetHttpClient: TNetHTTPClient;
    function GetHttpRequest: TNetHTTPRequest;
    function GetParameters: TArray<string>;
    function GetRedirectUrl: string;
    function GetScopes: TArray<string>;
    function GetScopeSeparator: string;
    function GetStateless: Boolean;
  protected
    { protected declarations }

    function RandomCodeStr(const CodeLen: Word): string;

    function GetAuthUrl(AState: string): string; virtual; abstract;
    function GetTokenUrl: string; virtual; abstract;
    function GetUserByToken(AToken: string): string; virtual; abstract;
    function MapUserToObject(AUser: string): ISocialUser; virtual; abstract;

    function GetTokenFields(ACode: string): TNameValueArray;
    function BuildAuthUrlFromBase(AUrl, AState: string): string;
    function UsesState: Boolean;
    function IsStateless: Boolean;
    function GetState: string;
    function GetCodeFields(AState: string): TQueryFieldArray;
    function FormatScopes(AScopes: TArray<string>; AScopeSeparator: string): string;
    procedure DoSocialUserCallback(const ASocialUser: ISocialUser = nil);
    procedure GetCode(AOnCode: TOnCode);
    function GetUserJsonValue<T>(AUserJsonResponse, AKey: string): T;
    function GetTokenValue(AUserJsonResponse: string): string;
    function GetRefreshTokenValue(AUserJsonResponse: string): string;
    function GetExpiresInValue(AUserJsonResponse: string): Integer;

    property ClientId: string read GetClientId write SetClientId;
    property ClientSecret: string read GetClientSecret write SetClientSecret;
    property RedirectUrl: string read GetRedirectUrl write SetRedirectUrl;
    property Parameters: TArray<string> read GetParameters write SetParameters;
    property Scopes: TArray<string> read GetScopes write SetScopes;
    property ScopeSeparator: string read GetScopeSeparator write SetScopeSeparator;
    property HttpClient: TNetHTTPClient read GetHttpClient write SetHttpClient;
    property HttpRequest: TNetHTTPRequest read GetHttpRequest write SetHttpRequest;

  public
    { public declarations }
    constructor Create(AClientID, AClientSecret, ARedirectUrl: string); virtual;
    destructor Destroy; override;
    function GetAccessTokenResponse(ACode: string): string;
    function UserFromToken(AToken: string): ISocialUser;
    function SocialUser(ASocialUserCallback: TSocialUserCallback<ISocialUser>): IProvider;
    property Stateless: Boolean read GetStateless write SetStateless;
  published
    { published declarations }
  end;

implementation

{ TAbstractProvider }

function TAbstractProvider.BuildAuthUrlFromBase(AUrl, AState: string): string;
var
  LURI: TURI;
  LQueryFieldArray: TQueryFieldArray;
  I: Integer;
begin
  LURI := TURI.Create(AUrl);
  LQueryFieldArray := GetCodeFields(AState);
  for I := Low(LQueryFieldArray) to High(LQueryFieldArray) do
    LURI.AddParameter(LQueryFieldArray[I].Name, LQueryFieldArray[I].Value);
  Result := LURI.ToString;
end;

constructor TAbstractProvider.Create(AClientID, AClientSecret, ARedirectUrl: string);
begin
  FHttpClient := TNetHTTPClient.Create(nil);
  FHttpClient.Asynchronous := True;
  FHttpRequest := TNetHTTPRequest.Create(nil);
  FHttpRequest.Client := FHttpClient;

  ClientId := AClientID;
  ClientSecret := AClientSecret;
  RedirectUrl := ARedirectUrl;
  Parameters := [];
  Scopes := [];
  ScopeSeparator := ',';

  FSocialWebBrowser := TSocialWebBrowser.Create;
end;

destructor TAbstractProvider.Destroy;
begin
  FreeAndNil(FHttpRequest);
  FreeAndNil(FHttpClient);
  inherited;
end;

procedure TAbstractProvider.DoSocialUserCallback(const ASocialUser: ISocialUser);
begin

end;

function TAbstractProvider.FormatScopes(AScopes: TArray<string>; AScopeSeparator: string): string;
begin
  Result := String.Join(AScopeSeparator, AScopes);
end;

function TAbstractProvider.GetAccessTokenResponse(ACode: string): string;
var
  LURI: TURI;
  LHeader: TNetHeaders;
begin
  LURI := TURI.Create(GetTokenUrl);
  LURI.Params := GetTokenFields(ACode);
  LHeader := [TNameValuePair.Create('Accept', 'application/json')];
  Result := HttpRequest.Get(LURI.ToString, nil, LHeader).ContentAsString(TEncoding.UTF8);
end;

function TAbstractProvider.GetClientId: string;
begin
  Result := FClientId;
end;

function TAbstractProvider.GetClientSecret: string;
begin
  Result := FClientSecret;
end;

procedure TAbstractProvider.GetCode(AOnCode: TOnCode);
var
  LState: string;
begin
  LState := GetState;
  FSocialWebBrowser.Execute(GetAuthUrl(LState)).OnAccessAllowed(
    procedure(ACode: string)
    begin
      AOnCode(TActionSocial.Allowed, ACode);
    end).OnAccessCanceled(
    procedure
    begin
      AOnCode(TActionSocial.Canceled, '');
    end).OnAccessDenied(
    procedure
    begin
      AOnCode(TActionSocial.Denied, '');
    end)
end;

function TAbstractProvider.GetCodeFields(AState: string): TQueryFieldArray;
var
  LCodeFieldsArray: TQueryFieldArray;
begin

  LCodeFieldsArray := [TQueryField.Create('client_id', ClientId), TQueryField.Create('redirect_uri', RedirectUrl), TQueryField.Create('scope', FormatScopes(Scopes, ScopeSeparator)
    ), TQueryField.Create('response_type', 'code')];

  if (UsesState) then
  begin
    LCodeFieldsArray := LCodeFieldsArray + [TQueryField.Create('state', AState)];
  end;

  Result := LCodeFieldsArray;

end;

function TAbstractProvider.GetExpiresInValue(AUserJsonResponse: string): Integer;
begin
  Result := GetUserJsonValue<Integer>(AUserJsonResponse, 'expires_in');
end;

function TAbstractProvider.GetHttpClient: TNetHTTPClient;
begin
  Result := FHttpClient;
end;

function TAbstractProvider.GetHttpRequest: TNetHTTPRequest;
begin
  Result := FHttpRequest;
end;

function TAbstractProvider.GetParameters: TArray<string>;
begin
  Result := FParameters;
end;

function TAbstractProvider.GetRedirectUrl: string;
begin
  Result := FRedirectUrl;
end;

function TAbstractProvider.GetRefreshTokenValue(AUserJsonResponse: string): string;
begin
  Result := GetUserJsonValue<string>(AUserJsonResponse, 'refresh_token');
end;

function TAbstractProvider.GetScopes: TArray<string>;
begin
  Result := FScopes;
end;

function TAbstractProvider.GetScopeSeparator: string;
begin
  Result := FScopeSeparator;
end;

function TAbstractProvider.GetState: string;
begin
  Result := RandomCodeStr(50);
end;

function TAbstractProvider.GetStateless: Boolean;
begin
  Result := FStateless;
end;

function TAbstractProvider.GetTokenFields(ACode: string): TNameValueArray;
begin
  Result := [TNameValuePair.Create('client_id', ClientId), TNameValuePair.Create('client_secret', ClientSecret), TNameValuePair.Create('code', ACode),
    TNameValuePair.Create('redirect_uri', RedirectUrl)]
end;

function TAbstractProvider.GetTokenValue(AUserJsonResponse: string): string;
begin
  Result := GetUserJsonValue<string>(AUserJsonResponse, 'access_token');
end;

function TAbstractProvider.GetUserJsonValue<T>(AUserJsonResponse, AKey: string): T;
var
  LJsonObject: TJsonObject;
  LValue: T;
begin
  LJsonObject := TJsonObject.ParseJSONValue(AUserJsonResponse) as TJsonObject;
  if Assigned(LJsonObject) then
  begin
    try
      if LJsonObject.TryGetValue<T>(AKey, LValue) then
        Result := LValue;
    finally
      LJsonObject.Free;
    end;
  end;
end;

function TAbstractProvider.IsStateless: Boolean;
begin
  Result := Stateless;
end;

function TAbstractProvider.RandomCodeStr(const CodeLen: Word): string;
var
  n: Integer;
begin
  SetLength(Result, CodeLen);
  for n := 1 to CodeLen do
    Result[n] := Char(ord('0') + Random(10));
end;

procedure TAbstractProvider.SetClientId(const Value: string);
begin
  FClientId := Value;
end;

procedure TAbstractProvider.SetClientSecret(const Value: string);
begin
  FClientSecret := Value;
end;

procedure TAbstractProvider.SetHttpClient(const Value: TNetHTTPClient);
begin
  FHttpClient := Value;
end;

procedure TAbstractProvider.SetHttpRequest(const Value: TNetHTTPRequest);
begin
  FHttpRequest := Value;
end;

procedure TAbstractProvider.SetParameters(const Value: TArray<string>);
begin
  FParameters := Value;
end;

procedure TAbstractProvider.SetRedirectUrl(const Value: string);
begin
  FRedirectUrl := Value;
end;

procedure TAbstractProvider.SetScopes(const Value: TArray<string>);
begin
  FScopes := Value;
end;

procedure TAbstractProvider.SetScopeSeparator(const Value: string);
begin
  FScopeSeparator := Value;
end;

procedure TAbstractProvider.SetStateless(const Value: Boolean);
begin
  FStateless := Value;
end;

function TAbstractProvider.SocialUser(ASocialUserCallback: TSocialUserCallback<ISocialUser>): IProvider;
begin
  FSocialUserCallback := ASocialUserCallback;
  GetCode(
    procedure(AAction: TActionSocial; ACode: string)
    var
      LResponse: string;
      LSocialUser: ISocialUser;
    begin
      case AAction of
        TActionSocial.Canceled:
          FSocialUserCallback(TActionSocial.Canceled, nil);
        TActionSocial.Allowed:
          begin
            LResponse := GetAccessTokenResponse(ACode);
            LSocialUser := MapUserToObject(GetUserByToken(GetTokenValue(LResponse)));
            TSocialUser(LSocialUser).SetToken(GetTokenValue(LResponse));
            TSocialUser(LSocialUser).SetRefreshToken(GetRefreshTokenValue(LResponse));
            TSocialUser(LSocialUser).SetExpiresIn(GetExpiresInValue(LResponse));
            FSocialUserCallback(TActionSocial.Allowed, LSocialUser);
          end;
        TActionSocial.Denied:
          FSocialUserCallback(TActionSocial.Denied, nil);
      end;

    end);
end;

function TAbstractProvider.UserFromToken(AToken: string): ISocialUser;
var
  LSocialUser: ISocialUser;
begin
  LSocialUser := MapUserToObject(GetUserByToken(AToken));
  TSocialUser(LSocialUser).SetToken(AToken);
  Result := LSocialUser;
end;

function TAbstractProvider.UsesState: Boolean;
begin
  Result := not Stateless;
end;

end.
