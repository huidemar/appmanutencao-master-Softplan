unit TratarExcecao;

interface

uses System.Sysutils, Forms, System.Classes, Vcl.Dialogs;

type
  TExcecao = class
    private
      FLogAquivo: String;
    public
      constructor Create;
      procedure TratarException(Sender: TObject; E: Exception);
      procedure GravarLog(Valor: String);
  end;

implementation


{ TException }

constructor TExcecao.Create;
begin
  FLogAquivo := ExtractFilePath(ParamStr(0))+'log.log';
  Application.OnException := TratarException;
end;

procedure TExcecao.GravarLog(Valor: String);
var
  txtLog: TextFile;
begin
  AssignFile(txtLog, FLogAquivo);
  if FileExists(FLogAquivo) then
    Append(txtLog)
  else
    Rewrite(txtLog);
  Writeln(txtLog, FormatDateTime('dd/mm/YY hh:mm:ss ', Now)+' - '+Valor);
  CloseFile(txtLog);
end;

procedure TExcecao.TratarException(Sender: TObject; E: Exception);
begin
  GravarLog('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-');
  if TComponent(Sender) is TForm then
    begin
      GravarLog('Nome Form:' + TForm(Sender).Name);
      GravarLog('Título Form:' + TForm(Sender).Caption);
      GravarLog('Classe do Erro:'+E.ClassName);
      GravarLog('Erro:'+E.Message);
    end
  else
    begin
      GravarLog('Nome Form:' + TForm(TForm(Sender).Owner).Name);
      GravarLog('Título Form:' + TForm(TForm(Sender).Owner).Caption);
      GravarLog('Classe do Erro:'+E.ClassName);
      GravarLog('Erro:'+E.Message);
    end;
  ShowMessage(e.Message);
end;


var
  TratarEx: TExcecao;
Initialization
    TratarEx := TExcecao.create;
finalization
  TratarEx.free;
end.
