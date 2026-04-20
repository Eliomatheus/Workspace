#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} PIFINC02
Exibe browse de contas correntes utilizando FWMBrowse com menu de opções
personalizado para visualizar, incluir, alterar e excluir registros da tabela SZ1.
@type 		function
@version  2410
@author 	Ponto INI - ELIO MATHEUS
@since 		13/03/2026
/*/
User Function PIFINC02()

	Local oBrowse
	Private aRotina :=MenuDef()
	private ccadastro := 'Conta Corrente'
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZ1")
	oBrowse:SetDescription('Cadastro Banco')
	oBrowse:Activate()

Return
/*/{Protheus.doc} MenuDef
Define menu de opções da rotina PIFINC02 com ações de pesquisar, visualizar,
incluir, alterar e excluir contas correntes.
@type 		function
@version  2410
@author 	Ponto INI - ELIO MATHEUS
@since 		13/03/2026
/*/
Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina, {'Pesquisar'  , 'AxPesqui'  ,0  ,1})
	aAdd(aRotina, {'Visualizar' , 'AxVisual'  ,0  ,2})
	aAdd(aRotina, {'Incluir'    , 'U_PIBLQC01',0  ,3})
	aAdd(aRotina, {'Alterar'    , 'U_PIFINA01',0  ,4})
	aAdd(aRotina, {'Excluir'    , 'U_PIFINE03',0  ,5})

return aRotina
/*/{Protheus.doc} PIBLQC01
Efetua inclusão de conta corrente chamando AxInclui com validação PIVALCN.
Após inclusão bem-sucedida, retorna .T.
@type 		function
@version  2410
@author 	Ponto INI - ELIO MATHEUS
@since 		13/03/2026
/*/
User Function PIBLQC01()
	Local lRet  := .F.
	nOpcao := AxInclui("SZ1", 0, 3,,,, "U_PIVALCN()",, , , , , ,) // Antes de fazer a Inclusão vai passar pela validação do PIVALCN

	If nOpcao == 1
		lRet := .T.
	EndIf
Return lRet
/*/{Protheus.doc} PIVALCN
Valida se banco, agência, conta e dígito já estão vinculados a outro correntista
na tabela SZ1. Se já existirem, bloqueia a inclusão e exibe erro.
@type 		function
@version  2410
@author 	Ponto INI - ELIO MATHEUS
@since 		13/03/2026
/*/
User function PIVALCN()
	Local cBanco :=  M->Z1_BANCO
	Local cAgencia := M->Z1_AGENCIA
	Local cConta := M->Z1_CONTA
	Local cDigito := M->Z1_DGCNT
	Local lRet := .T.

	SZ1->(DbSetOrder(3))
	If SZ1->(DbSeek(xFilial("SZ1") + cBanco + cAgencia + cConta + cDigito)) // Verificar se o Banco, Agencia, conta e Digito ja existe na SZ1
		FWAlertError("Banco, agência, conta e dígito já estão vinculados a um correntista. Favor realizar o cadastro com dados bancários diferentes.", "ATENÇÃO")
		lRet := .F.
	Else
		lRet := .T.
	EndIf
Return lRet
/*/{Protheus.doc} PIFINA01
Efetua alteração de conta corrente verificando se existe movimentação vinculada
na tabela SZ2. Se não houver movimento, permite alteração via AxAltera.
@type 		function
@version  2410
@author 	Ponto INI - ELIO MATHEUS
@since 		20/04/2026
/*/
User Function PIFINA01()
	Local nAltera := 0

	SZ2->(DbSetOrder(2))
	If SZ2->(DbSeek(xFilial("SZ2")+SZ1->Z1_CORRENT+ SZ1->Z1_BANCO+SZ1->Z1_AGENCIA+SZ1->Z1_CONTA+SZ1->Z1_DGCNT)) // Verifica se ja existe movimento criado para correntista se existir nao deixa fazer alteração
		FWAlertError("Não é possivel Alterar registro", "Atenção")
	Else
		nAltera:= AxAltera("SZ1",SZ1->(RECNO()),4) //  RECNO para fazer alteração no registro que to pocisionado
		If nAltera == 1
			FWAlertSuccess("Registro Alterado com Sucesso","Operação Concluida")
		Else
			FWAlertError("Operação Cancelada", "Atenção")
		EndIF
	EndIf
Return nAltera
/*/{Protheus.doc} PIFINE03
Efetua exclusão de conta corrente verificando se existe movimentação vinculada
na tabela SZ2. Se não houver movimento, permite exclusão via AxDeleta.
@type 		function
@version  2410
@author 	Ponto INI - ELIO MATHEUS
@since 		20/04/2026
/*/
User Function PIFINE03()
	Local nDeleta := 0

	SZ2->(DbSetOrder(2))
	If SZ2->(DbSeek(xFilial("SZ2")+SZ1->Z1_CORRENT+SZ1->Z1_BANCO+SZ1->Z1_AGENCIA+SZ1->Z1_CONTA+SZ1->Z1_DGCNT)) // Verifica se o Registro tem Movimentação na SZ2
		Alert("Conta com movimentação, não pode ser excluida") // Mensagem de erro se existir Registro na SZ2
	Else
		nDeleta := AxDeleta("SZ1",SZ1->(RECNO()),5)
		If nDeleta == 2
			FWAlertSuccess("Registro Excluido Com Sucesso", "Atenção")
		Else
			FWAlertError("Operação Cancelada", "Atenção")
		EndIf
	EndIf

Return nDeleta
