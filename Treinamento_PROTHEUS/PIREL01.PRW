#Include "Protheus.ch"
#INCLUDE 'TOTVS.CH'

//Função para a criação do Relatorio 
User Function PIREL01()
	Local nValor := SZ2->Z2_VALOR
	Local cHisto := SUBSTR( SZ2->Z2_HIST, 1 , 2550 ) // Função para falar o inicio de caracteres e o FIM
// Variavel para fazer a quebra de linha
	Local nx := 0
	Local cMemo := 0
	Local nTamanho := MLCount(Alltrim((cHisto)),70)
	Local	nLinha := 470
	Local oFont1 := NIL
	Local oFont2 := NIL

	Private oPrinter := NIL

	oFont1 := TFont():New( "", ,-36,, .T.) // Definindo o Tamanho da Fonte 01
	oFont2 := TFont():New( "", ,-16,, .F.) // Definindo o Tamanho da Fonte 02

	oPrinter := FWMsPrinter():New("Teste",6,.F.,,.T.) // Estou decalrando no meu Objeto a Função FWMsPrinter -> Impressão de PDF
	oPrinter:SetResolution() // Estou setando a Resolução que por padrao é 72
	oPrinter:SetPortrait() // Delcarando que vai vim no modo Retrato
	oPrinter:SetPaperSize(9) // Declarando a opção 9 para sair no modo de A4
	oPrinter:SetMargin(50,50,50,50) // Setei as margens
	oPrinter:StartPage() // Iniciando a Paginaw

	oPrinter:Box(30,10,830,555) // Montando a caixa (Espaço lateral,Espaço de altura,, Tamano altura, Tamano Lateral)
	oPrinter:Box(130,10,280,400) // Caixa para a Imagem
	oPrinter:SayBitmap(130,405, "C:\TOTVS\ERP\Protheus_Data\system\newlogo.png", 150, 150)// Imagem, Tamnaho e definição em pixel

//TITULO
	oPrinter:Say( 80,78,"Comprovante de Transação",oFont1,, )
	oPrinter:Line( 130, 10, 130, 555,)// Linha do Texto acima
//	COMPROVANTE DE DEBITO OU CREDITO 
	oPrinter:Say( 158,11,"Comprovante de: " + IIf(SZ2->Z2_MOVIMEN == "C", "Credito","Debito"),oFont2,, )
	oPrinter:Line( 160, 10, 160,400,)// Linha do Texto acima
// Data da Movimentação
	oPrinter:Say( 188,11,"Data da Transação: " + dToC(SZ2->Z2_DATAMOV),oFont2,, )
	oPrinter:Line( 190, 10, 190, 400,)// Linha do Texto acima
// Nome do Correntista
	oPrinter:Say( 218,11,"Nome: " + SZ2->Z2_NOME,oFont2,, )
	oPrinter:Line( 220, 10, 220, 400,)// Linha do Texto acima
	// Cod Do Correntista
	oPrinter:Say( 248,11,"Correntsita:"  + SZ2->Z2_CORRENT,oFont2,, )
	oPrinter:Line( 250, 10, 250, 400,)// Linha do Texto acima
// Banco 
	oPrinter:Say( 278,11,"Banco: "  + SZ2->Z2_BANCO,oFont2,, )
	oPrinter:Line( 280, 10, 280, 555,)// Linha do Texto acima
// Agencia 
	oPrinter:Say( 308,11,"Agência: "  + SZ2->Z2_AGENCIA,oFont2,, )
	oPrinter:Line( 310, 10, 310, 555,)// Linha do Texto acima
// Conta 
	oPrinter:Say( 338,11,"Conta: "  + SZ2->Z2_CONTA,oFont2,, )
	oPrinter:Line( 340, 10, 340, 555,)// Linha do Texto acima
// Digito da Conta 
	oPrinter:Say( 368,11,"Digito Conta: "  + SZ2->Z2_DGCNTA,oFont2,, )
	oPrinter:Line( 370, 10, 370, 555,)// Linha do Texto acima
// Valor do Movimento 
	oPrinter:Say( 398,11,"Valor: " + MoedaBR(nValor),oFont2,,)
	oPrinter:Line( 400, 10, 400, 555,) // Linha do Texto acima
//Status 
	oPrinter:Say( 428,11,"Status: "  + SZ2->Z2_STATUS,oFont2,, )
	oPrinter:Line( 430, 10, 430, 555,)// Linha do Texto acima
//Historico da Movimentação 
	oPrinter:Say( 450,190,"Histórico de movimento: ",oFont2,, )
	//Função para fazer quebra de linha
	For nx := 1 To nTamanho // For para pecorrer meu Nx que começa em 1 e termina no nTamanho

		cMemo := Memoline(Alltrim((cHisto)),70,nx,,.T.) // o cMemo recebe a variavel Momoline e utilizo o Alltrim para remover espaço em branco da Direita
		oPrinter:Say(nLinha,12,cMemo,oFont2) // Impreção do meu memo o 12 é o " Espaço da linha lateral"
		nLinha += 10 // Para cada quebra de linha vai aumentar mias 10 no meu nLinha

	Next nx // Volta para o FOR

	Oprinter:EndPage() // Terminando a Impressão
	Oprinter:Print() //Imprimindo

Return
// Função para fazer a Conversao do Valor
Static Function MoedaBR(nValor) // Declarando a Função e chamando a variavel
Return ("R$ " + (Transform(nValor,"@E 999,999,999.99"))) // Fazendo a transformação e inserindo a mascara.
