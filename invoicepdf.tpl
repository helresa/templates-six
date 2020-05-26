<?php
class BiLang
{ // BEGIN class BiLang
  // variables
  protected $primaryLang;
  protected $secondryLang;
  protected $theSame;
  // constructor
  public function __construct($userLang, $scondry)
  { // BEGIN constructor
    $_LANG = Null ; // this is local
    $this->secondryLang = $userLang ;
// clear $_Lang just in case
$_LANG = Null ;
// now get the secondary lang
include ($scondry);
$this->primaryLang = $_LANG ;
// clear $_Lang just in case
$_LANG = Null ;
// check if they are the same
$this->theSame = $this->primaryLang['locale'] == $this->secondryLang['locale'] ;
} // END constructor
function  getTextHorizontal ($id)
/*
*
*
*  getTextHorizontal ( )
*/
{
if($this->theSame || strpos($this->primaryLang[$id],$this->secondryLang[$id]) !== false)
{
return $this->primaryLang[$id] ;
}
else
{
return $this->primaryLang[$id]."
<small>(". $this->secondryLang[$id] . ")</small>";
}
} // end getTextHorizontal
function  getTextVertical ($id)
/*
*
*
*  getTextVertical ( )
*/
{
if($this->theSame || strpos($this->primaryLang[$id],$this->secondryLang[$id]) !== false)
{
return $this->primaryLang[$id] ;
}
else
{
return $this->primaryLang[$id]."<br/>
<small>(". $this->secondryLang[$id] . ")</small>";
}
} // end getTextVertical
} // END class BiLang
//$_LANG = 'en_GB';
$biLang = new BiLang($_LANG, '/home/ecogeekn/public_html/whmcs/lang/spanish.php');
//$biLang = new BiLang($_LANG, './spanish.php');
$pdf->SetAutoPageBreak(true,1);
# Logo
if (file_exists(ROOTDIR.'/images/logo.png')) $pdf->Image(ROOTDIR.'/images/logo.png',20,25,50);
elseif (file_exists(ROOTDIR.'/images/logo.jpg')) $pdf->Image(ROOTDIR.'/images/logo.jpg',20,25,75);
else $pdf->Image(ROOTDIR.'/images/placeholder.png',20,25,75);
# Invoice Status
$statustext = $biLang->getTextVertical('invoices'.strtolower($status));
$pdf->SetFillColor(223,85,74);
$pdf->SetDrawColor(171,49,43);
if ($status=="Paid") {
$pdf->SetFillColor(151, 223, 74);
$pdf->SetDrawColor(110, 192, 70);
}elseif ($status=="Cancelled") {
$pdf->SetFillColor(200);
$pdf->SetDrawColor(140);
} elseif ($status=="Refunded") {
$pdf->SetFillColor(131, 182, 218);
$pdf->SetDrawColor(91, 136, 182);
} elseif ($status=="Collections") {
$pdf->SetFillColor(3, 3, 2);
$pdf->SetDrawColor(127);
}

$pdf->SetXY(0,0);
$pdf->SetFont('freesans','B',20);
$pdf->SetTextColor(255);
$pdf->SetLineWidth(0.75);
$pdf->StartTransform();
$pdf->Rotate(-35,100,225);
//$pdf->Cell(100,18,strtoupper($statustext),'TB',0,'C','1');
$pdf->writeHTMLCell(100,18,'','',"<p>".strtoupper($statustext)."</p>",'TB',0,1,1,'C','1');
$pdf->StopTransform();
$pdf->SetTextColor(0);
# Company Details
$pdf->SetXY(15,26);
$pdf->SetFont('freesans','',9);
$pdf->Cell(160,4,trim($companyaddress[0]),0,1,'R');
for ( $i = 1; $i < ((count($companyaddress)>6) ? count($companyaddress) : 6); $i += 1) {
$pdf->Cell(160,4,trim($companyaddress[$i]),0,1,'R');
}
if ($taxCode) {
    $pdf->Cell(180, 4, $taxIdLabel . ': ' . trim($taxCode), 0, 1, 'R');
}
$pdf->Ln(5);
# Header Bar
$invoiceprefix = $biLang->getTextHorizontal("invoicenumber");
/*
** This code should be uncommented for EU companies using the sequential invoice numbering so that when unpaid it is shown as a proforma invoice **
if ($status!="Paid") {
$invoiceprefix = $biLang->getTextHorizontal("proformainvoicenumber");
}
*/
$pdf->SetFont('freesans','B',15);
$pdf->SetFillColor(239);
$pdf->writeHTMLCell(0,8,'','',"<p>" .$invoiceprefix." " .$invoicenum."</p>",0,1,1,1,'L','1');
$pdf->SetFont('freesans','',10);
$pdf->writeHTMLCell(0,6,'','',"<p>" .$biLang->getTextHorizontal("invoicesdatecreated").':
    '.$datecreated.''."</p>",0,1,1,1,'L','1');
$pdf->writeHTMLCell(0,6,'','',"<p>" .$biLang->getTextHorizontal("invoicesdatedue").':
    '.$duedate.''."</p>",0,0,1,1,'L','1');
$pdf->Ln(10);
$startpage = $pdf->GetPage();
# Clients Details
$addressypos = $pdf->GetY();
$pdf->SetFont('freesans','B',10);
$pdf->writeHTMLCell(0,4,'','',"<p>" .$biLang->getTextHorizontal("invoicesinvoicedto")."</p>",0,1);
$pdf->SetFont('freesans','',9);
if ($clientsdetails["companyname"]) {
$pdf->Cell(0, 4, $clientsdetails["companyname"], 0, 1, 'L');
$pdf->Cell(0,4,$_LANG["invoicesattn"].": ".$clientsdetails["firstname"]." ".$clientsdetails["lastname"],0,1,'L');
} else {
$pdf->Cell(0, 4, $clientsdetails["firstname"] . " " . $clientsdetails["lastname"], 0, 1, 'L');
}
$pdf->Cell(0, 4, $clientsdetails["address1"], 0, 1, 'L');
if ($clientsdetails["address2"]) {
$pdf->Cell(0, 4, $clientsdetails["address2"], 0, 1, 'L');
}
$pdf->Cell(0, 4, $clientsdetails["city"] . ", " . $clientsdetails["state"] . ", " . $clientsdetails["postcode"], 0, 1, 'L');
$pdf->Cell(0, 4, $clientsdetails["country"], 0, 1, 'L');
if (array_key_exists('tax_id', $clientsdetails) && $clientsdetails['tax_id']) {
    $pdf->Cell(0, 4, $taxIdLabel . ': ' . $clientsdetails['tax_id'], 0, 1, 'L');
}
if ($customfields) {
$pdf->Ln();
foreach ($customfields AS $customfield) {
$pdf->Cell(0, 4, $customfield['fieldname'] . ': ' . $customfield['value'], 0, 1, 'L');
}
}
$pdf->Ln(10);
// handel inclusen of 0 vat on vat exsampt companies for documentation.
if ($clientsdetails["taxexempt"] && ! $taxname) $taxname = "IGIC" ;
# Invoice Items
$tblhtml = '
<table width="100%" bgcolor="#ccc" cellspacing="1" cellpadding="2" border="0">
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;text-align:center;">
        <td colspan="2" width="80%">'.$biLang->getTextVertical('invoicesdescription').'</td>
        <td width="20%">'.$biLang->getTextVertical('quotelinetotal').'</td>
    </tr>
    ';
    foreach ($invoiceitems AS $item) {
    $tblhtml .= '
    <tr bgcolor="#fff">
        <td colspan="2" align="left">'.nl2br($item['description']).'<br/></td>
        <td align="center">' . $item['amount'] . '</td>
    </tr>
    ';
    }
    $tblhtml .= '
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;">
        <td colspan="2" align="right">'.$biLang->getTextHorizontal('invoicessubtotal').'</td>
        <td align="center">' . $subtotal . '</td>
    </tr>
    ';
    if ($taxname) {
    $tblhtml .= '
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;">';
        if ($clientsdetails["taxexempt"])
        {
        $tblhtml .= '
        <td width="70%">
            <small>Sujeto a inversión del sujeto pasivo en el país de recepción (Subject to reverse charge in the
                country of receipt)
            </small>
        </td>
        ';
        }
        else
        {
        $tblhtml .= '
        <td width="70%"></td>
        ';
        }
        $tblhtml .= '
        <td width="10%" align="right">'.$taxrate.'% '.$taxname.'</td>
        <td align="center">' . $tax . '</td>
    </tr>
    ';
    }
    if ($taxname2) $tblhtml .= '
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;">
        <td colspan="2" align="right">'.$taxrate2.'% '.$taxname2.'</td>
        <td align="center">' . $tax2 . '</td>
    </tr>
    ';
    $tblhtml .= '
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;">
        <td colspan="2" align="right">'.$biLang->getTextHorizontal('invoicescredit').'</td>
        <td align="center">' . $credit . '</td>
    </tr>
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;">
        <td colspan="2" align="right">'.$biLang->getTextHorizontal('invoicestotal').'</td>
        <td align="center">' . $total . '</td>
    </tr>
</table>';
$pdf->writeHTML($tblhtml, true, false, false, false, '');
$pdf->Ln(5);
# Transactions
$pdf->SetFont('freesans','B',12);
$pdf->writeHTMLCell(0,4,'','',"<p>" .$biLang->getTextHorizontal("invoicestransactions")."</p>",0,1);
$pdf->Ln(5);
$pdf->SetFont('freesans','',9);
$tblhtml = '
<table width="100%" bgcolor="#ccc" cellspacing="1" cellpadding="2" border="0">
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;text-align:center;">
        <td width="25%">'.$biLang->getTextVertical('invoicestransdate').'</td>
        <td width="25%">'.$biLang->getTextVertical('invoicestransgateway').'</td>
        <td width="30%">'.$biLang->getTextVertical('invoicestransid').'</td>
        <td width="20%">'.$biLang->getTextVertical('invoicestransamount').'</td>
    </tr>
    ';
    if (!count($transactions)) {
    $tblhtml .= '
    <tr bgcolor="#fff">
        <td colspan="4" align="center">'.$biLang->getTextHorizontal('invoicestransnonefound').'</td>
    </tr>
    ';
    } else {
    foreach ($transactions AS $trans) {
    $tblhtml .= '
    <tr bgcolor="#fff">
        <td align="center">' . $trans['date'] . '</td>
        <td align="center">' . $trans['gateway'] . '</td>
        <td align="center">' . $trans['transid'] . '</td>
        <td align="center">' . $trans['amount'] . '</td>
    </tr>
    ';
    }
    }
    $tblhtml .= '
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;">
        <td colspan="3" align="right">'.$biLang->getTextHorizontal('invoicesbalance').'</td>
        <td align="center">' . $balance . '</td>
    </tr>
</table>';
$pdf->writeHTML($tblhtml, true, false, false, false, '');
# Notes
if ($notes) {
$pdf->Ln(5);
$pdf->SetFont('freesans','',8);
$pdf->writeHTMLCell(20,4,'','',"<p>" .$biLang->getTextHorizontal("invoicesnotes").":</p>",0,0);
$pdf->MultiCell(170,5,$notes,0,'L');
}
#Footer Text
$pdf->SetFont('freesans','',7);
$pdf->SetY(-32);
$pdf->SetDrawColor(0,0,0);
$pdf->SetLineWidth(0.4);
$pdf->Cell(0,0,'','T','','C');
$pdf->Ln(1);
$pdf->Cell(180,4,"Banco: Santander Account Number: 0049 5319 9121 16611692 IBAN: ES7000495319912116611692 Swift/Bic: BSCHESMM",'','','C');
$pdf->Ln(4);

$pdf->Cell(180,4,"EcoGeek SL Registrado en el Registro Mercantil de La Palma volumen 72 hoja 221 Página IP-3128 CIF: B76739663",'','','C');
$pdf->Ln(3);
$pdf->Cell(180,4,"(EcoGeek SL Registered in the Mercantile Register of La Palma volume 72 sheet 221 Page IP-3128 CIF: B76739663)",'','','C');
$pdf->Ln(3);
$pdf->Cell(180,4,"Todas las ordenes sujeto a nuestros Terminos de Servicio ver http://eco-geek.net/terms-conditions-of-service",'','','C');
$pdf->Ln(3);
$pdf->Cell(180,4,"(All orders subject to our Terms of Service see http://eco-geek.net/terms-conditions-of-service)",'','','C');
# Generation Date
$pdf->SetFont('freesans','',7);
$pdf->Ln(4);
$pdf->writeHTMLCell(180,4,'','',"<p>" .$biLang->getTextHorizontal('invoicepdfgenerated').' '.getTodaysDate(1)."</p>",0,1,0,1,'C','1');
