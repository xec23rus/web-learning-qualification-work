<?php
//sleep(3);
if (isset($_GET['sprodpage']) && is_numeric($_GET['sprodpage']) && isset($_GET['sprodup']) && is_numeric($_GET['sprodup']) && isset($_GET['type'])) {

	$host = 'localhost';
	$port = 5432;
	$db = 'postgres';
	$user = 'diplom';
	$pass = 'diplom';

	$dbcon = "host='$host' port='$port' dbname='$db' user='$user' password='$pass'";
	$con = pg_connect($dbcon) or die ("error.: ". pg_last_error());

	$sProdPage = $_GET['sprodpage'];
	$sProdUp = $_GET['sprodup'];
	$type = $_GET['type'];

	$sProdFrom = ($sProdPage - 1) * 4;

	if ($type == 'same') {
		$query = "select n, name, picture, btrim(to_char((case when priced=0 then price else priced end),'9 999 999')) price, lbl from product\$get_product_list(".$sProdUp.",NULL,null,null,null,null,".$sProdFrom.",5,null)";
	} elseif ($type == 'hot') {
		$query = "select up, n, name, picture, btrim(to_char((case when priced=0 then price else priced end),'9 999 999')) price, lbl from product\$get_product_list(NULL,NULL,null,null,null,null,".$sProdFrom.",5,8)";/*8*/
	} elseif ($type == 'new') {
		$query = "select up, n, name, picture, btrim(to_char((case when priced=0 then price else priced end),'9 999 999')) price, lbl from product\$get_product_list(NULL,NULL,null,null,null,null,".$sProdFrom.",9,7)";/*7*/		
	} else {
		echo '-1';	
	};

	$resSameProd = pg_query($con, $query);

	pg_close($con);

	$sameProds = pg_fetch_all($resSameProd);
	$sameProdsCnt = sizeof($sameProds);

	
	if ($sameProds && $type=='same') { 
		foreach ($sameProds as $key => $sProd) {
			$sProdKey = $key + 1;
			if ($sProdKey==5) {
				break;
			}
			echo '<div data-product="'.$sProdKey.'">';
			echo '	<div class="ProdImg" style="background-image: url(img/products/'.$sProdUp.'/'.$sProd['picture'].'"></div>';
			echo '	<div class="ProdName">'.$sProd['name'].'</div>';
			echo '	<div class="ProdPrice">'.$sProd['price'].'<span>руб.</span></div>';
			echo '	<a class="refBox" href="product.php?id='.$sProd['n'].'"></a>';
			if ($sProd['lbl']==1) {
				echo '	<div class="NewLabel">NEW</div>';
		  	} elseif ($sProd['lbl']==2) {
				echo '	<div class="HotLabel">HOT</div>';
		  	} elseif ($sProd['lbl']==3) {
		  		echo '	<div class="SaleLabel">SALE</div>';
		  	}
		  	echo '</div>';
		} 
		echo '<div id="sameProdStat" data-sProdNext="'.$sProdKey.'"></div>';
	} elseif ($sameProds && $type=='hot') {
		foreach ($sameProds as $hotKey => $hProd) {
			$hProdKey = $hotKey + 1;
			if ($hProdKey==5) {
				break;
			}
			echo '<div data-topProdItem="'.$hProdKey.'">';
			echo '	<div class="ProdImg" style="background-image: url(img/products/'.$hProd['up'].'/'.$hProd['picture'].')"></div>';
			echo '	<div class="ProdName">'.$hProd['name'].'</div>';
			echo '	<div class="ProdPrice">'.$hProd['price'].'<span>руб.</span></div>';
			echo '	<a class="refBox" href="product.php?id='.$hProd['n'].'"></a>';
			echo '	<div class="HotLabel">HOT</div>';
		  	echo '</div>';
		} 
		echo '<div id="hotProdStat" data-hProdNext="'.$hProdKey.'"></div>';
	} elseif ($sameProds && $type=='new') {
		foreach ($sameProds as $newKey => $nProd) {
			$nProdKey = $newKey + 1;
			if ($nProdKey==9) {
				break;
			}
			echo '<div data-topProdItem="'.$nProdKey.'">';
			echo '	<div class="ProdImg" style="background-image: url(img/products/'.$nProd['up'].'/'.$nProd['picture'].')"></div>';
			echo '	<div class="ProdName">'.$nProd['name'].'</div>';
			echo '	<div class="ProdPrice">'.$nProd['price'].'<span>руб.</span></div>';
			echo '	<a class="refBox" href="product.php?id='.$nProd['n'].'"></a>';
			echo '	<div class="NewLabel">NEW</div>';
		  	echo '</div>';
		} 
		echo '<div id="newProdStat" data-nProdNext="'.$nProdKey.'"></div>';
	}

}
else {
	echo '-1';
}

?>