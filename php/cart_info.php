<?php
	$host = 'localhost';
	$port = 5432;
	$db = 'postgres';
	$user = 'diplom';
	$pass = 'diplom';

	$dbcon = "host='$host' port='$port' dbname='$db' user='$user' password='$pass'";
	$con = pg_connect($dbcon) or die ("error.: ". pg_last_error());

if (isset($_SESSION['supermagUserId'])) {
	$noAuth = FALSE;

	$userId = $_SESSION['supermagUserId'];

	$query = "select * from cart\$get_product_list(".$userId.")";

	$resCartQ = pg_query($con, $query);
	$cartArray = pg_fetch_all($resCartQ);
	
	foreach ($cartArray as $key => $value) {
		if ($value['attr1']) {
			$query = "select * from attr\$get_attr_info(".$value['attr1'].")";
			$resAttrQ = pg_query($con, $query);
			$attrArray = pg_fetch_all($resAttrQ);
			$cartArray[$key]['color'] = $attrArray[0]['dic_term'];
		}
	}

	$cartPrice = $_SESSION['supermagPrice'];
} 
else {
	$noAuth = TRUE;
	$cartPrice = '0';
} 
	pg_close($con);
?>