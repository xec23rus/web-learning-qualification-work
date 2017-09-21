<?php
 session_start();
?>

<!DOCTYPE html>
<html>
<head>
	<title>Спорт Маг</title>
	<meta charset="utf-8">
	<link rel="stylesheet" type="text/css" href="css/common.css">
	<link rel="stylesheet" type="text/css" href="css/checkout.css">
	<script src="js/common.js"></script>
	<script src="js/nonfunc.js"></script>

	<?php include_once 'php/person_info.php' ?>	
	
</head>
<body>
	<div id="wrp">
		<div id="head">

			<?php include_once 'php/header.php' ?>		
		
			<div id="winName">
				Оформление заказа
			</div>
		</div>
		<div id="body">
			<div id="mainForm">
				<form id="orderForm" action="" method="post"> <!-- style="display: none;" -->
					<div class="outItem">
						<div data-outItemName="contacts" class="OINameOpen" onclick="toggleX('contacts');">
							<h2><span>1.</span> Контактная информация</h2>
						</div>
						<div data-outItemData="contacts">
							<div class="outUser">
								<!-- <h3>Для новых покупателей</h3> -->
								<h4>Контактное лицо (ФИО):</h4>
								<input class="outUserField" type="text" name="userName" autofocus value=<?php echo '"'.$fio.'"'; ?>>
								<h4>Контактный телефон:</h4>
								<input class="outUserField" type="text" name="userPhone" value=<?php echo '"'.$phone.'"'; ?>>
								<h4>E-mail:</h4>
								<input class="outUserField" type="Email" name="newEmail" value=<?php echo '"'.$mail.'"'; ?> autocomplete="on" pattern="([A-z0-9_.-]{1,})@([A-z0-9_.-]{1,}).([A-z]{2,8})" title="name@domain.com" placeholder="E-mail">
								<input id="next" class="redBtn" type="button" value="Продолжить" onclick="nextstep(1);">
							</div>
							<!-- <div class="outUser">
								<h3>Быстрый вход</h3>
								<h4>Ваш e-mail:</h4>
								<input class="outUserField" type="Email" name="email" autocomplete="on" pattern="([A-z0-9_.-]{1,})@([A-z0-9_.-]{1,}).([A-z]{2,8})" title="name@domain.com" placeholder="E-mail">
								<h4 id="h4sp">Пароль:</h4>
								<input class="outUserField" type="password" name="pas">
								<input id="outLogin" class="redBtn" type="button" value="Войти">
								<a href="#">Восстановить пароль</a>
							</div> -->
						</div>
					</div>
					<div id="firstLine"></div>
					<div class="outItem">
						<div data-outItemName="deliveryInfo" class="OINameClose" onclick="toggleX('deliveryInfo');">
							<h2><span>2.</span> Информация о доставке</h2>
						</div>
						<div data-outItemData="deliveryInfo" style="display: none;">
							<div id="outDeliveryAddress">
								<h3>Адрес доставки</h3>
								<h4>Город:</h4>
								<input class="outUserField" type="text" name="city" value=<?php echo '"'.$city.'"'; ?>>
								<h4>Улица:</h4>
								<input class="outUserField" type="text" name="street" value=<?php echo '"'.$street.'"'; ?>>
								<div class="outDeliveryAddressApp">
									<h4>Дом:</h4>
									<input class="outAddrField" type="text" name="build" value=<?php echo '"'.$house.'"'; ?>>
								</div>
								<div class="outDeliveryAddressApp">
									<h4>Квартира:</h4>
									<input class="outAddrField" type="text" name="appartment" value=<?php echo '"'.$appartment.'"'; ?>>
								</div>
								<input id="next" class="redBtn" type="button" value="Продолжить" onclick="nextstep(2);">
							</div>
							<div id="outDeliveryMethod">
								<h3>Способ доставки</h3>
								<div id="outDeliveryMethodList">
									<input type="radio" name="deliveryMethod" value="0" onclick="radioCopy(this);" checked><div>Курьерская доставка <br>с оплатой при получении</div>
									<input type="radio" name="deliveryMethod" value="1" onclick="radioCopy(this);" ><div>Почта России <br>с наложенным платежом</div>
									<input type="radio" name="deliveryMethod" value="2" onclick="radioCopy(this);" ><div>Доставка через терминалы <br>QIWI Post</div>
								</div>
							</div>
							<div id="outDeliveryComment">
								<h3>Комментарий к заказу</h3>
								<h4>Введите ваш комментарий:</h4>
								<textarea id="outDeliveryCommentField" name="comment" onblur="copyHTML(this.value, '#delivComm');"></textarea>
							</div>
						</div>					
					</div>
					<div id="secLine"></div>
					<div class="outItem">
						<div data-outItemName="confirm" class="OINameClose" onclick="toggleX('confirm');">
							<h2><span>3.</span> Подтверждение заказа</h2>
						</div>
						<div data-outItemData="confirm" style="display: none;">
							<div id="outConfirmListHeader">
								<h3>Состав заказа:</h3>
								<table>
									<tr>
										<td id="outTblProductCol">Товар</td>
										<td id="outTblPriceCol" align="right">Стоимость</td>
										<td id="outTblCountCol" align="center">Количество</td>
										<td id="outTblResCol" align="center">Итого</td>
									</tr>
								</table>
							</div>
							<div id="outConfirmLine"></div>
							<div id="outConfirmList">
								<table>
									<tr>
										<td class="outTblProductCol">Велик</td>
										<td class="outTblPriceCol" align="right">1 256<span>руб.</span></td>
										<td class="outTblCountCol" align="center">1</td>
										<td class="outTblResCol" align="center">1 256<span>руб.</span></td>
									</tr>									
									<tr>
										<td class="outTblProductCol">Мопед</td>
										<td class="outTblPriceCol" align="right">7 256<span>руб.</span></td>
										<td class="outTblCountCol" align="center">1</td>
										<td class="outTblResCol" align="center">7 256<span>руб.</span></td>
									</tr>
									<tr>
										<td class="outTblProductCol">Хлеб</td>
										<td class="outTblPriceCol" align="right">56<span>руб.</span></td>
										<td class="outTblCountCol" align="center">1</td>
										<td class="outTblResCol" align="center">56<span>руб.</span></td>
									</tr>
									<tr>
										<td class="outTblProductCol">Яйца</td>
										<td class="outTblPriceCol" align="right">5,6<span>руб.</span></td>
										<td class="outTblCountCol" align="center">10</td>
										<td class="outTblResCol" align="center">56<span>руб.</span></td>
									</tr>																		
								</table>								
							</div>
							<div id="outConfirmSum">
								<div id="outRes">
									25 325руб.
								</div>
								<div id="outResTerm">
									Итого:
								</div>
							</div>
							<div id="outConfirmCommon">
								<h3>Доставка:</h3>
								<table>
									<tr class="outDeliveryTermLight">
										<td id="outDeliveryCol0">Контактное лицо (ФИО):</td>
										<td id="outDeliveryCol1" colspan="2">Город:</td>
									</tr>
									<tr class="outDeliveryData">
										<td><?php echo $fio; ?></td>
										<td colspan="2"><?php echo $city; ?></td>
									</tr>
									<tr class="outDeliveryTermLight">
										<td>Контактный телефон:</td>
										<td colspan="2">Улица:</td>
									</tr>
									<tr class="outDeliveryData">
										<td><?php echo $phone; ?></td>
										<td colspan="2"><?php echo $street; ?></td>
									</tr>	
									<tr class="outDeliveryTermLight">
										<td>E-mail:</td>
										<td id="outDeliveryCol2">Дом</td>
										<td>Квартира</td>
									</tr>	
									<tr class="outDeliveryData">
										<td><?php echo $mail; ?></td>
										<td><?php echo $house; ?></td>
										<td><?php echo $appartment; ?></td>
									</tr>				
								</table>
								<table>
									<tr class="outDeliveryTermLight"><td>Способ доставки:</td></tr>
									<tr class="outDeliveryDataSmall">
										<td>
											<span data-deliveryType='0'>Курьерская доставка с оплатой при получении</span>
											<span class="disable" data-deliveryType='1'>Почта России с наложенным платежом</span>
											<span class="disable" data-deliveryType='2'>Доставка через терминалы QIWI Post</span>
										</td>
									</tr>
									<tr class="outDeliveryTermLight"><td>Комментарий к заказу:</td></tr>
									<tr class="outDeliveryDataSmall"><td id="delivComm">Текс комментария</td></tr>
								</table>
								<div class="clear"></div>
							</div>
							<input id="confirmBtn" class="redBtn" type="button" value="Подтвердить заказ" onclick="nextstep(3);">
						</div>					
					</div>
				</form>
				<div id="confirmation" style="display: none;"> <!-- style="display: none;" -->
					<h2>Заказ № 24415 <span>успешно оформлен</span></h2>
					<p>
						Спасибо за ваш заказ. <br>
						<br>
						В ближайшее время с вами свяжется оператор <br>
						для уточнения времени доставки.
					</p>	
					<a href="index.php"><button id="outBackInStoreBtn" class="redBtn">Вернуться в магазин</button></a>			
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