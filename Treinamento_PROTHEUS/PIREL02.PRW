#Include "Protheus.ch"
#INCLUDE 'TOTVS.CH'

//--------------------------------------------------------------------------------
/*/{Protheus.doc} PIREL02
Exibe tela de parâmetros e gera relatório de correntistas utilizando TReport.
Apresenta dados de correntista, banco, agência, conta e saldo da tabela SZ1.
@author    .iNi Sistemas - Joao Tonini
@since     26/09/2024
@version   P.12
@param     Nenhum
@return    Nenhum
@obs       Nenhum
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//--------------------------------------------------------------------------------
User Function PIREL02()

	Local cAliasQry     := GetNextAlias()
	Private cPerg       := "SZFINREL2"
	Private oReport     := Nil
	Private oSection    := Nil


	If Pergunte(cPerg,.T.)
		FReportDef(cAliasQry)
		oReport:PrintDialog()
	EndIf

Return(Nil)
/*/{Protheus.doc} FReportDef
Define a estrutura do relatório de correntistas com TReport e TRSection.
Configura células para exibir correntista, banco, agência, conta, dígito e saldo.
@type function
@version 2410
@author Ponto INI - Elio Matheus
@since 20/04/2026
/*/
Static Function FReportDef(cAliasQry)

	Local cTitulo := "Correntista"

	oReport := TReport():New("Correntista",cTitulo,cPerg,{|oReport| FPrintReport(cAliasQry)},"Relatório de "+cTitulo)
	oReport:ShowParamPage()
	oReport:lParamPage := .F.
	oReport:SetLandscape(.T.)

	oSection := TRSection():New(oReport , "Correntista",cAliasQry,,,,,.T.)

	TRCell():New(oSection, "CORRENTISTA"                     ,cAliasQry,"CORRENTISTA"           ,PesqPict('SZ1','Z1_CORRENT')   ,   12)
	TRCell():New(oSection, "BANCO"                           ,cAliasQry,"BANCO"                 ,PesqPict('SZ1','Z1_BANCO')    ,   TamSx3("Z1_BANCO")[1])
	TRCell():New(oSection, "AGENCIA"                         ,cAliasQry,"AGENCIA"               ,PesqPict('SZ1','Z1_AGENCIA')       ,   TamSx3("Z1_AGENCIA")[1])
	TRCell():New(oSection, "CONTA"                           ,cAliasQry,"CONTA"                 ,PesqPict('SZ1','Z1_CONTA')   ,   TamSx3("Z1_CONTA")[1])
	//TRCell():New(oSection, "MARGEM"                         ,cAliasQry,"Margem")
//	TRCell():New(oSection, "TIPOTAB"                        ,cAliasQry,"TIPOTAB"        ,                               ,   5)
	TRCell():New(oSection, "DIGITO"                           ,cAliasQry,"DIGITO"               ,PesqPict('SZ1','Z1_DGCNT')   ,   TamSx3("Z1_DGCNT")[1])
	TRCell():New(oSection, "SALDO"                        ,cAliasQry,"SALDO"        ,PesqPict('SZ1','Z1_SALDO')    ,   TamSx3("Z1_SALDO")[1])
//	TRCell():New(oSection, "COMISS"                         ,cAliasQry,"COMISS"         ,PesqPict('SC5','C5_COMIS1')    ,   TamSx3("C5_COMIS1")[1])

Return(Nil)
/*/{Protheus.doc} FPrintReport
Executa query SQL na tabela SZ1 e popula o relatório com dados de correntistas.
Percorre os registros e imprime cada linha na seção do relatório.
@type 		function
@version  2410
@author 	Ponto INI - Elio Matheus
@since 20/04/2026
/*/
Static Function FPrintReport(cAliasQry)

	Local cQuery:= ''
	Local lXlsPrnt	:= If(oReport:nDevice == 4,.T.,.F.)

	cQuery := "SELECT Z1_CORRENT AS CORRENTISTA, Z1_BANCO AS BANCO, Z1_AGENCIA AS AGENCIA, Z1_CONTA AS CONTA, Z1_DGCNT AS DIGITO, Z1_SALDO AS SALDO"
//	cQuery += "CASE "
//	cQuery += "WHEN C5_XTABELA = '010' THEN 'MISTA'"
//	cQuery += "ELSE 'FIXA' "
//	cQuery += "END AS TIPOTAB"
	cQuery += CRLF+ "FROM SZ1990 Z1"
	cQuery += CRLF+ "WHERE Z1.D_E_L_E_T_ = ' '"
//cQuery += CRLF+ "INNER JOIN "+RetSqlName("SA1")+" A1 WITH(NOLOCK) ON  A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1.D_E_L_E_T_ = ' '"
//cQuery += CRLF+ "INNER JOIN "+RetSqlName("SA3")+" A3 WITH(NOLOCK) ON  A3_FILIAL = '"+xFilial('SA3')+"' AND A3_COD = C5_VEND1 AND A3.D_E_L_E_T_ = ' '"
//cQuery += CRLF+ "WHERE C5_FILIAL = C5_FILIAL AND C5_NUM = C5_NUM AND C5_EMISSAO BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"' AND C5.D_E_L_E_T_ = ' '"
//cQuery += CRLF+ "ORDER BY VEND"

	DBUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry, .T., .T.)

	If (cAliasQry)->(!Eof())

		oSection:Init()

		While (cAliasQry)->(!Eof())

			oSection:PrintLine()
			oSection:lHeaderSection := !lXlsPrnt
			oReport:IncMeter()
			(cAliasQry)->(DBSkip())
		EndDo
		oSection:Finish()
	Else
		ApMsgAlert("Não existem dados para imprimir com os parâmetros informados!")
	EndIf
	(cAliasQry)->(DBCloseArea())
Return(Nil)
