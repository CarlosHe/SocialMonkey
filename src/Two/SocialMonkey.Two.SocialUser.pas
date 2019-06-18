unit SocialMonkey.Two.SocialUser;

interface

uses SocialMonkey.AbstractSocialUser;

type

  TSocialUser = class(TAbstractSocialUser)
  private
    FRefreshToken: string;
    FToken: string;
    FExpiresIn: Integer;

    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    property Token: string read FToken;
    property RefreshToken: string read FRefreshToken;
    property ExpiresIn: Integer read FExpiresIn;
    function SetExpiresIn(const Value: Integer): TSocialUser;
    function SetRefreshToken(const Value: string): TSocialUser;
    function SetToken(const Value: string): TSocialUser;
  published
    { published declarations }
  end;

implementation

{ TSocialUser }

function TSocialUser.SetExpiresIn(const Value: Integer): TSocialUser;
begin
  Result := Self;
  FExpiresIn := Value;
end;

function TSocialUser.SetRefreshToken(const Value: string): TSocialUser;
begin
  Result := Self;
  FRefreshToken := Value;
end;

function TSocialUser.SetToken(const Value: string): TSocialUser;
begin
  Result := Self;
  FToken := Value;
end;

end.
