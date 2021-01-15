unit ClienteServidor;

interface

uses
  Threads,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Threading;

type
  TServidor = class
  private
    FPath: String;
  public
    constructor Create;
    //Tipo do parâmetro não pode ser alterado
    function SalvarArquivos(AData: OleVariant): Boolean; overload;
    function SalvarArquivos(cds: TClientDataSet): Boolean; overload;
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btEnviarParaleloClick(Sender: TObject);
  private
    FPath: String;
    FServidor: TServidor;
    FCDSParalelo: TClientDataSet;

    function InitDataset: TClientDataset;
    procedure Inicializar_ProgressBar;
    procedure Carregar_ProgressBar(Posicao: Integer);
    procedure EnviarSemErros(Qtde_Enviar: Integer);
    procedure GravarCds(Cds: TClientDataSet; contador: Integer);
  public
  end;

var
  fClienteServidor: TfClienteServidor;

const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  cds := InitDataset;
  Inicializar_ProgressBar;
  for i := 1 to QTD_ARQUIVOS_ENVIAR do
  begin
    try
      GravarCds(cds, I);
      Carregar_ProgressBar(i);
      {$REGION Simulação de erro, não alterar}
      if i = (QTD_ARQUIVOS_ENVIAR/2) then
        FServidor.SalvarArquivos(NULL);
      {$ENDREGION}
    except on e: EDBClient do
      begin
        ShowMessage('aqui');
      end;

    end;
  end;

  FServidor.SalvarArquivos(cds.Data);
end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
begin
  if not Assigned(FCDSParalelo) then
    FCDSParalelo := InitDataset;
  TParallel.For(1, QTD_ARQUIVOS_ENVIAR,
            procedure(i: Integer)
            begin
              TThread.Queue(TThread.CurrentThread,
                procedure
                begin
                  GravarCds(FCDSParalelo, I);
                  Carregar_ProgressBar(I);
                  if I mod 10 = 0 then
                    begin
                      FServidor.SalvarArquivos(FCDSParalelo);
                      FCDSParalelo.EmptyDataSet;
                    end;
                end);
            end);
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
begin
  EnviarSemErros(QTD_ARQUIVOS_ENVIAR);
end;

procedure TfClienteServidor.Carregar_ProgressBar(Posicao: Integer);
begin
  ProgressBar.Position := Posicao;
end;

procedure TfClienteServidor.EnviarSemErros(Qtde_Enviar: Integer);
var
  cds: TClientDataset;
  I: Integer;
begin
  try
    cds := InitDataset;
    Inicializar_ProgressBar;
    for I := 1 to Qtde_Enviar do
      begin
        GravarCds(cds, I);
        Carregar_ProgressBar(I);
        if I mod 10 = 0 then
          begin
            FServidor.SalvarArquivos(cds);
            cds.EmptyDataSet;
            Application.ProcessMessages;
          end;
      end;
  finally
    FreeAndNil(cds);
    ShowMessage('Finalizado!');
    Inicializar_ProgressBar;
  end;
end;

procedure TfClienteServidor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FServidor.Free;
  FCDSParalelo.Free;
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  FPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';
  FServidor := TServidor.Create;
end;

procedure TfClienteServidor.GravarCds(Cds: TClientDataSet; contador: Integer);
begin
  cds.Append;
  TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
  cds.FieldByName('Nome').AsString := contador.ToString;
  cds.Post;
end;

procedure TfClienteServidor.Inicializar_ProgressBar;
begin
  ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
  ProgressBar.Position := 0;
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.FieldDefs.Add('Nome', ftString, 20);
  Result.CreateDataSet;
end;

{ TServidor }

constructor TServidor.Create;
begin
  FPath := ExtractFilePath(ParamStr(0)) + 'Servidor\';
end;

function TServidor.SalvarArquivos(AData: OleVariant): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
  try
    Result := False;
    cds := TClientDataset.Create(nil);
    cds.Data := AData;

    {$REGION Simulação de erro, não alterar}
    if cds.RecordCount = 0 then
      Exit;
    {$ENDREGION}

    cds.First;

    while not cds.Eof do
    begin
      FileName := FPath + cds.FieldByName('Nome').AsString+'.pdf';//cds.RecNo.ToString + '.pdf';
      if TFile.Exists(FileName) then
        TFile.Delete(FileName);

      TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
      cds.Next;
    end;
    Result := True;
  except
    raise;
  end;
end;

function TServidor.SalvarArquivos(cds: TClientDataSet): Boolean;
var
  FileName: string;
begin
  try
    Result := False;

    {$REGION Simulação de erro, não alterar}
    if cds.RecordCount = 0 then
      Exit;
    {$ENDREGION}

    cds.First;

    while not cds.Eof do
    begin
      FileName := FPath + cds.FieldByName('Nome').AsString+'.pdf';//cds.RecNo.ToString + '.pdf';
      if TFile.Exists(FileName) then
        TFile.Delete(FileName);

      TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
      cds.Next;
    end;
    Result := True;
  except
    raise;
  end;
end;

end.
