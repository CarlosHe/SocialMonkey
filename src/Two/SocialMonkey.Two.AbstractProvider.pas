unit SocialMonkey.Two.AbstractProvider;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.Net.URLClient,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.Generics.Collections,

  FMX.Dialogs,

  SocialMonkey.Contracts.Provider,
  SocialMonkey.Contracts.SocialUser,
  SocialMonkey.Contracts.SocialWebBrowser,
  SocialMonkey.Types,
  SocialMonkey.SocialWebBrowser,
  SocialMonkey.Two.SocialUser;

type
  TAbstractProviderType = (aptNone, aptFacebook, aptInstagram, aptOutlook);

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
    FAuthFields: TDictionary<string, string>;
    FTokenFields: TDictionary<string, string>;
    FStateless: Boolean;
    FAbstractProviderType: TAbstractProviderType;

    procedure SetClientId(const Value: string);
    procedure SetClientSecret(const Value: string);
    procedure SetParameters(const Value: TArray<string>);

    procedure SetHttpClient(const Value: TNetHTTPClient);
    procedure SetHttpRequest(const Value: TNetHTTPRequest);
    procedure SetStateless(const Value: Boolean);
    function GetClientId: string;
    function GetClientSecret: string;
    function GetHttpClient: TNetHTTPClient;
    function GetHttpRequest: TNetHTTPRequest;
    function GetParameters: TArray<string>;
    function GetRedirectUrl: string;
    function GetStateless: Boolean;
    function GetTokenFields: TDictionary<string, string>; overload;
    procedure SetTokenFields(const Value: TDictionary<string, string>);
    function GetAuthFields: TDictionary<string, string>;
  protected
    { protected declarations }
    procedure SetRedirectUrl(const Value: string); virtual;
    function RandomCodeStr(const CodeLen: Word): string;

    function GetAuthUrl(AState: string): string; virtual; abstract;
    function GetTokenUrl: string; virtual; abstract;
    function GetUserByToken(AToken: string): string; virtual; abstract;
    function MapUserToObject(AUser: string): ISocialUser; virtual; abstract;

    // function GetTokenFields(ACode: string): TNameValueArray; virtual;
    function GetTokenFieldsArray: TNameValueArray;
    function GetTokenFieldsStrLst: TStringList;
    function BuildAuthUrlFromBase(AUrl, AState: string): string;
    function BuildAuthUrl(AUrl, AState: string): string;
    function BuildTokenUrl(AUrl: string): string;
    function UsesState: Boolean;
    function IsStateless: Boolean;
    function GetState: string;
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
    property AuthFields: TDictionary<string, string> read GetAuthFields;
    property TokenFields: TDictionary<string, string> read GetTokenFields;
    property HttpClient: TNetHTTPClient read GetHttpClient write SetHttpClient;
    property HttpRequest: TNetHTTPRequest read GetHttpRequest write SetHttpRequest;
    property AbstractProviderType: TAbstractProviderType read FAbstractProviderType write FAbstractProviderType;
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
  // LQueryFieldArray := GetCodeFields(AState);
  for I := Low(LQueryFieldArray) to High(LQueryFieldArray) do
    LURI.AddParameter(LQueryFieldArray[I].Name, LQueryFieldArray[I].Value);
  Result := LURI.ToString;
end;

function TAbstractProvider.BuildTokenUrl(AUrl: string): string;
var
  LURI: TURI;
  LKey: string;
  LValue: string;
begin
  LURI := TURI.Create(AUrl);
  for LKey in FTokenFields.Keys do
    LURI.AddParameter(LKey, FTokenFields.Items[LKey]);
  Result := LURI.ToString;
end;

function TAbstractProvider.BuildAuthUrl(AUrl, AState: string): string;
var
  LURI: TURI;
  LKey: string;
  LValue: string;
begin
  LURI := TURI.Create(AUrl);
  for LKey in FAuthFields.Keys do
    LURI.AddParameter(LKey, FAuthFields.Items[LKey]);
  if not AState.Trim.IsEmpty then
    LURI.AddParameter('state', AState);
  Result := LURI.ToString;
end;

constructor TAbstractProvider.Create(AClientID, AClientSecret,
  ARedirectUrl: string);
begin
  FHttpClient := TNetHTTPClient.Create(nil);
  FHttpClient.Asynchronous := True;
  FHttpRequest := TNetHTTPRequest.Create(nil);
  FHttpRequest.Client := FHttpClient;
  FAbstractProviderType := aptNone;
  FAuthFields := TDictionary<string, string>.Create;
  FTokenFields := TDictionary<string, string>.Create;

  ClientId := AClientID;
  ClientSecret := AClientSecret;
  RedirectUrl := ARedirectUrl;
  Parameters := [];

  FSocialWebBrowser := TSocialWebBrowser.Create;
end;

destructor TAbstractProvider.Destroy;
begin
  FreeAndNil(FHttpRequest);
  FreeAndNil(FHttpClient);
  FreeAndNil(FAuthFields);
  FreeAndNil(FTokenFields);
  inherited;
end;

procedure TAbstractProvider.DoSocialUserCallback(const ASocialUser
  : ISocialUser);
begin

end;

function TAbstractProvider.GetAccessTokenResponse(ACode: string): string;
var
  LUrl: string;
  LURI: TURI;
  LHeader: TNetHeaders;
  LResponse: IHTTPResponse;
  LStrLst: TStringList;
  LNva: TNameValueArray;
begin
  if FTokenFields.ContainsKey('code') then
    FTokenFields.AddOrSetValue('code', ACode);

  LUrl := GetTokenUrl;
  LURI := TURI.Create(GetTokenUrl);

  case FAbstractProviderType of
    aptNone:
      raise Exception.Create('AbstractProviderType unknown');
    aptFacebook, aptInstagram:
      LHeader := [TNameValuePair.Create('Accept', 'application/json')];
    aptOutlook:
      LHeader := [TNameValuePair.Create('Content-Type', 'application/x-www-form-urlencoded')];
  end;

  case FAbstractProviderType of
    aptNone:
      raise Exception.Create('AbstractProviderType unknown');
    aptFacebook:
      begin
        LURI.Params := GetTokenFieldsArray;
        LResponse := HttpRequest.Get(LURI.ToString, nil, LHeader);

      end;
    aptInstagram, aptOutlook:
      begin
        LStrLst := nil;
        try
          LStrLst := GetTokenFieldsStrLst;
          LResponse := HttpRequest.Post(LURI.ToString, LStrLst, nil, nil, LHeader);
        finally
          FreeAndNil(LStrLst);
        end;
        //
      end;
  end;

  if LResponse.StatusCode <> 200 then
    raise Exception.Create(LResponse.StatusText);

  Result := LResponse.ContentAsString(TEncoding.UTF8);

  if Result.Contains('error') then
    raise Exception.Create(Result);
end;

function TAbstractProvider.GetAuthFields: TDictionary<string, string>;
begin
  Result := FAuthFields;
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
  FSocialWebBrowser
    .OnAccessAllowed(
    procedure(ACode: string)
    begin
      AOnCode(TActionSocial.Allowed, ACode);
    end)
    .OnAccessError(
    procedure(ACode: string)
    begin
      AOnCode(TActionSocial.Error, ACode);
    end)
    .OnAccessCanceled(
    procedure
    begin
      AOnCode(TActionSocial.Canceled, '');
    end)
    .OnAccessDenied(
    procedure
    begin
      AOnCode(TActionSocial.Denied, '');
    end)
    .Execute(GetAuthUrl(LState))
end;

function TAbstractProvider.GetExpiresInValue(AUserJsonResponse: string)
  : Integer;
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

function TAbstractProvider.GetRefreshTokenValue(AUserJsonResponse
  : string): string;
begin
  Result := GetUserJsonValue<string>(AUserJsonResponse, 'refresh_token');
end;

function TAbstractProvider.GetState: string;
begin
  Result := RandomCodeStr(50);
end;

function TAbstractProvider.GetStateless: Boolean;
begin
  Result := FStateless;
end;

function TAbstractProvider.GetTokenFields: TDictionary<string, string>;
begin
  Result := FTokenFields;
end;

function TAbstractProvider.GetTokenFieldsArray: TNameValueArray;
var
  LKey: string;
begin
  Result := [];
  for LKey in FTokenFields.Keys do
  begin
    Result := Result + [TNameValuePair.Create(LKey, FTokenFields.Items[LKey])];
  end;
end;

function TAbstractProvider.GetTokenFieldsStrLst: TStringList;
var
  LKey: string;
begin
  Result := TStringList.Create;
  for LKey in FTokenFields.Keys do
  begin
    Result.Add(LKey + '=' + FTokenFields.Items[LKey]);
  end;
end;

function TAbstractProvider.GetTokenValue(AUserJsonResponse: string): string;
begin
  Result := GetUserJsonValue<string>(AUserJsonResponse, 'access_token');
end;

function TAbstractProvider.GetUserJsonValue<T>(AUserJsonResponse,
  AKey: string): T;
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
  if FAuthFields.ContainsKey('client_id') then
    FAuthFields.AddOrSetValue('client_id', Value);
  if FTokenFields.ContainsKey('client_id') then
    FTokenFields.AddOrSetValue('client_id', Value);
end;

procedure TAbstractProvider.SetClientSecret(const Value: string);
begin
  FClientSecret := Value;
  if FAuthFields.ContainsKey('client_secret') then
    FAuthFields.AddOrSetValue('client_secret', Value);
  if FTokenFields.ContainsKey('client_secret') then
    FTokenFields.AddOrSetValue('client_secret', Value);
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
  if FAuthFields.ContainsKey('redirect_uri') then
    FAuthFields.AddOrSetValue('redirect_uri', Value);
  if FTokenFields.ContainsKey('redirect_uri') then
    FTokenFields.AddOrSetValue('redirect_uri', Value);
end;

procedure TAbstractProvider.SetStateless(const Value: Boolean);
begin
  FStateless := Value;
end;

procedure TAbstractProvider.SetTokenFields(const Value: TDictionary<string, string>);
begin
  FTokenFields := Value;
end;

function TAbstractProvider.SocialUser(ASocialUserCallback
  : TSocialUserCallback<ISocialUser>): IProvider;
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
            try
              LResponse := GetAccessTokenResponse(ACode);
              LSocialUser := MapUserToObject(GetUserByToken(GetTokenValue(LResponse)));
              TSocialUser(LSocialUser).SetToken(GetTokenValue(LResponse));
              TSocialUser(LSocialUser).SetRefreshToken(GetRefreshTokenValue(LResponse));
              TSocialUser(LSocialUser).SetExpiresIn(GetExpiresInValue(LResponse));
              FSocialUserCallback(TActionSocial.Allowed, LSocialUser);
            except
              on E:Exception do
              begin
                LSocialUser := MapUserToObject('{"id":"' + E.Message + '"}');
                FSocialUserCallback(TActionSocial.Error, LSocialUser);
              end;
            end;
          end;
        TActionSocial.Error:
          begin
            LSocialUser := MapUserToObject('{"id":"' + ACode + '"}');
            FSocialUserCallback(TActionSocial.Error, LSocialUser);
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

function TAbstractProvider.GetCodeFields(AState: string): TQueryFieldArray;
var
  LCodeFieldsArray: TQueryFieldArray;
begin
  LCodeFieldsArray := [
    TQueryField.Create('client_id', ClientId),
    TQueryField.Create('redirect_uri', RedirectUrl),
    TQueryField.Create('scope', FormatScopes(Scopes, ScopeSeparator)),
    TQueryField.Create('response_type', 'code') { ,
    TQueryField.Create('auth_type', 'rerequest') }
    ];

  if (UsesState) then
  begin
    LCodeFieldsArray := LCodeFieldsArray +
      [TQueryField.Create('state', AState)];
  end;

  Result := LCodeFieldsArray;

end;
