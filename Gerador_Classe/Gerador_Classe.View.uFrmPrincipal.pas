unit Gerador_Classe.View.uFrmPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.TabControl, FMX.ListBox, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Edit, DB,
  Gerardor_Classe.GerarClasseZeos, Gerar_Classe.Firebird.GerarClasseBancoFirebird,
  Gerador_Classe.Gerar_Classes.GerarClasseVO, Gerador_Classe.Gerar_Classes.GerarClasseController,
  Gerador_Classe.Postgresql.GerarClasseBancoPostgresql;

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
  System.IniFiles;

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
         GerarVO.Gerar(cmbTabelas.Items.Text, edtPacote.Text, classeVO);
       finally
         GeradorFirebird.Free;
         GerarVO.Free;
       end;
     end;
     if chkController.IsChecked then
     begin
       GeradorFirebird := TGerarClasseBancoFirebird.Create;
       GerarController := TGerarClasseController.Create(GeradorFirebird);
       try
         GerarController.Gerar(cmbTabelas.Items.Text, cmbTabelas.Items.Text + 'Controller', edtPacoteController.Text);
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
          GerarVO.Gerar(cmbTabelas.Items.Text, edtPacote.Text, cmbTabelas.Items.Text + 'VO');
        finally
          GeradorPostgresql.Free;
          GerarVO.Free;
        end;
      end;
      if chkController.IsChecked then
      begin
        GeradorPostgresql := TGerarClasseBancoPostgresql.Create;
        GerarController := TGerarClasseController.Create(classeVO, edtPacote.Text);
        GerarController.Gerar(cmbTabelas.Items.Text, cmbTabelas.Items.Text, edtPacoteController.Text);
      end;
   end;


end;

procedure TfrmPrincipal.btnSairClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmPrincipal.CarregarCamposTabela;
var ds: TDataSet;
    Gerador: TGerarClasseZeos;
    GeradorFirebird: TGerarClasseBancoFirebird;
begin
//Carrega no Memo os campos da tabela selecionada.
   if cmbTabelas.ItemIndex = 0 then
      Gerador := TGerarClasseZeos.Create(GeradorFirebird);

   ds := Gerador.GetCamposTabela(cmbTabelas.Items.Text);
   ds.First;
   while not ds.Eof do
   begin
     mmCampos.Lines.Add(ds.FieldByName('NOME').AsString + '    ' + ds.FieldByName('TIPO').AsString);
     ds.Next;
   end;
end;

procedure TfrmPrincipal.CarregarComboBox;
var ds: TDataSet;
    Gerador: TGerarClasseZeos;
    GeradorFirebird: TGerarClasseBancoFirebird;
begin
  //Carrega com as tabelas do banco de dados.
  if cmbBaseDados.ItemIndex = 0 then //Banco Firebird falta implementar para o Postgresql.
     Gerador := TGerarClasseZeos.Create(GeradorFirebird);

  ds := Gerador.GetTabela;
  ds.First;
  while not ds.Eof do
  begin
    cmbTabelas.Items.Add(ds.FieldByName('TABELAS').AsString);
    ds.Next;
  end;
end;

procedure TfrmPrincipal.CarregarIni;
var ini: TIniFile;
begin
   ini := TIniFile.Create(ExtractFileDir(GetCurrentDir));
   try
      cmbBaseDados.Items.Text := ini.ReadString('Servidor', 'Driver', 'Erro ao carregar');
      edtCaminhoBanco.Text := ini.ReadString('Servidor', 'Banco', 'Erro ao carregar.');
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
