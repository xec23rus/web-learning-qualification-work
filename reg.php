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

	function newPerson(event) {
		// создаем объект для запроса к серверу
		var req = getXmlHttp()  
       
        // (2)
		// span рядом с кнопкой
		// в нем будем отображать ход выполнения
		//var statusElem = document.getElementById('login_status') 
	
		//берем значение поля с мылом
		var mail = document.getElementById('mail').value;
		var pass = document.getElementById('pass').value;
		var passCon = document.getElementById('passCon').value;
		var fio = document.getElementById('fio').value;
		//alert(new_mail);

		if (pass == passCon) {
	
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
							alert('Пользователь с такой почтой существует!');
						}
						else if (req.responseText == '-999') {
							//document.getElementById('res').innerHTML='Упс, что-то пошло не так!';
							alert('Упс, что-то пошло не так!');
						} 
						else {
							//document.getElementById('res').innerHTML='Добро пожаловать!';
							alert('Регистрация завершена!');
							document.getElementById('newPersonForm').submit();
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
			req.open('GET', '/diplom/php/new_person.php?mail='+mail+'&pass='+pass+'&fio='+fio, true);  

			// объект запроса подготовлен: указан адрес и создана функция onreadystatechange
			// для обработки ответа сервера
	 
		        // (4)
			req.send(null);  // отослать запрос
  
		        // (5)
			//statusElem.innerHTML = 'Ожидаю ответа сервера...' 
		} else {
			alert('Пароли не совпадают!');
			
	 		event = event || window.event;

	 		if (event.preventDefault) { // если метод существует
				event.preventDefault(); // то вызвать его
			} else { // иначе вариант IE8-:
				event.returnValue = false;
			}			
		}
	}

</script>	
</head>
<body>
	<div id="wrp">
		<div id="head">
			
			<?php include_once 'php/header.php' ?>

			<div id="winName">
				Регистрация
			</div>
		</div>
		<div id="body">
			<div id="mainForm">
				<form action="index.php" method="post" id="newPersonForm">
					<div id="userNameForm">
						<p class="regDsc">Контактное лицо [ФИО]:</p>
						<input id="fio" class="loginField" type="text" name="userName" autofocus required>
						<p class="regDsc">E-mail адрес:</p>
						<input id="mail" class="loginField" type="Email" name="email" required autocomplete="on" pattern="([A-z0-9_.-]{1,})@([A-z0-9_.-]{1,}).([A-z]{2,8})" title="name@domain.com" placeholder="E-mail">
					</div>
					<div id="pasForm">
						<p class="regDsc">Пароль:</p>
						<input id="pass" class="loginField" type="password" name="pas" required>
						<p class="regDsc">Повторите пароль:</p>
						<input id="passCon" class="loginField" type="password" name="pasAgain" required>
					</div>
					<input id="regBtn" class="redBtn" type="submit" value="Зарегистрироваться" onclick="newPerson(event)">
				</form>
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