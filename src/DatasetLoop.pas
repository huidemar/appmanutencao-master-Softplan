unit DatasetLoop;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Datasnap.DBClient, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, System.Math;

type
  TfDatasetLoop = class(TForm)
    DBGrid: TDBGrid;
    ClientDataSet: TClientDataSet;
    DataSource: TDataSource;
    btDeletarPares: TButton;
    DBNavigator: TDBNavigator;
    procedure FormCreate(Sender: TObject);
    procedure btDeletarParesClick(Sender: TObject);
  private
  public
  end;

var
  fDatasetLoop: TfDatasetLoop;

implementation

{$R *.dfm}

procedure TfDatasetLoop.btDeletarParesClick(Sender: TObject);
begin
  ClientDataSet.First;
  while not ClientDataSet.Eof do
    begin
      if ClientDataSet.FieldByName('Field2').AsInteger mod 2 = 0 then
        ClientDataSet.Delete
      else
        ClientDataSet.Next;
    end;
  ClientDataSet.First;
end;

procedure TfDatasetLoop.FormCreate(Sender: TObject);
var
  x: Integer;
begin
  ClientDataSet.CreateDataSet;
  x := 1;
  while x <= 10 do
    begin
      ClientDataSet.Append;
      ClientDataSet.FieldByName('Field1').AsString := 'Field'+x.ToString;
      ClientDataSet.FieldByName('Field2').AsInteger := RandomRange(1,3);
      ClientDataSet.Post;
      Inc(x);
    end;
  ClientDataSet.First;
end;

end.
