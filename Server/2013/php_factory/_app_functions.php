<?php
function validate_incoming_parameters(array $parameters){
	//TODO
}

function get_where_clause(array $parameters){
	$where=null;
	if(!is_null($parameters) && count($parameters)>0){
	
		$date=$parameters['date'];
		if(!$parameters['date'] || is_null($parameters['date']) || ($parameters['date'])==""){
			
		}else{
			$where="WHERE DateLastUpdated>Cast('$date' as DateTime)";	
		}
	}
	return $where;
}

function output_results_as_json(array $results){
	echo json_encode($results);
}

?>