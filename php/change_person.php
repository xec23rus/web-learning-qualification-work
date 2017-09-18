<?php
	$host = 'localhost';
	$port = 5432;
	$db = 'postgres';
	$user = 'diplom';
	$pass = 'diplom';

	$dbcon = "host='$host' port='$port' dbname='$db' user='$user' password='$pass'";
	$con = pg_connect($dbcon) or die ("error.: ". pg_last_error());

	if (isset($_SESSION['supermagName']) and isset($_POST['userPhone'])) {

		$mail = $_SESSION['supermagName'];
		$sessionId = $_SESSION['supermagId'];
		$newFio = $_POST['userName'];
		$newPhone = $_POST['userPhone'];
		$newCity = $_POST['city'];
		$newStreet = $_POST['street'];
		$newBuild = $_POST['build'];
		$newAppartment = $_POST['appartment'];
		$newPas = $_POST['pas'];
		$newPass = $_POST['pasAgain'];

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
		$oldPerson = pg_fetch_array($res);	

		$oldId = $oldPerson['id'];
		$oldFio = $oldPerson['fio'];
		$oldPhone = $oldPerson['phone'];
		$oldAddress = $oldPerson['address'];

		//change address data
		if (isset($_POST['addrchange']) and $_POST['addrchange'] == 'yes') {
			$query = "select new_address('Россия','".$newCity."','".$newStreet."','".$newBuild."',".$newAppartment.",null) as res";
			$res = pg_query($con, $query);
			$newAddrec = pg_fetch_array($res);
			$newAddress = $newAddrec['res'];
		} else {
			$newAddress = $oldAddress;
		}

		//change personal data
		if ($oldFio != $newFio or $oldPhone != $newPhone or $oldAddress != $newAddress) {
			$query = "select change_person_info (".$oldId.",null,null,'".$newFio."',null,null,'".$newPhone."',".$newAddress.") as res";
			//echo $query;
			$res = pg_query($con, $query);
			$changeRes = pg_fetch_array($res);
			//echo $changeRes['res'];
		}

		if ($newPas and $newPass and $newPas == $newPass) {
			//echo $oldId;
			//echo $sessionId;
			$query = "select check_session (".$oldId.",'".$sessionId."') as res";
			$res = pg_query($con, $query);
			$checkSesRes = pg_fetch_array($res);
			//echo $checkSesRes['res'];
			if ($checkSesRes['res'] == 1) {
				$query = "select change_password (".$oldId.",'".$newPas."','".$sessionId."') as res";
				$res = pg_query($con, $query);
				$changePasRes = pg_fetch_array($res);
				if ($changePasRes['res'] == 1) {
					echo "<script> alert ('Пароль был изменен!'); </script>";
				} elseif ($changePasRes['res'] == -2) {
					echo "<script> alert ('Пароль совпадает с текущим!'); </script>";
				} else {
					echo "<script> alert ('Пароль изменить не удалось!'); </script>";
				}
			} else {
				echo "<script> alert ('Не авторизованная сессия!'); </script>";
			}
			
		}

	} 
	pg_close($con);
?>