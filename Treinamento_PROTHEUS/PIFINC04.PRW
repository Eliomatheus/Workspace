// Bibliotecas 
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.ch"

User Function PIFINC04() // Função para a Criação da Tela Benificiario

	Local oBrowse
	Private aRotina :=MenuDef()
	private ccadastro := 'Benificiario'
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZ3")
	oBrowse:SetDescription('Cadastro de Benificiario')
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotin := {} // Variavel decalrada para passar as opções do Outras Ações, Variavel vai receber as Arreys

	aAdd(aRotin, {'Pesquisar'  , 'AxPesqui'  ,0  ,1})
	aAdd(aRotin, {'Visualizar' , 'U_PIFINC4B'  ,0  ,2})
	aAdd(aRotin, {'Incluir'    , 'U_PIFINC4B',0  ,3})
	aAdd(aRotin, {'Alterar'    , 'U_PIFINC4B',0  ,4})
	aAdd(aRotin, {'Excluir'    , 'U_PIFINC4B',0  ,5})


return aRotin
/*/{Protheus.doc} PIFINC4B
Função que faz a criação da tela e suas funcionalidades.
@type function
@version  12
@author Ponto Ini Elio Matheus
@since 10/04/2026
@param cAlias, character, param_description
@param nReg, numeric, param_description
@param nOpc, numeric, param_description
@return variant, return_description
/*/
User Function PIFINC4B(cAlias,nReg,nOpc)

	Local aButtons	:= {}
	Local aPosObj	:= {}
	Local oDlg		:= Nil
	Local oMsmGet	:= Nil
	Local aCabP24	:= {}
	Local cIniCpos  := ('+Z3_ITEM')
	Local aAlter	:= IIF (INCLUI .Or. ALTERA,{"Z3_ITEM","Z3_NOMFI","Z3_CGCFI","Z3_DTNASC","Z3_SEXO","Z3_PROFI","Z3_USUARIO","Z3_EMAIL"},{})

	Private oGetDad	:= Nil
	Private INCLUI 	:= nOpc == 3
	Private ALTERA	:= nOpc == 4
	Private aCols	:= {}
	Private aHeader := {}
	Private aTela[0][0]
	Private aGets[0]

	//--Coloca as variaveis na mémoria*/
	RegToMemory("SZ3",IIF(nOpc == 3,.T.,.F.))
	//--Carrega aHeader e array com as informações do cabeçalhp*/
	FCarreAcols('SZ3',@aCabP24,@aHeader)
	//--Carrega grid
	FCarreGrid('SZ3',nReg,nOpc)

    /* Define resolução Tela*/
	aSize := MsAdvSize(.T.)
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	aObjects := {}
	AADD(aObjects,{20,20,.T.,.T.})
	AADD(aObjects,{80,80,.T.,.T.})
	aPosObj := MsObjSize(aInfo,aObjects,.T.,.F.)

	//--Tela
	Define MsDialog oDlg Title cCadastro From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel  //Esta linha cria a janela principal (o "pop-up" ou tela que vai abrir para o usuário).
	oMsmGet := MsmGet():New("SZ3",nReg,nOpc,,,,aCabP24,aPosObj[1],,,,,,oDlg,,.T.,,,,,,,,,)
	oGetDad	:= MsNewGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],nOpc, "U_PIVLIN()","ALLWAYSTRUE",cIniCpos,aAlter,,9999,,,,oDlg,@aHeader,@aCols,,)

	//oMsmGet:oBox:Align := CONTROL_ALIGN_TOP
	//oGetDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
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
	Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,{|| IIF(Obrigatorio(aGets,aTela) .AND. oGetDad:TudoOk(),(PIFIAD1(),oDlg:End()),.F.)},{|| RollBackSx8(),oDlg:End()},,aButtons))
Return(Nil)

///// 

/*/{Protheus.doc} FCarreAcols6
Função para carregar as colunas do grid  
@type function
@version  
@author TONINI
@since 3/19/2024
@param cTab, character, param_description
@param aCabP24, array, param_description
@param aHeader, array, param_description
@return variant, return_description
/*/
Static Function FCarreAcols(cTab, aCabP24, aHeader)

	Local cCampCab	:= 'Z3_CORRENT|Z3_NOME|Z3_CPF'
	Local cCampIte	:= 'Z3_ITEM|Z3_NOMFI|Z3_CGCFI|Z3_DTNASC|Z3_SEXO|Z3_PROFI|Z3_USUARIO|Z3_EMAIL'
	Local aStru := {}
	Local nXi := 0

	aStru := FWSX3Util():GetListFieldsStruct( 'SZ3', .T. )

	For nXi := 1 to Len(aStru)
		If (Alltrim(AllTrim(aStru[nXi][1])) $ cCampCab)
			AAdd(aCabP24,{GETSX3CACHE(aStru[nXi][1],"X3_TITULO"),GETSX3CACHE(aStru[nXi][1],"X3_CAMPO"),GETSX3CACHE(aStru[nXi][1],"X3_TIPO"),GETSX3CACHE(aStru[nXi][1],"X3_TAMANHO"),GETSX3CACHE(aStru[nXi][1],"X3_DECIMAL"),GETSX3CACHE(aStru[nXi][1],"X3_PICTURE"),&(GETSX3CACHE(aStru[nXi][1],"X3_VLDUSER")),;
				IIf(AllTrim(GETSX3CACHE(aStru[nXi][1],"X3_OBRIGAT"))<>"",.T.,.F.),GETSX3CACHE(aStru[nXi][1], "X3_NIVEL"),GETSX3CACHE(aStru[nXi][1],"X3_RELACAO"),GETSX3CACHE(aStru[nXi][1],"X3_F3"),&(GETSX3CACHE(aStru[nXi][1],"X3_WHEN")),;
				IIf(AllTrim(GETSX3CACHE(aStru[nXi][1],"X3_VISUAL"))=="V",.T.,.F.),.F.,GETSX3CACHE(aStru[nXi][1],"X3_CBOX"),Val(GETSX3CACHE(aStru[nXi][1],"X3_FOLDER")),;
				IIf(AllTrim(GETSX3CACHE(aStru[nXi][1],"X3_CONTEXT"))=="V",.T.,.F.),GETSX3CACHE(aStru[nXi][1],"X3_PICTVAR"),GETSX3CACHE(aStru[nXi][1],"X3_TRIGGER")})
		EndIf
	Next nXi

	For nXi := 1 to Len(aStru)
		If (Alltrim(aStru[nXi][1]) $ cCampIte)
			AAdd(aHeader,{GETSX3CACHE(aStru[nXi][1],"X3_TITULO"),Alltrim(GETSX3CACHE(aStru[nXi][1],"X3_CAMPO")),GETSX3CACHE(aStru[nXi][1],"X3_PICTURE"),GETSX3CACHE(aStru[nXi][1],"X3_TAMANHO"),GETSX3CACHE(aStru[nXi][1],"X3_DECIMAL"),GETSX3CACHE(aStru[nXi][1],"X3_VALID"),;
				GETSX3CACHE(aStru[nXi][1],"X3_USADO"),GETSX3CACHE(aStru[nXi][1],"X3_TIPO"),GETSX3CACHE(aStru[nXi][1],"X3_F3"),GETSX3CACHE(aStru[nXi][1],"X3_CONTEXT"),GETSX3CACHE(aStru[nXi][1],"X3_CBOX"),GETSX3CACHE(aStru[nXi][1],"X3_RELACAO"),GETSX3CACHE(aStru[nXi][1],"X3_WHEN"),;
				GETSX3CACHE(aStru[nXi][1],"X3_VISUAL"),GETSX3CACHE(aStru[nXi][1],"X3_VLDUSER"),GETSX3CACHE(aStru[nXi][1],"X3_PICTVAR"),GETSX3CACHE(aStru[nXi][1],"X3_BROWSE"),GETSX3CACHE(aStru[nXi][1],"X3_OBRIGAT")})
		EndIf
	Next nXi
Return(Nil)

/*/{Protheus.doc} FCarreGrid
description
@type function
@version  
@author TONINI
@since 3/19/2024
@param cAlias, character, param_description
@param nReg, numeric, param_description
@param nOpc, numeric, param_description
@return variant, return_description
/*/
Static Function FCarreGrid(cAlias,nReg,nOpc)

	Local aAreaAll	:= {SZ3->(GetArea()),GetArea()}

	Local xI := 0

	If	nOpc <> 3 // nOpc tem que ser diferente de 3
		(cAlias)->(dbSetOrder(1))
		If (cAlias)->(dbSeek(xFilial("SZ3") + Avkey(M->Z3_CORRENT,'Z3_CORRENT'))) // verifica se existe chave e o avkey é para formatar o Z3_CORRENT para o mesmo tamanho do campo 'Z3_CORRENT'
			Do While (cAlias)->(!EoF()) .And. (cAlias)->Z3_FILIAL == xFilial("SZ3") .And. (cAlias)->Z3_CORRENT == M->Z3_CORRENT // cAlias == Tabela foi declarado no parametro FCarreGrid que foi o SZ3,
				//enquanto SZ3 TIVER NO FINAL E SZ3 PONTERADO NA Z3FILIAL IGUAL A XFILIAL SZ3 E CFILIAL PONTERANDO Z3CORRENT IGUAL A MEMORIA DO Z3_CORRENT FOR VERDADEIRA VAI PARA A PROXIMA LINAH DE CODIGO
				//--Monta o aCols no tamanho do meu aHeader
				AADD(aCols,Array(Len(aHeader) + 1))
				aCols[Len(aCols)][Len(aHeader) + 1] := .F.
				For xI := 1 To Len(aHeader) // XI COMEÇA A PARTIR DA PRIMEIRA POSIÇÃO E O LEN FALA A QUANTIDADE QUE O FOR VAI PECORRER
					If aHeader[xI][10] == "V"
						aCols[len(aCols)][xI] := CriaVar(aHeader[xI][2],.T.)
					Else // SE NAO
						aCols[len(aCols)][xI] := SZ3->(FieldGet(FieldPos(aHeader[xI][2]))) //
					EndIf
				Next xI
				(cAlias)->(dbSkip())
			EndDo
		EndIf
		//Carrega campos virtuais
		DbSelectArea('SZ0')
		SZ0->(DbSetOrder(1))
		If SZ0->(DbSeek(xFilial("SZ0")+M->Z3_CORRENT))
			M->Z3_NOME := SZ0->Z0_NOME
			M->Z3_CPF := SZ0->Z0_CPF
		EndIf
	EndIf

	AEVal(aAreaAll,{|x|RestArea(x)})

Return(Nil)


/*/{Protheus.doc} PIFIAD1
Validação para poder fazer Inclusão, alteração e exclusão de registros
@type  function
@version  12.0
@author Ponto ini Elio Matheus
@since 10/04/2026
/*/
Static Function PIFIAD1()
// aScan para saber a possição de cada campo solicitado
	Local aCols := OGETDAD:ACOLS
	Local nPosItem := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_ITEM"})
	Local nPosNome := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_NOMFI"})
	Local nPosCgc := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_CGCFI"})
	Local nPosDt := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_DTNASC"})
	Local nPosSexo := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_SEXO"})
	Local nPosProf := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_PROFI"})
	Local nPosUser := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_USUARIO"})
	Local nPosEmail := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_EMAIL"})
	Local nLinha := 0

	SZ3->(DbSetOrder(3))

	// Validção para fazer inclusão
	If INCLUI
		For nLinha := 1 to Len(aCols)
			If !aCols[nLinha][9]
				RecLock("SZ3", .T.)
				SZ3->Z3_CORRENT :=  M->Z3_CORRENT
				SZ3->Z3_NOME 		:=  M->Z3_NOME
				SZ3->Z3_CPF 		:=  M->Z3_CPF
				SZ3->Z3_ITEM  	:=	aCols[nLinha][nPosItem]
				SZ3->Z3_NOMFI 	:=	aCols[nLinha][nPosNome]
				SZ3->Z3_CGCFI 	:=	aCols[nLinha][nPosCgc]
				SZ3->Z3_DTNASC 	:= 	aCols[nLinha][nPosDt]
				SZ3->Z3_SEXO 		:=	aCols[nLinha][nPosSexo]
				SZ3->Z3_PROFI 	:= 	aCols[nLinha][nPosProf]
				SZ3->Z3_USUARIO := 	aCols[nLinha][nPosUser]
				SZ3->Z3_EMAIL 	:= 	aCols[nLinha][nPosEmail]
				SZ3->(MsUnlock())
			EndIf
		Next nLinha
		// Validção para fazer alteração
	ElseIf ALTERA
		For nLinha := 1 to Len(aCols)
			If SZ3->(DbSeek(xFilial("SZ3")+ M->Z3_CORRENT + aCols[nLinha][nPosItem] + aCols[nLinha][nPosCgc]))
				IF  aCols[nLinha][9]
					RecLock("SZ3", .F.)
					SZ3->(DbDelete())
					SZ3->(MsUnlock())
				Else
					RecLock("SZ3", .F.)
					SZ3->Z3_CORRENT :=  SZ3->Z3_CORRENT
					SZ3->Z3_NOME 		:=  SZ3->Z3_NOME
					SZ3->Z3_CPF 		:=  SZ3->Z3_CPF
					SZ3->Z3_ITEM  	:=	aCols[nLinha][nPosItem]
					SZ3->Z3_NOMFI 	:=	aCols[nLinha][nPosNome]
					SZ3->Z3_CGCFI 	:=	aCols[nLinha][nPosCgc]
					SZ3->Z3_DTNASC 	:= 	aCols[nLinha][nPosDt]
					SZ3->Z3_SEXO 		:=	aCols[nLinha][nPosSexo]
					SZ3->Z3_PROFI 	:= 	aCols[nLinha][nPosProf]
					SZ3->Z3_USUARIO :=	aCols[nLinha][nPosUser]
					SZ3->Z3_EMAIL 	:= 	aCols[nLinha][nPosEmail]
					SZ3->(MsUnlock())
				EndIf
			Else
				RecLock("SZ3", .T.)
				SZ3->Z3_CORRENT :=  M->Z3_CORRENT
				SZ3->Z3_NOME 		:=  M->Z3_NOME
				SZ3->Z3_CPF 		:=  M->Z3_CPF
				SZ3->Z3_ITEM  	:=	aCols[nLinha][nPosItem]
				SZ3->Z3_NOMFI 	:=	aCols[nLinha][nPosNome]
				SZ3->Z3_CGCFI 	:=	aCols[nLinha][nPosCgc]
				SZ3->Z3_DTNASC 	:= 	aCols[nLinha][nPosDt]
				SZ3->Z3_SEXO 		:=	aCols[nLinha][nPosSexo]
				SZ3->Z3_PROFI 	:= 	aCols[nLinha][nPosProf]
				SZ3->Z3_USUARIO :=	aCols[nLinha][nPosUser]
				SZ3->Z3_EMAIL 	:= 	aCols[nLinha][nPosEmail]
				SZ3->(MsUnlock())
			EndIf
		Next nLinha

		// Validação para Excluir registro
	Else
		For nLinha := 1 to Len(aCols)
			If SZ3->(DbSeek(xFilial("SZ3")+ M->Z3_CORRENT + aCols[nLinha][nPosItem] + aCols[nLinha][nPosCgc]))
				RecLock("SZ3", .F.)
				SZ3->(DbDelete())
				SZ3->(MsUnlock())
			EndIf
		Next nLinha
	EndIf
Return

/*/{Protheus.doc} PIVLIN
Validação para verificar se a linha esta correta e poder alterar para proxima ou salvar
@type  function 
@version 12.0
@author Ponto Ini Elio Matheus
@since 10/04/2026
/*/
User Function PIVLIN()
	Local lRet := .T.

	Local nPosNome := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_NOMFI"})
	Local nPosCgc := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_CGCFI"})
	Local nPosDt := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_DTNASC"})
	Local nPosSexo := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_SEXO"})
	Local nPosProf := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_PROFI"})
	Local nPosUser := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_USUARIO"})
	Local nPosEmail := aScan(aHeader, {|x| AllTrim(x[2]) == "Z3_EMAIL"})
	Local nX        := 0
	Local aArray := OGETDAD:ACOLS

// Verificando se os campos não esta em branco 
	SZ0->(DbSetOrder(4))
	If Empty(Alltrim(OGETDAD:ACOLS[n][nPosNome])) .OR. Empty(OGETDAD:ACOLS[n][nPosCgc]) .OR. Empty(OGETDAD:ACOLS[n][nPosDt]) .OR.;
			Empty(OGETDAD:ACOLS[n][nPosSexo]) .OR. Empty(Alltrim(OGETDAD:ACOLS[n][nPosProf])) .OR. Empty(OGETDAD:ACOLS[n][nPosUser]) .OR.;
			Empty(OGETDAD:ACOLS[n][nPosEmail])
		lRet := .F.
		FWAlertError("Existe campos a serem preenchidos, favor verificar","Atenção")
	ELseIf !ChkCPF(OGETDAD:ACOLS[n][nPosCgc]) // Verifica se o CPF é Valido
		lRet := .F.
	ElseIf lRet
		For nX := 1 To Len(aArray)
			If SZ0->(DbSeek(xFilial("SZ0")+ aArray[nX][nPosCgc]))
				lRet := .F.
				FWAlertError("CPF igual de correntista ja cadastrado, Favor verificar ","Atenção")
				Exit
			EndIf
			If nX != n
				If aArray[nX][nPosCgc] == aArray[n][nPosCgc]
					lRet := .F.
					FWAlertError("Não pode repetir o mesmo CPF para o Filho, Favor verificar ","Atenção")
				EndIf
			EndIf
		Next nX
	EndIf

Return lRet
