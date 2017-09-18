<?php

if (isset($_GET['mail'])) {
	$mail = $_GET['mail'];
	$pas = $_GET['pass'];
	$name = $_GET['fio'];
	
	$host = 'localhost';
	$port = 5432;
	$db = 'postgres';
	$user = 'diplom';
	$pass = 'diplom';

	$dbcon = "host='$host' port='$port' dbname='$db' user='$user' password='$pass'";
	$con = pg_connect($dbcon) or die ("error.: ". pg_last_error());

	$query = "select find_mail('".$mail."') as res;"; //try to find mail. if mail was found then return person.n.
	//echo $query;

	$res = pg_query($con, $query);
	$myName = pg_fetch_array($res);

	if ($myName['res'] > 0 ) { //if mail was found then return 0.
		echo '0'; 
	} elseif ($myName['res'] == 0 ) { //if mail was not found then create person, create log and return person.n of new record.
		$query = "select new_user(null, null, null, '".$mail."', null, '".$pas."', '".$name."') as res;";

		$res = pg_query($con, $query);
		$myName = pg_fetch_array($res);

		$q = "select reg_log(".$myName['res'].",null,5,null,null) as res;";
		$res = pg_query($con, $q);

		echo $myName['res'];
	} else {
		echo '-999';
	}

}
else {
	echo '-1';
}

?>