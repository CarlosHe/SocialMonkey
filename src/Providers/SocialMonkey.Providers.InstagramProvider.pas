unit SocialMonkey.Providers.InstagramProvider;

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
  TSocialMonkeyInstagramProvider = class(TAbstractProvider, IFacebookProviderInterface)
  private
    FVersion: string;
    FGraphUrl: string;
    FFields: TArray<string>;
    FPictureSize: Integer;

    procedure SetRedirectUrl(const Value: string); override;
    procedure SetFields(const Value: TArray<string>);
    procedure SetGraphUrl(const Value: string);
    procedure SetPictureSize(const Value: Integer);
    procedure SetVersion(const Value: string);
    function GetFields: TArray<string>;
    function GetGraphUrl: string;
    function GetPictureSize: Integer;
    function GetVersion: string;
    { private declarations }
  protected
    function GetAuthUrl(AState: string): string; override;
    function GetTokenUrl: string; override;
    function GetUserByToken(AToken: string): string; override;
    function MapUserToObject(AUser: string): ISocialUser; override;

    property Fields: TArray<string> read GetFields write SetFields;
    property GraphUrl: string read GetGraphUrl write SetGraphUrl;
    property Version: string read GetVersion write SetVersion;
    property PictureSize: Integer read GetPictureSize write SetPictureSize;
    { protected declarations }
  public
    constructor Create(AClientID, AClientSecret, ARedirectUrl: string); override;
    { public declarations }
  published
    { published declarations }
  end;

implementation

{ TSocialMonkeyInstagramProvider }

constructor TSocialMonkeyInstagramProvider.Create(AClientID, AClientSecret, ARedirectUrl: string);
begin
  inherited;
  AuthFields.Clear;
  AuthFields.AddOrSetValue('client_id', EmptyStr);
  AuthFields.AddOrSetValue('redirect_uri', EmptyStr);
  AuthFields.AddOrSetValue('response_type', 'code');
  AuthFields.AddOrSetValue('scope', 'user_profile,user_media');


  TokenFields.Clear;
  TokenFields.AddOrSetValue('client_id', EmptyStr);
  TokenFields.AddOrSetValue('client_secret', EmptyStr);
  TokenFields.AddOrSetValue('code', EmptyStr);
  TokenFields.AddOrSetValue('redirect_uri', EmptyStr);
  TokenFields.AddOrSetValue('grant_type', 'authorization_code');

  AbstractProviderType := aptInstagram;
  Fields := ['id', 'username', 'media'];
  GraphUrl := 'https://graph.instagram.com/';
  Version := 'v12.0';
  RedirectUrl := 'https://google.com/';
  PictureSize := 100;
  Stateless := True;
end;

function TSocialMonkeyInstagramProvider.GetAuthUrl(AState: string): string;
begin
  Result := BuildAuthUrl('https://api.instagram.com/oauth/authorize', AState);
end;

function TSocialMonkeyInstagramProvider.GetFields: TArray<string>;
begin
  Result := FFields;
end;

function TSocialMonkeyInstagramProvider.GetGraphUrl: string;
begin
  Result := FGraphUrl;
end;

function TSocialMonkeyInstagramProvider.GetPictureSize: Integer;
begin
  Result := FPictureSize;
end;

function TSocialMonkeyInstagramProvider.GetTokenUrl: string;
begin
  Result := 'https://api.instagram.com/oauth/access_token';
end;

function TSocialMonkeyInstagramProvider.GetUserByToken(AToken: string): string;
var
  LURI: TURI;
  LAppSecretProof: string;
  LId: string;
  LToken: string;
  LHeader: TNetHeaders;
  LJsonObject: TJsonObject;
begin
  LURI := TURI.Create(GraphUrl + '/me');
  LURI.AddParameter('fields', String.Join(',', Fields));
  LURI.AddParameter('access_token', AToken);

  LHeader := [TNameValuePair.Create('Accept', 'application/json')];
  Result := HttpRequest.Get(LURI.ToString, nil, LHeader).ContentAsString(TEncoding.UTF8);
end;

function TSocialMonkeyInstagramProvider.GetVersion: string;
begin
  Result := FVersion;
end;

function TSocialMonkeyInstagramProvider.MapUserToObject(AUser: string): ISocialUser;
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
      if LJsonObject.TryGetValue<string>('username', LName) then
        LSocialUser.Name := LName;
      if LJsonObject.TryGetValue<string>('email', LEmail) then
        LSocialUser.Email := LEmail;
      {LAvatarUrl := GraphUrl + Version + '/' + LId + '/picture';
      LSocialUser.Avatar := LAvatarUrl + '?type=normal&height=' +
        FPictureSize.ToString + '&width=' + FPictureSize.ToString;}
      Result := LSocialUser;
    finally
      LJsonObject.Free;
    end;
  end;
end;

procedure TSocialMonkeyInstagramProvider.SetFields(const Value: TArray<string>);
begin
  FFields := Value;
end;

procedure TSocialMonkeyInstagramProvider.SetGraphUrl(const Value: string);
begin
  FGraphUrl := Value;
end;

procedure TSocialMonkeyInstagramProvider.SetPictureSize(const Value: Integer);
begin
  FPictureSize := Value;
end;

procedure TSocialMonkeyInstagramProvider.SetRedirectUrl(const Value: string);
var
  LRedirectUrl: string;
begin
  LRedirectUrl := Value.Trim;
   if not (LRedirectUrl.EndsWith('/')) then
   LRedirectUrl := LRedirectUrl + '/';

  inherited SetRedirectUrl(LRedirectUrl);
end;

procedure TSocialMonkeyInstagramProvider.SetVersion(const Value: string);
begin
  FVersion := Value;
end;

end.
