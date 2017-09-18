<?php
 session_start();
?>

<!DOCTYPE html>
<html>
<head>
	<title>Спорт Маг</title>
	<meta charset="utf-8">
	<link rel="stylesheet" type="text/css" href="css/common.css">
	<link rel="stylesheet" type="text/css" href="css/account.css">
	<script src="js/common.js"></script>
	
	<?php include_once 'php/change_person.php' ?>

	<?php include_once 'php/person_info.php' ?>

	<script>
		function checkNewPwd(event) {
			var pas = document.getElementById('newPas').value;
			var pass = document.getElementById('newPass').value;
			if (pas || pass) {
				if (pas != pass) {
					alert('Пароли не совпадают!');
			
	 				event = event || window.event;

	 				if (event.preventDefault) { // если метод существует
						event.preventDefault(); // то вызвать его
					} else { // иначе вариант IE8-:
						event.returnValue = false;
					}
				}
			}
		}

		var curCity = null;
		var curStr = null;
		var curHse = null;
		var curApp = null;

		document.addEventListener('DOMContentLoaded', function(){
    		curCity = document.getElementById('addrCity').value;
    		curStr = document.getElementById('addrStr').value;
    		curHse = document.getElementById('addrHse').value;
    		curApp = document.getElementById('addrApp').value;
		}, false);

		function checkNewAddr() {
    		var newCity = document.getElementById('addrCity').value;
    		var newStr = document.getElementById('addrStr').value;
    		var newHse = document.getElementById('addrHse').value;
    		var newApp = document.getElementById('addrApp').value;
			if (newCity != curCity || newStr != curStr || newHse != curHse || newApp != curApp) {
				document.getElementById('hidAddr').value = 'yes';
			}
		};

	</script>
</head>
<body  onload="update_cart_attr();">
	<div id="wrp">
		<div id="head">

			<?php include_once 'php/header.php' ?>

			<div id="winName">
				Личный кабинет
			</div>
		</div>
		<div id="body">
			<div id="mainForm">
				<form action="account.php" method="post">
					<div id="accountInfoForm">
						<h3>Ваши данные</h3>
						<h4>Контактное лицо [ФИО]:</h4>
						<input class="fontInForm styleOfForm AccFormWidth" type="text" name="userName" value=<?php echo '"'.$fio.'"'; ?> required>
						<h4>Контактный телефон:</h4>
						<input class="fontInForm styleOfForm AccFormWidth" type="tel" name="userPhone" value=<?php echo '"'.$phone.'"'; ?> pattern="\+7\-[0-9]{3}\-[0-9]{3}\-[0-9]{2}\-[0-9]{2}" title="+7-XXX-XXX-XX-XX">
						<h4>E-mail адрес:</h4>
						<input class="fontInForm styleOfForm AccFormWidth" type="email" name="email" value=<?php echo '"'.$mail.'"'; ?> placeholder="E-mail" disabled>
						<h3>Адрес доставки</h3>
						<h4>Город:</h4>
						<input class="fontInForm styleOfForm AccFormWidth" type="text" name="city" id="addrCity" value=<?php echo '"'.$city.'"'; ?>>
						<h4>Улица:</h4>
						<input class="fontInForm styleOfForm AccFormWidth" type="text" name="street" id="addrStr" value=<?php echo '"'.$street.'"'; ?>>
						<div class="accountAddrApp">
							<h4>Дом:</h4>
							<input class="fontInForm styleOfForm AccFormWidthApp" type="text" name="build" id="addrHse" value=<?php echo '"'.$house.'"'; ?>>
						</div>
						<div class="accountAddrApp" id="accountAddrAppM">
							<h4>Квартира:</h4>
							<input class="fontInForm styleOfForm AccFormWidthApp" type="text" name="appartment" id="addrApp" value=<?php echo '"'.$appartment.'"'; ?>>
						</div>	
						<div class="clear"></div>	
						<h3>Изменение пароля</h3>
						<h4>Пароль:</h4>
						<input class="fontInForm styleOfForm AccFormWidth" type="password" name="pas" id="newPas">
						<h4>Повторите пароль:</h4>
						<input class="fontInForm styleOfForm AccFormWidth" type="password" name="pasAgain" id="newPass">
						<input type=hidden name="addrchange" id="hidAddr" value="no">
					</div>
					<div id="orders">
						<h3>Ваши заказы</h3>
						<table id="accountOrdHistory">
							<tr>
								<td class="accountOrdInfo">
									<p class="accountOrdN">№1</p>
									<p class="accountOrdSum">[12 001руб.]</p>
									<p class="accountOrdDate">15.03.2017 в 11:30</p>
								</td>
								<td class="accountOrdStatus">
									<p>Доставлен</p>
								</td>
							</tr>
							<tr>
								<td class="accountOrdInfo">
									<p class="accountOrdN">№2304</p>
									<p class="accountOrdSum">[42 901руб.]</p>
									<p class="accountOrdDate">06.04.2017 в 22:17</p>
								</td>
								<td class="accountOrdStatus">
									<p>Ожидает доставки</p>
								</td>							
							</tr>
						</table>
						
					</div>
					<div class="clear"></div>
					<input id="saveBtn" class="redBtn" type="submit" value="Сохранить" onclick="checkNewPwd(event); checkNewAddr();" >
				</form>
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