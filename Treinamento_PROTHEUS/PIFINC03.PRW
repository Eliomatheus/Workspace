// Bibliotecas 
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.ch"

/*/{Protheus.doc} PIFINC03
Rotina de tela da Tabela SZ2 com validações de movimentações
@type function
@author Elio Matheus 
@since 24/03/2026
/*/


User Function PIFINC03() // Função para a Criação da Tela Movimentos

	Local oBrowse
	Private aRotina :=MenuDef()
	private ccadastro := 'Movimentação'
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZ2")
	oBrowse:SetDescription('Movimentação Bancaria')
	oBrowse:Activate()

Return


Static Function MenuDef()

	Local aRotin := {} // Variavel decalrada para passar as opções do Outras Ações, Variavel vai receber as Arreys

	aAdd(aRotin, {'Pesquisar'  , 'AxPesqui'  ,0  ,1}) // Pesquisa com uma função Padrao
	aAdd(aRotin, {'Visualizar' , 'AxVisual'  ,0  ,2}) // Visual com uma função Padrao
	aAdd(aRotin, {'Incluir'    , 'U_PIFINM01',0  ,3}) // Incluir com uma Função Criada
	//aAdd(aRotin, {'Alterar'    , 'AxAltera',0  ,4})
	//aAdd(aRotin, {'Excluir'    , 'AxDeleta',0  ,5})
	aAdd(aRotin,{'Estornar Valor','U_PIFINM01',0 ,6}) // Estorno com uma Função Criada
	aAdd(aRotin,{'Comprovante', 'U_PIREL01',0  ,7}) // Comprovante com uma Função Criada -> essa função esta em outro fonte

return aRotin

// Função para fazer Inclusão de Movimentos
User Function PIFINM01(cAlias,nRec,nOpc)
	Local nOpcao := 0
	Local lRet := .T.
	If nOpc == 3 // Validação para entender se è Inclusão

		nOpcao := AxInclui("SZ2", 0, 3,,,, "U_PIVALI(3)",, , , , , ,) // Chamando a Função AxInclui para fazer Inclusao Antes de ir para o IF ele vai para a Validação PIVALI

		If nOpcao == 1

			If SZ2->Z2_MOVIMEN == "D"

				SZ1->(RecLock('SZ1', .F.))
				SZ1->Z1_SALDO := SZ1->Z1_SALDO - SZ2->Z2_VALOR
				SZ1->(MsUnlock())

			Else

				SZ1->(RecLock('SZ1', .F.))
				SZ1->Z1_SALDO := SZ1->Z1_SALDO + SZ2->Z2_VALOR
				SZ1->(MsUnlock())

			EndIf

		EndIf // Final do IF de Inclusão
	Else // Para validar o Estorno
		SZ1->(DbSetOrder(5))
		If SZ1->(DbSeek(xFilial("SZ1")+SZ2->Z2_CORRENT+ SZ2->Z2_BANCO+SZ2->Z2_AGENCIA+SZ2->Z2_CONTA+SZ2->Z2_DGCNTA)) // Verifica se o que esta salvo no banco existe na SZ1


			If MsgYesNo("Tem certeza que deseja estornar essa transação")
				If SZ2->Z2_MOVIMEN == "C"
					If !(SZ1->Z1_SALDO > SZ2->Z2_VALOR)
						lRet := .F.
						FWAlertError("Valor do Extorno maior que o saldo", "Atenção")
					Else
						SZ1->(RecLock('SZ1', .F.)) // RecLock para fazer a alteração na SZ1
						SZ1->Z1_SALDO := SZ1->Z1_SALDO - SZ2->Z2_VALOR
						SZ1->(MsUnlock()) // Para liberar o Registro

						SZ2->(RecLock('SZ2', .F.))
						SZ2->(DbDelete()) // Para deletar a Movimentação feita na SZ2
						SZ2->(MsUnlock())
						FWAlertSuccess("Estorno Concluido com Sucesso", "Operação Concluida")

					EndIf

				Else
					// RecLock do Movimento de Debito
					SZ1->(RecLock('SZ1', .F.))
					SZ1->Z1_SALDO := SZ1->Z1_SALDO + SZ2->Z2_VALOR
					SZ1->(MsUnlock())

					SZ2->(RecLock('SZ2', .F.))
					SZ2->(DbDelete())
					SZ2->(MsUnlock())


				EndIf
			EndIf
		EndIf

	EndIf
Return lRet

//Validação de Inclusão de movimentos
User Function PIVALI(nEscolha)
	Local lRet := .T. // Variavel para poder deixar fazer a inclusão de Movimentos
	Default nEscolha := 0

	If nEscolha == 3
		SZ1->(DbSetOrder(5)) //setando o Order em 5 por que é a posição do indice que quero fazer validaçãp
		If SZ1->(DbSeek(xFilial("SZ1")+M->Z2_CORRENT+ M->Z2_BANCO+M->Z2_AGENCIA+M->Z2_CONTA+M->Z2_DGCNTA)) //Verificando se a possição dos campos em memoria existe na SZ1
			If M->Z2_MOVIMEN == "D" // Se o Movimento for Igual a "D" Fazer a validação abaixo
				If !(SZ1->Z1_SALDO >= M->Z2_VALOR) // Verifia se o Saldo é Maior ou Igual ao Valor, se o Valor for maior o sistema nao vai deixar inserir na SZ1, vai gerar a mensagem de alerta
					lRet := .F.
					FWAlertError("Saldo insuficiente para Movimentação", "Erro")
				EndIf
			EndIf
		Else
			lRet := .F.
			FWAlertError("Conta Bancaria Invalida", "Atenção")
		EndIf
	EndIf
Return lRet
