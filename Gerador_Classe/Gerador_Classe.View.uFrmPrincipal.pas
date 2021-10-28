unit Gerador_Classe.View.uFrmPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.TabControl, FMX.ListBox, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Edit, DB,
  Gerardor_Classe.GerarClasseZeos, Gerar_Classe.Firebird.GerarClasseBancoFirebird;

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
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure CarregarComboBox;
    procedure CarregarCamposTabela;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

procedure TfrmPrincipal.CarregarCamposTabela;
var ds: TDataSet;
    Gerador: TGerarClasseZeos;
    GeradorFirebird: TGerarClasseBancoFirebird;
begin
//Carrega no listbox os campos da tabela selecionada.
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

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
   TabControl1.ActiveTab := tbConfiguracao;
   TabControl1.TabPosition := TTabPosition.None;
end;

end.