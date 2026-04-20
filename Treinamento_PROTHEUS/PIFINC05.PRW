#include "PROTHEUS.CH"
#include "RWMAKE.CH"
//--------------------------------------------------------------------------------
/*/{Protheus.doc} PIFINC05()
TELA MODELO 3 TREINAMENTO
@type function
@author INI Elio Matheus 
@since 14/04/2026
/*/
//--------------------------------------------------------------------------------
User Function PIFINC05()
	Local oBrowse
	Private aRotina :=MenuDef()
	private ccadastro := 'Cabeçalho de Movimentações'
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZ4")
	oBrowse:SetDescription('Movimentações de Beneficiarios')
	oBrowse:AddLegend( "SZ4->Z4_STATUS == 'P'", "YELLOW",   "Pendente" )
	oBrowse:AddLegend( "SZ4->Z4_STATUS == 'A'", "GREEN",    "Aprovado" )
	oBrowse:AddLegend( "SZ4->Z4_STATUS == 'R'", "RED"  ,     "Reprovado" )
	oBrowse:Activate()
Return
/*/{Protheus.doc} MenuDef
Define menu de opcoes da rotina PIFINC05
@type       function
@author 		Ponto INI - Elio Matheus
@since      14/04/2026
/*/
Static Function MenuDef()

	Local aRotin := {} // Variavel decalrada para passar as opções do Outras Ações, Variavel vai receber as Arreys

	aAdd(aRotin, {'Pesquisar'  , 	'AxPesqui'  ,0  ,1})
	aAdd(aRotin, {'Visualizar' , 	'U_PIFINC5B',0  ,2})
	aAdd(aRotin, {'Incluir'    , 	'U_PIFINC5B',0  ,3})
	aAdd(aRotin, {'Alterar'    ,	'U_PIFINC5B',0  ,4})
	aAdd(aRotin, {'Excluir'    , 	'U_PIFINC5B',0  ,5})
	aAdd(aRotin, {'Legenda'    , 	'U_PIFINLE'	,0  ,6})
	aAdd(aRotin, {'Aprovar'    , 	'U_PIFINAR1',0  ,7})
	aAdd(aRotin, {'Reprovar'   ,	'U_PIFINAR1',0  ,8})

return aRotin
/*/{Protheus.doc} PIFINLE
Adcionando cores com legendas
@type       function
@author 		Ponto INI - Elio Matheus
@since      14/04/2026
/*/
User Function PIFINLE()

	Local aLegenda := {}

	aAdd(aLegenda,{"BR_AMARELO","Pendente"})
	aAdd(aLegenda,{"BR_VERDE","Aprovado"})
	aAdd(aLegenda,{"BR_VERMELHO","Reprovado"})
	BrwLegenda("Situação da Movimentação", "Legenda", aLegenda)

return
/*/{Protheus.doc} PIFINC5B
Manutencao de movimentacoes financeiras - Modelo 3 (Header + Grid)
@type 		function
@version 	2410
@author 	Ponto INI - Elio Matheus
@since 		16/04/2026
/*/
User Function PIFINC5B(cAlias,nReg,nOpc)

	Local aButtons	:= {}
	Local aPosObj	:= {}
	Local oDlg		:= Nil
	Local oMsmGet	:= Nil
	Local aCabec	:= {}
	Local cIniCpos  := ('+Z5_ITEM')
	Local aAlter	:= IIF (INCLUI .Or. ALTERA,{"Z5_DESCRI","Z5_DATAD","Z5_QUANT","Z5_PRECO","Z5_TIPO","Z5_OBS"},{})

	Private oGetDad	:= Nil
	Private INCLUI 	:= nOpc == 3
	Private ALTERA	:= nOpc == 4
	Private DELETA  := nOpc == 5
	Private aCols	:= {}
	Private aItens := {}
	Private aTela[0][0]
	Private aGets[0]

	//--Coloca as variaveis na mémoria*/
	RegToMemory("SZ4",IIF(nOpc == 3,.T.,.F.))
	//--Carrega aItens e array com as informações do cabeçalho*/
	FCarreAcols('SZ4',@aCabec,@aItens)
	//--Carrega grid
	FCarreGrid('SZ5',nReg,nOpc)

  /* Define resolução Tela*/
	aSize := MsAdvSize(.T.)
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	aObjects := {}
	AADD(aObjects,{30,30,.T.,.T.})
	AADD(aObjects,{70,70,.T.,.T.})
	aPosObj := MsObjSize(aInfo,aObjects,.T.,.F.)

	//--Tela
	Define MsDialog oDlg Title cCadastro From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel  //Esta linha cria a janela principal (o "pop-up" ou tela que vai abrir para o usuário).
	oMsmGet := MsmGet():New("SZ4",nReg,nOpc,,,,aCabec,aPosObj[1],,,,,,oDlg,,.T.,,,,,,,,,)
	oGetDad	:= MsNewGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],nOpc, "U_PIFINL01","U_PIFINTOK",cIniCpos,aAlter,,9999,"U_PIFINT01",,,oDlg,@aItens,@aCols,,)
	// Opções de ações
	If nOpc == 4  //Alteração
		oGetDad:lUpdate := IIF(nOpc == 4 ,.T.,oGetDad:lUpdate)
		oGetDad:lInsert := .T.
	ElseIf nOpc == 3 //Inclusão
		oGetDad:ldelete := .T.
	ElseIf nOpc == 2 //Visualização
		oGetDad:lUpdate := .F.
		oGetDad:lInsert := .F.
		oGetDad:ldelete := .F.
	EndIf
	Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,{|| IIF(Obrigatorio(aGets,aTela) .AND. oGetDad:TudoOk(),(PIFINA5(),oDlg:End()),.F.)},{|| RollBackSx8(),oDlg:End()},,aButtons))
Return(Nil)
/*/{Protheus.doc} FCarreAcols
Função para carregar o acols
@type 		function
@version  1.0
@author 	Ponto INI - Elio Matheus
@since 		16/04/2026
/*/
Static Function FCarreAcols(cTab, aCabec, aItens)

	//Local cCampCab	:= 'Z4_CODDES|Z4_CPFBEN|Z4_NOMBEN|Z4_CODCORR|Z4_NOMCORR|Z4_DATA|Z4_STATUS'
	//Local cCampIte	:= 'Z5_ITEM|Z5_CODDES|Z5_DESCRI|Z5_DATAD|Z5_PRECO|Z5_QUANT|Z5_VALOR|Z5_TIPO|Z5_OBS'
	Local aStruZ4 := FWSX3Util():GetListFieldsStruct( 'SZ4', .T. )
	Local aStruZ5 := FWSX3Util():GetListFieldsStruct( 'SZ5', .T. )
	Local nXi := 0
	Local nXo := 0

	For nXi := 1 to Len(aStruZ4)
		//If (Alltrim(AllTrim(aStruZ4[nXi][1]))) // $ cCampCab)
		AAdd(aCabec,{GETSX3CACHE(aStruZ4[nXi][1],"X3_TITULO"),GETSX3CACHE(aStruZ4[nXi][1],"X3_CAMPO"),GETSX3CACHE(aStruZ4[nXi][1],"X3_TIPO"),GETSX3CACHE(aStruZ4[nXi][1],"X3_TAMANHO"),GETSX3CACHE(aStruZ4[nXi][1],"X3_DECIMAL"),GETSX3CACHE(aStruZ4[nXi][1],"X3_PICTURE"),&(GETSX3CACHE(aStruZ4[nXi][1],"X3_VLDUSER")),;
			IIf(AllTrim(GETSX3CACHE(aStruZ4[nXi][1],"X3_OBRIGAT"))<>"",.T.,.F.),GETSX3CACHE(aStruZ4[nXi][1], "X3_NIVEL"),GETSX3CACHE(aStruZ4[nXi][1],"X3_RELACAO"),GETSX3CACHE(aStruZ4[nXi][1],"X3_F3"),&(GETSX3CACHE(aStruZ4[nXi][1],"X3_WHEN")),;
			IIf(AllTrim(GETSX3CACHE(aStruZ4[nXi][1],"X3_VISUAL"))=="V",.T.,.F.),.F.,GETSX3CACHE(aStruZ4[nXi][1],"X3_CBOX"),Val(GETSX3CACHE(aStruZ4[nXi][1],"X3_FOLDER")),;
			IIf(AllTrim(GETSX3CACHE(aStruZ4[nXi][1],"X3_CONTEXT"))=="V",.T.,.F.),GETSX3CACHE(aStruZ4[nXi][1],"X3_PICTVAR"),GETSX3CACHE(aStruZ4[nXi][1],"X3_TRIGGER")})
		//	EndIf
	Next nXi

	For nXo := 1 to Len(aStruZ5)
		//If (Alltrim(aStruZ5[nXo][1])) // $ cCampIte)
		If Alltrim(GETSX3CACHE(aStruZ5[nXo][1],"X3_CAMPO")) != "Z5_CODDES" .AND. Alltrim(GETSX3CACHE(aStruZ5[nXo][1],"X3_CAMPO")) != "Z5_FILIAL"
			AAdd(aItens,{GETSX3CACHE(aStruZ5[nXo][1],"X3_TITULO"),Alltrim(GETSX3CACHE(aStruZ5[nXo][1],"X3_CAMPO")),GETSX3CACHE(aStruZ5[nXo][1],"X3_PICTURE"),GETSX3CACHE(aStruZ5[nXo][1],"X3_TAMANHO"),GETSX3CACHE(aStruZ5[nXo][1],"X3_DECIMAL"),GETSX3CACHE(aStruZ5[nXo][1],"X3_VALID"),;
				GETSX3CACHE(aStruZ5[nXo][1],"X3_USADO"),GETSX3CACHE(aStruZ5[nXo][1],"X3_TIPO"),GETSX3CACHE(aStruZ5[nXo][1],"X3_F3"),GETSX3CACHE(aStruZ5[nXo][1],"X3_CONTEXT"),GETSX3CACHE(aStruZ5[nXo][1],"X3_CBOX"),GETSX3CACHE(aStruZ5[nXo][1],"X3_RELACAO"),GETSX3CACHE(aStruZ5[nXo][1],"X3_WHEN"),;
				GETSX3CACHE(aStruZ5[nXo][1],"X3_VISUAL"),GETSX3CACHE(aStruZ5[nXo][1],"X3_VLDUSER"),GETSX3CACHE(aStruZ5[nXo][1],"X3_PICTVAR"),GETSX3CACHE(aStruZ5[nXo][1],"X3_BROWSE"),GETSX3CACHE(aStruZ5[nXo][1],"X3_OBRIGAT")})
		EndIf
	Next nXo
Return(Nil)
/*/{Protheus.doc} FCarreGrid
Função para carregar Grid
@type 		function
@version  1.0
@author 	Ponto INI - Elio Matheus
@since 		16/04/2026
/*/
Static Function FCarreGrid(cAlias,nReg,nOpc)

	Local aAreaAll	:= {SZ5->(GetArea()),GetArea()}
	Local xI := 0

	If	nOpc <> 3 // nOpc tem que ser diferente de 3
		(cAlias)->(dbSetOrder(1))
		If (cAlias)->(dbSeek(xFilial("SZ5") + Avkey(M->Z4_CODDES,'Z5_CODDES'))) // verifica se existe chave e o avkey é para formatar o Z4_CODDES para o mesmo tamanho do campo 'Z5_CODDES'
			Do While (cAlias)->(!EoF()) .And. (cAlias)->Z5_FILIAL == xFilial("SZ5") .And. (cAlias)->Z5_CODDES == M->Z4_CODDES // cAlias == Tabela foi declarado no parametro FCarreGrid que foi o SZ5,
				//enquanto SZ TIVER NO FINAL E SZ5 PONTERADO NA Z5FILIAL IGUAL A XFILIAL SZ E CFILIAL PONTERANDO Z5_CODDES IGUAL A MEMORIA DO Z4_CODDES FOR VERDADEIRA VAI PARA A PROXIMA LINAH DE CODIGO
				//--Monta o aCols no tamanho do meu aItens
				AADD(aCols,Array(Len(aItens) + 1))
				aCols[Len(aCols)][Len(aItens) + 1] := .F.
				For xI := 1 To Len(aItens) // XI COMEÇA A PARTIR DA PRIMEIRA POSIÇÃO E O LEN FALA A QUANTIDADE QUE O FOR VAI PECORRER
					If aItens[xI][10] == "V"
						aCols[len(aCols)][xI] := CriaVar(aItens[xI][2],.T.)
					Else // SE NAO
						aCols[len(aCols)][xI] := SZ5->(FieldGet(FieldPos(aItens[xI][2]))) //
					EndIf
				Next xI
				(cAlias)->(dbSkip())
			EndDo
		EndIf
		//Carrega campos virtuais
		DbSelectArea('SZ0')
		SZ0->(DbSetOrder(1))
		If SZ0->(DbSeek(xFilial("SZ0")+M->Z4_CODCORR))
			M->Z4_CODCORR := SZ0->Z0_COD
			M->Z4_NOMCORR := SZ0->Z0_NOME
		EndIf
	EndIf

	AEVal(aAreaAll,{|x|RestArea(x)})

Return(Nil)
/*/{Protheus.doc} PIFINA5
Função para fazer Inclusão, Alteração e Exclusao de Registros
@type 		function
@version 	12.0
@author 	Ponto Ini Elio Matheus
@since 		15/04/2026
/*/
Static Function PIFINA5()
	Local lRet 				:= .T.
	Local nPosItem 		:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_ITEM"})
	Local nPosDesc 		:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_DESCRI"})
	Local nPosDt 			:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_DATAD"})
	Local nPosPreco 	:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_PRECO"})
	Local nPosQtd 		:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_QUANT"})
	Local nPosTotal 	:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_VALOR"})
	Local nPosTpDesc 	:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_TIPO"})
	Local nPosObs 		:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_OBS"})
	Local aCols       := OGETDAD:ACOLS
	Local nLinha 			:= 0

	SZ4->(DbSetOrder(1))
	SZ5->(DbSetOrder(1))
	If INCLUI
		RecLock("SZ4", .T.)
		SZ4->Z4_CODDES 		:=  M->Z4_CODDES
		SZ4->Z4_CPFBEN 		:=  M->Z4_CPFBEN
		SZ4->Z4_NOMBEN 		:=  M->Z4_NOMBEN
		SZ4->Z4_CODCORR 	:=  M->Z4_CODCORR
		SZ4->Z4_NOMCORR 	:=  M->Z4_NOMCORR
		SZ4->Z4_DATA 			:=  M->Z4_DATA
		SZ4->Z4_STATUS 		:=  M->Z4_STATUS
		SZ4->(MsUnlock())
		If lRet
			For nLinha := 1 to Len(aCols) // Pecorre o acols
				If !aCols[nLinha][9] //se a possição [9] for .F. vai executar o RecLock Abaixo


					RecLock("SZ5", .T.)
					SZ5->Z5_CODDES := M->Z4_CODDES
					SZ5->Z5_ITEM  	:=	aCols[nLinha][nPosItem]
					SZ5->Z5_DESCRI 	:=	aCols[nLinha][nPosDesc]
					SZ5->Z5_DATAD 	:=	aCols[nLinha][nPosDt]
					SZ5->Z5_PRECO 	:= 	aCols[nLinha][nPosPreco]
					SZ5->Z5_QUANT 	:=	aCols[nLinha][nPosQtd]
					SZ5->Z5_VALOR 	:= 	aCols[nLinha][nPosTotal]
					SZ5->Z5_TIPO 		:= 	aCols[nLinha][nPosTpDesc]
					SZ5->Z5_OBS 		:= 	aCols[nLinha][nPosObs]
					SZ5->(MsUnlock())
					ConfirmSX8()
				EndIf
			Next nLinha

		EndIf

	ElseIf ALTERA
		RecLock("SZ4", .F.)
		SZ4->Z4_CODDES 		:=  M->Z4_CODDES
		SZ4->Z4_CPFBEN 		:=  M->Z4_CPFBEN
		SZ4->Z4_NOMBEN 		:=  M->Z4_NOMBEN
		SZ4->Z4_CODCORR 	:=  M->Z4_CODCORR
		SZ4->Z4_NOMCORR 	:=  M->Z4_NOMCORR
		SZ4->Z4_DATA 			:=  M->Z4_DATA
		SZ4->Z4_STATUS 		:=  M->Z4_STATUS
		SZ4->(MsUnlock())

		For nLinha := 1 to Len(aCols)
			If SZ4->(DbSeek(xFilial("SZ4")+ M->Z4_CODDES)) .AND. SZ5->(DbSeek(xFilial("SZ5")+ M->Z4_CODDES + aCols[nLinha][nPosItem])) // verifica se ta pocisionado no registro da SZ4 E SZ5
				IF  aCols[nLinha][9] // se a possisão [9] tiver marcada como .T. vai fazer o RecLock abaixo
					RecLock("SZ5", .F.)
					SZ5->(DbDelete()) //deleta
					SZ5->(MsUnlock()) //Libera o Registro
				Else
					RecLock("SZ5", .F.) // Reclock de Alteração
					SZ5->Z5_CODDES 	:= M->Z4_CODDES
					SZ5->Z5_ITEM  	:=	aCols[nLinha][nPosItem]
					SZ5->Z5_DESCRI 	:=	aCols[nLinha][nPosDesc]
					SZ5->Z5_DATAD 	:=	aCols[nLinha][nPosDt]
					SZ5->Z5_PRECO 	:= 	aCols[nLinha][nPosPreco]
					SZ5->Z5_QUANT 	:=	aCols[nLinha][nPosQtd]
					SZ5->Z5_VALOR 	:= 	aCols[nLinha][nPosTotal]
					SZ5->Z5_TIPO 		:= 	aCols[nLinha][nPosTpDesc]
					SZ5->Z5_OBS 		:= 	aCols[nLinha][nPosObs]
					SZ5->(MsUnlock())
				EndIf
			Else
				IF !aCols[nLinha][9]
					RecLock("SZ5", .T.) // RecLock de Inclusão
					SZ5->Z5_CODDES 	:= M->Z4_CODDES
					SZ5->Z5_ITEM  	:=	aCols[nLinha][nPosItem]
					SZ5->Z5_DESCRI 	:=	aCols[nLinha][nPosDesc]
					SZ5->Z5_DATAD 	:=	aCols[nLinha][nPosDt]
					SZ5->Z5_PRECO 	:= 	aCols[nLinha][nPosPreco]
					SZ5->Z5_QUANT 	:=	aCols[nLinha][nPosQtd]
					SZ5->Z5_VALOR 	:= 	aCols[nLinha][nPosTotal]
					SZ5->Z5_TIPO 		:= 	aCols[nLinha][nPosTpDesc]
					SZ5->Z5_OBS 		:= 	aCols[nLinha][nPosObs]
					SZ5->(MsUnlock())
				EndIf
			EndIf
		Next nLinha
	Else // se nao for Inclusão ou Alteração vai Executar a linha abaixo
		If DELETA // se for Deleta vai executar a linha abaixo
			If SZ4->(DbSeek(xFilial("SZ4")+ M->Z4_CODDES)) .AND. SZ5->(DbSeek(xFilial("SZ5")+ M->Z4_CODDES)) // Posiciona no Registro
				For nLinha := 1 to Len(aCols) //Pecorre a quantidade que tiver no aCols
					If SZ5->(DbSeek(xFilial("SZ5")+ M->Z4_CODDES)) //Posiciona no registro da SZ5 que estiver no conteudo na memoria da sz4
						RecLock("SZ4", .F.)
						SZ4->(DbDelete())
						SZ4->(MsUnlock())
						RecLock("SZ5", .F.)
						SZ5->(DbDelete())
						SZ5->(MsUnlock())
					EndIf
				Next nLinha
			EndIf
		EndIf
	EndIf

Return lRet
//--------------------------------------------------------------------------------
   /*/{Protheus.doc} PIFINL01
	Validação para ver se ta tudo OK na Linha
	@author Ini Elio Matheus
	@since 15/04/2026
	@type function
   /*/
//--------------------------------------------------------------------------------
User Function PIFINL01()

	Local lRet 				:= .T.
	//Local nPosItem 		:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_ITEM"})
	Local nPosDesc 		:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_DESCRI"})
	Local nPosQtd 		:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_QUANT"})
	Local nPosPreco 	:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_PRECO"})
	Local nPosDt 			:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_DATAD"})
	Local nPosTpDesc 	:= aScan(aItens, {|x| AllTrim(x[2]) == "Z5_TIPO"})
	Local aCols       := OGETDAD:ACOLS
	Local dDataItem        := aCols[n][nPosDt]
	Local nMesComp         := 0
	Local nAnoComp         := 0

	SZ3->(DbSetOrder(4))

	If Empty(Alltrim(aCols[n][nPosDesc])) .OR. aCols[n][nPosQtd] == 0 .OR.;
			aCols[n][nPosPreco] == 0 .OR. Empty(aCols[n][nPosTpDesc])
		lRet := .F.
		FWAlertError("Existe campos a serem preenchidos, favor verificar","Atenção")
	EndIf
	If lRet
		If !Empty(M->Z4_DATA) .And. Len(M->Z4_DATA) >= 7
			nMesComp := Val(SubStr(M->Z4_DATA, 1, 2))
			nAnoComp := Val(SubStr(M->Z4_DATA, 3, 4))

			If Month(dDataItem) <> nMesComp .Or. Year(dDataItem) <> nAnoComp
				FWAlertError("Data fora da competência, Favor verificar", "Atenção")
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If !SZ3->(DbSeek(xFilial("SZ3")+ M->Z4_CODCORR + M->Z4_CPFBEN))
		lRet := .F.
		FWAlertError("Beneficiario não vinculado ao correntista, favor verificar", "Atenção")
	EndIf
Return lRet
//--------------------------------------------------------------------------------
   /*/{Protheus.doc} PIVCPT
	Valida a Competencia: Não permite Mes/ano futuro
	Permite meses atual ou passados
	@author Ini Elio Matheus
	@since 15/04/2026
	@type function
   /*/
//--------------------------------------------------------------------------------
User Function PIVCPT()

	Local lRet         	:= .T.
	Local nMesComp     	:= 0
	Local nAnoComp     	:= 0
	Local dAtual        := Date()
	Local nMesAtual    	:= Month(dAtual)
	Local nAnoAtual    	:= Year(dAtual)

	SZ4->(DbSetOrder(2))
	If !Empty(M->Z4_DATA) .And. Len(M->Z4_DATA) >= 7
		nMesComp := Val(SubStr(M->Z4_DATA, 1, 2))
		nAnoComp := Val(SubStr(M->Z4_DATA, 3, 4))
	EndIf
	If nAnoComp > nAnoAtual
		lRet := .F.
		FWAlertError("Ano da competência não pode ser maior que o ano atual, favor verificar", "Atenção")
	ElseIf nAnoComp == nAnoAtual .And. nMesComp > nMesAtual
		lRet := .F.
		FWAlertError("Mês da competência não pode ser maior que o mês atual, favor verificar", "Atenção")
	EndIf
	If INCLUI
		If SZ4->(DbSeek(xFilial("SZ4") + M->Z4_CPFBEN + M->Z4_CODCORR)) .And. M->Z4_DATA == SZ4->Z4_DATA
			lRet := .F.
			FWAlertError("Não pode existir uma nova movimentação na competência atual," + CRLF + CRLF+;
				"ja existe uma movimentação feita para o beneficiario atual,"+ CRLF + CRLF+;
				"Favor verificar", "Atenção")
		EndIf
	EndIf
Return lRet
//--------------------------------------------------------------------------------
/*/{Protheus.doc} PIFINT01
Função de gatilho para fazer calculo de quantidade X Preço
@type function
@version  1.0 
@author INI Elio Matheus
@since 16/04/2026
/*/
//--------------------------------------------------------------------------------
User Function PIFINT01()

	Local lRet             := .T.
	Local nPosQtd          := aScan(aItens, {|x| AllTrim(x[2]) == "Z5_QUANT"})
	Local nPosPreco        := aScan(aItens, {|x| AllTrim(x[2]) == "Z5_PRECO"})
	Local nPosTotal        := aScan(aItens, {|x| AllTrim(x[2]) == "Z5_VALOR"})
	LOcal nColPos    		   := oGetDad:oBrowse:nColPos //&(ReadVar())
	Local aCols            := OGETDAD:ACOLS
	Local nQtd             := 0
	Local nPreco           := 0

	nQtd := aCols[n][nPosQtd]
	nPreco := aCols[n][nPosPreco]

	If nColPos == nPosQtd
		nQtd := &(ReadVar())
	ElseIf nColPos == nPosPreco
		nPreco := &(ReadVar())
	Else
		nPreco := aCols[n][nPosPreco]
		nQtd := aCols[n][nPosQtd]
	EndIf

	aCols[n][nPosTotal] := nQtd * nPreco
	oGetDad:Refresh()
Return lRet
//--------------------------------------------------------------------------------
/*/{Protheus.doc} PIFINTOK
Função para Validar se esta tudo ok para fazer a Inclusão.
@type function
@version 1.0
@author INI Elio Matheus 
@since 17/04/2026
/*/
//--------------------------------------------------------------------------------
User Function PIFINTOK()
	Local lRet 				:= .F.
	Local aCols       := OGETDAD:ACOLS
	Local nLinha 			:= 0

	If INCLUI .Or. ALTERA
		For nLinha := 1 to len(acols)
			If !aCols[nLinha][9]
				lRet := .T.
			EndIf
		Next nLinha
		If lRet == .F.
			FWAlertError("Tem que haver ao menos 1 Item para poder salvar, favor verificar", "Atenção")
		EndIf
	ELse
		lRet := .T.
	Endif
Return lRet

User Function PIFINAR1(cAlias, nReg, nOpc)
	Local lRet := .F.
	Local nTotal := 0

	SZ4->(DbSetOrder(1))
	SZ5->(DbSetOrder(1))
	If nOpc == 8
		If SZ4->(DbSeek(xFilial("SZ4") + SZ4->Z4_CODDES))
			If FWAlertYesNo("Deseja Reprovar essa despesa?", "Reprovar despesa " + SZ4->Z4_CODDES)
				RecLock("SZ4", .F.) // Reclock de Alteração
				SZ4->Z4_STATUS := "R"
				SZ4->(MsUnlock())
				lRet := .T.
			EndIf
		EndIf
	ElseIf nOpc == 7
		If SZ5->(dbSeek(xFilial("SZ5") + SZ4->Z4_CODDES))
			While ! SZ5->(Eof()) .And. SZ5->Z5_FILIAL == xFilial("SZ5") .And. SZ5->Z5_CODDES == SZ4->Z4_CODDES
				nTotal += SZ5->Z5_VALOR
				SZ5->(dbSkip())
			EndDo
			Alert("o Valor total é " + TransForm(nTotal, "@E 999,999,999.99"))
		EndIf
	EndIf
Return lRet
