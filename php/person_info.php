<?php
	$host = 'localhost';
	$port = 5432;
	$db = 'postgres';
	$user = 'diplom';
	$pass = 'diplom';

	$dbcon = "host='$host' port='$port' dbname='$db' user='$user' password='$pass'";
	$con = pg_connect($dbcon) or die ("error.: ". pg_last_error());

	if (isset($_SESSION['supermagName'])) {
		$mail = $_SESSION['supermagName'];
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
		$person = pg_fetch_array($res);	
		$fio = $person['fio'];
		$phone = $person['phone'];
		$personAddr = $person['address'];
		if (!isset($phone)) {
			$phone = 'Номер не указан!';
		}

		if (!isset($personAddr)) {
			$personAddr = 0;
		}

		$query = "select cnt, cit, str, hse, app, dsc from get_address_info(".$personAddr.") as (cnt VARCHAR, cit VARCHAR, str VARCHAR, hse VARCHAR, app NUMERIC, dsc VARCHAR)";
		$res = pg_query($con, $query);
		$address = pg_fetch_array($res);
		$city = $address['cit'];
		$street = $address['str'];
		$house = $address['hse'];
		$appartment = $address['app'];

	} else {
		$fio = '';
		$phone = '';
		$mail = '';
	}
	pg_close($con);
?>