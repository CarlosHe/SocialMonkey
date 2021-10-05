unit SocialMonkey.Types;
{$SCOPEDENUMS ON}

interface

type

  TActionSocial = (Canceled, Allowed, Denied, Error);

  TOnBeginAction = reference to procedure;
  TOnFinishAction = reference to procedure;
  TOnAccessCanceled = reference to procedure;
  TOnAccessAllowed = reference to procedure(ACode: string);
  TOnAccessError = reference to procedure(AError: string);
  TOnAccessDenied = reference to procedure;
  TOnSocialUser<T> = reference to procedure(ASocialUser: T);
  TOnCloseSocialWebBrowser = reference to procedure(Action: TActionSocial; Code: string);
  TSocialUserCallback<T> = reference to procedure(Action: TActionSocial; ASocialUser: T);
  TOnCode = reference to procedure(Action: TActionSocial; ACode: string);

  TQueryField = record
    Name: string;
    Value: string;
    constructor Create(const AName, AValue: string);
  end;

  TQueryFieldArray = TArray<TQueryField>;

implementation

{ TQueryField }

constructor TQueryField.Create(const AName, AValue: string);
begin
  Name := AName;
  Value := AValue;
end;

end.
