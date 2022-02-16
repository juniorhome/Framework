unit Gerador_Classe.View.uFrmPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.TabControl, FMX.ListBox, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Edit, DB,
  Gerardor_Classe.GerarClasseZeos, Gerar_Classe.Firebird.GerarClasseBancoFirebird,
  Gerador_Classe.Gerar_Classes.GerarClasseVO, Gerador_Classe.Gerar_Classes.GerarClasseController,
  Gerador_Classe.Postgresql.GerarClasseBancoPostgresql, FMX.Memo.Types;

type
  TfrmPrincipal = class(TForm)
    lytPrincipal: TLayout;
    Rectangle1: TRectangle;
    TabControl1: TTabControl;
    tbConfiguracao: TTabItem;
    tbArquivos: TTabItem;
    Label1: TLabel;
    cmbTabelas: TComboBox;
    Label2: TLabel;
    mmCampos: TMemo;
    chkClasseVO: TCheckBox;
    chkController: TCheckBox;
    salvarVO: TSaveDialog;
    salvarController: TSaveDialog;
    btnGerar: TButton;
    btnSair: TButton;
    mmClasseVO: TMemo;
    mmController: TMemo;
    btnSalvar: TButton;
    btnVoltar: TButton;
    Label3: TLabel;
    edtPacote: TEdit;
    Label4: TLabel;
    cmbBaseDados: TComboBox;
    pnlBotes: TPanel;
    Label5: TLabel;
    edtPacoteController: TEdit;
    Label6: TLabel;
    edtCaminhoVO: TEdit;
    Label7: TLabel;
    Edit2: TEdit;
    Label8: TLabel;
    edtCaminhoBanco: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnGerarClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure btnVoltarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure CarregarComboBox;
    procedure CarregarCamposTabela;
    procedure CarregarIni;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  System.IniFiles, Gerador_Classe.view.uDM;

{$R *.fmx}

procedure TfrmPrincipal.btnGerarClick(Sender: TObject);
var GerarVO: TGerarClasseVO;
    GerarController: TGerarClasseController;
    GeradorFirebird: TGerarClasseBancoFirebird;
    GeradorPostgresql: TGerarClasseBancoPostgresql;
    classeVO: string;
begin
   if cmbBaseDados.ItemIndex = 0 then //Firebird.
   begin
     if chkClasseVO.IsChecked then
     begin
       GeradorFirebird := TGerarClasseBancoFirebird.Create;
       GerarVO := TGerarClasseVO.Create(GeradorFirebird);
       try
         classeVO := cmbTabelas.Items.Text + 'VO';
         salvarVO.FileName := edtPacote.Text + '.' + classeVO;
         mmClasseVO.Text := GerarVO.Gerar(cmbTabelas.Items.Text, edtPacote.Text, classeVO);
       finally
         GeradorFirebird.Free;
         GerarVO.Free;
       end;
     end;
     if chkController.IsChecked then
     begin
       GeradorFirebird := TGerarClasseBancoFirebird.Create;
       GerarController := TGerarClasseController.Create(classeVO, edtPacote.Text);
       try
         salvarController.FileName :=  edtPacoteController.Text + '.' + cmbTabelas.Items.Text + 'Controller';
         mmController.Text := GerarController.Gerar(cmbTabelas.Items.Text, cmbTabelas.Items.Text + 'Controller', edtPacoteController.Text);
       finally
          GeradorFirebird.Free;
          GerarController.Free;
       end;
     end;
   end;
   if cmbBaseDados.ItemIndex = 1 then //Postgresql.
   begin
      if chkClasseVO.IsChecked then
      begin
        GeradorPostgresql := TGerarClasseBancoPostgresql.Create;
        GerarVO := TGerarClasseVO.Create(GeradorPostgresql);
        try
          classeVO :=  cmbTabelas.Items.Text + 'VO';
          salvarVO.FileName := edtPacote.Text + '.' + classeVO;
          mmClasseVO.Text := GerarVO.Gerar(cmbTabelas.Items.Text, edtPacote.Text, classeVO);
        finally
          GeradorPostgresql.Free;
          GerarVO.Free;
        end;
      end;
      if chkController.IsChecked then
      begin
        GeradorPostgresql := TGerarClasseBancoPostgresql.Create;
        GerarController := TGerarClasseController.Create(classeVO, edtPacote.Text);
        try
          salvarController.FileName := edtPacoteController.Text + '.' + cmbTabelas.Items.Text + 'Controller';
          mmController.Text := GerarController.Gerar(cmbTabelas.Items.Text, cmbTabelas.Items.Text + 'Controller', edtPacoteController.Text);
        finally
           GeradorPostgresql.Free;
           GerarController.Free;
        end;
      end;
   end;


end;

procedure TfrmPrincipal.btnSairClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmPrincipal.btnSalvarClick(Sender: TObject);
begin
  if chkClasseVO.IsChecked then
  begin
    salvarVO.DefaultExt := 'pas';
    salvarVO.Filter := 'PAS|*.pas';
    if salvarVO.Execute then
     mmClasseVO.Lines.SaveToFile(salvarVO.FileName);
  end;
  if chkController.IsChecked then
  begin
    salvarController.DefaultExt := 'pas';
    salvarController.Filter := 'PAS|*.pas';

    if salvarController.Execute then
       mmController.Lines.SaveToFile(salvarController.FileName);
  end;
end;

procedure TfrmPrincipal.btnVoltarClick(Sender: TObject);
begin
  TabControl1.ActiveTab := tbConfiguracao;
end;

procedure TfrmPrincipal.CarregarCamposTabela;
var ds: TDataSet;
    Gerador: TGerarClasseZeos;
    GeradorFirebird: TGerarClasseBancoFirebird;
    GeradorPostgresql: TGerarClasseBancoPostgresql;
begin
//Carrega no Memo os campos da tabela selecionada.
   if cmbTabelas.ItemIndex = 0 then
   begin
      GeradorFirebird := TGerarClasseBancoFirebird.Create;
      Gerador := TGerarClasseZeos.Create(GeradorFirebird);

      ds := Gerador.GetCamposTabela(cmbTabelas.Items.Text);
      ds.First;
      while not ds.Eof do
      begin
        mmCampos.Lines.Add(ds.FieldByName('NOME').AsString + '    ' + ds.FieldByName('TIPO').AsString);
        ds.Next;
      end;
   end;
   if cmbTabelas.ItemIndex = 1 then
   begin
     GeradorPostgresql := TGerarClasseBancoPostgresql.Create;
     Gerador := TGerarClasseZeos.Create(GeradorPostgresql);

     ds := Gerador.GetCamposTabela(cmbTabelas.Items.Text);
      ds.First;
      while not ds.Eof do
      begin
        mmCampos.Lines.Add(ds.FieldByName('NOME').AsString + '    ' + ds.FieldByName('TIPO').AsString);
        ds.Next;
      end;
   end;
end;

procedure TfrmPrincipal.CarregarComboBox;
var ds: TDataSet;
    Gerador: TGerarClasseZeos;
    GeradorFirebird: TGerarClasseBancoFirebird;
begin
  //Carrega com as tabelas do banco de dados.
  if cmbBaseDados.ItemIndex = 0 then //Banco Firebird falta.
  begin
     GeradorFirebird := TGerarClasseBancoFirebird.Create;
     Gerador := TGerarClasseZeos.Create(GeradorFirebird);
     ds := Gerador.GetTabela;
     ds.First;
     while not ds.Eof do
     begin
      cmbTabelas.Items.Add(ds.FieldByName('TABELAS').AsString);
      ds.Next;
     end;
  end;
end;

procedure TfrmPrincipal.CarregarIni;
var ini: TIniFile;
begin
   ini := TIniFile.Create(ExtractFileDir(GetCurrentDir) + 'config.ini');
   try
      if FileExists(ExtractFileDir(GetCurrentDir) + 'config.ini') then
      begin
        cmbBaseDados.Items.Text := ini.ReadString('Configuração', 'Driver', 'Erro ao carregar');
        edtCaminhoBanco.Text := ini.ReadString('Configuração', 'Banco', 'Erro ao carregar.');
      end;
   finally
     ini.Free;
   end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
   TabControl1.ActiveTab := tbConfiguracao;
   TabControl1.TabPosition := TTabPosition.None;
   CarregarIni;
   CarregarComboBox;
   CarregarCamposTabela;
   if cmbTabelas.ItemIndex > -1 then
      btnGerar.Enabled := True
   else btnGerar.Enabled := False;
end;

end.
