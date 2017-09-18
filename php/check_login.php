<?php
//sleep(3);
if (isset($_GET['mail'])) {
	$mail = $_GET['mail'];
	$upass = $_GET['pass'];
	
	$host = 'localhost';
	$port = 5432;
	$db = 'postgres';
	$user = 'diplom';
	$pass = 'diplom';

	$dbcon = "host='$host' port='$port' dbname='$db' user='$user' password='$pass'";
	$con = pg_connect($dbcon) or die ("error.: ". pg_last_error());

	$query = "select login('".$mail."','".$upass."') as res;";
	//echo $query;

	$res = pg_query($con, $query);
	$myName = pg_fetch_array($res);
	echo $myName['res'];	

}
else {
	echo 'Ваш голос принят!';
}

?>