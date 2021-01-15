unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, MidasLib;

type
  TfMain = class(TForm)
    btDatasetLoop: TButton;
    btThreads: TButton;
    btStreams: TButton;
    procedure btDatasetLoopClick(Sender: TObject);
    procedure btStreamsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btThreadsClick(Sender: TObject);
  private
  public
  end;

var
  fMain: TfMain;

implementation

uses
  DatasetLoop, ClienteServidor, Threads;

{$R *.dfm}

procedure TfMain.btDatasetLoopClick(Sender: TObject);
begin
  try
    Application.CreateForm(TfDatasetLoop, fDatasetLoop);
    fDatasetLoop.ShowModal;
  finally
    fDatasetLoop.Free;
  end;
end;

procedure TfMain.btStreamsClick(Sender: TObject);
begin
  try
    Application.CreateForm(TfClienteServidor, fClienteServidor);
    fClienteServidor.ShowModal;
  finally
    fClienteServidor.Free;
  end;
end;

procedure TfMain.btThreadsClick(Sender: TObject);
begin
  try
    Application.CreateForm(TfThreads, fThreads);
    fThreads.ShowModal;
  finally
    fThreads.Free;
  end;
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
end;

end.
