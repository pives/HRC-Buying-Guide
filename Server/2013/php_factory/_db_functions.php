<?php
function connect_to_db(array $db_args){
	return mssql_connect($db_args['db_sever'],$db_args['db_auth_user'],$db_args['db_auth_pass']);
}

function set_db_name(array $db_args, $conn){
	return mssql_select_db($db_args['db_name'],$conn);
}

function setup_database(array $db_args){
	$conn = connect_to_db($db_args);
	if ($conn===false)
	{
		echo '<p>Cannot connect to SQL Server Database. Please try again later.</p>';
		exit;
	}

	if (set_db_name($db_args, $conn) === false) 
	{
		echo '<p>Cannot connect to ' . $db_args['db_name'] . '. Please try again later.</p>';
		exit;
	}
	return $conn;
}


function make_query($qry_settings){
	$query="";
	$query=$qry_settings['TYPE'] . " " . implode(',', $qry_settings['COLS']) . " FROM " . implode(',', $qry_settings['FROM']) . " ";
	if(!is_null($qry_settings['WHERE'])){
		$query.=$qry_settings['WHERE'];
	}
	return $query;
}

function execute_query($query, $conn){
	return mssql_query($query,$conn);
}

function get_results_array($executedQuery){
	$result_set=array();
	if(mssql_num_rows($executedQuery)) 
	{
    while($row = mssql_fetch_assoc($executedQuery)) 
        {
            $result_set[] = array('row'=>array_map('utf8_encode',$row));
        }
    }else{
    	return array();
    }
    return $result_set;
}


?>