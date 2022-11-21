unit Fabica_Objetos.IFactoryMethod;

interface

uses
  orm.IBaseVO;

//objetos do tipo BaseVO.
  type
    tTipoVO = (ttCliente, ttProduto, ttPessoa, ttPessoaJuridica, ttPessoaFisica,
    ttCstIcms, ttCstIpi, ttCstPis, ttCstCofins, ttTributacao, ttNcm, ttCest, ttNcmCest,
    ttNfe, ttNfce, ttTransportadora, ttFormaPgto, ttBanco, ttContaPagar, ttContaReceber, ttConfiguracao,
    ttCaixa, ttVenda, ttVendaItem, ttUF, ttCart�o, ttCidade, ttCfop, ttCompra, ttCompraItem, ttCotacao, ttCotacaoItem,
    ttCrt, ttCsosn, ttFornecProduto, ttFornecedor, ttFuncionario, ttMesa, ttNfse, ttNfeStatus, ttNfceStatus, ttPedido,
    ttPedidoItem, ttPerfilUsuario, ttUsuario, ttPlanoContas, ttRefeicao, ttRefeicaoItem, ttReserva, ttVendaVolume,
    ttVendaTransportadora, ttCstIcmsST, ttNfEntrada, ttNfEntradaProduto, ttNfEntradaVolume, ttNfeTransportadora);

type
  IFactoryMethod<T: class> = interface(IInterface)
    ['{D173603F-AF5A-4B1F-B402-EBD69EA7D781}']
    function FabricaObjeto(const opcao: tTipoVO): T;
  end;

implementation

end.
