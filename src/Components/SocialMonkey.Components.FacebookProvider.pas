unit SocialMonkey.Components.FacebookProvider;

interface

uses
  System.Classes,
  System.SysUtils,

  SocialMonkey.Two.AbstractProvider,
  SocialMonkey.Contracts.Provider,
  SocialMonkey.Providers.FacebookProvider,
  SocialMonkey.Providers.Contracts.FacebookProvider,
  SocialMonkey.Components.BaseProvider;

type
  TSocialMonkeyFacebookProvider = class(TSocialMonkeyBaseProvider)
  private
    { private declarations }
    procedure SetClientId(const Value: string);
    procedure SetClientSecret(const Value: string);
    procedure SetFields(const Value: string);
    procedure SetRedirectUrl(const Value: string);
    procedure SetStateless(const Value: Boolean);
    procedure SetVersion(const Value: string);
    function GetClientId: string;
    function GetClientSecret: string;
    function GetFields: string;
    function GetRedirectUrl: string;
    function GetStateless: Boolean;
    function GetVersion: string;
    function GetPictureSize: Integer;
    procedure SetPictureSize(const Value: Integer);
  protected
    { protected declarations }
    function GetInstanceAsIFacebookProviderInterface: IFacebookProviderInterface;
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { published declarations }
    property ClientId: string read GetClientId write SetClientId;
    property ClientSecret: string read GetClientSecret write SetClientSecret;
    property RedirectUrl: string read GetRedirectUrl write SetRedirectUrl;
    property Stateless: Boolean read GetStateless write SetStateless;
    property Version: string read GetVersion write SetVersion;
    property Fields: string read GetFields write SetFields;
    property PictureSize: Integer read GetPictureSize write SetPictureSize;
  end;

implementation

{ TSocialMonkeyFacebookProvider }

constructor TSocialMonkeyFacebookProvider.Create(AOwner: TComponent);
begin
  inherited;
  SetProvider(SocialMonkey.Providers.FacebookProvider.TSocialMonkeyFacebookProvider.Create('', '', ''));
end;

destructor TSocialMonkeyFacebookProvider.Destroy;
begin

  inherited;
end;

function TSocialMonkeyFacebookProvider.GetClientId: string;
begin
  Result := GetInstanceAsIFacebookProviderInterface.GetClientId;
end;

function TSocialMonkeyFacebookProvider.GetClientSecret: string;
begin
  Result := GetInstanceAsIFacebookProviderInterface.GetClientSecret;
end;

function TSocialMonkeyFacebookProvider.GetFields: string;
begin
  Result := String.Join(',', GetInstanceAsIFacebookProviderInterface.GetFields);
end;

function TSocialMonkeyFacebookProvider.GetInstanceAsIFacebookProviderInterface: IFacebookProviderInterface;
begin
  Supports(Provider, IFacebookProviderInterface, Result);
end;

function TSocialMonkeyFacebookProvider.GetPictureSize: Integer;
begin
  Result := GetInstanceAsIFacebookProviderInterface.GetPictureSize;
end;

function TSocialMonkeyFacebookProvider.GetRedirectUrl: string;
begin
  Result := GetInstanceAsIFacebookProviderInterface.GetRedirectUrl;
end;

function TSocialMonkeyFacebookProvider.GetStateless: Boolean;
begin
  Result := GetInstanceAsIFacebookProviderInterface.GetStateless;
end;

function TSocialMonkeyFacebookProvider.GetVersion: string;
begin
  Result := GetInstanceAsIFacebookProviderInterface.GetVersion;
end;

procedure TSocialMonkeyFacebookProvider.SetClientId(const Value: string);
begin
  GetInstanceAsIFacebookProviderInterface.SetClientId(Value);
end;

procedure TSocialMonkeyFacebookProvider.SetClientSecret(const Value: string);
begin
  GetInstanceAsIFacebookProviderInterface.SetClientSecret(Value);
end;

procedure TSocialMonkeyFacebookProvider.SetFields(const Value: string);
begin
  GetInstanceAsIFacebookProviderInterface.SetFields(Value.Split([',']));
end;

procedure TSocialMonkeyFacebookProvider.SetPictureSize(const Value: Integer);
begin
  GetInstanceAsIFacebookProviderInterface.SetPictureSize(Value);
end;

procedure TSocialMonkeyFacebookProvider.SetRedirectUrl(const Value: string);
begin
  GetInstanceAsIFacebookProviderInterface.SetRedirectUrl(Value);
end;

procedure TSocialMonkeyFacebookProvider.SetStateless(const Value: Boolean);
begin
  GetInstanceAsIFacebookProviderInterface.SetStateless(Value);
end;

procedure TSocialMonkeyFacebookProvider.SetVersion(const Value: string);
begin
  GetInstanceAsIFacebookProviderInterface.SetVersion(Value);
end;

end.
