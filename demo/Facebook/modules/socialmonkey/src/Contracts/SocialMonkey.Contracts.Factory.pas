unit SocialMonkey.Contracts.Factory;

interface

uses
  SocialMonkey.Contracts.Provider;

type
  IFactory = interface
    ['{3DF46563-A132-47A7-821D-338777E879DF}']
    function Driver(ADriver: string): IProvider;
  end;

implementation

end.
