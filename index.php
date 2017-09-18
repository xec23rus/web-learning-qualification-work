<?php
 session_start();
?>

<!DOCTYPE html>
<html>
<head>
	<title>Спорт Маг</title>
	<meta charset="utf-8">
	<link rel="stylesheet" type="text/css" href="css/common.css">
	<link rel="stylesheet" type="text/css" href="css/main.css">
	<script src="js/common.js"></script>

	<?php include 'php/main_product_list.php' ?>

</head>
<body onload="update_cart_attr();">

<?php
	include_once 'php/login_out.php'; /*check $_POST['email'], $_POST['pas'] for login; 
											  $_GET['logout'] for logout;
											  use: $_SESSION['supermagName'] (email), $_SESSION['supermagId']
										*/
?>

<div id="wrp">
	<div id="head">

		<?php include_once 'php/header.php' ?>

		<div id="promo">
			<p id="promo_name">Дельта-14В</p>
			<p id="promo_type">Мопед</p>
			<p id="promo_desc">Отличный мопед с мощностью в 0.01 ЛС!</p>
			<div id="promoRef">
				<a class="refBox" href="product.php?id=1">Посмотреть  +</a>
			</div>
		</div>
	</div>
	<div id="body">
		<div id="NewProd">
			<div class="ProdNav">
				<p>Новые товары</p>
				<div id="newProdNavRight" class="NavBtn ProdNavRight" <?php if ($newProdsCnt < 9) {echo $disable;}?> onclick="newProd(event);" style="background-image: url(img/list_btn_black_right.png);">
				</div>
				<div id="newProdNavLeft" class="NavBtn ProdNavLeft" <?php if ($newProdsCnt < 9) {echo $disable;}?> onclick="newProd(event);"  style="background-image: url(img/list_btn_grey_left.png); cursor: auto;">
				</div>
			</div>

			<div id="NewProdList" data-newProdListCur="1">
<?php
				if ($newProds) { 
					foreach ($newProds as $newKey => $nProd) {
						$nProdKey = $newKey + 1;
						if ($nProdKey==9) {
							break;
						}
						echo '<div data-NewProdItem="'.$nProdKey.'">';
						echo '	<div class="ProdImg" style="background-image: url(img/products/'.$nProd['up'].'/'.$nProd['picture'].')"></div>';
						echo '	<div class="ProdName">'.$nProd['name'].'</div>';
						echo '	<div class="ProdPrice">'.$nProd['price'].'<span>руб.</span></div>';
						echo '	<a class="refBox" href="product.php?id='.$nProd['n'].'"></a>';
						echo '	<div class="NewLabel">NEW</div>';
					  	echo '</div>';
					} 
					echo '<div id="newProdStat" data-nProdNext="'.$nProdKey.'"></div>';
				}
				/*<div data-NewProdItem="1">
					<div class="ProdImg"><img src="img/product.jpg"></div>
					<div class="ProdName">Название товара</div>
					<div class="ProdPrice">7 258<span>руб.</span></div>
					<a class="refBox" href="#"></a>
				</div>
				<div data-NewProdItem="2">
					<div class="ProdImg"><img src="img/product.jpg"></div>
					<div class="ProdName">Название товара</div>
					<div class="ProdPrice">7 258<span>руб.</span></div>
					<a class="refBox" href="#"></a>
					<div class="NewLabel">NEW</div>
				</div>
				<div data-NewProdItem="3">
					<div class="ProdImg"><img src="img/product.jpg"></div>
					<div class="ProdName">Название товара</div>
					<div class="ProdPrice">7 258<span>руб.</span></div>
					<a class="refBox" href="#"></a>
				</div>
				<div data-NewProdItem="4">
					<div class="ProdImg"><img src="img/product.jpg"></div>
					<div class="ProdName">Название товара</div>
					<div class="ProdPrice">7 258<span>руб.</span></div>
					<a class="refBox" href="#"></a>
					<div class="HotLabel">HOT</div>
				</div>
				<div data-NewProdItem="5">
					<div class="ProdImg"><img src="img/product.jpg"></div>
					<div class="ProdName">Название товара</div>
					<div class="ProdPrice">7 258<span>руб.</span></div>
					<a class="refBox" href="#"></a>
				</div>
				<div data-NewProdItem="6">
					<div class="ProdImg"><img src="img/product.jpg"></div>
					<div class="ProdName">Название товара</div>
					<div class="ProdPrice">7 258<span>руб.</span></div>
					<a class="refBox" href="#"></a>
				</div>
				<div data-NewProdItem="7">
					<div class="ProdImg"><img src="img/product.jpg"></div>
					<div class="ProdName">Название товара</div>
					<div class="ProdPrice">7 258<span>руб.</span></div>
					<a class="refBox" href="#"></a>
				</div>
				<div data-NewProdItem="8">
					<div class="ProdImg"><img src="img/product.jpg"></div>
					<div class="ProdName">Название товара</div>
					<div class="ProdPrice">7 258<span>руб.</span></div>
					<a class="refBox" href="#"></a>
				</div>*/
?>			
			</div>
		</div>
		<div id="promoProdList">
			<div id="promo_1" class="promoItem">
				<div class="promoImg"><img src="img/promo_1.jpg"></div>
				<div data-PromoName="1">
					<h2>заголовок</h2>
					<h3>промо товара</h3>
				</div>
				<a class="refBox" href="#"></a>
			</div>
			<div id="promo_2" class="promoItem">
				<div class="promoImg"><img src="img/promo_2.jpg"></div>
				<div data-PromoName="2">
					<h2>заголовок</h2>
					<h3>промо товара</h3>
				</div>
				<a class="refBox" href="#"></a>
			</div>
			<div id="promo_3" class="promoItem">
				<div class="promoImg"><img src="img/promo_3.jpg"></div>
				<div data-PromoName="3">
					<h2>заголовок</h2>
					<h3>промо товара</h3>
				</div>
				<a class="refBox" href="#"></a>
			</div>						
		</div>
		<div id="topProd">
			<div class="ProdNav">
				<p>Популярные товары</p>
				<div id="hotProdNavRight" class="NavBtn ProdNavRight" <?php if ($hotProdsCnt < 5) {echo $disable;}?> onclick="hotProd(event);" style="background-image: url(img/list_btn_black_right.png);">
				</div>
				<div id="hotProdNavLeft" class="NavBtn ProdNavLeft" <?php if ($hotProdsCnt < 5) {echo $disable;}?> onclick="hotProd(event);"  style="background-image: url(img/list_btn_grey_left.png); cursor: auto;">
				</div>
			</div>					

			<div id="topProdList" data-hotProdListCur="1">
<?php
				if ($hotProds) { 
					foreach ($hotProds as $hotKey => $hProd) {
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
				}
				/*<div data-topProdItem="1">
					<div class="ProdImg"><img src="img/product.jpg"></div>
					<div class="ProdName">Название товара</div>
					<div class="ProdPrice">7 258<span>руб.</span></div>
					<a class="refBox" href="#"></a>					
				</div>
				<div data-topProdItem="2">
					<div class="ProdImg"><img src="img/product.jpg"></div>
					<div class="ProdName">Название товара</div>
					<div class="ProdPrice">7 258<span>руб.</span></div>
					<a class="refBox" href="#"></a>					
				</div>
				<div data-topProdItem="3">
					<div class="ProdImg"><img src="img/product.jpg"></div>
					<div class="ProdName">Название товара</div>
					<div class="ProdPrice">7 258<span>руб.</span></div>
					<a class="refBox" href="#"></a>	
					<div class="SaleLabel">SALE</div>
					<div class="SalePrice">9 308<span>руб.</span></div>				
				</div>
				<div data-topProdItem="4">
					<div class="ProdImg"><img src="img/product.jpg"></div>
					<div class="ProdName">Название товара</div>
					<div class="ProdPrice">7 258<span>руб.</span></div>
					<a class="refBox" href="#"></a>					
				</div>	*/
?>								
			</div>
		</div>
		<div id="about">
			<h4>О магазине</h4>
			<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem.</p> <br>
			<p>Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapi</p>
		</div>
		<div id="footer">
			<p>Шаблон для экзаменационного задания.<br>
			Разработан специально для «Всероссийской Школы Программирования»<br>
			http://bedev.ru/</p>
			<a href="#top">Наверх <img src="img/up.png"></a>
		</div>
	</div>
</div>
<?php
/*echo '<br> Номер сессии = ' . $_SESSION['supermagId'];
echo '<br> mail = '. $_POST['email'];*/
?>
</body>
</html>