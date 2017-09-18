<?php
	$host = 'localhost';
	$port = 5432;
	$db = 'postgres';
	$user = 'diplom';
	$pass = 'diplom';

	$dbcon = "host='$host' port='$port' dbname='$db' user='$user' password='$pass'";
	$con = pg_connect($dbcon) or die ("error.: ". pg_last_error());

	 /*list of new products*/
	$query = "select n, up, name, picture, btrim(to_char((case when priced=0 then price else priced end),'9 999 999')) price, lbl from product\$get_product_list(NULL,NULL,null,null,null,null,null,9,7)";/*7*/
	$resNewProd = pg_query($con, $query);
	$newProds = pg_fetch_all($resNewProd);
	$newProdsCnt = sizeof($newProds);

	 /*list of Hot products*/
	$query = "select n, up, name, picture, btrim(to_char((case when priced=0 then price else priced end),'9 999 999')) price, lbl from product\$get_product_list(NULL,NULL,null,null,null,null,null,5,8)";/*8*/
	$resHotProd = pg_query($con, $query);
	$hotProds = pg_fetch_all($resHotProd);
	$hotProdsCnt = sizeof($hotProds);

	$disable ='style = "display: none;"';
	pg_close($con);
?>