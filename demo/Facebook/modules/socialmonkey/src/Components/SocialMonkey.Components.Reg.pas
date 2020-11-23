unit SocialMonkey.Components.Reg;

interface

uses
  System.Classes, SocialMonkey.Components.Manager;

procedure Register;

implementation

uses
  SocialMonkey.Components.FacebookProvider;

procedure Register;
begin
  RegisterComponents('Social Monkey', [TSocialMonkeyFacebookProvider]);
  RegisterComponents('Social Monkey', [TSocialMonkeyManager]);
end;

end.
