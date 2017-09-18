function main_page() {
	//window.open('index.php'); //open in new winwow
	top.location.href='index.php';
}

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

function changej(event) {
	if (typeof(event.srcElement.dataset.previmg) != "undefined" && event.srcElement.dataset.previmg !== null) {
		var newJpgNum = event.srcElement.dataset.previmg;
		if (newJpgNum != 'A') {
			listel = document.querySelectorAll('[data-prevImg]');
			for (var i = 0; i < listel.length; i++) {
				//console.log(listel[i].dataset.previmg);
				if (listel[i].dataset.previmg == 'A') {
					var curJpg = i + 1;
					var elCurJpg = document.querySelector('[data-prevImg="A"]');
					var elNewJpg = document.querySelector('[data-prevImg="'+newJpgNum+'"]');
					elCurJpg.dataset.previmg = curJpg;
    				elCurJpg.className = "prevImg";
    				elNewJpg.dataset.previmg = 'A';
    				elNewJpg.className = "curImg";
    				document.getElementById('bigImg').style.backgroundImage = elNewJpg.style.backgroundImage;
    				break;
    			}
  			}
		}				
	} else {
		var listel = document.querySelectorAll('[data-prevImg]');
		var jpgCnt = listel.length;
		//console.log('jpgCnt='+jpgCnt);
		if (jpgCnt > 1) {
			for (var i = 0; i < jpgCnt; i++) {
    			//console.log(listel[i].dataset.previmg);
    			if (listel[i].dataset.previmg == 'A') {
    				var curJpg = i + 1;
    				if (event.srcElement.id == 'prodImgListNext') {
    					var newJpgNum = curJpg + 1;
    					//console.log(newJpgNum);
    					if (newJpgNum > jpgCnt) {
    						newJpgNum = 1;
    						//console.log('new='+newJpgNum);
    					}
    				} else {
     					var newJpgNum = curJpg - 1;
    					if (newJpgNum < 1) {
    						newJpgNum = jpgCnt;
    					}   							
    				}
    				var elCurJpg = document.querySelector('[data-prevImg="A"]');
    				var elNewJpg = document.querySelector('[data-prevImg="'+newJpgNum+'"]');
    				elCurJpg.dataset.previmg = curJpg;
    				elCurJpg.className = "prevImg";
    				elNewJpg.dataset.previmg = 'A';
    				elNewJpg.className = "curImg";
    				document.getElementById('bigImg').style.backgroundImage = elNewJpg.style.backgroundImage;
    				break;
    			}
  			}					
		}
	}

/*
	listel = document.querySelectorAll('[data-prevImg]');
	console.log(event.srcElement.dataset.previmg);
	console.log(event);
	el = document.querySelector('[data-prevImg="A"]');
	console.log(el.dataset.previmg);
	listel = document.querySelectorAll('[data-prevImg]');
	console.log(listel);*/
}

/*получаем список товаров тойже категории для product.php*/
function sameProd(event) {
	//alert('test');
	// создаем объект для запроса к серверу
	var req = getXmlHttp()  
       
	// (2)
	// span рядом с кнопкой
	// в нем будем отображать ход выполнения
	//var statusElem = document.getElementById('login_status') 

	//берем значение категории и номера страницы
	var curCat = document.getElementById('sameProdList').dataset.sameprodlistcat;
	var curPage = document.getElementById('sameProdList').dataset.sameprodlistcur;
	var curNewPage = document.getElementById('sameProdStat').dataset.sprodnext;
	var leftNav = document.getElementById('sameProdNavLeft');
	var rightNav = document.getElementById('sameProdNavRight');
	//alert(new_mail);
	//console.log(curNewPage);
	if (event.srcElement.id == 'sameProdNavRight') {
		if (curNewPage == 5) {curPage++;} else {return;}} 
	else if (curPage > 1) {curPage--;}
	else {return;};

		
	req.onreadystatechange = function() {  
	    // onreadystatechange активируется при получении ответа сервера

		if (req.readyState == 4) { 
	      // если запрос закончил выполняться

			//statusElem.innerHTML = req.statusText; // показать статус (Not Found, ОК..)

			if(req.status == 200) { 
		        // если статус 200 (ОК) - выдать ответ пользователю
				//alert("Ответ сервера: "+req.responseText);
				//проверим результат
				if(req.responseText == '-1') {
					//document.getElementById('res').innerHTML='Пользователь с такой почтой не найден!';
					alert('Упс, что-то пошло не так!');
				} 
				else {
					document.getElementById('sameProdList').innerHTML=req.responseText;
					document.getElementById('sameProdList').dataset.sameprodlistcur = curPage;
					if (curPage !=1 ) {
						leftNav.style.cursor = 'pointer';
						leftNav.style.backgroundImage = 'url(img/list_btn_black_left.png)';
					} else {
						leftNav.style.cursor = 'auto';
						leftNav.style.backgroundImage = 'url(img/list_btn_grey_left.png)';
					};
					if (document.getElementById('sameProdStat').dataset.sprodnext == 5) {
						rightNav.style.cursor = 'pointer';
						rightNav.style.backgroundImage = 'url(img/list_btn_black_right.png)';
					} else {
						rightNav.style.cursor = 'auto';
						rightNav.style.backgroundImage = 'url(img/list_btn_grey_right.png)';
					}
					//alert('Добро пожаловать!');
				}
			}
			// тут можно добавить else с обработкой ошибок запроса
		}
	}

	    // (3) задать адрес подключения
	req.open('GET', '/diplom/php/product_list.php?type=same&sprodpage='+curPage+'&sprodup='+curCat, true);  

	// объект запроса подготовлен: указан адрес и создана функция onreadystatechange
	// для обработки ответа сервера
		 
	   // (4)
	req.send(null);  // отослать запрос
  
	    // (5)
	//statusElem.innerHTML = 'Ожидаю ответа сервера...' 			
}

/*добавляем продукты в корзину*/
function add_product(reason = 0) {
/*
	var lCartPprice = document.getElementById('cart_sum');
	var lCartCnt = document.getElementById('cart_item');
	var lPrice = '1 999';
	var lCnt = 22;
	var lCntTxt = ' предмет';

	if ((lCnt % 10 == 2 || lCnt % 10 == 3 || lCnt % 10 == 4) && (lCnt % 100 != 12 || lCnt % 100 != 13 || lCnt % 100 != 14)) {
		lCntTxt = ' предмета';
	} else if ((lCnt % 10 == 1) && (lCnt % 100 != 11)) {
		lCntTxt = ' предмет';
	} else if (lCnt > 4) {
		lCntTxt = ' предметов';
	};

	lCartPprice.innerHTML = lPrice+' <span>руб.</span>';
	lCartCnt.innerHTML = lCnt + lCntTxt;

*/
	var req = getXmlHttp()  

	if (reason == 0) {
		var prodId = document.getElementById('productId').innerHTML;
		var prodAttrA = document.getElementById('productAttrValA').value;
		var cartAdjCnt = 1;		
	}
	else {
		var cartCurProdData = document.querySelector('[data-cartProdID="'+cartProdId+'"]');
		var prodId = cartProdN;
		var prodAttrA = cartProdAttr1;
		if (cartAction == 'cartListCountPlus') {
			var cartAdjCnt = 1;
		} 
		else if (cartAction == 'cartListCountMinus') {
			var cartAdjCnt = -1;
		}
		else if (cartAction == 'cartListDel') {
			var cartAdjCnt = -9999999;
		};
		if (cartAdjCnt < 0) {
			var cartCurProdCnt = cartCurProdData.getElementsByClassName('cartListCountRes');
			if(cartCurProdCnt) { 
				for(var i=0; i<cartCurProdCnt.length; i++) {  
					if (cartCurProdCnt[i].innerHTML == 0) {return;}
				};
			};
		};
	};

	//console.log(prodId);
	//console.log(prodAttrA);

		
	req.onreadystatechange = function() {  

		if (req.readyState == 4) { 

			if(req.status == 200) { 

				if(req.responseText == '-1') {

					alert('Упс, что-то пошло не так!');

				} 
				else {
					var resXml = req.responseXML;
					//console.log(resXml);
					var xmlPrice = resXml.getElementsByTagName('price');
					if(xmlPrice) { 
						for(var i=0; i<xmlPrice.length; i++) {  
						   var price = xmlPrice[i].innerHTML;   
						}
					};
					var xmlCnt = resXml.getElementsByTagName('cnt');
					if(xmlCnt) { 
						for(var i=0; i<xmlCnt.length; i++) {  
						   var cnt = xmlCnt[i].innerHTML;   
						}
					};
					var xmlProdCnt = resXml.getElementsByTagName('prod_cnt');
					if(xmlProdCnt) { 
						for(var i=0; i<xmlProdCnt.length; i++) {  
						   var prod_cnt = xmlProdCnt[i].innerHTML;   
						}
					};					

					if (price < 0) {
						var xmlErr = resXml.getElementsByTagName('err');
						if(xmlErr) { 
							for(var i=0; i<xmlErr.length; i++) {  
							   var err = xmlErr[i].innerHTML;   
							}
						};
						if (err=1) {
							alert ('Для работы с корзиной необходимо авторизоваться! Войдите или зарегестрируйтесь пожалуйста.')
						} else {
							alert ('Что-то пошло не так! err='+err);
						}
						return;
					}

					var lCntTxt = ' предмет';
					if ((cnt % 10 == 2 || cnt % 10 == 3 || cnt % 10 == 4) && (cnt % 100 != 12 || cnt % 100 != 13 || cnt % 100 != 14)) {
						lCntTxt = ' предмета';
					} else if ((cnt % 10 == 1) && (cnt % 100 != 11)) {
						lCntTxt = ' предмет';
					} else if (cnt > 4) {
						lCntTxt = ' предметов';
					};
					
					document.getElementById('cart_sum').innerHTML=price+' <span>руб.</span>';
					document.getElementById('cart_item').innerHTML='<span id="cart_cnt">'+cnt+'</span> '+lCntTxt;

					if (reason == 1) {
						var cartCurProdCnt = cartCurProdData.getElementsByClassName('cartListCountRes');
						if(cartCurProdCnt) { 
							for(var i=0; i<cartCurProdCnt.length; i++) {  
						   	cartCurProdCnt[i].innerHTML = prod_cnt;   
							}
						};	
						var cartCurProdPrice = cartCurProdData.getElementsByClassName('cartListPrice');
						if(cartCurProdPrice) { 
							for(var i=0; i<cartCurProdPrice.length; i++) {  
						   	var prod_pricec = cartCurProdPrice[i].innerHTML;   
							}
						};		

						var prod_price = '';
						for (var i = 0; i < prod_pricec.length; i++) {
							if (prod_pricec[i] == ' ') {continue} 
							else if (prod_pricec[i] == '<') {break}
							else {prod_price = prod_price + prod_pricec[i]}
						}
						prod_price = Number(prod_price);
						prod_price = prod_price * prod_cnt;
						prod_pricec = String(prod_price);

						var tmp = 0;
						var prod_prc = '';
						for (var i = prod_pricec.length - 1; i >= 0; i--) {
							tmp++;
							prod_prc = prod_pricec[i] + prod_prc;
							if (tmp%3 == 0) {prod_prc = ' ' + prod_prc;} 
						}

						//console.log(prod_price);				
						var cartCurProdSumPrice = cartCurProdData.getElementsByClassName('cartListSum');
						if(cartCurProdSumPrice) { 
							for(var i=0; i<cartCurProdSumPrice.length; i++) {  
						   	cartCurProdSumPrice[i].innerHTML = prod_prc+'<span>руб.</span>';   
							}
						};	

						document.getElementById('cartResSum').innerHTML=price+'руб.';											
					}
					//alert(price);
					/*
					document.getElementById('sameProdList').innerHTML=req.responseText;
					document.getElementById('sameProdList').dataset.sameprodlistcur = curPage;
					if (curPage !=1 ) {
						leftNav.style.cursor = 'pointer';
						leftNav.style.backgroundImage = 'url(img/list_btn_black_left.png)';
					} else {
						leftNav.style.cursor = 'auto';
						leftNav.style.backgroundImage = 'url(img/list_btn_grey_left.png)';
					};
					if (document.getElementById('sameProdStat').dataset.sprodnext == 5) {
						rightNav.style.cursor = 'pointer';
						rightNav.style.backgroundImage = 'url(img/list_btn_black_right.png)';
					} else {
						rightNav.style.cursor = 'auto';
						rightNav.style.backgroundImage = 'url(img/list_btn_grey_right.png)';
					}
					*/
				}
			}
		}
	}
	req.open('GET', '/diplom/php/add_product.php?prod='+prodId+'&cnt='+cartAdjCnt+'&attra='+prodAttrA+'&attrb=', true);  

	req.send(null);  	
}

function update_cart_attr() {
	var cnt = document.getElementById('cart_cnt').innerHTML;

	var lCntTxt = ' предмет';
	if ((cnt % 10 == 2 || cnt % 10 == 3 || cnt % 10 == 4) && (cnt % 100 != 12 || cnt % 100 != 13 || cnt % 100 != 14)) {
		lCntTxt = ' предмета';
	} else if ((cnt % 10 == 1) && (cnt % 100 != 11)) {
		lCntTxt = ' предмет';
	} else if (cnt > 4 || cnt == 0) {
		lCntTxt = ' предметов';
	};
	document.getElementById('cart_item').innerHTML='<span id="cart_cnt">'+cnt+'</span> '+lCntTxt;
}

/*прокрутка популярных товаров*/
function hotProd(event) {

	var req = getXmlHttp()  

	//берем значение категории и номера страницы
	var curPage = document.getElementById('topProdList').dataset.hotprodlistcur;
	var curNewPage = document.getElementById('hotProdStat').dataset.hprodnext;
	var leftNav = document.getElementById('hotProdNavLeft');
	var rightNav = document.getElementById('hotProdNavRight');

	if (event.srcElement.id == 'hotProdNavRight') {
		if (curNewPage == 5) {curPage++;} else {return;}} 
	else if (curPage > 1) {curPage--;}
	else {return;};

		
	req.onreadystatechange = function() {  

		if (req.readyState == 4) { 

			if(req.status == 200) { 

				if(req.responseText == '-1') {
					alert('Упс, что-то пошло не так!');
				} 
				else {
					document.getElementById('topProdList').innerHTML=req.responseText;
					document.getElementById('topProdList').dataset.hotprodlistcur = curPage;
					if (curPage !=1 ) {
						leftNav.style.cursor = 'pointer';
						leftNav.style.backgroundImage = 'url(img/list_btn_black_left.png)';
					} else {
						leftNav.style.cursor = 'auto';
						leftNav.style.backgroundImage = 'url(img/list_btn_grey_left.png)';
					};
					if (document.getElementById('hotProdStat').dataset.hprodnext == 5) {
						rightNav.style.cursor = 'pointer';
						rightNav.style.backgroundImage = 'url(img/list_btn_black_right.png)';
					} else {
						rightNav.style.cursor = 'auto';
						rightNav.style.backgroundImage = 'url(img/list_btn_grey_right.png)';
					}
				}
			}
		}
	}

	req.open('GET', '/diplom/php/product_list.php?type=hot&sprodpage='+curPage+'&sprodup=0', true);  

	req.send(null);  

}

/*прокрутка новых товаров*/
function newProd(event) {

	var req = getXmlHttp()  

	//берем значение категории и номера страницы
	var curPage = document.getElementById('NewProdList').dataset.newprodlistcur;
	var curNewPage = document.getElementById('newProdStat').dataset.nprodnext;
	var leftNav = document.getElementById('newProdNavLeft');
	var rightNav = document.getElementById('newProdNavRight');

	if (event.srcElement.id == 'newProdNavRight') {
		if (curNewPage == 9) {curPage++;} else {return;}} 
	else if (curPage > 1) {curPage--;}
	else {return;};

		
	req.onreadystatechange = function() {  

		if (req.readyState == 4) { 

			if(req.status == 200) { 

				if(req.responseText == '-1') {
					alert('Упс, что-то пошло не так!');
				} 
				else {
					document.getElementById('NewProdList').innerHTML=req.responseText;
					document.getElementById('NewProdList').dataset.newprodlistcur = curPage;
					if (curPage !=1 ) {
						leftNav.style.cursor = 'pointer';
						leftNav.style.backgroundImage = 'url(img/list_btn_black_left.png)';
					} else {
						leftNav.style.cursor = 'auto';
						leftNav.style.backgroundImage = 'url(img/list_btn_grey_left.png)';
					};
					if (document.getElementById('newProdStat').dataset.nprodnext == 9) {
						rightNav.style.cursor = 'pointer';
						rightNav.style.backgroundImage = 'url(img/list_btn_black_right.png)';
					} else {
						rightNav.style.cursor = 'auto';
						rightNav.style.backgroundImage = 'url(img/list_btn_grey_right.png)';
					}
				}
			}
		}
	}

	req.open('GET', '/diplom/php/product_list.php?type=new&sprodpage='+curPage+'&sprodup=0', true);  

	req.send(null);  

}
/*изменяем количество товаров в корзине*/
function change_cart(event) {
	/*
	console.log(event);
	console.log(event.srcElement.className);
	console.log(event.srcElement.offsetParent.parentElement.dataset.cartprodn);
	console.log(event.srcElement.parentElement.dataset.cartprodn);
	*/
	cartAction = event.srcElement.className;
	if (cartAction == 'cartListDel') {
		cartProdN = event.srcElement.parentElement.dataset.cartprodn;
		cartProdAttr1 = event.srcElement.parentElement.dataset.cartprodattr1;
		cartProdAttr2 = event.srcElement.parentElement.dataset.cartprodattr2;
		cartProdId = event.srcElement.parentElement.dataset.cartprodid;
	} 
	else {
		cartProdN = event.srcElement.offsetParent.parentElement.dataset.cartprodn;
		cartProdAttr1 = event.srcElement.offsetParent.parentElement.dataset.cartprodattr1;
		cartProdAttr2 = event.srcElement.offsetParent.parentElement.dataset.cartprodattr2;
		cartProdId = event.srcElement.offsetParent.parentElement.dataset.cartprodid;		
	}
	//console.log(cartAction);
	//console.log(cartProdN);
	//console.log(cartProdAttr1);
	//console.log(cartProdAttr2);
	//console.log(cartProdId);
	add_product(1);
}