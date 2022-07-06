unit uFrmCadastro;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, uDM;

type
  TFrmCadastro = class(TForm)
    pnlFundo: TPanel;
    pnlTitulo: TPanel;
    lblNome: TLabel;
    llbCPF: TLabel;
    lblDataNascimento: TLabel;
    lblDisciplinaSerie: TLabel;
    lblSexo: TLabel;
    lblEmail: TLabel;
    edtNome: TEdit;
    edtCPF: TEdit;
    edtNascimento: TEdit;
    edtEmail: TEdit;
    edtDisciplinaSerie: TEdit;
    cbbSexo: TComboBox;
    pnlBotoes: TPanel;
    btnSalvar: TSpeedButton;
    btnCancelar: TSpeedButton;
    procedure btnSalvarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
  private
    { Private declarations }
  public
    Tipo: integer;
    ID: integer;
  end;

var
  FrmCadastro: TFrmCadastro;

implementation

{$R *.dfm}

procedure TFrmCadastro.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCadastro.btnSalvarClick(Sender: TObject);
Const
  cInsereProfessor = ' INSERT INTO PROFESSORES(NOME, CPF, SEXO, DATA_NASCIMENTO, EMAIL, DISCIPLINA) VALUES ';
  cInsereAluno = ' INSERT INTO ALUNOS(NOME, CPF, SEXO, DATA_NASCIMENTO, EMAIL, SERIE) VALUES ';
  cAtualizaProfessor = ' UPDATE PROFESSORES SET NOME = :pNome, CPF = :pCpf, SEXO = :pSexo, DATA_NASCIMENTO = :pDataNasc, ' +
                       ' EMAIL = :pEmail, DISCIPLINA = :pDisciplinaSerie WHERE ID_PROFESSOR = :pId ';
  cAtualizaAluno = ' UPDATE ALUNOS SET NOME = :pNome, CPF = :pCpf, SEXO = :pSexo, DATA_NASCIMENTO = :pDataNasc, ' +
                   ' EMAIL = :pEmail, SERIE = :pDisciplinaSerie WHERE ID_ALUNO = :pId ';
var
  qrySalvar: TFDQuery;
begin
  qrySalvar := TFDQuery.Create(nil);
  try
    qrySalvar.Connection := DM.Connection;
    if ID > 0 then
    begin
      case Tipo of
        1: qrySalvar.Sql.Add(cAtualizaProfessor);
        2: qrySalvar.Sql.Add(cAtualizaAluno);
      end;
    end
    else
    begin
      case Tipo of
        1: qrySalvar.Sql.Add(cInsereProfessor);
        2: qrySalvar.Sql.Add(cInsereAluno);
      end;
    end;
    if not(ID > 0) then
      qrySalvar.Sql.Add(' (:pNome, :pCpf, :pSexo, :pDataNasc, :pEmail, :pDisciplinaSerie) ');
    qrySalvar.Params.ParamByName('pNome').Value := edtNome.Text;
    qrySalvar.Params.ParamByName('pCpf').Value := edtCPF.Text;
    qrySalvar.Params.ParamByName('pSexo').Value := copy(cbbSexo.Text,1,1);
    qrySalvar.Params.ParamByName('pDataNasc').Value := StrToDate(edtNascimento.Text);
    qrySalvar.Params.ParamByName('pEmail').Value := edtEmail.Text;
    qrySalvar.Params.ParamByName('pDisciplinaSerie').Value := edtDisciplinaSerie.Text;
    if ID > 0 then
      qrySalvar.Params.ParamByName('pId').Value := ID;
    qrySalvar.ExecSQL;
    ShowMessage('Salvo com sucesso!');
  finally
    FreeAndNil(qrySalvar);
  end;
  Close;
end;

procedure TFrmCadastro.FormShow(Sender: TObject);
Const
  cCarregaDadosProfessor = ' SELECT NOME, CPF, SEXO, DATA_NASCIMENTO, EMAIL, DISCIPLINA FROM PROFESSORES WHERE ID_PROFESSOR = :pId ';
  cCarregaDadosAluno = ' SELECT NOME, CPF, SEXO, DATA_NASCIMENTO, EMAIL, SERIE FROM ALUNOS WHERE ID_ALUNO = :pId ';
var
  qryCarregaDados: TFDQuery;
begin
  if id > 0 then
  begin
    qryCarregaDados := TFDQuery.Create(nil);
    try
      qryCarregaDados.Connection := DM.Connection;
      case Tipo of
        1: qryCarregaDados.Sql.Add(cCarregaDadosProfessor);
        2: qryCarregaDados.Sql.Add(cCarregaDadosAluno);
      end;
      qryCarregaDados.Params.ParamByName('pID').Value := ID;
      qryCarregaDados.Open;
      edtNome.Text := qryCarregaDados.FieldByName('NOME').AsString;
      edtCPF.Text := qryCarregaDados.FieldByName('CPF').AsString;
      edtNascimento.Text := qryCarregaDados.FieldByName('DATA_NASCIMENTO').AsString;
      edtEmail.Text := qryCarregaDados.FieldByName('EMAIL').AsString;
      case Tipo of
        1: edtDisciplinaSerie.Text := qryCarregaDados.FieldByName('DISCIPLINA').AsString;
        2: edtDisciplinaSerie.Text := qryCarregaDados.FieldByName('SERIE').AsString;
      end;
      if qryCarregaDados.FieldByName('SEXO').AsString = 'M' then
        cbbSexo.ItemIndex := 0
      else
        if qryCarregaDados.FieldByName('SEXO').AsString = 'F' then
          cbbSexo.ItemIndex := 1
        else
          cbbSexo.ItemIndex := 2;
    finally
      FreeAndNil(qryCarregaDados);
    end;
  end;

  case Tipo of
    1:
    begin
      pnlTitulo.Caption := 'Cadastro de Professor';
      lblDisciplinaSerie.Caption := 'Disciplina';
    end;
    2:
    begin
      pnlTitulo.Caption := 'Cadastro de Aluno';
      lblDisciplinaSerie.Caption := 'Serie';
    end;
  end;
end;

end.