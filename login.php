<?php
 session_start();
?>

<!DOCTYPE html>
<html>
<head>
	<title>Спорт Маг</title>
	<meta charset="utf-8">
	<link rel="stylesheet" type="text/css" href="css/common.css">
	<link rel="stylesheet" type="text/css" href="css/autent.css">

<script>
	function getXmlHttp(){
		var xmlhttp;
		try {
			xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			try {
				xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (E) {
				xmlhttp = false;
			}
		}
		if (!xmlhttp && typeof XMLHttpRequest!='undefined') {
			xmlhttp = new XMLHttpRequest();
		}
		return xmlhttp;
	}

	function login(event) {
		// создаем объект для запроса к серверу
		var req = getXmlHttp()  
       
        // (2)
		// span рядом с кнопкой
		// в нем будем отображать ход выполнения
		//var statusElem = document.getElementById('login_status') 
	
		//берем значение поля с мылом
		var mail = document.getElementById('mail').value;
		var pass = document.getElementById('pass').value;
		//alert(new_mail);
	
		req.onreadystatechange = function() {  
	        // onreadystatechange активируется при получении ответа сервера

			if (req.readyState == 4) { 
	            // если запрос закончил выполняться

				//statusElem.innerHTML = req.statusText; // показать статус (Not Found, ОК..)

				if(req.status == 200) { 
	                 // если статус 200 (ОК) - выдать ответ пользователю
					//alert("Ответ сервера: "+req.responseText);
					//проверим результат
					if(req.responseText == '0') {
						//document.getElementById('res').innerHTML='Пользователь с такой почтой не найден!';
						alert('Пользователь с такой почтой не найден!');
					}
					else if (req.responseText == '-1') {
						//document.getElementById('res').innerHTML='Пароль не подходит!';
						alert('Пароль не подходит!');
					}
					else if (req.responseText == '-999') {
						//document.getElementById('res').innerHTML='Упс, что-то пошло не так!';
						alert('Упс, что-то пошло не так!');
					} 
					else {
						//document.getElementById('res').innerHTML='Добро пожаловать!';
						alert('Добро пожаловать!');
						document.getElementById('loginF').submit();
					}
				}
				// тут можно добавить else с обработкой ошибок запроса
			}

 			event = event || window.event;

 			if (event.preventDefault) { // если метод существует
				event.preventDefault(); // то вызвать его
			} else { // иначе вариант IE8-:
				event.returnValue = false;
			}
		}

	       // (3) задать адрес подключения
		req.open('GET', '/diplom/php/check_login.php?mail='+mail+'&pass='+pass, true);  

		// объект запроса подготовлен: указан адрес и создана функция onreadystatechange
		// для обработки ответа сервера
	 
	        // (4)
		req.send(null);  // отослать запрос
  
	        // (5)
		//statusElem.innerHTML = 'Ожидаю ответа сервера...' 
	}

</script>

</head>
<body>
	<div id="wrp">
		<div id="head">
			
			<?php include_once 'php/header.php' ?>

			<div id="winName">
				Вход
			</div>
		</div>
		<div id="body">
			<div id="mainForm">
				<div id="loginForm">
					<form id="loginF" action="index.php" method="post">
						<h3>Зарегистрированный пользователь</h3>
						<p class="loginDsc">Email адрес:</p>
						<input class="loginField" id="mail" type="Email" name="email" autofocus required autocomplete="on" pattern="([A-z0-9_.-]{1,})@([A-z0-9_.-]{1,}).([A-z]{2,8})" title="name@domain.com" placeholder="E-mail">
						<p class="loginDsc">Пароль:</p>
						<input class="loginField" id="pass" type="password" name="pas" required>
						<input id="loginBtn" type="submit" value="Войти" onclick="login(event)">
						<a href="#">Забыли пароль?</a>
					</form>
				</div>
				<div id="regForm">
					<h3>Новый пользователь</h3>
					<form action="reg.html" method="post">
						<input id="regBtn" class="redBtn" type="submit" value="Зарегистрироваться">
					</form>
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