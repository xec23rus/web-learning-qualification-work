<?php
 session_start();
?>

<!DOCTYPE html>
<html>
<head>
	<title>Спорт Маг</title>
	<meta charset="utf-8">
	<link rel="stylesheet" type="text/css" href="css/common.css">
	<link rel="stylesheet" type="text/css" href="css/cart.css">
	<script src="js/common.js"></script>

	<?php include_once 'php/cart_info.php' ?>

</head>
<body onload="update_cart_attr();">
	<div id="wrp">
		<div id="head">
			
			<?php include_once 'php/header.php' ?>

			<div id="winName">
				Корзина
			</div>
		</div>
		<div id="body">
			<div id="mainForm">
				<div id="cartListProd">
					<table>
						<tr id="cartListTitle">
							<td id="cartListTitleProd" colspan="2">Товар</td>
							<td align="center">Доступность</td>
							<td align="right">Стоимость</td>
							<td align="center">Количество</td>
							<td align="center">Итого</td>
							<td></td>
						</tr>
<?php
				if (!$noAuth) {
					if ($cartArray) {
						foreach ($cartArray as $cKey => $cartProd) {
							$in_stock = 'Есть в наличии';
							if ($cartProd['in_stock'] == 0) {
								$in_stock = 'Нет в наличии';
							}
							$cartProdPriceSum = number_format(($cartProd['price'] * $cartProd['cnt']),0,'.',' ');
							$cartProdPrice = number_format($cartProd['price'],0,'.',' ');
							echo '
						<tr data-cartProdN='.$cartProd['prod_n'].' data-cartProdAttr1='.$cartProd['attr1'].' data-cartProdAttr2='.$cartProd['attr2'].' data-cartProdID='.$cartProd['prod_n'].'.'.$cartProd['attr1'].'.'.$cartProd['attr2'].'>
							<td class="cartListImg">
								<div style="background-image: url(img/products/'.$cartProd['prod_up'].'/'.$cartProd['pic'].')"></div>
							</td>
							<td class="cartListName"><a href="product.php?id='.$cartProd['prod_n'].'">'.$cartProd['name'].'</a></td>
							<td class="cartListPos" align="center">'.$in_stock.'</td>
							<td class="cartListPrice" align="right">'.$cartProdPrice.'<span>руб.</span></td>
							<td class="cartListCount" align="center">
								<div class="cartListCountChange">
									<div class="cartListCountMinus" onclick="change_cart(event);">-</div>
									<div class="cartListCountRes">'.$cartProd['cnt'].'</div>
									<div class="cartListCountPlus" onclick="change_cart(event);">+</div>
								</div>
							</td>
							<td class="cartListSum" align="center">'.$cartProdPriceSum.'<span>руб.</span></td>
							<td class="cartListDel" align="center" onclick="change_cart(event);" style="background-image: url(img/remove.png)"></td>
						</tr>					
							';

/*
							if ($cartProd['attr1'] > 0) {
								echo $cartProd['attr1'].'-';
								echo $cartProd['color'].'</br>';
							}

							<img src="">
							*/
						}
					}
				}
?>
					</table>
				</div>
				<div id="cartMan">
					<div id="cartBack">
						<!-- ссылка на ту страницу, с которой пришли в корзину -->
						<a href="index.php"><button id="outBackBtn">Вернуться к покупкам</button></a> 
					</div>
					<div id="cartOut">
						<table>
							<tr>
								<td>Итого:</td>
								<td id="cartResSum" align="right"><?php echo $cartPrice;?>руб.</td>
							</tr>
						</table>
						<?php if (isset($_SESSION['supermagUserId']) & $cartPrice != '0') {
							echo '<a href="checkout.php"><button id="outBtn" class="redBtn" type="submit">Оформить заказ</button></a>';
						} 
						else {
							echo '<a href="#"><button id="outBtnG" class="redBtn" type="submit">Оформить заказ</button></a>';
						}
						?>
						
					</div>
					<div class="clear"></div>
				</div>
			</div>
		</div>
		<div id="footer">
			<p>Шаблон для экзаменационного задания.<br>
			Разработан специально для «Всероссийской Школы Программирования»<br>
			http://bedev.ru/</p>
			<a href="#top">Наверх <img src="img/up.png"></a>
		</div>
		<div id="footerNull"></div>
	</div>
</body>
</html>