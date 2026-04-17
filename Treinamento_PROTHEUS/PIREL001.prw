#Include "Protheus.ch"
#Include "TBICONN.ch"
#INCLUDE "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

User Function PIREL01()

	Local nLin := 0
	Local nCol := 0
	Local nAdc := 0
	Local cCorrent := ''
	Local cConta := ''

// Declarando o tamanho das fontes do relatorio
	Local oFont16 := TFont():New('Arial',,-16,  .T.)
	Local oFont12 := TFont():New('Arial',,-12,  .T.)
	Local oFont35 := TFont():New('Arial',,-28,  .T.)

// variavel padrao
	Private oPrinter := NIL
	Private cAliasQry := GetNextAlias()
	PIREL01B()

//definicoes padrao 
	oPrinter := FWMsPrinter():New("Teste",6,.F.,,.T.)
	oPrinter:SetResolution(72)
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(9)
	oPrinter:SetMargin(60,60,60,60)

	oPrinter:lServer := .F.
	oPrinter:lViewPDF := .T.

	oPrinter:StartPage()

// largura total 593
// altura total 876

// fazendo um retangulo com margens 
	oPrinter:Box(40,15,836,550) //linha - coluna - linha final - coluna final
	nLin := 55
	nCol := 50

// For para que ele imprima essa sessao quantas vezes eu quiser

	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->(!Eof())

		If cCorrent != (cAliasQry)->Z0_CODIGO

// Titulo
			fVldPag(@nLin,5)
			oPrinter:Say(nLin+30,130, "Comprovante de Transação",oFont35)
			fVldPag(@nLin,60)

// linha horizontal de ponta a ponta
			oPrinter:Line(nLin, 15, nlin, 550)
			fVldPag(@nLin,20)

// Primeiro bloco de informaçôes

			nAdc:=PIREL01A('Nome: ' + (cAliasQry)->Z0_NOME,40,nLin-6,@nLin,nCol-25,oFont16)
			oPrinter:Line(nLin, 15, nlin, 300)
			oPrinter:Line(nLin-nAdc-20,300,nLin,300)

// Imagem
			oPrinter:SayBitmap(nLin-20-nAdc,301,"/system/img/testeimagem.jpeg",248,60+nAdc)
			nAdc:=0
			fVldPag(@nLin,20)

			oPrinter:Say(nLin-6,nCol-25, "CPF: " + Alltrim(Transform((cAliasQry)->Z0_CPF, "@R 999.999.999-99")),oFont16 )

			oPrinter:Line(nLin-20, 300, nlin, 300)
			oPrinter:Line(nLin, 15, nlin, 300)

			fVldPag(@nLin,20)

			oPrinter:Say(nLin-6,nCol-25, "Codigo: " + (cAliasQry)->Z0_CODIGO,oFont16 )

			oPrinter:Line(nLin-20, 300, nlin, 300)
			oPrinter:Line(nLin, 15, nlin, 300)

			oPrinter:Line(nLin, 300, nlin, 550)
		Endif

		// SESSAO CONTA

//Titulo
		If cConta != (cAliasQry)->Z1_BANCO + (cAliasQry)->Z1_AGENCIA + (cAliasQry)->Z1_CONTA + (cAliasQry)->Z1_DGCNTA
			fVldPag(@nLin,20)
			oPrinter:Say(nLin+10,120, "Conta: " + (cAliasQry)->Z1_CONTA +  space(1) + "Saldo: R$" +ALLTRIM(TRANSFORM((cAliasQry)->Z1_SALDO, '@E  999,999,999.99 ')),oFont35)
			fVldPag(@nLin,20)

			oPrinter:Line(nLin, 15, nlin, 550)

			fVldPag(@nLin,20)

			oPrinter:Line(nLin-20,265,nLin+20,265) // Linha vertical no meio

			oPrinter:Say(nLin-6,nCol-25, "Banco: " + (cAliasQry)->Z1_BANCO,oFont12 )
			oPrinter:Say(nLin-6,nCol+230, "Agencia: " + (cAliasQry)->Z1_AGENCIA,oFont12 )
			oPrinter:Line(nLin, 15, nlin, 550)
			fVldPag(@nLin,20)

			oPrinter:Say(nLin-6,nCol-25, "Conta: " + (cAliasQry)->Z1_CONTA,oFont12 )
			oPrinter:Say(nLin-6,nCol+230, "Digito conta: " + (cAliasQry)->Z1_DGCNTA,oFont12 )

			oPrinter:Line(nLin, 15, nlin, 550)
			fVldPag(@nLin,20)

		Endif

		// SESSAO MOVS

//Titulo
		If !empty((cAliasQry)->Z2_MOVIMEN)
			If cConta != (cAliasQry)->Z1_BANCO + (cAliasQry)->Z1_AGENCIA + (cAliasQry)->Z1_CONTA + (cAliasQry)->Z1_DGCNTA
				oPrinter:Say(nLin+10,180, "Movimentação",oFont35)
				fVldPag(@nLin,20)
			EndIf

			oPrinter:Line(nLin, 15, nlin, 550)
			fVldPag(@nLin,20)

			oPrinter:Say(nLin-6,nCol-25, "Data: " + DToC(STOD((cAliasQry)->Z2_DATAMOV)) ,oFont12 )

// Condiçao para mudar o nome das movimentacoes
			If (cAliasQry)->Z2_MOVIMEN == "D"
				oPrinter:Say(nLin-6,nCol+83, "Tipo: Debito"  ,oFont12 )
			Else
				oPrinter:Say(nLin-6,nCol+83, "Tipo: Credito"  ,oFont12 )
			Endif

// transform para editar o valor da forma correta
			oPrinter:Say(nLin-6,nCol+200, "Valor: R$" + ALLTRIM(TRANSFORM((cAliasQry)->Z2_VALOR, '@E  999,999,999.99 ')),oFont12 )

			//nAdc:= PIREL01A('Historico: ' + Memoline(Alltrim(cAliasQry)->Z2_HIST),25,nLin-6,@nLin,nCol+320,oFont12)
			oPrinter:Line(nLin, 15, nlin, 550)

			oPrinter:Line(nLin-20-nAdc,120,nLin,120) // Linha vertical
			oPrinter:Line(nLin-20-nAdc,240,nLin,240) // Linha vertical
			oPrinter:Line(nLin-20-nAdc,360,nLin,360) // Linha vertical

			nAdc:=0
		Else
			nLin-=20
		Endif

		cCorrent := (cAliasQry)->Z0_CODIGO

		cConta := (cAliasQry)->Z1_BANCO + (cAliasQry)->Z1_AGENCIA + (cAliasQry)->Z1_CONTA + (cAliasQry)->Z1_DGCNTA

		(cAliasQry)->(DBSkip())
	EndDo

	(cAliasQry)->(DBCloseArea())
	Oprinter:EndPage()

	Oprinter:Print()

return



// Funcao para ser utilizada para quebra de paginas
Static Function fVldPag(nLin,nSoma)

	Local nTam := 830

	If (nLin+nSoma) <= nTam
		nLin += nSoma

	Else
		Oprinter:EndPage()
		Oprinter:StartPage()
		oPrinter:Box(40,15,836,550)
		nLin := 55

	Endif
Return


// funcao para quando for necessaria aumentar um espaco no campo ele ficar de forma responsiva
Static Function PIREL01A(nNome,cLen,nLinha,nlin,nCol,oFont)

	Local nQuant := 0
	Local nXXCount := 0
	Local cMemo := 0
	Local nTamanho := 0
	nTamanho := MLCount(Alltrim((nNome)),cLen)
	nQuant:= 0
	nXXCount:= 0

	For nXXCount := 1 To nTamanho

		cMemo := Memoline(Alltrim((nNome)),cLen,nXXCount,,.T.)
		oPrinter:Say(nLinha,nCol,cMemo,oFont)
		nLinha += 10
		nLin += 10
		nQuant++

	Next nXXCount
return nTamanho * 10



// Query para buscar todas as informacoes das tabelas
Static Function PIREL01B()

	Local cQuery := ''

	cQuery += CRLF+ "SELECT "
	cQuery += CRLF+ "Z0_CODIGO, "
	cQuery += CRLF+ "Z0_NOME, "
	cQuery += CRLF+ "Z0_CPF, "
	cQuery += CRLF+ "Z1_SALDO, "
	cQuery += CRLF+ "Z1_CONTA, "
	cQuery += CRLF+ "Z1_BANCO, "
	cQuery += CRLF+ "Z1_AGENCIA, "
	cQuery += CRLF+ "Z1_DGCNTA, "
	cQuery += CRLF+ "Z2_DATAMOV, "
	cQuery += CRLF+ "Z2_MOVIMEN, "
	cQuery += CRLF+ "Z2_VALOR, "
	cQuery += CRLF+ "Z2_HIST "

	cQuery += CRLF+ "FROM "+RetSqlname("SZ0")+" Z0 "

	cQuery += CRLF+ "INNER JOIN "+RetSqlname("SZ1")+" Z1 "
	cQuery += CRLF+ "ON Z1_FILIAL = Z0_FILIAL "
	cQuery += CRLF+ "AND Z1_CORRENT = Z0_CODIGO "
	cQuery += CRLF+ "AND Z1.D_E_L_E_T_ = '' "

	cQuery += CRLF+ "LEFT JOIN "+RetSqlname("SZ2")+" Z2 "
	cQuery += CRLF+ "ON Z2_FILIAL = Z1_FILIAL "
	cQuery += CRLF+ "AND Z2_CORRENT = Z1_CORRENT"
	cQuery += CRLF+ "AND Z2_BANCO = Z1_BANCO "
	cQuery += CRLF+ "AND Z2_AGENCIA = Z1_AGENCIA "
	cQuery += CRLF+ "AND Z2_CONTA = Z1_CONTA "
	cQuery += CRLF+ "AND Z2_DGCNTA   = Z1_DGCNTA "
	cQuery += CRLF+ "AND Z2.D_E_L_E_T_ = '' "

	cQuery += CRLF+ "WHERE Z0_FILIAL = '"+xFilial("SZ0")+"' "
	cQuery += CRLF+ "AND Z0.D_E_L_E_T_ = '' "

	cQuery += CRLF+ "ORDER BY "
	cQuery += CRLF+ "Z0_CODIGO, "
	cQuery += CRLF+ "Z0_NOME, "
	cQuery += CRLF+ "Z0_CPF, "
	cQuery += CRLF+ "Z1_SALDO, "
	cQuery += CRLF+ "Z1_CONTA, "
	cQuery += CRLF+ "Z1_BANCO, "
	cQuery += CRLF+ "Z1_AGENCIA, "
	cQuery += CRLF+ "Z1_DGCNTA, "
	cQuery += CRLF+ "Z2_DATAMOV, "
	cQuery += CRLF+ "Z2_MOVIMEN, "
	cQuery += CRLF+ "Z2_VALOR, "
	cQuery += CRLF+ "Z2_HIST "

	//cQuery := ChangeQuery(cQuery)

	DBUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry, .T., .T.)

	//(cAliasQry)->(DBCloseArea())
return
