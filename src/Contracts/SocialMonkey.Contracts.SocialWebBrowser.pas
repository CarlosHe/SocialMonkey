unit SocialMonkey.Contracts.SocialWebBrowser;

interface

uses
  SocialMonkey.Types;

type

  ISocialWebBrowser = interface
    ['{3CEB4F42-B72E-436E-93DC-BA30525165B5}']
    function OnBegin(AOnBegin: TOnBeginAction): ISocialWebBrowser;
    function OnFinish(AOnFinish: TOnFinishAction): ISocialWebBrowser;
    function OnAccessCanceled(AAccessCanceled: TOnAccessCanceled): ISocialWebBrowser;
    function OnAccessAllowed(AOnAccessAllowed: TOnAccessAllowed): ISocialWebBrowser;
    function OnAccessDenied(AOnAccessDenied: TOnAccessDenied): ISocialWebBrowser;
    function Execute(AAuthUrl: string): ISocialWebBrowser;
  end;

implementation

end.
