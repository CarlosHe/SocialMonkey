unit SocialMonkey.Two.ProviderInterface;

interface

uses
  SocialMonkey.Contracts.SocialUser,
  SocialMonkey.Contracts.Provider,
  SocialMonkey.Types;

type
  IProviderInterface = interface
    ['{8637D197-4B91-46EC-B324-F76B91423597}']
    procedure SetClientId(const Value: string);
    procedure SetClientSecret(const Value: string);
    procedure SetParameters(const Value: TArray<string>);
    procedure SetRedirectUrl(const Value: string);
    procedure SetStateless(const Value: Boolean);
    function GetClientId: string;
    function GetClientSecret: string;
    function GetParameters: TArray<string>;
    function GetRedirectUrl: string;
    function GetStateless: Boolean;
    function SocialUser(ASocialUserCallback: TSocialUserCallback<ISocialUser>): IProvider;
  end;

implementation

end.
