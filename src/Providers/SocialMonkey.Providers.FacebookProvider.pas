unit SocialMonkey.Providers.FacebookProvider;

interface

uses

  System.SysUtils, System.Json, System.Hash, System.Net.UrlClient,
  SocialMonkey.Two.AbstractProvider,
  SocialMonkey.Contracts.SocialUser, SocialMonkey.Two.SocialUser,
  SocialMonkey.Providers.Contracts.FacebookProvider;

type

  TSocialMonkeyFacebookProvider = class(TAbstractProvider, IFacebookProviderInterface)
  private
    { private declarations }
    FGraphUrl: string;
    FFields: TArray<string>;
    FVersion: string;
    procedure SetFields(const Value: TArray<string>);
    procedure SetGraphUrl(const Value: string);
    procedure SetVersion(const Value: string);
    function GetFields: TArray<string>;
    function GetGraphUrl: string;
    function GetVersion: string;
  protected
    { protected declarations }
    function GetAuthUrl(AState: string): string; override;
    function GetTokenUrl: string; override;
    function GetUserByToken(AToken: string): string; override;
    function MapUserToObject(AUser: string): ISocialUser; override;

    property Fields: TArray<string> read GetFields write SetFields;
    property GraphUrl: string read GetGraphUrl write SetGraphUrl;
    property Version: string read GetVersion write SetVersion;
  public
    { public declarations }
    constructor Create(AClientID, AClientSecret, ARedirectUrl: string); override;
  published
    { published declarations }
  end;

implementation

{ TSocialMonkeyFacebookProvider }

constructor TSocialMonkeyFacebookProvider.Create(AClientID, AClientSecret, ARedirectUrl: string);
begin
  inherited;
  Scopes := ['email'];
  Fields := ['name', 'email', 'gender', 'verified', 'link'];
  GraphUrl := 'https://graph.facebook.com';
  Version := 'v3.3';
end;

function TSocialMonkeyFacebookProvider.GetAuthUrl(AState: string): string;
begin
  Result := BuildAuthUrlFromBase('https://www.facebook.com/' + Version + '/dialog/oauth', AState);
end;

function TSocialMonkeyFacebookProvider.GetFields: TArray<string>;
begin
  Result := FFields;
end;

function TSocialMonkeyFacebookProvider.GetGraphUrl: string;
begin
  Result := FGraphUrl;
end;

function TSocialMonkeyFacebookProvider.GetTokenUrl: string;
begin
  Result := GraphUrl + '/' + Version + '/oauth/access_token';
end;

function TSocialMonkeyFacebookProvider.GetUserByToken(AToken: string): string;
var
  LURI: TURI;
  LAppSecretProof: string;
  LHeader: TNetHeaders;
begin
  LURI := TURI.Create(GraphUrl + '/' + Version + '/me');
  LURI.AddParameter('access_token', AToken);
  LURI.AddParameter('fields', String.Join(',', Fields));
  if (not ClientSecret.Trim.IsEmpty) then
  begin
    LAppSecretProof := THashSHA2.GetHMAC(AToken, ClientSecret.Trim);
    LURI.AddParameter('appsecret_proof', LAppSecretProof);
  end;

  LHeader := [TNameValuePair.Create('Accept', 'application/json')];
  Result := HttpRequest.Get(LURI.ToString, nil, LHeader).ContentAsString(TEncoding.UTF8);

end;

function TSocialMonkeyFacebookProvider.GetVersion: string;
begin
  Result := FVersion;
end;

function TSocialMonkeyFacebookProvider.mapUserToObject(AUser: string): ISocialUser;
var
  LJsonObject: TJsonObject;
  LSocialUser: TSocialUser;
  LId: string;
  LName: string;
  LEmail: string;
  LAvatarUrl: string;
begin
  LJsonObject := TJsonObject.ParseJSONValue(AUser) as TJsonObject;
  if Assigned(LJsonObject) then
  begin
    try
      LSocialUser := TSocialUser.Create;
      LId := LJsonObject.GetValue<string>('id');
      LSocialUser.Id := LId;
      LSocialUser.Nickname := '';
      if LJsonObject.TryGetValue<string>('name', LName) then
        LSocialUser.Name := LName;
      if LJsonObject.TryGetValue<string>('email', LEmail) then
        LSocialUser.Email := LEmail;
      LAvatarUrl := GraphUrl + '/' + Version + '/' + LId + '/picture';
      LSocialUser.Avatar := LAvatarUrl + '?type=normal';
      Result := LSocialUser;
    finally
      LJsonObject.Free;
    end;
  end;
end;

procedure TSocialMonkeyFacebookProvider.SetFields(const Value: TArray<string>);
begin
  FFields := Value;
end;

procedure TSocialMonkeyFacebookProvider.SetGraphUrl(const Value: string);
begin
  FGraphUrl := Value;
end;

procedure TSocialMonkeyFacebookProvider.SetVersion(const Value: string);
begin
  FVersion := Value;
end;

end.
