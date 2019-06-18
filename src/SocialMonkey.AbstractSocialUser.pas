unit SocialMonkey.AbstractSocialUser;

interface

uses
  SocialMonkey.Contracts.SocialUser;

type
  TAbstractSocialUser = class(TInterfacedObject, ISocialUser)
  private
    FName: string;
    FEmail: string;
    FAvatar: string;
    FId: string;
    FNickname: string;
    procedure SetAvatar(const Value: string);
    procedure SetEmail(const Value: string);
    procedure SetId(const Value: string);
    procedure SetName(const Value: string);
    procedure SetNickname(const Value: string);
    function GetAvatar: string;
    function GetEmail: string;
    function GetId: string;
    function GetName: string;
    function GetNickname: string;
    { private declarations }
  protected
    { protected declarations }

  public
    { public declarations }
    property Id: string read GetId write SetId;
    property Nickname: string read GetNickname write SetNickname;
    property Name: string read GetName write SetName;
    property Email: string read GetEmail write SetEmail;
    property Avatar: string read GetAvatar write SetAvatar;
  published
    { published declarations }
  end;

implementation

{ TAbstractSocialUser }

function TAbstractSocialUser.GetAvatar: string;
begin
  Result := FAvatar;
end;

function TAbstractSocialUser.GetEmail: string;
begin
  Result := FEmail;
end;

function TAbstractSocialUser.GetId: string;
begin
  Result := FId;
end;

function TAbstractSocialUser.GetName: string;
begin
  Result := FName;
end;

function TAbstractSocialUser.GetNickname: string;
begin
  Result := FNickname;
end;

procedure TAbstractSocialUser.SetAvatar(const Value: string);
begin
  FAvatar := Value;
end;

procedure TAbstractSocialUser.SetEmail(const Value: string);
begin
  FEmail := Value;
end;

procedure TAbstractSocialUser.SetId(const Value: string);
begin
  FId := Value;
end;

procedure TAbstractSocialUser.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TAbstractSocialUser.SetNickname(const Value: string);
begin
  FNickname := Value;
end;

end.
