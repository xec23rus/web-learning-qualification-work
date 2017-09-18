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
<body>
	<div id="wrp">
		<div id="head">

			<?php include_once 'php/header.php' ?>
			
		</div>
		<div id="body">
			<div id="winNameN"><?php echo $categoryName ?></div>
			<div id="winSummary">Показано <span id="prodShowFrom">1</span>–<span id="prodShowTill"><?php echo $prodShowed ?></span> из <?php echo $categoryCnt ?> товаров</div>		
			<div id="mainForm">
				<div class="categoryNav">
					<ul class="listOfPage">
						<li><button class="pageGreyBtn"><span>3</span></button></li>
						<li><button class="pageGreyBtn"><span><a class="refBox" href="?category=3&pg=2">2</a></span></button></li>
						<li><button class="pageRedBtn"><span>1</span></button></li>
						<li><button class="blankBtn"><span>Страницы</span></button></li>
					</ul>
				</div>
				<div id="catProdList">
					<div id="cat1main" class="bBorder rBorder">
						<p id="catDesc">Описание категории</p>
						<p id="catAbout">Краткий текст о категории</p>
					</div>
					<div class="tBorder bBorder" data-product="1">
						<div class="ProdImg"><img src="img/product.jpg"></div>
						<div class="ProdName">Название товара</div>
						<div class="ProdPrice">7 258<span>руб.</span></div>
						<a class="refBox" href="#"></a>						
					</div>
					<div class="bBorder rBorder" data-product="2">
						<div class="ProdImg"><img src="img/product.jpg"></div>
						<div class="ProdName">Название товара</div>
						<div class="ProdPrice">7 258<span>руб.</span></div>
						<a class="refBox" href="#"></a>						
					</div>		
					<div class="bBorder rBorder" data-product="3">
						<div class="ProdImg"><img src="img/product.jpg"></div>
						<div class="ProdName">Название товара</div>
						<div class="ProdPrice">7 258<span>руб.</span></div>
						<a class="refBox" href="#"></a>	
						<div class="NewLabel">NEW</div>					
					</div>
					<div class="bBorder rBorder" data-product="4">
						<div class="ProdImg"><img src="img/product.jpg"></div>
						<div class="ProdName">Название товара</div>
						<div class="ProdPrice">7 258<span>руб.</span></div>
						<a class="refBox" href="#"></a>	
						<div class="HotLabel">HOT</div>					
					</div>		
					<div class="bBorder" data-product="5">
						<div class="ProdImg"><img src="img/product.jpg"></div>
						<div class="ProdName">Название товара</div>
						<div class="ProdPrice">7 258<span>руб.</span></div>
						<a class="refBox" href="#"></a>						
					</div>	
					<div class="rBorder" data-product="6">
						<div class="ProdImg"><img src="img/product.jpg"></div>
						<div class="ProdName">Название товара</div>
						<div class="ProdPrice">7 258<span>руб.</span></div>
						<a class="refBox" href="#"></a>						
					</div>		
					<div class="rBorder" data-product="7">
						<div class="ProdImg"><img src="img/product.jpg"></div>
						<div class="ProdName">Название товара</div>
						<div class="ProdPrice">7 258<span>руб.</span></div>
						<a class="refBox" href="#"></a>						
					</div>
					<div class="rBorder" data-product="8">
						<div class="ProdImg"><img src="img/product.jpg"></div>
						<div class="ProdName">Название товара</div>
						<div class="ProdPrice">7 258<span>руб.</span></div>
						<a class="refBox" href="#"></a>						
					</div>		
					<div data-product="9">
						<div class="ProdImg"><img src="img/product.jpg"></div>
						<div class="ProdName">Название товара</div>
						<div class="ProdPrice">7 258<span>руб.</span></div>
						<a class="refBox" href="#"></a>						
					</div>
					<div id="leftPromo">
						<div class="tBorder rBorder" data-product="10">
							<div class="ProdImg"><img src="img/product.jpg"></div>
							<div class="ProdName">Название товара</div>
							<div class="ProdPrice">7 258<span>руб.</span></div>
							<a class="refBox" href="#"></a>						
						</div>		
						<div class="tBorder" data-product="11">
							<div class="ProdImg"><img src="img/product.jpg"></div>
							<div class="ProdName">Название товара</div>
							<div class="ProdPrice">7 258<span>руб.</span></div>
							<a class="refBox" href="#"></a>						
						</div>
						<div class="tBorder rBorder bBorder" data-product="12">
							<div class="ProdImg"><img src="img/product.jpg"></div>
							<div class="ProdName">Название товара</div>
							<div class="ProdPrice">7 258<span>руб.</span></div>
							<a class="refBox" href="#"></a>						
						</div>		
						<div class="tBorder bBorder" data-product="13">
							<div class="ProdImg"><img src="img/product.jpg"></div>
							<div class="ProdName">Название товара</div>
							<div class="ProdPrice">7 258<span>руб.</span></div>
							<a class="refBox" href="#"></a>						
						</div>
						<div class="clear"></div>
					</div>
					<div id="cat1promo">
						<p id="promoName">Заголовок<br>промо-товара</p>
						<p id="promoDesc">Описание промо-товара</p>
						<p id="promoPrice">4 540<span>руб.</span></p>
						<a href="product.html"><button><span>Посмотреть  +</span></button></a>
					</div>	
					<div class="rBorder bBorder" data-product="14">
						<div class="ProdImg"><img src="img/product.jpg"></div>
						<div class="ProdName">Название товара</div>
						<div class="ProdPrice">7 258<span>руб.</span></div>
						<a class="refBox" href="#"></a>						
					</div>		
					<div class="rBorder bBorder" data-product="15">
						<div class="ProdImg"><img src="img/product.jpg"></div>
						<div class="ProdName">Название товара</div>
						<div class="ProdPrice">7 258<span>руб.</span></div>
						<a class="refBox" href="#"></a>						
					</div>
					<div class="rBorder bBorder" data-product="16">
						<div class="ProdImg"><img src="img/product.jpg"></div>
						<div class="ProdName">Название товара</div>
						<div class="ProdPrice">7 258<span>руб.</span></div>
						<a class="refBox" href="#"></a>						
					</div>		
					<div class="bBorder" data-product="17">
						<div class="ProdImg"><img src="img/product.jpg"></div>
						<div class="ProdName">Название товара</div>
						<div class="ProdPrice">7 258<span>руб.</span></div>
						<a class="refBox" href="#"></a>						
					</div>
					<div class="clear"></div>
				</div>
				<div class="categoryNav">
					<ul class="listOfPage">
						<li><button class="pageGreyBtn"><span>3</span></button></li>
						<li><button class="pageGreyBtn"><span>2</span></button></li>
						<li><button class="pageRedBtn"><span>1</span></button></li>
						<li><button class="blankBtn"><span>Страницы</span></button></li>
					</ul>
					
				</div>				
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