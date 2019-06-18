unit SocialMonkey.Providers.Contracts.FacebookProvider;

interface

uses
  SocialMonkey.Two.ProviderInterface;

type

  IFacebookProviderInterface = interface(IProviderInterface)
    ['{2DD1BE02-D836-4998-AFBF-2150E1347233}']
    procedure SetFields(const Value: TArray<string>);
    procedure SetVersion(const Value: string);
    function GetFields: TArray<string>;
    function GetVersion: string;
  end;

implementation

end.
