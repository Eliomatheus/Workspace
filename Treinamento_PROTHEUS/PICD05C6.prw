#include "PROTHEUS.CH"
#include "RWMAKE.CH"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} PICD05C4()    

TELA MODELO 2 TREINAMENTO

@author    .iNi Sistemas - Samuel Colomattre
@since     04/09/2025
@version   P.12
@param     Nenhum
@return    Nenhum
@obs       Nenhum

/*/
//--------------------------------------------------------------------------------

User Function PICD05C6()

	Private oBrowse := Nil
	Private aOutrac := MenuDef()
	Private cTitulo := "Cadastro de Manutenções"
	oBrowse := FWMBrowse():New()
	oBrowse:AddFilter("Tecnico","UNIQUEKEY({'ZZ4_CODTEC'})",.T.,.T.,"ZZ4",,,"Filt01")
	oBrowse:SetAlias("ZZ4")
	oBrowse:SetDescription(cTitulo)
	oBrowse:AddLegend( "ZZ4->ZZ4_APROV == 'P'", "YELLOW",   "Pendente" )
	oBrowse:AddLegend( "ZZ4->ZZ4_APROV == 'A'", "GREEN",    "Aprovado" )
	oBrowse:AddLegend( "ZZ4->ZZ4_APROV == 'R'", "RED"  ,     "Reprovado" )
	oBrowse:Activate()

return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()    

Cria os botões com as funções necessarias

@author    .iNi Sistemas - Samuel Colomattre
@since     04/09/2025
@version   P.12
@param     Nenhum
@return    Nenhum
@obs       Nenhum

/*/
//---------------------------------------------------------------------------------

Static Function MenuDef()

	Local aOutrac := {}

	aAdd(aOutrac, {'Pesquisar'	, 'AxPesqui' ,	  0 ,1})
	aAdd(aOutrac, {'Visualizar'	, 'U_PITLTEC',    0	 ,2})
	aAdd(aOutrac, {'Incluir'	, 'U_PITLTEC',    0	 ,3})
	aAdd(aOutrac, {'Alterar'    , 'U_PITLTEC',    0  ,4})
	aAdd(aOutrac, {'Excluir'	, 'U_PITLTEC',    0	 ,5})

return aOutrac

//--------------------------------------------------------------------------------
/*/{Protheus.doc} PICD05C3()    

Cria a tela 

@author    .iNi Sistemas - Samuel Colomattre
@since     04/09/2025
@version   P.12
@param     Nenhum
@return    Nenhum
@obs       Nenhum

/*/
//---------------------------------------------------------------------------------

Static Function PIFINLE()

	Local aLegenda := {}

	aAdd(aLegenda,{"BR_AMARELO","Pendente"})
	aAdd(aLegenda,{"BR_VERDE","Aprovado"})
	aAdd(aLegenda,{"BR_VERMELHO","Reprovado"})

	BrwLegenda("Cadastro de Serviços", "Legenda", aLegenda)

return

User Function PITLTEC(cAlias, nReg, nOpc)

	Local aPosObj	:= {}
	Local oDlg		:= Nil
	Local oMsmGet	:= Nil
	Local aCabP24	:= {}
	Local cIniCpos  := ('++ZZ5_ITEM')
	Local aButtons	:= {}
	Local aAlter	:= IIF (INCLUI .Or. ALTERA,{"ZZ5_ITEM","ZZ5_CODEQP","ZZ5_DESC","ZZ5_CLIENT","ZZ5_NMCLI","ZZ5_PROB","ZZ5_TPMAN","ZZ5_VLR"},{})
	Private oGetDad	:= Nil
	Private INCLUI 	:= IIF(nOpc == 3,.T.,.F.)
	Private ALTERA	:= IIF(nOpc == 4,.T.,.F.)
	Private DELETE  := IIF(nOpc == 5,.T.,.F.)
	Private aCols	:= {}
	Private aHeader := {}
	Private aTela[0][0]
	Private aGets[0]

	// Colocando a Tabela ZZ3 em memoria
	RegToMemory("ZZ4",IIF(nOpc == 3,.T.,.F.))
	// Carrega as informações do cabeçalho
	PICRACSE('ZZ4',@aCabP24,@aHeader)
	//Carrega as iformações do Grid
	PICRGDBE('ZZ5',nReg,nOpc)

	//Define a resolução da tela
	aSize := MsAdvSize(.T.)
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	aObjects := {}
	AADD(aObjects,{20,20,.T.,.T.})
	AADD(aObjects,{80,30,.T.,.T.})
	aPosObj := MsObjSize(aInfo,aObjects,.T.,.F.)

	//Define as dimenssões da tela atraves do MsDialog
	Define MsDialog oDlg Title cTitulo From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel

	oMsmGet := MsmGet():New("ZZ4",nReg,nOpc,/*aCRA*/,/*cLetras*/,/*cTexto*/,aCabP24,aPosObj[1],,/*nModelo*/,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,;
		oDlg,/*lF3*/,.T.,/*lColumn*/,/*caTela*/,/*lNoFolder*/,/*lProperty*/,/*aField*/,/*aFolder*/,/*lCreate*/,/*lNoMDIStretch*/,/*cTela*/)

	oGetDad	:= MsNewGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],nOpc,,,cIniCpos,aAlter,,9999,,,,oDlg,@aHeader,@aCols,,)

	If nOpc == 4
		oGetDad:lUpdate := IIF(nOpc == 4 ,.T.,oGetDad:lUpdate)
		oGetDad:lInsert := .T.
	ElseIf nOpc == 3 //Inclusão
		oGetDad:lInsert := .T.
	ElseIf nOpc == 2 //Visualização
		oGetDad:lUpdate := .F.
		oGetDad:lInsert := .F.
		oGetDad:ldelete := .F.
	ElseIf nOpc == 5 //Exclusão
		oGetDad:ldelete := .T.
	EndIf

	Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,{|| IIF(Obrigatorio(aGets,aTela) .And. oGetDad:TudoOk(),(CADBENEF(nOpc),oDlg:End()),.F.)},{|| RollBackSx8(),oDlg:End()},,aButtons))

return(Nil)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} PICRACSE()    

Faz a validação e o carregamento do Acols

@author    .iNi Sistemas - Samuel Colomattre
@since     04/09/2025
@version   P.12
@param     Nenhum
@return    Nenhum
@obs       Nenhum

/*/
//---------------------------------------------------------------------------------

Static Function PICRACSE(cTab, aCabP24, aHeader)

	Local aStru1    := {}
	Local aStru2    := {}
	Local Bx       := 0
	Local Bz	   := 0


	aStru1 := FWSX3Util():GetListFieldsStruct( "ZZ4" , .T. )
	aStru2 := FWSX3Util():GetListFieldsStruct( "ZZ5" , .T. )

	For Bx := 1 to Len(aStru1)
		AAdd(aCabP24,{GETSX3CACHE(aStru1[Bx][1],"X3_TITULO"),GETSX3CACHE(aStru1[Bx][1],"X3_CAMPO"),GETSX3CACHE(aStru1[Bx][1],"X3_TIPO"),GETSX3CACHE(aStru1[Bx][1],"X3_TAMANHO"),GETSX3CACHE(aStru1[Bx][1],"X3_DECIMAL"),GETSX3CACHE(aStru1[Bx][1],"X3_PICTURE"),&(GETSX3CACHE(aStru1[Bx][1],"X3_VLDUSER")),;
			IIf(AllTrim(GETSX3CACHE(aStru1[Bx][1],"X3_OBRIGAT"))<>"",.T.,.F.),GETSX3CACHE(aStru1[Bx][1], "X3_NIVEL"),GETSX3CACHE(aStru1[Bx][1],"X3_RELACAO"),GETSX3CACHE(aStru1[Bx][1],"X3_F3"),&(GETSX3CACHE(aStru1[Bx][1],"X3_WHEN")),;
			IIf(AllTrim(GETSX3CACHE(aStru1[Bx][1],"X3_VISUAL"))=="V",.T.,.F.),.F.,GETSX3CACHE(aStru1[Bx][1],"X3_CBOX"),Val(GETSX3CACHE(aStru1[Bx][1],"X3_FOLDER")),;
			IIf(AllTrim(GETSX3CACHE(aStru1[Bx][1],"X3_CONTEXT"))=="V",.T.,.F.),GETSX3CACHE(aStru1[Bx][1],"X3_PICTVAR"),GETSX3CACHE(aStru1[Bx][1],"X3_TRIGGER")})
	Next Bx

	For Bz := 1 to Len(aStru2)
		If Alltrim(GETSX3CACHE(aStru2[Bz][1],"X3_CAMPO")) != "ZZ5_NUMS" .AND. Alltrim(GETSX3CACHE(aStru2[Bz][1],"X3_CAMPO")) != "ZZ5_FILIAL"
			AAdd(aHeader,{GETSX3CACHE(aStru2[Bz][1],"X3_TITULO"),Alltrim(GETSX3CACHE(aStru2[Bz][1],"X3_CAMPO")),GETSX3CACHE(aStru2[Bz][1],"X3_PICTURE"),GETSX3CACHE(aStru2[Bz][1],"X3_TAMANHO"),GETSX3CACHE(aStru2[Bz][1],"X3_DECIMAL"),GETSX3CACHE(aStru2[Bz][1],"X3_VALID"),;
				GETSX3CACHE(aStru2[Bz][1],"X3_USADO"),GETSX3CACHE(aStru2[Bz][1],"X3_TIPO"),GETSX3CACHE(aStru2[Bz][1],"X3_F3"),GETSX3CACHE(aStru2[Bz][1],"X3_CONTEXT"),GETSX3CACHE(aStru2[Bz][1],"X3_CBOX"),GETSX3CACHE(aStru2[Bz][1],"X3_RELACAO"),GETSX3CACHE(aStru2[Bz][1],"X3_WHEN"),;
				GETSX3CACHE(aStru2[Bz][1],"X3_VISUAL"),GETSX3CACHE(aStru2[Bz][1],"X3_VLDUSER"),GETSX3CACHE(aStru2[Bz][1],"X3_PICTVAR"),GETSX3CACHE(aStru2[Bz][1],"X3_BROWSE"),GETSX3CACHE(aStru2[Bz][1],"X3_OBRIGAT")})
		EndIf
	Next Bz

return(Nil)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} PICRACSE()    

Faz a validação e o carregamento do Acols

@author    .iNi Sistemas - Samuel Colomattre
@since     04/09/2025
@version   P.12
@param     Nenhum
@return    Nenhum
@obs       Nenhum

/*/
//---------------------------------------------------------------------------------

Static Function PICRGDBE(cAlias,nReg,nOpc)

	Local aAreaAll	:= {ZZ5->(GetArea()),GetArea()}

	Local xI := 0
	//--Se diferente de Inclusao
	If	nOpc <> 3
		(cAlias)->(dbSetOrder(01))
		If (cAlias)->(dbSeek(xFilial("ZZ5") + Avkey(M->ZZ4_NUMS,'ZZ5_NUMS')))
			Do While (cAlias)->(!EoF()) .And. (cAlias)->ZZ5_FILIAL == xFilial("ZZ5") .And. (cAlias)->ZZ5_NUMS == M->ZZ4_NUMS
				//--Monta o aCols no tamanho do meu aHeader
				AADD(aCols,Array(Len(aHeader) + 1))
				/*Seta o ultimo campo do aCols como .F. para validar a se está deletado*/
				aCols[Len(aCols)][Len(aHeader) + 1] := .F.
				For xI := 1 To Len(aHeader)
					/*Verifica se o campo é virtual, se sim cria variavel na memoria*/ 
					If aHeader[xI][10] == "V"
						aCols[len(aCols)][xI] := CriaVar(aHeader[xI][2],.T.)
					Else
						aCols[len(aCols)][xI] := ZZ5->(FieldGet(FieldPos(aHeader[xI][2])))
					EndIf
				Next xI
				(cAlias)->(dbSkip())
			EndDo
		EndIf
	EndIf

	AEVal(aAreaAll,{|x|RestArea(x)})

Return(Nil)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} PICRACSE()    

Faz a validação sobre o preenchimento do modelo 2 com inclusão alteração e execlusão 

@author    .iNi Sistemas - Samuel Colomattre
@since     04/09/2025
@version   P.12
@param     Nenhum
@return    Nenhum
@obs       Nenhum

/*/
//---------------------------------------------------------------------------------

Static Function CADBENEF(nOpc)

	Local nItem   := aScan(oGetDad:aHeader,{|x| AllTrim(x[2])=='ZZ5_ITEM'})
	Local nCodEqp := aScan(oGetDad:aHeader,{|x| AllTrim(x[2])=='ZZ5_CODEQP'})
	Local nDesceq := aScan(oGetDad:aHeader,{|x| AllTrim(x[2])=='ZZ5_DESC'})
	Local nCodCli := aScan(oGetDad:aHeader,{|x| AllTrim(x[2])=='ZZ5_CLIENT'})
	Local nNmcli  := aScan(oGetDad:aHeader,{|x| AllTrim(x[2])=='ZZ5_NMCLI'})
	Local nProble := aScan(oGetDad:aHeader,{|x| AllTrim(x[2])=='ZZ5_PROB'})
	Local nTpmanu := aScan(oGetDad:aHeader,{|x| AllTrim(x[2])=='ZZ5_TPMAN'})
	Local nVlr    := aScan(oGetDad:aHeader,{|x| AllTrim(x[2])=='ZZ5_VLR'})

	Local nX := 0

	if nOpc == 3

		Reclock('ZZ4',.T.)
		ZZ4->ZZ4_FILIAL   := xFilial('ZZ4')
		ZZ4->ZZ4_NUMS	 := M->ZZ4_NUMS
		ZZ4->ZZ4_CODTEC	 := M->ZZ4_CODTEC
		ZZ4->ZZ4_NOMET   := M->ZZ4_NOMET
		ZZ4->ZZ4_TIPOT   := M->ZZ4_TIPOT
		ZZ4->ZZ4_APROV   := M->ZZ4_APROV
		ZZ4->(MsUnLock())

		For nX := 1 To Len(oGetDad:aCols)
			If !oGetDad:aCols[nX][Len(oGetDad:aCols[nX])] //faz a inversão do campo logico do aCols para realizar de forma correta a inclusão
				if RecLock('ZZ5', .T.)
					ZZ5->ZZ5_FILIAL   := xFilial('ZZ5')
					ZZ5->ZZ5_NUMS := M->ZZ4_NUMS
					Replace &("ZZ5->" + oGetDad:aHeader[nItem][2]) 		With oGetDad:aCols[nX][nItem],; // & faz uma opeção em tempo de execução (faz a função antes de executa - la fazendo assim já seu resultado)
					&("ZZ5->" + oGetDad:aHeader[nCodEqp][2]) 	With oGetDad:aCols[nX][nCodEqp],;
						&("ZZ5->" + oGetDad:aHeader[nDesceq][2]) 	With oGetDad:aCols[nX][nDesceq],;
						&("ZZ5->" + oGetDad:aHeader[nCodCli][2]) 	With oGetDad:aCols[nX][nCodCli],;
						&("ZZ5->" + oGetDad:aHeader[nNmcli][2]) 	With oGetDad:aCols[nX][nNmcli],;
						&("ZZ5->" + oGetDad:aHeader[nProble][2]) 	With oGetDad:aCols[nX][nProble],;
						&("ZZ5->" + oGetDad:aHeader[nTpmanu][2]) 	With oGetDad:aCols[nX][nTpmanu],;
						&("ZZ5->" + oGetDad:aHeader[nVlr][2]) 		With oGetDad:aCols[nX][nVlr]
					ZZ5->(MsUnLock())
					ConfirmSX8()
				Else
					RollBackSx8()
				EndIf
			EndIf
		Next nX
	ElseIf	nOpc == 4

		Reclock('ZZ4',.F.)
		ZZ4->ZZ4_FILIAL   := xFilial('ZZ4')
		ZZ4->ZZ4_NUMS	 := M->ZZ4_NUMS
		ZZ4->ZZ4_CODTEC	 := M->ZZ4_CODTEC
		ZZ4->ZZ4_NOMET   := M->ZZ4_NOMET
		ZZ4->ZZ4_TIPOT   := M->ZZ4_TIPOT
		ZZ4->ZZ4_APROV   := M->ZZ4_APROV
		ZZ4->(MsUnLock())

		ZZ5->(dbSetOrder(01)) //Faz o posicionamento atraves do indice 01 da tabela
		For nX := 1 To Len(oGetDad:aCols) //Faz a verificação se registro está deletado no Grid
			If !oGetDad:aCols[nX][Len(oGetDad:aCols[nX])]
				If ZZ5->(DbSeek(xFilial('ZZ5')+M->ZZ4_NUMS+oGetDad:aCols[nX][nItem]))
					Reclock('ZZ5',.F.)
					ZZ5->ZZ5_FILIAL   := xFilial('ZZ5')
					ZZ5->ZZ5_NUMS := M->ZZ4_NUMS
					&("ZZ5->" + oGetDad:aHeader[nItem][2]) 		:= oGetDad:aCols[nX][nItem]
					&("ZZ5->" + oGetDad:aHeader[nCodEqp][2]) 	:= oGetDad:aCols[nX][nCodEqp]
					&("ZZ5->" + oGetDad:aHeader[nDesceq][2]) 	:= oGetDad:aCols[nX][nDesceq]
					&("ZZ5->" + oGetDad:aHeader[nCodCli][2]) 	:= oGetDad:aCols[nX][nCodCli]
					&("ZZ5->" + oGetDad:aHeader[nNmcli][2]) 	:= oGetDad:aCols[nX][nNmcli]
					&("ZZ5->" + oGetDad:aHeader[nProble][2]) 	:= oGetDad:aCols[nX][nProble]
					&("ZZ5->" + oGetDad:aHeader[nTpmanu][2]) 	:= oGetDad:aCols[nX][nTpmanu]
					&("ZZ5->" + oGetDad:aHeader[nVlr][2]) 		:= oGetDad:aCols[nX][nVlr]
					ZZ5->(MsUnLock())
				Else

					Reclock('ZZ4',.F.)
					ZZ4->ZZ4_FILIAL   := xFilial('ZZ4')
					ZZ4->ZZ4_NUMS	 := M->ZZ4_NUMS
					ZZ4->ZZ4_CODTEC	 := M->ZZ4_CODTEC
					ZZ4->ZZ4_NOMET   := M->ZZ4_NOMET
					ZZ4->ZZ4_TIPOT   := M->ZZ4_TIPOT
					ZZ4->ZZ4_APROV   := M->ZZ4_APROV
					ZZ4->(MsUnLock())

					Reclock('ZZ5',.T.)
					ZZ5->ZZ5_FILIAL := xFilial('ZZ5')
					ZZ5->ZZ5_NUMS := M->ZZ4_NUMS
					&("ZZ5->" + oGetDad:aHeader[nItem][2]) 		:= oGetDad:aCols[nX][nItem]
					&("ZZ5->" + oGetDad:aHeader[nCodEqp][2]) 	:= oGetDad:aCols[nX][nCodEqp]
					&("ZZ5->" + oGetDad:aHeader[nDesceq][2]) 	:= oGetDad:aCols[nX][nDesceq]
					&("ZZ5->" + oGetDad:aHeader[nCodCli][2]) 	:= oGetDad:aCols[nX][nCodCli]
					&("ZZ5->" + oGetDad:aHeader[nNmcli][2]) 	:= oGetDad:aCols[nX][nNmcli]
					&("ZZ5->" + oGetDad:aHeader[nProble][2]) 	:= oGetDad:aCols[nX][nProble]
					&("ZZ5->" + oGetDad:aHeader[nTpmanu][2]) 	:= oGetDad:aCols[nX][nTpmanu]
					&("ZZ5->" + oGetDad:aHeader[nVlr][2]) 		:= oGetDad:aCols[nX][nVlr]
					ZZ5->(MsUnLock())
				EndIf
			Else
				If ZZ5->(DbSeek(xFilial('ZZ5')+M->ZZ4_NUMS+oGetDad:aCols[nX][nItem])) // Faz a busca se o item está deletado no grid
					RecLock('ZZ5', .F.)
					ZZ5->(DbDelete())
					ZZ5->(MsUnLock())
					ZZ5->(DbGotop())
				EndIf
			EndIf
		Next nX
		// Opção exclusão
	ElseIf nOpc == 5
		ZZ4->(dbSetOrder(01))
		For nX:= 1 To Len(oGetDad:aCols)
			If ZZ5->(DbSeek(xFilial('ZZ5')+M->ZZ4_NUMS+oGetDad:aCols[nX][nItem]))
				RecLock('ZZ5', .F.)
				ZZ4->(DbDelete())
				ZZ4->(MsUnLock())
			EndIf
		Next nX
		RecLock('ZZ4', .F.)
		ZZ4->(DbDelete())
		ZZ4->(MsUnLock())
	EndIf

Return(Nil)
