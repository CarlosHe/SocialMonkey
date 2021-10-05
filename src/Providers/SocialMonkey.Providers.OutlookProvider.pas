unit SocialMonkey.Providers.OutlookProvider;

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

  TSocialMonkeyOutlookProvider = class(TAbstractProvider, IFacebookProviderInterface)
  private
    { private declarations }
    FBaseUrl: string;
    FFields: TArray<string>;
    FVersion: string;
    FPictureSize: Integer;

    procedure SetRedirectUrl(const Value: string); override;
    procedure SetFields(const Value: TArray<string>);
    procedure SetBaseUrl(const Value: string);
    procedure SetVersion(const Value: string);
    function GetFields: TArray<string>;
    function GetBaseUrl: string;
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
    property BaseUrl: string read GetBaseUrl write SetBaseUrl;
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

{ TSocialMonkeyOutlookProvider }

constructor TSocialMonkeyOutlookProvider.Create(AClientID, AClientSecret,
  ARedirectUrl: string);
begin
  inherited;
  AuthFields.Clear;
  AuthFields.Add('client_id', EmptyStr);
  AuthFields.Add('redirect_uri', EmptyStr);
  AuthFields.Add('response_type', 'code');
  AuthFields.Add('response_mode', 'query');
  AuthFields.Add('prompt', 'login');
  AuthFields.Add('scope', 'openid%20offline_access%20https%3A%2F%2Fgraph.microsoft.com%2F.default'
  // 'https%3A%2F%2Fgraph.microsoft.com%2F.default'
  // 'https%3A%2F%2Fgraph.microsoft.com%2F.default%0D%0Ahttps%3A%2F%2Foutlook.office.com%2F.default'
  );

  TokenFields.Clear;
  TokenFields.AddOrSetValue('client_id', EmptyStr);
  TokenFields.AddOrSetValue('client_secret', EmptyStr);
  TokenFields.AddOrSetValue('code', EmptyStr);
  TokenFields.AddOrSetValue('redirect_uri', EmptyStr);
  TokenFields.AddOrSetValue('grant_type', 'authorization_code');

  AbstractProviderType := aptOutlook;
  Fields := ['openid', 'email', 'profile'];

  (*
  common here is the {tenant} on the Endpoints section on the API documentation
  *)

  BaseUrl := 'https://login.microsoftonline.com/common';
  Version := 'v2.0';
  RedirectUrl := 'http://localhost';
  PictureSize := 240;
  Stateless := False;
end;

function TSocialMonkeyOutlookProvider.GetAuthUrl(AState: string): string;
begin
  Result := BuildAuthUrl(BaseUrl + '/oauth2/' + Version + '/authorize', AState);
end;

function TSocialMonkeyOutlookProvider.GetFields: TArray<string>;
begin
  Result := FFields;
end;

function TSocialMonkeyOutlookProvider.GetBaseUrl: string;
begin
  Result := FBaseUrl;
end;

function TSocialMonkeyOutlookProvider.GetPictureSize: Integer;
begin
  Result := FPictureSize;
end;

function TSocialMonkeyOutlookProvider.GetTokenUrl: string;
begin
  Result := BuildTokenUrl(BaseUrl + '/oauth2/' + Version + '/token');
end;

function TSocialMonkeyOutlookProvider.GetUserByToken(AToken: string): string;
var
  LURI: TURI;
  LAppSecretProof: string;
  LHeader: TNetHeaders;
begin
  LURI := TURI.Create('https://graph.microsoft.com/v1.0/me');

  LHeader := [
    TNameValuePair.Create('Authorization', 'Bearer ' + AToken),
    TNameValuePair.Create('Accept', 'application/json')
    ];
  Result := HttpRequest.Get(LURI.ToString, nil, LHeader).ContentAsString(TEncoding.UTF8);
end;

function TSocialMonkeyOutlookProvider.GetVersion: string;
begin
  Result := FVersion;
end;

function TSocialMonkeyOutlookProvider.MapUserToObject(AUser: string): ISocialUser;
var
  LJsonObject: TJsonObject;
  LSocialUser: TSocialUser;
  LText: string;
begin
  LJsonObject := TJsonObject.ParseJSONValue(AUser) as TJsonObject;
  if Assigned(LJsonObject) then
  begin
    try
      LSocialUser := TSocialUser.Create;
      LJsonObject.TryGetValue<string>('id', LText);
      LSocialUser.Id := LText;
      LSocialUser.Nickname := EmptyStr;
      LJsonObject.TryGetValue<string>('displayName', LText);
      LSocialUser.Name := LText;
      LJsonObject.TryGetValue<string>('userPrincipalName', LText);
      LSocialUser.Email := LText;
      LText := 'https://graph.microsoft.com/v1.0/me/photos/' + PictureSize.ToString + 'x' + PictureSize.ToString + '/$value';
      {
      Take a look on:
      https://docs.microsoft.com/en-us/graph/api/profilephoto-get?view=graph-rest-1.0

      to get the avatar must send the Authenticated token and
      Content-Type image/jpg
      }
      LSocialUser.Avatar := LText;
      Result := LSocialUser;
    finally
      LJsonObject.Free;
    end;
  end;
end;

procedure TSocialMonkeyOutlookProvider.SetFields(const Value: TArray<string>);
begin
  FFields := Value;
end;

procedure TSocialMonkeyOutlookProvider.SetBaseUrl(const Value: string);
begin
  FBaseUrl := Value;
end;

procedure TSocialMonkeyOutlookProvider.SetPictureSize(const Value: Integer);
begin
  case Value of
    48, 64, 96, 120, 240, 360, 432, 504, 648: ;
  else
    raise Exception.Create(
      'Picture size is not value.' + sLineBreak +
      'Valid values: 48x48, 64x64, 96x96, 120x120, 240x240, 360x360, 432x432, 504x504, and 648x648' + sLineBreak +
      'More info on: https://docs.microsoft.com/en-us/graph/api/profilephoto-get?view=graph-rest-1.0'
      );
  end;

  FPictureSize := Value;
end;

procedure TSocialMonkeyOutlookProvider.SetRedirectUrl(const Value: string);
var
  LRedirectUrl: string;
begin
  LRedirectUrl := Value.Trim;
  if not(LRedirectUrl.EndsWith('/')) then
    LRedirectUrl := LRedirectUrl + '/';

  inherited SetRedirectUrl(LRedirectUrl);
end;

procedure TSocialMonkeyOutlookProvider.SetVersion(const Value: string);
begin
  FVersion := Value;
end;

end.
