unit SocialMonkey.Contracts.SocialUser;

interface

  type

  ISocialUser = interface
    ['{6DD4E865-70E2-4F2D-8EC2-436F068A607E}']
    function GetId: string;
    function GetNickname: string;
    function GetName: string;
    function GetEmail: string;
    function GetAvatar: string;
  end;


implementation

end.
