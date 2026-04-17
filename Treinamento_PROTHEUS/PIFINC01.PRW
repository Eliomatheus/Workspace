//Bibliotecas 
#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} PIFINC01
Tela de Correntista 
@type function
@author supor
@since 24/03/2026
/*/

// Criação da Tela Com Funções de Validação 
User Function PIFINC01()

	AxCadastro('SZ0', 'CORRENTISTA',"U_PIFINE01()", "U_PIFINE02()")

Return

// Validação para verificar se existe conta na SZ1 
User Function PIFINE01() // Função para excluir
	Local lRet := .T.

	SZ1->(DbSetOrder(1))
	If	SZ1->(DbSeek(xFilial("SZ1")+ SZ0->Z0_COD))
		Alert("Nao pode excluir correntista com conta no banco")
		lRet := .F.
	EndIf
Return lRet


// Validação para verificar se existe conta na SZ1 
User Function PIFINE02() // Função para Alterar
	Local lRet := .T.

	SZ1->(DbSetOrder(1))
	If	SZ1->(DbSeek(xFilial("SZ1")+ M->Z0_COD))
		Alert("Nao pode alterar correntista com conta no banco")
		lRet := .F.
	EndIf
Return lRet
