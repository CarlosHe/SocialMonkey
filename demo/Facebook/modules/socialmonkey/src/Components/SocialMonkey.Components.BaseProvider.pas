unit SocialMonkey.Components.BaseProvider;

interface

uses
  System.Classes, SocialMonkey.Contracts.Provider;

type

  TSocialMonkeyBaseProvider = class(TComponent)
  private
    { private declarations }
    FProvider: IProvider;
  protected
    { protected declarations }
    procedure SetProvider(AProvider: IProvider);
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Provider: IProvider;
  published
    { published declarations }
  end;

implementation

{ TSocialMonkeyBaseProvider }

constructor TSocialMonkeyBaseProvider.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TSocialMonkeyBaseProvider.SetProvider(AProvider: IProvider);
begin
  FProvider := AProvider;
end;

destructor TSocialMonkeyBaseProvider.Destroy;
begin

  inherited;
end;

function TSocialMonkeyBaseProvider.Provider: IProvider;
begin
  Result := FProvider;
end;

end.
