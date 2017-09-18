<?php
	$host = 'localhost';
	$port = 5432;
	$db = 'postgres';
	$user = 'diplom';
	$pass = 'diplom';

	$dbcon = "host='$host' port='$port' dbname='$db' user='$user' password='$pass'";
	$con = pg_connect($dbcon) or die ("error.: ". pg_last_error());

	if (isset($_POST['email']) && !(isset($_POST['hid']))) {

		$mail = $_POST['email'];
		$upass = $_POST['pas'];

		$query = "select login('".$mail."','".$upass."') as res;";
		//echo $query;

		$res = pg_query($con, $query);
		$myName = pg_fetch_array($res);
				
		if ($myName['res'] > 0) {
			$_SESSION['supermagName'] = $mail;
			$_SESSION['supermagId'] = $myName['res'];
			//echo '<br> Номер сессии = ' . $_SESSION['supermagId'] . '<br> <br>';
			$query = "select find_mail('".$mail."') as res;"; //get person.n

			$res = pg_query($con, $query);
			$myName = pg_fetch_array($res);

			$query = "select btrim(to_char(sm,'9 999 999')) sm, cnt from cart\$sum(".$myName['res'].") as (sm NUMERIC, cnt integer)";//get sum and count for cart

			$res = pg_query($con, $query);
			$curCart = pg_fetch_array($res);
			$_SESSION['supermagPrice'] = $curCart['sm'];
			$_SESSION['supermagCnt'] = $curCart['cnt'];
			$_SESSION['supermagUserId'] = $myName['res'];
		}
	};
	if (isset($_GET['logout'])) {
		$mail = $_SESSION['supermagName'];
		$sessId = $_SESSION['supermagId'];

		$query = "select find_mail('".$mail."') as res;";

		$res = pg_query($con, $query);
		$myName = pg_fetch_array($res);

		$query = "select reg_log(".$myName['res'].",null,4,'".$sessId."','') as res;";

		$res = pg_query($con, $query);

		unset($_SESSION['supermagName']);
		unset($_SESSION['supermagId']);
		unset($_SESSION['supermagPrice']);
		unset($_SESSION['supermagCnt']);
	};

	pg_close($con);
?>