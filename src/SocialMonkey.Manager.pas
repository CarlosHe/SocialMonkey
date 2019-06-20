unit SocialMonkey.Manager;

interface

uses
  SocialMonkey.Contracts.Factory, SocialMonkey.Contracts.Provider,
  System.SysUtils, System.Generics.Collections,
  SocialMonkey.Two.AbstractProvider;

type

  TSocialMonkeyManager = class(TInterfacedObject, IFactory)
  private
    { private declarations }
    FDrivers: TDictionary<string, IProvider>;
  protected
    { protected declarations }

  public
    { public declarations }
    constructor Create; virtual;
    destructor Destroy; override;
    function Driver(ADriver: string): IProvider;
    function GetDrivers: TDictionary<string, IProvider>;
    procedure SetDrivers(Value: TDictionary<string, IProvider>);
    procedure AddDriver(ADriver: string; AProvider: IProvider);
    procedure RemoveDriver(ADriver: string);
  published
    { published declarations }
  end;

implementation

{ TSocialMonkeyManager }

procedure TSocialMonkeyManager.AddDriver(ADriver: string; AProvider: IProvider);
var
  FDriver: string;
begin
  FDriver := ADriver.Trim.ToLower;
  if FDrivers.ContainsKey(FDriver) then
    raise Exception.Create('Driver already exists.');
  FDrivers.Add(FDriver, AProvider);
end;

constructor TSocialMonkeyManager.Create;
begin
  FDrivers := TDictionary<string, IProvider>.Create;
end;

destructor TSocialMonkeyManager.Destroy;
begin
  FreeAndNil(FDrivers);
  inherited;
end;

function TSocialMonkeyManager.Driver(ADriver: string): IProvider;
var
  FDriver: string;
begin
  FDriver := ADriver.Trim.ToLower;
  if not FDrivers.ContainsKey(FDriver) then
    raise Exception.Create('Social driver not found.');
  Result := FDrivers.Items[FDriver]
end;

function TSocialMonkeyManager.GetDrivers: TDictionary<string, IProvider>;
begin
  Result := FDrivers;
end;

procedure TSocialMonkeyManager.RemoveDriver(ADriver: string);
var
  FDriver: string;
begin
  FDriver := ADriver.Trim.ToLower;
  if not FDrivers.ContainsKey(FDriver) then
    raise Exception.Create('Social driver not found.');
  FDrivers.Remove(FDriver);
end;

procedure TSocialMonkeyManager.SetDrivers(Value: TDictionary<string, IProvider>);
begin
  FDrivers := Value
end;

end.
