<?php
 session_start();
?>

<!DOCTYPE html>
<html>
<head>
	<title>Спорт Маг</title>
	<meta charset="utf-8">
	<link rel="stylesheet" type="text/css" href="css/common.css">
	<link rel="stylesheet" type="text/css" href="css/category.css">
	<script src="js/common.js"></script>

	<?php include_once 'php/category_info.php' ?>

</head>
<body onload="update_cart_attr();">
	<div id="wrp">
		<div id="head">

			<?php include_once 'php/header.php' ?>
			
		</div>
		<div id="body">
			<div id="winNameN"><?php echo $categoryName ?></div>
			<div id="winSummary">Показано <span id="prodShowFrom"><?php echo $prodFrom + 1 ?></span>–<span id="prodShowTill"><?php echo $prodShowed ?></span> из <?php echo $categoryCnt ?> товаров</div>		
			<div id="mainForm">
				<?php
					if ($catPgCnt > 1) {
						echo ' <div class="categoryNav">';
						echo '  <ul class="listOfPage">';
							for ($i = $prodPg + 2; $i > $prodPg - 2 ; $i--) { 
								if ($catPgCnt >= $i && (($i > $prodPg && ($i - $prodPg) == 1) || ($i > $prodPg && $i == 3 && $prodPg == 1) || ($i > 0 && ($prodPg - $i) == 1) || ($i > 0 && ($prodPg - $i) == 2 && $catPgCnt == $prodPg)))
								 {
									echo '<li><a href="?category='.$category.'&pg='.$i.'"><button class="pageGreyBtn"><span>'.$i.'</span></button></a></li>';
								}
								elseif ($i == $prodPg) {
									echo '<li><button class="pageRedBtn"><span>'.$i.'</span></button></li>';
								}
							}
						echo '   <li><button class="blankBtn"><span>Страницы</span></button></li>';
						echo '  </ul>';
						echo ' </div>';
					}
				?>
				<div id="catProdList">
					<?php
						if ($prodArray) { 
							$cProdKey = 0;
							foreach ($prodArray as $cKey => $cProd) {
								$cProdKey++;
								if ($cProdKey==25) {
									break;
								}
								if ($prodPg==1) {
									if ($cProdKey==1) {
										$cProdKey = $cProdKey + 3;
										echo '<div data-product="1"></div><div data-product="2"></div><div data-product="3"></div>';
									} 
									elseif ($cProdKey==15) {
										$cProdKey = $cProdKey + 2;
										echo '<div data-product="15"></div><div data-product="16"></div>';
									}
									elseif ($cProdKey==19) {
										$cProdKey = $cProdKey + 2;
										echo '<div data-product="19"></div><div data-product="20"></div>';
									}
								}
								echo '<div data-product="'.$cProdKey.'">';
								echo '	<div class="ProdImg" style="background-image: url(img/products/'.$category.'/'.$cProd['picture'].')"></div>';
								echo '	<div class="ProdName">'.$cProd['name'].'</div>';
								echo '	<div class="ProdPrice">'.$cProd['price'].'<span>руб.</span></div>';
								echo '	<a class="refBox" href="product.php?id='.$cProd['n'].'"></a>';
								if ($cProd['lbl']==1) {
									echo '	<div class="NewLabel">NEW</div>';
							  	} elseif ($cProd['lbl']==2) {
									echo '	<div class="HotLabel">HOT</div>';
							  	} elseif ($cProd['lbl']==3) {
							  		echo '	<div class="SaleLabel">SALE</div>';
							  	}
							  	echo '</div>';
							} 
						}
						if ($prodPg==1) {
							echo'	
								<div id="cat1main" class="bBorder rBorder">
									<p id="catDesc">Описание категории</p>
									<p id="catAbout">Краткий текст о категории</p>
								</div>
								<div id="cat1promoM">
									<div id="cat1promo">
										<p id="promoName">Заголовок<br>промо-товара</p>
										<p id="promoDesc">Описание промо-товара</p>
										<p id="promoPrice">4 540<span>руб.</span></p>
										<a href="product.html"><button><span>Посмотреть  +</span></button></a>
									</div>
								</div>';
						}
					?>
							
					<div class="clear"></div>
				</div>
				<?php
					if ($catPgCnt > 1) {
						echo ' <div class="categoryNav">';
						echo '  <ul class="listOfPage">';
							for ($i = $prodPg + 2; $i > $prodPg - 2 ; $i--) { 
								if ($catPgCnt >= $i && (($i > $prodPg && ($i - $prodPg) == 1) || ($i > $prodPg && $i == 3 && $prodPg == 1) || ($i > 0 && ($prodPg - $i) == 1) || ($i > 0 && ($prodPg - $i) == 2 && $catPgCnt == $prodPg)))
								 {
									echo '<li><a href="?category='.$category.'&pg='.$i.'"><button class="pageGreyBtn"><span>'.$i.'</span></button></a></li>';
								}
								elseif ($i == $prodPg) {
									echo '<li><button class="pageRedBtn"><span>'.$i.'</span></button></li>';
								}
							}
						echo '   <li><button class="blankBtn"><span>Страницы</span></button></li>';
						echo '  </ul>';
						echo ' </div>';
					}
				?>			
			</div>
		</div>
		<div id="footer">
			<p>Шаблон для экзаменационного задания.<br>
			Разработан специально для «Всероссийской Школы Программирования»<br>
			http://bedev.ru/</p>
			<a href="#top">Наверх <img src="img/up.png" alt="up"></a>
		</div>
		<div id="footerNull"></div>
	</div>
</body>
</html>		