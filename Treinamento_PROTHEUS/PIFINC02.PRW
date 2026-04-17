#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PIFINC02
FUNÇÃO PARA CRIAR TELA DE CONTA CORRENTE
@type function
@author INI ELIO MATHEUS
@since 13/03/2026
/*/


// Função para a Criação da Tela de Conta Corrente 
User Function PIFINC02()

	Local oBrowse
	Private aRotina :=MenuDef()
	private ccadastro := 'Conta Corrente'
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZ1")
	oBrowse:SetDescription('Cadastro Banco')
	oBrowse:Activate()

Return


Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina, {'Pesquisar'  , 'AxPesqui'  ,0  ,1})
	aAdd(aRotina, {'Visualizar' , 'AxVisual'  ,0  ,2})
	aAdd(aRotina, {'Incluir'    , 'U_PIBLQC01',0  ,3})
	aAdd(aRotina, {'Alterar'    , 'U_PIFINA01',0  ,4})
	aAdd(aRotina, {'Excluir'    , 'U_PIFINE03',0  ,5})

return aRotina

// Funçao para Validar Criação de Correntista 
User Function PIBLQC01()
	Local lRet  := .F.
	nOpcao := AxInclui("SZ1", 0, 3,,,, "U_PIVALCN()",, , , , , ,) // Antes de fazer a Inclusão vai passar pela validação do PIVALCN

	If nOpcao == 1

		lRet := .T.
	EndIf
Return lRet

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

// Função Para fazer Alteração 
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

//Função para Excluir Registro 
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
