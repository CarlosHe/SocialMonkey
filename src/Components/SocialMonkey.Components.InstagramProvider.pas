unit SocialMonkey.Components.InstagramProvider;

interface

uses
  System.Classes,

  SocialMonkey.Components.FacebookProvider,
  SocialMonkey.Providers.InstagramProvider;

type
  TSocialMonkeyInstagramProvider = class(TSocialMonkeyFacebookProvider)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    { public declarations }
  published
    { published declarations }
  end;

implementation

{ TSocialMonkeyInstagramProvider }

constructor TSocialMonkeyInstagramProvider.Create(AOwner: TComponent);
begin
  // inherited;
  SetProvider(SocialMonkey.Providers.InstagramProvider.TSocialMonkeyInstagramProvider.Create('', '', ''));
end;

end.
