<?php 
session_start();
header("Content-type: text/xml");

if (isset($_SESSION['supermagName']) and isset($_GET['prod'])) {

	$host = 'localhost';
	$port = 5432;
	$db = 'postgres';
	$user = 'diplom';
	$pass = 'diplom';

	$dbcon = "host='$host' port='$port' dbname='$db' user='$user' password='$pass'";
	$con = pg_connect($dbcon) or die ("error.: ". pg_last_error());

	$mail = $_SESSION['supermagName'];
	$sessionId = $_SESSION['supermagId'];
	$prodN = $_GET['prod'];
	if (isset($_GET['attra'])) {
		$attra = $_GET['attra'];
	} else {
		$attra = '0';
	};
	if (isset($_GET['attrb'])) {
		$attrb = $_GET['attrb'];
	} else {
		$attrb = '0';
	};
	if (isset($_GET['cnt']) and is_numeric($_GET['cnt'])) {
		$prodCnt = $_GET['cnt'];
	} else {
		$prodCnt = 1;
	};	
	if (empty($attra)) {
		$attra = '0';
	};
	if (empty($attrb)) {
		$attrb = '0';
	}
/*	no need to check, bcz it is server side session data
	$query = "select 	id, 
						name, 
						surname, 
						fio, 
						bdate, 
						regdate, 
						email, 
						phone,
						address
				from get_person_info(null,'".$mail."') 
				as (id INTEGER, name VARCHAR, surname VARCHAR, fio VARCHAR, bdate date, regdate TIMESTAMP, email VARCHAR, phone VARCHAR, address NUMERIC)";	
	$res = pg_query($con, $query);
	$curPerson = pg_fetch_array($res);	

	$curId = $curPerson['id'];

	$query = "select check_session (".$curId.",'".$sessionId."') as res";
	$res = pg_query($con, $query);
	$checkSesRes = pg_fetch_array($res);
	*/
	$curId = $_SESSION['supermagUserId'];
	$checkSesRes['res'] = 1;

	if ($checkSesRes['res'] == 1) {
		$query = "select btrim(to_char(sm,'9 999 999')) sm, cnt, prod_cnt from cart\$add_product(".$curId.",".$prodN.",".$prodCnt.",".$attra.",".$attrb.",null) as (sm NUMERIC, cnt integer, prod_cnt integer)";
		$res = pg_query($con, $query);
		$curCart = pg_fetch_array($res);
		$_SESSION['supermagPrice'] = $curCart['sm'];
		$_SESSION['supermagCnt'] = $curCart['cnt'];
		echo '<xml><price>'.$curCart['sm'].'</price><cnt>'.$curCart['cnt'].'</cnt><prod_cnt>'.$curCart['prod_cnt'].'</prod_cnt></xml>';
	} else {
		echo '<xml><price>-100</price><cnt>0</cnt><prod_cnt>0</prod_cnt><err>3</err></xml>';
	}

} else if (isset($_GET['prod'])) {
	echo '<xml><price>-1000</price><cnt>0</cnt><prod_cnt>0</prod_cnt><err>1</err></xml>';
} else {
	echo '<xml><price>-1000</price><cnt>0</cnt><prod_cnt>0</prod_cnt><err>2</err></xml>';
}

?>
