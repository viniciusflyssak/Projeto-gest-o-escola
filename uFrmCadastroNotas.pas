unit uFrmCadastroNotas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Buttons, Vcl.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, uDM;

type
  TFrmCadastroNotas = class(TForm)
    pnlTitulo: TPanel;
    pnlBotoes: TPanel;
    btnSalvar: TSpeedButton;
    btnCancelar: TSpeedButton;
    pnlFundo: TPanel;
    lblAluno: TLabel;
    edtCodAluno: TEdit;
    lblAno: TLabel;
    edtAno: TEdit;
    edtNomeAluno: TEdit;
    lblNota1: TLabel;
    edtNota1: TEdit;
    edtNota2: TEdit;
    lblNota2: TLabel;
    edtNota3: TEdit;
    lblNota3: TLabel;
    edtNota4: TEdit;
    lblNota4: TLabel;
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure edtCodAlunoExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FIdProfessor: integer;
    FIdRegistro: integer;
  published
    property IdProfessor: integer read FIdProfessor write FIdProfessor;
    property IdRegistro: integer read FIdRegistro write FIdRegistro;
  end;

var
  FrmCadastroNotas: TFrmCadastroNotas;

implementation

{$R *.dfm}

procedure TFrmCadastroNotas.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCadastroNotas.btnSalvarClick(Sender: TObject);
Const
  cSqlInsertNotas = ' INSERT INTO ALUNOS_PROFESSOR(ANO, ID_ALUNO, ID_PROFESSOR, NOTA1, NOTA2, NOTA3, NOTA4) ' +
               ' VALUES (:pAno, :pIdAluno, :pIdProfessor, :pNota1, :pNota2, :pNota3, :pNota4) ';
  cSqlUpdateNotas = ' UPDATE ALUNOS_PROFESSOR SET ANO = :pAno, ID_ALUNO = :pIdAluno, ID_PROFESSOR = :pIdProfessor, ' +
                    ' NOTA1 = :pNota1, NOTA2 = :pNota2, NOTA3 = :pNota3, NOTA4 = :pNota4 ' +
                    ' WHERE ID_ALUNOS_PROFESSOR = :pId';
var
  qryCadastro: TFDQuery;

begin
  if edtCodAluno.Text = '' then
  begin
    raise Exception.Create('Necess�rio informar o aluno!');
    edtCodAluno.SetFocus;
  end;
  if edtAno.Text = '' then
  begin
    raise Exception.Create('Necess�rio informar o ano!');
    edtAno.SetFocus;
  end;
  qryCadastro := TFDQuery.Create(nil);
  try
    qryCadastro.Connection := DM.Connection;
    if FIdRegistro > 0 then
      qryCadastro.Sql.Add(cSqlUpdateNotas)
    else
      qryCadastro.Sql.Add(cSqlInsertNotas);
    qryCadastro.Params.ParamByName('pAno').Value := StrToInt(edtAno.Text);
    qryCadastro.Params.ParamByName('pIdAluno').Value := StrToInt(edtCodAluno.Text);
    qryCadastro.Params.ParamByName('pIdProfessor').Value := FIdProfessor;
    qryCadastro.Params.ParamByName('pNota1').Value := StrToFloatDef(edtNota1.Text, 0);
    qryCadastro.Params.ParamByName('pNota2').Value := StrToFloatDef(edtNota2.Text, 0);
    qryCadastro.Params.ParamByName('pNota3').Value := StrToFloatDef(edtNota3.Text, 0);
    qryCadastro.Params.ParamByName('pNota4').Value := StrToFloatDef(edtNota4.Text, 0);
    if FIdRegistro > 0 then
      qryCadastro.Params.ParamByName('pId').Value := FIdRegistro;
    qryCadastro.ExecSQL;
  finally
    FreeAndNil(qryCadastro);
  end;
  ShowMessage('Salvo com sucesso!');
  Close;
end;

procedure TFrmCadastroNotas.edtCodAlunoExit(Sender: TObject);
Const
  cSqlAluno = ' SELECT NOME FROM ALUNOS WHERE ID_ALUNO = :pIdAluno ';
Var
  qryValidaAluno: TFDQuery;
begin
  if edtCodAluno.Text = '' then
  begin
    edtNomeAluno.Clear;
    exit;
  end;
  qryValidaAluno := TFDQuery.Create(nil);
  try
    qryValidaAluno.Connection := DM.Connection;
    qryValidaAluno.Sql.Add(cSqlAluno);
    qryValidaAluno.Params.ParamByName('pIdAluno').Value := StrToIntDef(edtCodAluno.Text, 0);
    qryValidaAluno.Open;
    if qryValidaAluno.RecordCount > 0 then
      edtNomeAluno.Text := qryValidaAluno.FieldByName('NOME').AsString
    else
    begin
      edtCodAluno.Clear;
      edtNomeAluno.Clear;
      ShowMessage('Aluno n�o encontrado!');
    end;
  finally
    FreeAndNil(qryValidaAluno);
  end;
end;

procedure TFrmCadastroNotas.FormShow(Sender: TObject);
Const
  cCarregaDados = ' SELECT ID_ALUNO, ANO, NOTA1, NOTA2, NOTA3, NOTA4 ' +
                  ' FROM ALUNOS_PROFESSOR ' +
                  ' WHERE ID_ALUNOS_PROFESSOR = :pId ';
var
  qryCarregaRegistro: TFDQuery;
begin
  if FIdRegistro > 0 then
  begin
    qryCarregaRegistro := TFDQuery.Create(nil);
    try
      qryCarregaRegistro.Connection := DM.Connection;
      qryCarregaRegistro.Sql.Add(cCarregaDados);
      qryCarregaRegistro.Params.ParamByName('pID').Value := FIdRegistro;
      qryCarregaRegistro.Open;      
      edtCodAluno.Text := qryCarregaRegistro.FieldByName('ID_ALUNO').AsString;
      edtAno.Text := qryCarregaRegistro.FieldByName('ANO').AsString;
      edtNota1.Text := qryCarregaRegistro.FieldByName('NOTA1').AsString;
      edtNota2.Text := qryCarregaRegistro.FieldByName('NOTA2').AsString;
      edtNota3.Text := qryCarregaRegistro.FieldByName('NOTA3').AsString;
      edtNota4.Text := qryCarregaRegistro.FieldByName('NOTA4').AsString;
      edtCodAlunoExit(nil);
    finally
      FreeAndNil(qryCarregaRegistro);
    end;
  end;
end;

end.
