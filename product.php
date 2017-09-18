<?php
 session_start();
?>

<!DOCTYPE html>
<html>
<head>
	<title>Спорт Маг</title>
	<meta charset="utf-8">
	<link rel="stylesheet" type="text/css" href="css/common.css">
	<link rel="stylesheet" type="text/css" href="css/product.css">
	<script src="js/common.js"></script>

	<?php include_once 'php/product_info.php' ?>

</head>
<body  onload="update_cart_attr();">
	<div id="wrp">
		<div id="head">

			<?php include_once 'php/header.php' ?>

		</div>
		<div id="body">
			<div id="winNameN"> <?php echo $category; ?> </div>
			<div id="winSummary"><a href="category.php?category=<?php echo $categoryN ?>&pg=1">Вернуться в каталог</a></div>	
			<div id="mainForm">
				<div id="productImg">
					<div id="bigImg" style="background-image: url(img/products/<?php echo $mainJPGpath; ?>);">
						<div id="magnifierImg"></div>
					</div>
					<div id="prodImgList">
						<div id="prodImgListPrev" onclick="changej(event);"></div>
						<ul>
							<li data-prevImg="A" style="background-image: url(img/products/<?php echo $mainJPGpath; ?>);" onclick="changej(event);" class="curImg"></li>
							<?php 
								if ($JPGs) { 
								foreach ($JPGs as $key => $JPG) {
									$JPGkey = $key + 2;
									echo "<li data-prevImg=\"".$JPGkey."\" style=\"background-image: url(img/products/".$product['up_n']."/".$JPG['jpgpath'].");\" onclick=\"changej(event);\" class=\"prevImg\"></li>";} 
								}
							?>
						</ul>
						<div id="prodImgListNext" onclick="changej(event);"></div>
						<div class="clear"></div>													
					</div>
				</div>
				<div id="productDesc">
					<div id="productName">
						<h1> <?php echo $productName; ?> </h1>
					</div>
					<span id="productId" class="disable"><?php echo $product_id; ?></span>
					<p id="productDescVal"> <?php echo $productDesc; ?> </p>
					<p class="productAttr" <?php if (!$colors) {echo $disable;} ?>>
						Выберите цвет:
						<select id="productAttrValA" size="1" name="productAttrVal">
							<?php if ($colors) { foreach ($colors as $color) {echo "<option value=\"".$color['n']."\">".$color['color']."</option>";} }?>
						</select>
					</p>
				</div>
				<div id="productPrice">
					<div id="productPriceMain">
						<div id="oldPrice" <?php echo $disablePrice; ?>><?php echo $oldPrice; ?> руб.</div>
						<div id="curPrice"><?php echo $curPrice; ?> руб.</div>
						<table id="inStock">
							<tr> 
								<td <?php echo $stockDisable; ?>><img src="img/in_stock.png" alt=""></td>
								<td <?php echo $stockDisable; ?>><span>есть в наличии</span></td>
								<td <?php echo $stockDisableInv; ?>><span>нет в наличии</span></td>
							</tr>
						</table>
					</div>
					<div id="productPriceBut" <?php echo $stockDisable; ?> onclick="add_product();">
						<table class="redBtn buyBtn">
							<tr>
								<td id="cartImgField">
									<img src="img/cart_white.png" alt="">
								</td>
								<td>
									<span>Купить</span>
								</td>
							</tr>
						</table>
					</div>
					<div id="addInfo">
						<table>
							<tr id="deliveryPres">
								<td class="addInfoImg"><img src="img/delivery.png" alt=""></td>
								<td><span><b>Бесплатная доставка</b><br>по всей России</span></td>
							</tr>
							<tr id="supportPres">
								<td class="addInfoImg"><img src="img/support.png" alt=""></td>
								<td><span><b>Горячая линия</b><br>8 800 000-00-00</span></td>
							</tr>
							<tr id="presentPres">
								<td class="addInfoImg"><img src="img/present.png" alt=""></td>
								<td><span><b>Подарки</b><br>каждому покупателю</span></td>
							</tr>
						</table>
					</div>
				</div>
				<div class="clear"></div>
			</div>	
			<div id="mainFormSameProd" <?php if ($sameProdsCnt==0) {echo $disable;}; ?>>
				<div class="ProdNav">
					<p>Другие товары из категории «<?php echo $category; ?>»</p>
					<div id="sameProdNavRight" class="NavBtn ProdNavRight" <?php if ($sameProdsCnt < 5) {echo $disable;}?> onclick="sameProd(event);" style="background-image: url(img/list_btn_black_right.png);">
					</div>
					<div id="sameProdNavLeft" class="NavBtn ProdNavLeft" <?php if ($sameProdsCnt < 5) {echo $disable;}?> onclick="sameProd(event);"  style="background-image: url(img/list_btn_grey_left.png); cursor: auto;">
					</div>
				</div>
				<div id="sameProdList" data-sameProdListCat="<?php echo $categoryN; ?>" data-sameProdListCur="1">
					<?php
						if ($sameProds) { 
							foreach ($sameProds as $key => $sProd) {
								$sProdKey = $key + 1;
								if ($sProdKey==5) {
									break;
								}
								echo '<div data-product="'.$sProdKey.'">';
								echo '	<div class="ProdImg" style="background-image: url(img/products/'.$categoryN.'/'.$sProd['picture'].')"></div>';
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
						}
					?>
					<div class="clear"></div>
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
	<div id="testDiv"</div>>
</body>
</html>		