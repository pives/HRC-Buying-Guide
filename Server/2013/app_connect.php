<?php
//<<<<<<<BEGIN HEADERS AND IMPORTS
require_once("./php_factory/_auth_key.php");
if($_GET['content-type']=="json"){
	header('Content-type: application/json');
}
require_once("./php_factory/_app_config.php");
require_once("./php_factory/_db_functions.php");
require_once("./php_factory/_app_functions.php");
//>>>>>END HEADERS AND IMPORTS


//<<<<START APPLICATION CODE

//Create Database Connection
$conn=setup_database($db_args);
validate_incoming_parameters($_REQUEST);

//Create and Execute Query To Return Results - CATEGORIES
$qry_cols=array();
$qry_cols[]="*";
$qry_tbls=array();
$qry_tbls[]="tlkBGCategory";

$qry_settings=array();
$qry_settings['WHERE']="";
$qry_settings['TYPE']="SELECT";
$qry_settings['FROM']=$qry_tbls;
$qry_settings['COLS']=$qry_cols;

$catResultSet=array(); 
$catResult = execute_query(make_query($qry_settings), $conn) or die('Errant query:  '. print_r($qry_settings));
$catResultSet = get_results_array($catResult);

//Create and Execute Query To Return Results - ORGANIZATIONS
$qry_cols=array();
$qry_cols[]="*";
$qry_tbls=array();
$qry_tbls[]="tblBGOrganization";

$qry_settings=array();
$qry_settings['WHERE']=get_where_clause($_GET);
$qry_settings['TYPE']="SELECT";
$qry_settings['FROM']=$qry_tbls;
$qry_settings['COLS']=$qry_cols;

$organizationResultSet=array();
$organizationResult=execute_query(make_query($qry_settings), $conn) or die('Errant query:  '. print_r($qry_settings));
$organizationResultSet=get_results_array($organizationResult);





//Create and Execute Query To Return Results - SCORECARDS
$qry_cols=array();
$qry_cols[]="*";
$qry_tbls=array();
$qry_tbls[]="qryOrgCEIRating";

$qry_settings=array();








$qry_settings['WHERE']=get_where_clause($_GET);
$qry_settings['TYPE']="SELECT";
$qry_settings['FROM']=$qry_tbls;
$qry_settings['COLS']=$qry_cols;

$scoreCardResultSet=array(); 
$scoreCardResult = execute_query(make_query($qry_settings), $conn) or die('Errant query:  '. print_r($qry_settings));
$scoreCardResultSet = get_results_array($scoreCardResult);




//Create and Execute Query To Return Results - BRANDS

$qry_cols=array();
$qry_cols[]="*";
$qry_tbls=array();
$qry_tbls[]="qryOrgNBrandWAllOrgsAsBrands";

$qry_settings=array();
$qry_settings['WHERE']=get_where_clause($_GET);
$qry_settings['TYPE']="SELECT";
$qry_settings['FROM']=$qry_tbls;
$qry_settings['COLS']=$qry_cols;

$brandResultSet=array();
$brandResult=execute_query(make_query($qry_settings), $conn) or die('Errant query:  '. print_r($qry_settings));
$brandResultSet=get_results_array($brandResult);
//Prepare results array


$qry_cols=array();
$qry_cols[]="*";
$qry_tbls=array();
$qry_tbls[]="qryOrgsToRemove";

$qry_settings=array();
$qry_settings['WHERE']=get_where_clause($_GET);
$qry_settings['TYPE']="SELECT";
$qry_settings['FROM']=$qry_tbls;
$qry_settings['COLS']=$qry_cols;

$removedResultSet=array();
$removedResult=execute_query(make_query($qry_settings), $conn) or die(mssql_get_last_message() . 'Errant query:  '. print_r($qry_settings));
$removedResultSet=get_results_array($removedResult);
//Prepare results array


//$results=array("categories"=>$catResultSet, 'organizations'=>$organizationResultSet, 'brands'=>$brandResultSet, 'removed'=>$removedResultSet);

//$results=array("categories"=>$catResultSet,  'organizations'=>$organizationResultSet, 'brands'=>$brandResultSet, "scorecards"=>$scoreCardResultSet ,'removed'=>$removedResultSet);

$results=array("categories"=>array(),  'organizations'=>array(), 'brands'=>array(), "scorecards"=>array() ,'removed'=>array());

//Output results
output_results_as_json($results);


mssql_close($conn);
//>>>>>>>END APPLICATION CODE

?>
