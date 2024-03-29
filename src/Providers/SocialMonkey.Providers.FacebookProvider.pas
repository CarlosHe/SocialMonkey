unit SocialMonkey.Providers.FacebookProvider;

interface

uses

  System.SysUtils,
  System.Json,
  System.Hash,
  System.Net.UrlClient,

  SocialMonkey.Two.AbstractProvider,
  SocialMonkey.Contracts.SocialUser,
  SocialMonkey.Two.SocialUser,
  SocialMonkey.Providers.Contracts.FacebookProvider;

type

  TSocialMonkeyFacebookProvider = class(TAbstractProvider, IFacebookProviderInterface)
  private
    { private declarations }
    FGraphUrl: string;
    FFields: TArray<string>;
    FVersion: string;
    FPictureSize: Integer;

    procedure SetRedirectUrl(const Value: string); override;
    procedure SetFields(const Value: TArray<string>);
    procedure SetGraphUrl(const Value: string);
    procedure SetVersion(const Value: string);
    function GetFields: TArray<string>;
    function GetGraphUrl: string;
    function GetVersion: string;
    function GetPictureSize: Integer;
    procedure SetPictureSize(const Value: Integer);

  protected
    { protected declarations }
    function GetAuthUrl(AState: string): string; override;
    function GetTokenUrl: string; override;
    function GetUserByToken(AToken: string): string; override;
    function MapUserToObject(AUser: string): ISocialUser; override;

    property Fields: TArray<string> read GetFields write SetFields;
    property GraphUrl: string read GetGraphUrl write SetGraphUrl;
    property Version: string read GetVersion write SetVersion;
    property PictureSize: Integer read GetPictureSize write SetPictureSize;
  public
    { public declarations }
    constructor Create(AClientID, AClientSecret, ARedirectUrl: string);
      override;
  published
    { published declarations }
  end;

implementation

{ TSocialMonkeyFacebookProvider }

constructor TSocialMonkeyFacebookProvider.Create(AClientID, AClientSecret,
  ARedirectUrl: string);
begin
  inherited;
  AuthFields.Clear;
  AuthFields.AddOrSetValue('client_id', EmptyStr);
  AuthFields.AddOrSetValue('redirect_uri', EmptyStr);
  AuthFields.AddOrSetValue('response_type', 'code');

  TokenFields.Clear;
  TokenFields.AddOrSetValue('client_id', EmptyStr);
  TokenFields.AddOrSetValue('client_secret', EmptyStr);
  TokenFields.AddOrSetValue('code', EmptyStr);
  TokenFields.AddOrSetValue('redirect_uri', EmptyStr);

  AbstractProviderType := aptFacebook;
  //Scopes := ['email'];
  Fields := ['name', 'email', 'gender', 'verified', 'link'];
  GraphUrl := 'https://graph.facebook.com';
  Version := 'v12.0';
  RedirectUrl := 'https://google.com/';
  PictureSize := 100;
  Stateless := False;
end;

function TSocialMonkeyFacebookProvider.GetAuthUrl(AState: string): string;
begin
  Result := BuildAuthUrl('https://www.facebook.com/' + Version + '/dialog/oauth', AState);
  // BuildAuthUrlFromBase('https://www.facebook.com/' + Version + '/dialog/oauth', AState);
end;

function TSocialMonkeyFacebookProvider.GetFields: TArray<string>;
begin
  Result := FFields;
end;

function TSocialMonkeyFacebookProvider.GetGraphUrl: string;
begin
  Result := FGraphUrl;
end;

function TSocialMonkeyFacebookProvider.GetPictureSize: Integer;
begin
  Result := FPictureSize;
end;

function TSocialMonkeyFacebookProvider.GetTokenUrl: string;
begin
  Result := GraphUrl + '/oauth/access_token';
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

function TSocialMonkeyFacebookProvider.MapUserToObject(AUser: string): ISocialUser;
var
  LJsonObject: TJsonObject;
  LSocialUser: TSocialUser;
  LText: string;
  LName: string;
  LEmail: string;
  LAvatarUrl: string;
begin
  LJsonObject := TJsonObject.ParseJSONValue(AUser) as TJsonObject;
  if Assigned(LJsonObject) then
  begin
    try
      LSocialUser := TSocialUser.Create;
      LJsonObject.TryGetValue<string>('id', LText);
      LSocialUser.Id := LText;
      LSocialUser.Nickname := EmptyStr;
      LJsonObject.TryGetValue<string>('name', LText);
      LSocialUser.Name := LText;
      LJsonObject.TryGetValue<string>('email', LText);
      LSocialUser.Email := LText;
      LAvatarUrl := GraphUrl + '/' + Version + '/' + LSocialUser.Id + '/picture';
      LSocialUser.Avatar := LAvatarUrl + '?type=normal&height=' +
        FPictureSize.ToString + '&width=' + FPictureSize.ToString;
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

procedure TSocialMonkeyFacebookProvider.SetPictureSize(const Value: Integer);
begin
  FPictureSize := Value;
end;

procedure TSocialMonkeyFacebookProvider.SetRedirectUrl(const Value: string);
var
  LRedirectUrl: string;
begin
  LRedirectUrl := Value.Trim;
   if not (LRedirectUrl.EndsWith('/')) then
   LRedirectUrl := LRedirectUrl + '/';

  inherited SetRedirectUrl(LRedirectUrl);
end;

procedure TSocialMonkeyFacebookProvider.SetVersion(const Value: string);
begin
  FVersion := Value;
end;

end.
