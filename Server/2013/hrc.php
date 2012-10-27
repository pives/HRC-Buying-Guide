<?php
header('Content-type: application/json');
// Report simple running errors
//error_reporting(E_ALL);
// Connect to SQL Server and check for errors
$db_host="10.88.88.228";
$db_user="iphone_app_user";
$db_password="5rc_1ph0n3";

$conn = mssql_connect($db_host,$db_user,$db_password);

if ($conn===false)
{
	echo '<p>Cannot connect to SQL Server Database. Please try again later.</p>';
	exit;
}else{
//	echo '<p>Connected to Server</p>';	
}
if (mssql_select_db("BuyersGuideReadOnlyForApps",$conn) === false) 
{
	echo '<p>Cannot connect to BuyersGuideReadOnlyForApps. Please try again later.</p>';
	exit;
}else{
//	echo '<p>Connected to DB</p>';
}

$date=$_GET['date'];//01OCT2010
if(!$date || is_null($date) || ($date)==""){
	$where="";	
}else{
	$where="WHERE DateLastUpdated>Cast('$date' as DateTime)";
}

$catResultSet=array();                
$sql ="SELECT * FROM tlkBGCategory";
$catResult = mssql_query($sql,$conn) or die('Errant query:  '.$sql);
  if(mssql_num_rows($catResult)) 
            {
                while($row = mssql_fetch_assoc($catResult)) 
                {
                    $catResultSet[] = array('single_cat'=>array_map('utf8_encode',$row));
                }
            }


$organizationResultSet=array();
$sql ="SELECT * FROM tblBGOrganization $where";

            $result = mssql_query($sql,$conn) or die('Errant query:  '.$sql);
         
            /* create one master array of the records */
        
            if(mssql_num_rows($result)) 
            {
                while($row = mssql_fetch_assoc($result)) 
                {
                    $organizationResultSet[] = array('single_organization'=>array_map('utf8_encode',$row));
                }
            }
        
$brandResultSet=array();                
$sql ="SELECT * FROM tblBGOrgBrand $where";
$branchResult = mssql_query($sql,$conn) or die('Errant query:  '.$sql);
  if(mssql_num_rows($branchResult)) 
            {
                while($row = mssql_fetch_assoc($branchResult)) 
                {
                    $brandResultSet[] = array('single_brand'=>array_map('utf8_encode',$row));
                }
            }
echo json_encode(array('resultset'=>array('categories'=>$catResultSet, 'organizations'=>$organizationResultSet, 'brands'=>$brandResultSet)));

mssql_close($conn);
?>