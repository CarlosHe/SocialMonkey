unit SocialMonkey.Contracts.Provider;

interface

uses
  SocialMonkey.Contracts.SocialUser, SocialMonkey.Types;

type

  IProvider = interface
    ['{1A8EF626-F0D2-47EF-8DE5-B68E07F7ACCE}']
    function SocialUser(ASocialUserCallback: TSocialUserCallback<ISocialUser>): IProvider;
  end;

implementation

end.
