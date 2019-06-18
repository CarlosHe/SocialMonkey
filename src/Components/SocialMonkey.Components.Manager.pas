unit SocialMonkey.Components.Manager;

interface

uses
  System.Classes, SocialMonkey.Contracts.Factory,
  SocialMonkey.Contracts.Provider, SocialMonkey.Manager, System.SysUtils,
  System.Generics.Collections, SocialMonkey.Components.BaseProvider;

type
  TSocialMonkeyManager = class(TComponent)
  private
    { private declarations }
    FSocialMonkeyManager: SocialMonkey.Manager.TSocialMonkeyManager;
    procedure SetDrivers(const Value: TDictionary<string, IProvider>);
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Driver(ADriver: string): IProvider;
    function GetDrivers: TDictionary<string, IProvider>;
    procedure AddDriver(ADriver: string; AProvider: IProvider);
    procedure RemoveDriver(ADriver: string);
  published
    { published declarations }
    property Drivers: TDictionary<string, IProvider> read GetDrivers write SetDrivers;
  end;

implementation

{ TSocialMonkeyManager }

procedure TSocialMonkeyManager.AddDriver(ADriver: string; AProvider: IProvider);
begin
  FSocialMonkeyManager.AddDriver(ADriver, AProvider);
end;

constructor TSocialMonkeyManager.Create(AOwner: TComponent);
begin
  inherited;
  FSocialMonkeyManager := SocialMonkey.Manager.TSocialMonkeyManager.Create;
end;

destructor TSocialMonkeyManager.Destroy;
begin
  FreeAndNil(FSocialMonkeyManager);
  inherited;
end;

function TSocialMonkeyManager.Driver(ADriver: string): IProvider;
begin
   Result := FSocialMonkeyManager.Driver(ADriver);
end;

function TSocialMonkeyManager.GetDrivers: TDictionary<string, IProvider>;
begin
  Result := FSocialMonkeyManager.GetDrivers;
end;

procedure TSocialMonkeyManager.RemoveDriver(ADriver: string);
begin
  FSocialMonkeyManager.RemoveDriver(ADriver);
end;

procedure TSocialMonkeyManager.SetDrivers(const Value: TDictionary<string, IProvider>);
begin
  FSocialMonkeyManager.SetDrivers(Value);
end;

end.
