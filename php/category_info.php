<?php
	$host = 'localhost';
	$port = 5432;
	$db = 'postgres';
	$user = 'diplom';
	$pass = 'diplom';

	$dbcon = "host='$host' port='$port' dbname='$db' user='$user' password='$pass'";
	$con = pg_connect($dbcon) or die ("error.: ". pg_last_error());

	if (isset($_GET['category']) && is_numeric($_GET['category'])) {
		$category = $_GET['category'];
		$query = "select * from category\$info(".$category.") as (n INTEGER, up INTEGER, level INTEGER, name VARCHAR, type INTEGER, status INTEGER, dsc VARCHAR, cnt INTEGER, stock INTEGER);";
		$res = pg_query($con, $query);
		$categoryRec = pg_fetch_array($res);

		$category = $categoryRec['n'];
		$categoryCnt = $categoryRec['cnt'];

		if ($category == 0 || $categoryRec['type'] != 1 || $categoryRec['status'] != 1) {
			echo '<script> main_page(); </script>';
			$categoryName = 'Категория';
		}
		else {
			$categoryName = $categoryRec['name'];
		}
	} 
	else {
		echo '<script> main_page(); </script>';
		$categoryName = 'Категория';
	}

	if ($category != 0 && isset($_GET['pg']) && is_numeric($_GET['pg'])) {
		$prodPg = $_GET['pg'];
		if ($categoryCnt/17 + 1 > $prodPg) {
			null;
		} else {
			$prodPg = 1;
		}
		if ($prodPg <= 0) {
			$prodPg = 1;
		}
		if ($categoryCnt % 17 > 0) {
			$catPgCnt = ($categoryCnt - $categoryCnt % 17)/17 + 1;
		} 
		else {
			$catPgCnt = ($categoryCnt - $categoryCnt % 17)/17;
		}
		$prodFrom = 0;
		if ($prodPg > 1) {
			$prodFrom = 17*($prodPg-1);
		}
		$query = "select n, name, picture, btrim(to_char((case when priced=0 then price else priced end),'9 999 999')) price, lbl from product\$get_product_list(".$category.",NULL,null,null,null,null,".$prodFrom.",18,null)"; /*".$category."*/
		$resProdQ = pg_query($con, $query);
		$prodArray = pg_fetch_all($resProdQ);
		$prodCnt = sizeof($prodArray);
		if ($prodCnt == 18) {
			$prodShowed = $prodPg * 17;
		} 
		else {
			$prodShowed = ($prodPg - 1) * 17 + $prodCnt;
		}
		
	}

	pg_close($con);
?>