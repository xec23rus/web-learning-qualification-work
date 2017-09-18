		<div id="logo">
			<a class="refBox" name="top" href="index.php"><h1>SPORT <span>SHOP</span></h1></a>
		</div>
		<div id="menu">
			<ul id="nav">
				<li><a class="refBox" href="category.php?category=5&pg=1">ВЕЙКБОРДЫ</a></li>
				<li><a class="refBox" href="category.php">ДВУХКОЛЕСНЫЕ СКЕЙТЫ</a></li>
				<li><a class="refBox" href="category.php">РОЛИКОВЫЕ КОНЬКИ</a></li>
				<li><a class="refBox" href="category.php?category=3&pg=1">САМОКАТЫ</a></li>
				<li><a class="refBox" href="category.php?category=4&pg=1">СНОУБОРДЫ</a></li>
				<li><a class="refBox" href="category.php">ТЕННИСНЫЕ РАКЕТКИ</a></li>
			</ul>
<?php	
	if (isset($_SESSION['supermagName'])) {
		echo '	<ul id="usr">';
		echo '		<li> <a class="noBorder" href="index.php?logout=y" title="Выход"><img src="img/logout.png"></a> </li>';
		echo ' 		<li> <img src="img/usr_icon.png" align="left"> <a class="ent" href="account.php" title="Мой кабинет">'.$_SESSION['supermagName'].'</a> </li>';
		echo '	</ul>';
	}	
	else {
		echo '	<ul id="usr">';
		echo '		<li> <a href="reg.php">Регистрация</a> </li>';
		echo '		<li> <img src="img/usr_icon.png" align="left"> <a class="ent" href="login.php">Войти</a> </li>';
		echo '	</ul>';
	}
?>			
		</div>
		<div id="line"></div>
		<div id="cart">
			<img id="cart_img" src="img/cart.png">
			<a class="refBox" href="cart.php"></a>
<?php 
	if (isset($_SESSION['supermagPrice'])) {
		echo '		<p id="cart_sum">'.$_SESSION['supermagPrice'].' <span>руб.</span></p>';
		echo '		<p id="cart_item"><span id="cart_cnt">'.$_SESSION['supermagCnt'].'</span> предметов</p>';
	}
	else {
		echo '		<p id="cart_sum">0 <span>руб.</span></p>';
		echo '		<p id="cart_item"><span id="cart_cnt">0</span> предметов</p>';		
	}
?>
		</div>