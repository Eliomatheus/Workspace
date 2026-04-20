#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PIFINC01
Exibe tela de cadastro de correntistas utilizando AxCadastro com validações,
personalizadas para inclusão, alteração, exclusão e visualização.
@type 		function
@version  2410
@author 	Ponto INI - Elio Matheus
@since 		20/04/2026
/*/
User Function PIFINC01()

	AxCadastro('SZ0', 'CORRENTISTA',"U_PIFINE01()", "U_PIFINE02()")

Return
/*/{Protheus.doc} PIFINE01
Valida se o correntista possui contas vinculadas na tabela SZ1 antes da exclusão.
Se houver vínculo, bloqueia a exclusão e exibe alerta.
@type 		function
@version  2410
@author 	Ponto INI - Elio Matheus
@since 		20/04/2026
/*/
User Function PIFINE01()
	Local lRet := .T.

	SZ1->(DbSetOrder(1))
	If	SZ1->(DbSeek(xFilial("SZ1")+ SZ0->Z0_COD))
		Alert("Nao pode excluir correntista com conta no banco")
		lRet := .F.
	EndIf
Return lRet
/*/{Protheus.doc} PIFINE02
Valida se o correntista possui contas vinculadas na tabela SZ1 antes da alteração.
Se houver vínculo, bloqueia a alteração e exibe alerta.
@type 		function
@version  2410
@author 	Ponto INI - Elio Matheus
@since 		20/04/2026
/*/
User Function PIFINE02() // Função para Alterar
	Local lRet := .T.

	SZ1->(DbSetOrder(1))
	If	SZ1->(DbSeek(xFilial("SZ1")+ M->Z0_COD))
		Alert("Nao pode alterar correntista com conta no banco")
		lRet := .F.
	EndIf
Return lRet
