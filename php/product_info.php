<?php
	$host = 'localhost';
	$port = 5432;
	$db = 'postgres';
	$user = 'diplom';
	$pass = 'diplom';

	$dbcon = "host='$host' port='$port' dbname='$db' user='$user' password='$pass'";
	$con = pg_connect($dbcon) or die ("error.: ". pg_last_error());

	if (isset($_GET['id']) && is_numeric($_GET['id'])) {
		$product_id = $_GET['id'];
		$query = "select n, 
	   					 up_n, 
	   					 up_c,
       					 vend_n,
       					 vend_c, 
       					 name, 
       					 dt, 
       					 dsc, 
       					 descr, 
       					 in_stock,
       					 btrim(to_char(price,'9 999 999')) pr,
       					 btrim(to_char(price_d,'9 999 999')) pr_d
					from product\$get_product_info(".$product_id.") as (n INTEGER, 
    									 							   up_n INTEGER,
    									 							   up_c VARCHAR,
                                        							   vend_n INTEGER,
                                        							   vend_c VARCHAR, 
                                        							   name VARCHAR, 
                                        							   dt date, 
                                        							   dsc VARCHAR, 
                                        							   descr VARCHAR, 
                                        							   in_stock INTEGER,
                                        							   price NUMERIC,
                                        							   price_d NUMERIC)";
		$res = pg_query($con, $query);
		$product = pg_fetch_array($res);

		$category = $product['up_c'];
		$categoryN = $product['up_n'];
		$productName = $product['name'];
		$productDesc = $product['descr'];
		$productStatus = $product['in_stock'];
		$productPrice = $product['pr'];
		$productPriceD = $product['pr_d'];
	} 
	if (!isset($categoryN)) {
		$product_id = 0;
		$category = 'Категория';
		$categoryN = 0;
		$productName = 'Название продукта';
		$productDesc = 'Описание продукта';
		$productStatus = 0;
		$productPrice = 0;
		$productPriceD = 0;
	}
		/* get colors if exist*/
		$query = "select dic_term color, val1 code, n from attr\$get_attr_list(1,".$product_id.",1,1)";		
		$resColors = pg_query($con, $query);
		$colors = pg_fetch_all($resColors);
		/*get main IMG*/
		$query = "select val1 jpgpath from attr\$get_attr_list(1,".$product_id.",2,1) where val2='1' limit 1";
		$resMainJPG = pg_query($con, $query);
		$mainJPG = pg_fetch_array($resMainJPG);
		$mainJPGpath = $categoryN."/".$mainJPG['jpgpath'];
		/*get list of IMG*/
		$query = "select val1 jpgpath, val2 mainj from attr\$get_attr_list(1,".$product_id.",2,1) where COALESCE(val2,'0') !='1'";
		$resJPG = pg_query($con, $query);
		$JPGs = pg_fetch_all($resJPG);
	 	/*list of same products*/
		$query = "select n, name, picture, btrim(to_char((case when priced=0 then price else priced end),'9 999 999')) price, lbl from product\$get_product_list(".$categoryN.",NULL,null,null,null,null,null,5,null)";
		$resSameProd = pg_query($con, $query);
		$sameProds = pg_fetch_all($resSameProd);
		$sameProdsCnt = sizeof($sameProds);

	pg_close($con);

/*	if (!isset($category)) {
		$category = 'Категория';
		$categoryN = 0;
		$productName = 'Название продукта';
		$productDesc = 'Описание продукта';
		$productStatus = 0;	
		$productPrice = 0;
		$productPriceD = 0;			
	}*/
	 if ($productPriceD == 0) {
	 	$disablePrice ='style = "display: none;"';/*visibility: hidden;*/
	 	$curPrice = $productPrice;
	 	$oldPrice = $productPriceD;
	 } else {
	 	$curPrice = $productPriceD;
	 	$oldPrice = $productPrice;
	 	$disablePrice = Null;
	 }
	 if ($productStatus == 0) {
	 	$stockDisable = 'style = "display: none;"';
	 	$stockDisableInv = Null;
	 } else {
	 	$stockDisable = Null;
	 	$stockDisableInv = 'style = "display: none;"';
	 }
	 $disable ='style = "display: none;"';

?>