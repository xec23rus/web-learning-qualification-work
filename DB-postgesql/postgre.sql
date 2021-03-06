-- SQL Manager Lite for PostgreSQL 5.9.1.49393
-- ---------------------------------------
-- Хост         : localhost
-- База данных  : postgres
-- Версия       : PostgreSQL 9.6.2, compiled by Visual C++ build 1800, 64-bit



CREATE SCHEMA diplom AUTHORIZATION diplom;
SET check_function_bodies = false;
--
-- Definition for function test (OID = 16510) : 
--
SET search_path = diplom, pg_catalog;
CREATE FUNCTION diplom.test (
  i_mail character varying
)
RETURNS boolean
AS 
$body$
declare
l_id numeric;
begin
select id into l_id from diplom.person where trim(lower(email))=i_mail;
if l_id>0 then
	return true;
else return false;
end if;
end;
$body$
LANGUAGE plpgsql;
--
-- Definition for function test_arg (OID = 16520) : 
--
CREATE FUNCTION diplom.test_arg (
  i_id numeric,
  out o_name character varying,
  out o_mail character varying
)
RETURNS record
AS 
$body$

begin
select name, email into o_name, o_mail
from person where id=i_id;
end;

$body$
LANGUAGE plpgsql;
--
-- Definition for function find_mail (OID = 16528) : 
--
CREATE FUNCTION diplom.find_mail (
  i_mail character varying = 'no'::character varying
)
RETURNS numeric
AS 
$body$
declare
l_id numeric;
begin
select coalesce(max(id),0) into l_id from diplom.person where trim(lower(email))=trim(lower(i_mail));
return l_id;
end; 
$body$
LANGUAGE plpgsql;
--
-- Definition for function check_pwd (OID = 16531) : 
--
CREATE FUNCTION diplom.check_pwd (
  i_id numeric = 0,
  i_pwd character varying = 'no'::character varying
)
RETURNS boolean
AS 
$body$
declare
l_id numeric;
begin
	l_id := 0;
	select coalesce(max(id),0) into l_id from diplom.person where id=i_id and password=i_pwd;
	if l_id > 0 then
		return TRUE;
	else
		return FALSE;
	end if;
end;
$body$
LANGUAGE plpgsql;
--
-- Definition for function login (OID = 16596) : 
--
CREATE FUNCTION diplom.login (
  i_mail character varying = 'no@no.no'::character varying,
  i_pwd character varying = 'no'::character varying
)
RETURNS numeric
AS 
$body$
DECLARE
  l_person_n NUMERIC := 0;
  l_chk_pwd BOOLEAN := FALSE;
  l_mc NUMERIC :=0;
  l_mc_char VARCHAR(32) := '0';
BEGIN
  SELECT n INTO l_person_n FROM diplom.find_mail(i_mail) AS n;
  IF l_person_n = 0 or l_person_n < 0 THEN
  	INSERT INTO diplom.person_log (up, dt, action, dsc) values (-1, now(), 2, i_mail);
  	RETURN 0;
  END IF;

  SELECT res INTO l_chk_pwd FROM diplom.check_pwd(l_person_n, i_pwd) AS res;
  IF l_chk_pwd THEN
  	l_mc := to_number(to_char(now(),'yyyymmddhh24miss'),'99999999999999') * l_person_n + to_number(to_char(now(),'yyyymmddhh24miss'),'99999999999999');
   	l_mc_char := trim(to_char(l_mc, '99999999999999999999999999999999'));
    INSERT INTO diplom.person_log (up, dt, action, mc) values (l_person_n, now(), 1, l_mc_char);
  	RETURN l_mc;
  ELSE
  	INSERT INTO diplom.person_log (up, dt, action, dsc) values (l_person_n, now(), 3, 'incorrect password');
  	RETURN -1;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  RETURN -999;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function reg_log (OID = 16597) : 
--
CREATE FUNCTION diplom.reg_log (
  i_up numeric,
  i_date timestamp without time zone,
  i_action numeric,
  i_mc character varying,
  i_dsc character varying
)
RETURNS void
AS 
$body$
BEGIN
  /*
  	actions:
  		1 - log in
    	2 - mail was not found
    	3 - incorrect password
    	4 - log off
        5 - new registration
        6 - update person
        7 - change password
    */
  INSERT INTO diplom.person_log (up, dt, action, mc, dsc) values (i_up, coalesce(i_date, now()), i_action, i_mc, i_dsc);
EXCEPTION
WHEN others THEN
  null;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function new_user (OID = 16598) : 
--
CREATE FUNCTION diplom.new_user (
  i_name character varying,
  i_surname character varying,
  i_bdate date,
  i_email character varying,
  i_phone character varying,
  i_password character varying,
  i_fio character varying
)
RETURNS numeric
AS 
$body$
begin
insert into person values (default, i_name, i_surname, i_bdate, now(), i_email, i_phone, i_password, now(), i_fio);
return lastval();
end;
$body$
LANGUAGE plpgsql;
--
-- Definition for function change_password (OID = 16613) : 
--
CREATE FUNCTION diplom.change_password (
  i_id numeric,
  i_newpas character varying,
  i_sessionid character varying
)
RETURNS numeric
AS 
$body$
DECLARE
  l_id NUMERIC;
  l_old_pas VARCHAR;
  l_log VARCHAR;
BEGIN
  	select COALESCE(max(id),0) into l_id from person where id=i_id limit 1;
    IF l_id = 0 then
    	return 0;
    end if;
    
    if COALESCE(i_newpas,'new') != COALESCE(i_newpas, 'old') then
    	return -1;
	end if;
    
    select password into l_old_pas from person where id=i_id limit 1;
    if l_old_pas = i_newpas then
    	return -2;
	end if;
    
    update person set password = i_newpas where id=i_id;
    
    l_log := 'select reg_log('||i_id||', null, 7, '||quote_literal(i_sessionid)||','|| quote_literal('Password was changed.') ||');';
    
    execute l_log;

    return 1;
    
    
EXCEPTION
WHEN others THEN
  return -999;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function check_session (OID = 16615) : 
--
CREATE FUNCTION diplom.check_session (
  i_id numeric,
  i_sessionid character varying
)
RETURNS numeric
AS 
$body$
DECLARE
  l_act NUMERIC;
  l_mc VARCHAR;
BEGIN
  	select action, mc into l_act, l_mc from person_log where up=i_id and action in (1,4) order by dt desc limit 1;
 	if l_mc=i_sessionid and l_act=1 then
 		return 1;
	ELSE
	    return 0;
	end if;
EXCEPTION
WHEN others THEN
  return 0;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function dic_data$find_or_insert (OID = 16660) : 
--
CREATE FUNCTION diplom.dic_data$find_or_insert (
  i_up numeric,
  i_term character varying,
  i_r$code numeric,
  i_dsc character varying
)
RETURNS numeric
AS 
$body$
DECLARE
  l_code NUMERIC;
  l_r$dic NUMERIC;
  l_tmp NUMERIC;
  l_new_code NUMERIC;
BEGIN
  select COALESCE(max(code),0) into l_code from dic_data where up=i_up and upper(term)=upper(i_term) and COALESCE(r$code,0)=COALESCE(i_r$code,0);
  if l_code > 0 then
  	return l_code;
  end if;
  
  if COALESCE(i_r$code,0) > 0 then
  
  	select up$dic$n into l_r$dic from dic where n=i_up;
    
    if COALESCE(l_r$dic,0) = 0 then
    	return -1;
    end if;
    
    select COALESCE(max(code),0) into l_tmp from dic_data where up=l_r$dic and code=i_r$code;
    
    if l_tmp = 0 then
    	return -2;
    end if;
  end if;
  
  select COALESCE(max(code),0) into l_new_code from dic_data where up=i_up;
  
  l_new_code := l_new_code + 1;
  
  for r in 1..l_new_code LOOP
  	select COALESCE(max(code),0) into l_tmp from dic_data where up=i_up and code=r;
    if l_tmp = 0 then
    	l_new_code := r;
        exit;
    end if;
  end loop;
  
  insert into dic_data (term, up, code, r$code, dsc) values (i_term, i_up, l_new_code, i_r$code, i_dsc);
  
  return l_new_code;
  
EXCEPTION
WHEN others THEN
  return -999;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function get_person_info (OID = 16661) : 
--
CREATE FUNCTION diplom.get_person_info (
  i_id numeric,
  i_mail character varying
)
RETURNS record
AS 
$body$
DECLARE
rec record;
BEGIN
  if coalesce(i_id,-1) > 0 then
  	select id, name, surname, fio, bdate, regdate, email, phone, address into rec from diplom.person where id=i_id LIMIT 1;
  ELSIF coalesce(i_mail,'-1') != '-1' then
  	select id, name, surname, fio, bdate, regdate, email, phone, address into rec from diplom.person where email=i_mail LIMIT 1;
  ELSE
  	return null;
  end if;
  return rec;
EXCEPTION
WHEN others THEN
  return null;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function get_address_info (OID = 16662) : 
--
CREATE FUNCTION diplom.get_address_info (
  i_n numeric
)
RETURNS record
AS 
$body$
DECLARE
l_rec record;
BEGIN
  select (select dic_data$get_term_by_code(1,country)) cnt, 
  		 (select dic_data$get_term_by_code(2,city)) cit,
         (select dic_data$get_term_by_code(3,street)) str,
         (select dic_data$get_term_by_code(4,house)) hse,
         appartment, dsc  into l_rec from diplom.address where n=i_n LIMIT 1;
  return l_rec;
EXCEPTION
WHEN others THEN
  return null;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function new_address (OID = 16663) : 
--
CREATE FUNCTION diplom.new_address (
  i_country character varying,
  i_city character varying,
  i_street character varying,
  i_house character varying,
  i_appartment numeric,
  i_dsc character varying
)
RETURNS numeric
AS 
$body$
DECLARE
  l_country NUMERIC;
  l_city NUMERIC;
  l_street NUMERIC;
  l_house NUMERIC;
BEGIN
  select dic_data$find_or_insert(1,i_country,null,null) into l_country;
  select dic_data$find_or_insert(2,i_city,l_country,null) into l_city;
  select dic_data$find_or_insert(3,i_street,l_city,null) into l_street;
  select dic_data$find_or_insert(4,i_house,l_street,null) into l_house;
  insert into address (country, city, street, house, appartment, dsc) values (l_country,l_city,l_street,l_house,i_appartment,i_dsc);
  return lastval();
EXCEPTION
WHEN others THEN
  return -999;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function dic_data$get_term_by_code (OID = 16664) : 
--
CREATE FUNCTION diplom.dic_data$get_term_by_code (
  i_up numeric,
  i_code numeric
)
RETURNS varchar
AS 
$body$
DECLARE
  l_term VARCHAR;
BEGIN
  select term into l_term from dic_data where up=i_up and code=i_code;
  return l_term;
EXCEPTION
WHEN others THEN
  return l_term;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function change_person_info (OID = 16665) : 
--
CREATE FUNCTION diplom.change_person_info (
  i_id numeric,
  i_name character varying,
  i_surname character varying,
  i_fio character varying,
  i_bdate date,
  i_email character varying,
  i_phone character varying,
  i_address numeric
)
RETURNS numeric
AS 
$body$
DECLARE
	new_name VARCHAR;
    new_surname VARCHAR;
    new_fio VARCHAR;
    new_bdate date;
    new_email VARCHAR;
    new_phone VARCHAR;
    new_addr NUMERIC;
    l_id NUMERIC;
    l_dsc VARCHAR;
    l_log VARCHAR;
    l_dt date := to_date('01-01-1900','dd-mm-yyyy');
    l_tmp NUMERIC := -1;
BEGIN

	select COALESCE(max(id),0) into l_id from person where id=i_id limit 1;
    IF l_id = 0 then
    	return 0;
    end if;

	select NAME, surname, fio, bdate, email, phone, address into new_name, new_surname, new_fio, new_bdate, new_email, new_phone, new_addr
    	from person where id=i_id limit 1;
        
    if upper(COALESCE(i_email, 'x')) = upper(new_email) THEN
    	return -1;
    end if;     
   
    l_dsc := 'old_name='||COALESCE(new_name,'-')||
    		'; old_surname='||COALESCE(new_surname,'-')||
            '; old_fio='||COALESCE(new_fio,'-')||
            '; old_bdate='||COALESCE(new_bdate,l_dt)||
            '; old_email='||COALESCE(new_email,'-')||
            '; old_phone='||COALESCE(new_phone,'-')||
            '; old_address='||COALESCE(new_addr,l_tmp)||'.';
    
    new_name := COALESCE(i_name, new_name);
    new_surname := COALESCE(i_surname, new_surname);
    new_fio := COALESCE(i_fio, new_fio);
    new_bdate := COALESCE(i_bdate, new_bdate);
    new_email := COALESCE(i_email, new_email);
    new_phone := COALESCE(i_phone, new_phone);
    new_addr := COALESCE(i_address, new_addr);
   
    update person set NAME = new_name, surname = new_surname, fio = new_fio, bdate = new_bdate, email = new_email, phone = new_phone, address = new_addr where id = i_id;
    
    l_log := 'select reg_log('||i_id||', null, 6, NULL,'|| quote_literal(l_dsc)||');';
    
    execute l_log;

    return 1;
  
EXCEPTION
WHEN others THEN
  return -999;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function category$new (OID = 16677) : 
--
CREATE FUNCTION diplom.category$new (
  i_up integer,
  i_name character varying,
  i_type integer,
  i_status integer,
  i_dsc character varying
)
RETURNS numeric
AS 
$body$
DECLARE
  l_up INTEGER;
  l_lvl INTEGER;
BEGIN
  if COALESCE(i_up,0) != COALESCE(i_up,1) or COALESCE(i_name,'x') != COALESCE(i_name,'y') or COALESCE(i_type,0) != COALESCE(i_type,1) or COALESCE(i_status,0) != COALESCE(i_status,1) THEN
  	return 0;
  end if;
  
  select COALESCE(max(level),-1) into l_lvl from category where n = i_up;
  if l_lvl = -1 then
  	return -1;
  end if;
  
  if i_type not in (0,1) or i_status not in (0,1) then
  	return -2;
  end if;
  
  select COALESCE(max(n),-1) into l_up from category where btrim(upper(name)) = btrim(upper(i_name)) and up=i_up;
  if l_up > 0 then
  	return -3;
  end if;
  
  l_lvl := l_lvl + 1;
  
  insert into category (UP, level, name, type, status, dsc) values (i_up, l_lvl, i_name, i_type, i_status, i_dsc);
  return lastval();
  
EXCEPTION
WHEN others THEN
  return -999;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function category$list_of_child (OID = 16679) : 
--
CREATE FUNCTION diplom.category$list_of_child (
  i_n integer,
  i_status integer
)
RETURNS TABLE (
  n integer,
  up integer,
  level integer,
  name character varying,
  type integer,
  status integer,
  dsc character varying
)
AS 
$body$
BEGIN
  	return QUERY (select * from category cat where cat.up=i_n and cat.status= i_status);
EXCEPTION
WHEN others THEN
  return;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function vendor$find_or_insert (OID = 16710) : 
--
CREATE FUNCTION diplom.vendor$find_or_insert (
  i_name character varying,
  i_dsc character varying
)
RETURNS numeric
AS 
$body$
DECLARE
  l_n NUMERIC;
BEGIN
  select COALESCE(max(n),0) into l_n from vendor where btrim(upper(name)) = btrim(upper(i_name));
  if l_n > 0 then
  	return l_n;
  end if;
  
  insert into vendor (name, dsc) values (i_name, i_dsc);
  
  return lastval();
  
EXCEPTION
WHEN others THEN
  return -999;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function product$new_product (OID = 16723) : 
--
CREATE FUNCTION diplom.product$new_product (
  i_up integer,
  i_vendor integer,
  i_name character varying,
  i_dsc character varying,
  i_desc character varying,
  i_stock integer
)
RETURNS numeric
AS 
$body$
DECLARE
  l_up INTEGER;
  l_ven INTEGER;
BEGIN
  select COALESCE(max(n),-1) into l_up from category where n=i_up;
  if l_up = -1 THEN
  	return -1;
  end if;
  
  if COALESCE(i_vendor,0) = COALESCE(i_vendor,1) then
  	select COALESCE(max(n),-1) into l_ven from vendor where n=i_vendor;
  	if l_ven = -1 THEN
  		return -2;
  	end if;
  end if;
  
  if COALESCE(i_stock,-1) not in (0,1) THEN
  	return -3;
  end if;
  
  insert into product (up, vendor, name, dt, dsc, descr, in_stock) values (i_up, i_vendor, i_name, now(), i_dsc, i_desc, i_stock);
  
  return lastval();
  
EXCEPTION
WHEN others THEN
  return -999;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function product$get_product_info (OID = 16751) : 
--
CREATE FUNCTION diplom.product$get_product_info (
  i_n integer
)
RETURNS record
AS 
$body$
DECLARE
l_rec record;
BEGIN
  select p.n,
  		 p.up up_n,
         (select c.name from category c where c.n=p.up) up_c,
         p.vendor vendor_n,
         (select name from vendor where n=p.vendor) vendor_c,
         p.name,
         p.dt,
         p.dsc,
         p.descr,
         p.in_stock,
         p.price,
         p.price_d
  	into l_rec from product p where n=i_n LIMIT 1;
  return l_rec;
EXCEPTION
WHEN others THEN
  return null;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function attr$get_attr_list (OID = 16756) : 
--
CREATE FUNCTION diplom.attr$get_attr_list (
  i_obj integer,
  i_obj_n integer,
  i_attr integer,
  i_status integer
)
RETURNS TABLE (
  n integer,
  obj integer,
  obj_n integer,
  attr integer,
  val1 character varying,
  val2 character varying,
  status integer,
  dsc character varying,
  dic_n integer,
  dic_term character varying
)
AS 
$body$
BEGIN
  return query (
  	select
    	a.n,
        a.obj,
        a.obj_n,
        a.attr,
        a.val1,
        a.val2,
        a.status,
        a.dsc,
     	coalesce((select ad.dic_n from attr_desc ad where ad.n=a.attr),0) dic_n,
			case 
        		when COALESCE((select ad.dic_n from attr_desc ad where ad.n=a.attr),0)>0 
            	then (select dd.term from dic_data dd where dd.up=(select add.dic_n from attr_desc add where add.n=a.attr) and dd.code=to_number(a.val1,'99999999')) 
            	else null 
        	end dic_term
    from attr a 
    where a.obj=COALESCE(i_obj,a.obj) 
      and a.obj_n=COALESCE(i_obj_n,a.obj_n)
      and a.attr = COALESCE(i_attr,a.attr)
      and a.status = COALESCE(i_status,a.status));
/*EXCEPTION
WHEN others THEN
  return;*/
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function product$get_product_list (OID = 16764) : 
--
CREATE FUNCTION diplom.product$get_product_list (
  i_up integer,
  i_vendor integer,
  i_stock integer,
  i_name character varying,
  i_price_mn numeric,
  i_price_mx numeric,
  i_from integer,
  i_cnt integer,
  i_sort integer
)
RETURNS TABLE (
  n integer,
  up integer,
  vendor integer,
  stock integer,
  price numeric,
  priced numeric,
  name character varying,
  picture character varying,
  lbl numeric
)
AS 
$body$
BEGIN
if COALESCE(i_sort,0) not in (0,1,2,3,4,5,6,7,8,9) then
	return;
end if;
if COALESCE(i_sort,0) = 0 then
	return query
  		select p.n,
  		 p.up,
         p.vendor,
         p.in_stock,
         p.price,
         COALESCE(p.price_d,0),
         p.name,
		 (select COALESCE(max(val1),'no.jpg')::varchar from attr$get_attr_list(1,p.n,2,1) where val2='1' limit 1) picture,
         (select COALESCE(max(val1),'0')::numeric from attr$get_attr_list(1,p.n,3,1) limit 1) lbl       
  		from product p
        where p.up=COALESCE(i_up,p.up)
          and p.vendor=COALESCE(i_vendor,p.vendor)
          and p.in_stock=COALESCE(i_stock,p.in_stock)
          and upper(p.name) like('%'||upper(COALESCE(i_name,p.name))||'%')
          and COALESCE(p.price_d, p.price) between COALESCE(i_price_mn,0) and COALESCE(i_price_mx,999999999)
        order by p.n limit COALESCE(i_cnt,10) OFFSET COALESCE(i_from,0);
elsif COALESCE(i_sort,0) = 1 THEN
	return query
  		select p.n,
  		 p.up,
         p.vendor,
         p.in_stock,
         p.price,
         COALESCE(p.price_d,0),
         p.name,
		 (select COALESCE(max(val1),'no.jpg')::varchar from attr$get_attr_list(1,p.n,2,1) where val2='1' limit 1) picture,
         (select COALESCE(max(val1),'0')::numeric from attr$get_attr_list(1,p.n,3,1) limit 1) lbl       
  		from product p
        where p.up=COALESCE(i_up,p.up)
          and p.vendor=COALESCE(i_vendor,p.vendor)
          and p.in_stock=COALESCE(i_stock,p.in_stock)
          and upper(p.name) like('%'||upper(COALESCE(i_name,p.name))||'%')
          and COALESCE(p.price_d, p.price) between COALESCE(i_price_mn,0) and COALESCE(i_price_mx,999999999)
        order by p.name limit COALESCE(i_cnt,10) OFFSET COALESCE(i_from,0);
elsif COALESCE(i_sort,0) = 2 THEN
	return query
  		select p.n,
  		 p.up,
         p.vendor,
         p.in_stock,
         p.price,
         COALESCE(p.price_d,0),
         p.name,
		 (select COALESCE(max(val1),'no.jpg')::varchar from attr$get_attr_list(1,p.n,2,1) where val2='1' limit 1) picture,
         (select COALESCE(max(val1),'0')::numeric from attr$get_attr_list(1,p.n,3,1) limit 1) lbl       
  		from product p
        where p.up=COALESCE(i_up,p.up)
          and p.vendor=COALESCE(i_vendor,p.vendor)
          and p.in_stock=COALESCE(i_stock,p.in_stock)
          and upper(p.name) like('%'||upper(COALESCE(i_name,p.name))||'%')
          and COALESCE(p.price_d, p.price) between COALESCE(i_price_mn,0) and COALESCE(i_price_mx,999999999)
        order by p.name desc limit COALESCE(i_cnt,10) OFFSET COALESCE(i_from,0);
elsif COALESCE(i_sort,0) = 3 THEN
	return query
  		select p.n,
  		 p.up,
         p.vendor,
         p.in_stock,
         p.price,
         COALESCE(p.price_d,0),
         p.name,
		 (select COALESCE(max(val1),'no.jpg')::varchar from attr$get_attr_list(1,p.n,2,1) where val2='1' limit 1) picture,
         (select COALESCE(max(val1),'0')::numeric from attr$get_attr_list(1,p.n,3,1) limit 1) lbl       
  		from product p
        where p.up=COALESCE(i_up,p.up)
          and p.vendor=COALESCE(i_vendor,p.vendor)
          and p.in_stock=COALESCE(i_stock,p.in_stock)
          and upper(p.name) like('%'||upper(COALESCE(i_name,p.name))||'%')
          and COALESCE(p.price_d, p.price) between COALESCE(i_price_mn,0) and COALESCE(i_price_mx,999999999)
        order by p.vendor limit COALESCE(i_cnt,10) OFFSET COALESCE(i_from,0);
elsif COALESCE(i_sort,0) = 4 THEN
	return query
  		select p.n,
  		 p.up,
         p.vendor,
         p.in_stock,
         p.price,
         COALESCE(p.price_d,0),
         p.name,
		 (select COALESCE(max(val1),'no.jpg')::varchar from attr$get_attr_list(1,p.n,2,1) where val2='1' limit 1) picture,
         (select COALESCE(max(val1),'0')::numeric from attr$get_attr_list(1,p.n,3,1) limit 1) lbl       
  		from product p
        where p.up=COALESCE(i_up,p.up)
          and p.vendor=COALESCE(i_vendor,p.vendor)
          and p.in_stock=COALESCE(i_stock,p.in_stock)
          and upper(p.name) like('%'||upper(COALESCE(i_name,p.name))||'%')
          and COALESCE(p.price_d, p.price) between COALESCE(i_price_mn,0) and COALESCE(i_price_mx,999999999)
        order by p.vendor desc limit COALESCE(i_cnt,10) OFFSET COALESCE(i_from,0);
elsif COALESCE(i_sort,0) = 5 THEN
	return query
  		select p.n,
  		 p.up,
         p.vendor,
         p.in_stock,
         p.price,
         COALESCE(p.price_d,0),
         p.name,
		 (select COALESCE(max(val1),'no.jpg')::varchar from attr$get_attr_list(1,p.n,2,1) where val2='1' limit 1) picture,
         (select COALESCE(max(val1),'0')::numeric from attr$get_attr_list(1,p.n,3,1) limit 1) lbl       
  		from product p
        where p.up=COALESCE(i_up,p.up)
          and p.vendor=COALESCE(i_vendor,p.vendor)
          and p.in_stock=COALESCE(i_stock,p.in_stock)
          and upper(p.name) like('%'||upper(COALESCE(i_name,p.name))||'%')
          and COALESCE(p.price_d, p.price) between COALESCE(i_price_mn,0) and COALESCE(i_price_mx,999999999)
        order by COALESCE(p.price_d,p.price) limit COALESCE(i_cnt,10) OFFSET COALESCE(i_from,0);
elsif COALESCE(i_sort,0) = 6 THEN
	return query
  		select p.n,
  		 p.up,
         p.vendor,
         p.in_stock,
         p.price,
         COALESCE(p.price_d,0),
         p.name,
		 (select COALESCE(max(val1),'no.jpg')::varchar from attr$get_attr_list(1,p.n,2,1) where val2='1' limit 1) picture,
         (select COALESCE(max(val1),'0')::numeric from attr$get_attr_list(1,p.n,3,1) limit 1) lbl       
  		from product p
        where p.up=COALESCE(i_up,p.up)
          and p.vendor=COALESCE(i_vendor,p.vendor)
          and p.in_stock=COALESCE(i_stock,p.in_stock)
          and upper(p.name) like('%'||upper(COALESCE(i_name,p.name))||'%')
          and COALESCE(p.price_d, p.price) between COALESCE(i_price_mn,0) and COALESCE(i_price_mx,999999999)
        order by COALESCE(p.price_d,p.price) desc limit COALESCE(i_cnt,10) OFFSET COALESCE(i_from,0);
elsif COALESCE(i_sort,0) = 7 THEN /*Only New Desc*/
	return query
  		select p.n,
  		 p.up,
         p.vendor,
         p.in_stock,
         p.price,
         COALESCE(p.price_d,0),
         p.name,
		 (select COALESCE(max(val1),'no.jpg')::varchar from attr$get_attr_list(1,p.n,2,1) where val2='1' limit 1) picture,
         (select COALESCE(max(val1),'0')::numeric from attr$get_attr_list(1,p.n,3,1) limit 1) lbl       
  		from product p
        where p.up=COALESCE(i_up,p.up)
          and p.vendor=COALESCE(i_vendor,p.vendor)
          and p.in_stock=COALESCE(i_stock,p.in_stock)
          and upper(p.name) like('%'||upper(COALESCE(i_name,p.name))||'%')
          and COALESCE(p.price_d, p.price) between COALESCE(i_price_mn,0) and COALESCE(i_price_mx,999999999)
          and p.n in (select obj_n from attr a where a.attr=3 and a.status=1 and a.val1='1')
        order by p.n desc limit COALESCE(i_cnt,10) OFFSET COALESCE(i_from,0);
elsif COALESCE(i_sort,0) = 8 THEN /*Only Hot Desc*/
	return query
  		select p.n,
  		 p.up,
         p.vendor,
         p.in_stock,
         p.price,
         COALESCE(p.price_d,0),
         p.name,
		 (select COALESCE(max(val1),'no.jpg')::varchar from attr$get_attr_list(1,p.n,2,1) where val2='1' limit 1) picture,
         (select COALESCE(max(val1),'0')::numeric from attr$get_attr_list(1,p.n,3,1) limit 1) lbl       
  		from product p
        where p.up=COALESCE(i_up,p.up)
          and p.vendor=COALESCE(i_vendor,p.vendor)
          and p.in_stock=COALESCE(i_stock,p.in_stock)
          and upper(p.name) like('%'||upper(COALESCE(i_name,p.name))||'%')
          and COALESCE(p.price_d, p.price) between COALESCE(i_price_mn,0) and COALESCE(i_price_mx,999999999)
          and p.n in (select obj_n from attr a where a.attr=3 and a.status=1 and a.val1='2')
        order by p.n desc limit COALESCE(i_cnt,10) OFFSET COALESCE(i_from,0); 
elsif COALESCE(i_sort,0) = 9 THEN /*Only Sale Desc*/
	return query
  		select p.n,
  		 p.up,
         p.vendor,
         p.in_stock,
         p.price,
         COALESCE(p.price_d,0),
         p.name,
		 (select COALESCE(max(val1),'no.jpg')::varchar from attr$get_attr_list(1,p.n,2,1) where val2='1' limit 1) picture,
         (select COALESCE(max(val1),'0')::numeric from attr$get_attr_list(1,p.n,3,1) limit 1) lbl       
  		from product p
        where p.up=COALESCE(i_up,p.up)
          and p.vendor=COALESCE(i_vendor,p.vendor)
          and p.in_stock=COALESCE(i_stock,p.in_stock)
          and upper(p.name) like('%'||upper(COALESCE(i_name,p.name))||'%')
          and COALESCE(p.price_d, p.price) between COALESCE(i_price_mn,0) and COALESCE(i_price_mx,999999999)
          and p.n in (select obj_n from attr a where a.attr=3 and a.status=1 and a.val1='3')
        order by p.n desc limit COALESCE(i_cnt,10) OFFSET COALESCE(i_from,0);       
end if;

/*
EXCEPTION
WHEN others THEN
  return;*/
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function cart$add_product (OID = 24965) : 
--
CREATE FUNCTION diplom.cart$add_product (
  i_up integer,
  i_product_n integer,
  i_cnt integer,
  i_attr_n_a integer,
  i_attr_n_b integer,
  i_dsc character varying
)
RETURNS record
AS 
$body$
DECLARE
  l_person_n INTEGER;
  l_tmp INTEGER;
  l_cnt INTEGER;
  l_rec record;
BEGIN
  select COALESCE(max(id),0) into l_person_n from person where id=COALESCE(i_up,-100500);
  if l_person_n < 1 then
  	select -1::numeric, 0::integer into l_rec;
  	return l_rec;
  end if;
  
  select COALESCE(max(n),0) into l_tmp from product where n=COALESCE(i_product_n,-100500);
  if l_tmp < 1 THEN
  	select -2::numeric, 0::integer into l_rec;
  	return l_rec;
  end if;
  
  if COALESCE(i_cnt,0) = 0 then
  	l_cnt := 1;
  else 
  	l_cnt := i_cnt;
  end if;
  
  if COALESCE(i_attr_n_a,0) !=0 then
  	select COALESCE(max(obj_n),0) into l_tmp from attr where n=i_attr_n_a and obj=1 and obj_n=i_product_n;
    if l_tmp < 1 then
    	select -3::numeric, 0::integer into l_rec;
  		return l_rec;
    end if;
  end if;
  
  if COALESCE(i_attr_n_b,0) !=0 then
  	select COALESCE(max(obj_n),0) into l_tmp from attr where n=i_attr_n_b and obj=1 and obj_n=i_product_n;
    if l_tmp < 1 then
    	select -4::numeric, 0::integer into l_rec;
  		return l_rec;
    end if;
  end if; 
  
  select COALESCE(max(cnt),-1) into l_tmp 
  	from cart 
    where up=i_up 
    	and product_n=i_product_n 
        and COALESCE(attr_1,-1) = COALESCE(i_attr_n_a,-1) 
        and COALESCE(attr_2,-1) = COALESCE(i_attr_n_b,-1);
        
  if l_tmp > 0 and l_cnt < 0 and l_tmp+l_cnt<0 then
  	l_cnt := -l_tmp;
  end if;      
        
  if l_tmp = 0 and l_cnt < 0 THEN
  	select -5::numeric, 0::integer into l_rec;
  	return l_rec;
  elsif l_tmp < 0 and l_cnt < 0 then
  	select -6::numeric, 0::integer into l_rec;
  	return l_rec;
  elsif (l_cnt > 0 and l_tmp > -1) or (l_tmp > 0 and l_tmp+l_cnt > -1) THEN
  	update cart 
    set cnt=l_tmp+l_cnt 
    where up=i_up 
    	and product_n=i_product_n 
        and COALESCE(attr_1,-1) = COALESCE(i_attr_n_a,-1) 
        and COALESCE(attr_2,-1) = COALESCE(i_attr_n_b,-1);
  elsif l_tmp=-1 and l_cnt>0 then
  	insert into cart (up, product_n, cnt, attr_1, attr_2, dsc) values (i_up, i_product_n, l_cnt, i_attr_n_a, i_attr_n_b, i_dsc);
  ELSE
  	select -10::numeric, 0::integer into l_rec;
  	return l_rec;
  end if;
  
  select sum(c.cnt*(COALESCE(p.price_d,p.price))) sm,
  		 sum(c.cnt)::integer cnt,
         (select ct.cnt from cart ct where ct.up=i_up and ct.product_n=i_product_n and ct.attr_1=i_attr_n_a and ct.attr_2=i_attr_n_b) prod_cnt
         into l_rec from cart c, product p where c.product_n=p.n and c.up=i_up;
    
  return l_rec;
EXCEPTION
WHEN others THEN
	select -999::numeric, 0::integer into l_rec;
  	return l_rec;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function cart$sum (OID = 24967) : 
--
CREATE FUNCTION diplom.cart$sum (
  i_up integer
)
RETURNS record
AS 
$body$
DECLARE
  l_rec record;
BEGIN
  
  select sum(c.cnt*(COALESCE(p.price_d,p.price))) sm, sum(c.cnt)::integer cnt into l_rec from cart c, product p where c.product_n=p.n and c.up=i_up;
    
  return l_rec;
EXCEPTION
WHEN others THEN
	select -999::numeric, 0::integer into l_rec;
  	return l_rec;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function category$info (OID = 24968) : 
--
CREATE FUNCTION diplom.category$info (
  i_cat integer
)
RETURNS record
AS 
$body$
DECLARE
  l_tmp NUMERIC;
  l_cnt NUMERIC;
  l_stock NUMERIC;
  l_rec record;
BEGIN
	select count(1)::numeric into l_tmp from category where n=i_cat;
    if l_tmp = 0 THEN
    	select -1::numeric, 0::integer into l_rec;
        select 0 :: INTEGER, 0:: INTEGER, 0:: INTEGER, null :: VARCHAR, 0:: INTEGER, 0:: INTEGER, null:: VARCHAR, 0:: INTEGER, 0:: INTEGER into l_rec;
  		return l_rec;
    end if;
    
    select c.*, 0 :: INTEGER cnt, 0 :: INTEGER stock into l_rec from category c where c.n=i_cat;
    
    select count(1)::NUMERIC into l_cnt from product where up=i_cat;
    
    select count(1)::NUMERIC into l_stock from product where up=i_cat and in_stock = 1;
    
    l_rec.cnt := l_cnt;
    l_rec.stock := l_stock;
    
    return l_rec;
EXCEPTION
WHEN others THEN
	select 0 :: INTEGER, 0:: INTEGER, 0:: INTEGER, null :: VARCHAR, 0:: INTEGER, 0:: INTEGER, null:: VARCHAR, 0:: INTEGER, 0:: INTEGER into l_rec;
  	return l_rec;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function cart$get_product_list (OID = 24971) : 
--
CREATE FUNCTION diplom.cart$get_product_list (
  i_up integer
)
RETURNS TABLE (
  prod_n integer,
  prod_up integer,
  name character varying,
  in_stock integer,
  price numeric,
  cnt integer,
  pic character varying,
  attr1 integer,
  attr2 integer
)
AS 
$body$
BEGIN
  	return QUERY
    	select p.n :: INTEGER, 
               p.up :: INTEGER, 
               p.name :: VARCHAR, 
               p.in_stock :: INTEGER, 
               p.price :: NUMERIC, 
               c.cnt :: INTEGER, 
               (select val1 :: VARCHAR from attr a where a.obj=1 and a.obj_n=p.n and a.attr=2 and a.val2='1' limit 1) jpg,
               COALESCE(c.attr_1 :: INTEGER, 0) attr1,  
               COALESCE(c.attr_2 :: INTEGER, 0) attr2
		from cart c, product p where c.product_n=p.n and c.up=i_up;
    
EXCEPTION
WHEN others THEN
  return;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function attr$get_attr_info (OID = 24974) : 
--
CREATE FUNCTION diplom.attr$get_attr_info (
  i_n integer
)
RETURNS TABLE (
  n integer,
  obj integer,
  obj_n integer,
  attr integer,
  val1 character varying,
  val2 character varying,
  status integer,
  dsc character varying,
  dic_n integer,
  dic_term character varying
)
AS 
$body$
BEGIN
  return query (
  	select
    	a.n,
        a.obj,
        a.obj_n,
        a.attr,
        a.val1,
        a.val2,
        a.status,
        a.dsc,
     	coalesce((select ad.dic_n from attr_desc ad where ad.n=a.attr),0) dic_n,
			case 
        		when COALESCE((select ad.dic_n from attr_desc ad where ad.n=a.attr),0)>0 
            	then (select dd.term from dic_data dd where dd.up=(select add.dic_n from attr_desc add where add.n=a.attr) and dd.code=to_number(a.val1,'99999999')) 
            	else null 
        	end dic_term
    from attr a 
    where a.n = i_n);
/*EXCEPTION
WHEN others THEN
  return;*/
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for sequence sq$person (OID = 16394) : 
--
CREATE SEQUENCE diplom.sq$person
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
--
-- Structure for table person (OID = 16444) : 
--
CREATE TABLE diplom.person (
    id integer DEFAULT nextval('"sq$person"'::regclass) NOT NULL,
    name varchar(32),
    surname varchar(32),
    bdate date,
    regdate timestamp without time zone,
    email varchar(32),
    phone varchar(16),
    password varchar(16),
    pass_dt timestamp without time zone,
    fio varchar(64),
    address numeric
)
WITH (oids = false);
--
-- Definition for sequence sq$person_log (OID = 16538) : 
--
CREATE SEQUENCE diplom.sq$person_log
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
--
-- Structure for table person_log (OID = 16587) : 
--
CREATE TABLE diplom.person_log (
    n integer DEFAULT nextval('"sq$person_log"'::regclass) NOT NULL,
    up integer NOT NULL,
    dt timestamp without time zone NOT NULL,
    action integer NOT NULL,
    mc varchar(32),
    dsc varchar(2000)
)
WITH (oids = false);
--
-- Definition for sequence sq$address (OID = 16616) : 
--
CREATE SEQUENCE diplom.sq$address
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
--
-- Structure for table address (OID = 16618) : 
--
CREATE TABLE diplom.address (
    n numeric DEFAULT nextval('"sq$address"'::regclass) NOT NULL,
    country numeric,
    city numeric,
    street numeric,
    house numeric,
    appartment numeric,
    dsc varchar(2000)
)
WITH (oids = false);
--
-- Definition for sequence sq$dic_data (OID = 16633) : 
--
CREATE SEQUENCE diplom.sq$dic_data
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
--
-- Structure for table dic_data (OID = 16635) : 
--
CREATE TABLE diplom.dic_data (
    n numeric DEFAULT nextval('"sq$dic_data"'::regclass) NOT NULL,
    term varchar(256) NOT NULL,
    up numeric NOT NULL,
    code numeric NOT NULL,
    r$code numeric,
    dsc varchar(2000)
)
WITH (oids = false);
--
-- Definition for sequence sq$dic (OID = 16644) : 
--
CREATE SEQUENCE diplom.sq$dic
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
--
-- Structure for table dic (OID = 16647) : 
--
CREATE TABLE diplom.dic (
    n numeric DEFAULT nextval('"sq$dic"'::regclass) NOT NULL,
    name varchar(128) NOT NULL,
    up$dic$n numeric,
    dsc varchar(2000)
)
WITH (oids = false);
--
-- Definition for sequence sq$category (OID = 16666) : 
--
CREATE SEQUENCE diplom.sq$category
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
--
-- Structure for table category (OID = 16668) : 
--
CREATE TABLE diplom.category (
    n integer DEFAULT nextval('"sq$category"'::regclass) NOT NULL,
    up integer NOT NULL,
    level integer NOT NULL,
    name varchar(64) NOT NULL,
    type integer NOT NULL,
    status integer NOT NULL,
    dsc varchar(2000)
)
WITH (oids = false);
--
-- Definition for sequence sq$vendor (OID = 16697) : 
--
CREATE SEQUENCE diplom.sq$vendor
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
--
-- Structure for table vendor (OID = 16699) : 
--
CREATE TABLE diplom.vendor (
    n integer DEFAULT nextval('"sq$vendor"'::regclass) NOT NULL,
    name varchar(64) NOT NULL,
    dsc varchar(2000)
)
WITH (oids = false);
--
-- Definition for sequence sq$product (OID = 16711) : 
--
CREATE SEQUENCE diplom.sq$product
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
--
-- Structure for table product (OID = 16713) : 
--
CREATE TABLE diplom.product (
    n integer DEFAULT nextval('"sq$product"'::regclass) NOT NULL,
    up integer NOT NULL,
    vendor integer,
    name varchar(128) NOT NULL,
    dt date NOT NULL,
    dsc varchar(2000),
    descr varchar(2000),
    in_stock integer NOT NULL,
    price numeric,
    price_d numeric
)
WITH (oids = false);
--
-- Definition for sequence sq$attr (OID = 16724) : 
--
CREATE SEQUENCE diplom.sq$attr
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
--
-- Structure for table attr (OID = 16726) : 
--
CREATE TABLE diplom.attr (
    n integer DEFAULT nextval('"sq$attr"'::regclass) NOT NULL,
    obj integer NOT NULL,
    obj_n integer NOT NULL,
    attr integer NOT NULL,
    val1 varchar(2000),
    val2 varchar(2000),
    status integer,
    dsc varchar(2000)
)
WITH (oids = false);
--
-- Structure for table obj (OID = 16735) : 
--
CREATE TABLE diplom.obj (
    n integer NOT NULL,
    obj_name varchar(32) NOT NULL,
    obj_type varchar(32) NOT NULL,
    dsc varchar(2000)
)
WITH (oids = false);
--
-- Structure for table attr_desc (OID = 16743) : 
--
CREATE TABLE diplom.attr_desc (
    n integer NOT NULL,
    name varchar NOT NULL,
    type integer NOT NULL,
    dic_n integer,
    dsc varchar(2000)
)
WITH (oids = false);
--
-- Structure for table cart (OID = 16765) : 
--
CREATE TABLE diplom.cart (
    up integer NOT NULL,
    product_n integer NOT NULL,
    cnt integer NOT NULL,
    attr_1 integer,
    attr_2 integer,
    dsc varchar(2000)
)
WITH (oids = false);
--
-- Data for table diplom.person (OID = 16444) (LIMIT 0,12)
--
INSERT INTO person (id, name, surname, bdate, regdate, email, phone, password, pass_dt, fio, address)
VALUES (104, NULL, NULL, NULL, '2017-06-28 20:23:56.249589', 'evgen@e.e', NULL, '123', '2017-06-28 20:23:56.249589', 'evgen', NULL);

INSERT INTO person (id, name, surname, bdate, regdate, email, phone, password, pass_dt, fio, address)
VALUES (105, NULL, NULL, NULL, '2017-06-30 00:13:56.242034', 'test@ts.ts', '+7-900-000-00-00', '123', '2017-06-30 00:13:56.242034', 'er', 7);

INSERT INTO person (id, name, surname, bdate, regdate, email, phone, password, pass_dt, fio, address)
VALUES (106, NULL, NULL, NULL, '2017-07-01 11:14:35.73738', 'ser@ser.ser', '+7-900-000-00-00', '1234', '2017-07-01 11:14:35.73738', 'er', 12);

INSERT INTO person (id, name, surname, bdate, regdate, email, phone, password, pass_dt, fio, address)
VALUES (13, 'Semen', 'Semenov', '1986-03-15', '2017-05-03 23:27:14.895671', 'er@er.er', '+7-909-777-77-77', '12', '2017-05-03 23:27:14.895671', 'Альберт Сергеевич', 13);

INSERT INTO person (id, name, surname, bdate, regdate, email, phone, password, pass_dt, fio, address)
VALUES (107, NULL, NULL, NULL, '2017-08-02 01:02:52.137301', 'era@era.era', '+7-909-433-33-33', '123', '2017-08-02 01:02:52.137301', 'vasya', 14);

INSERT INTO person (id, name, surname, bdate, regdate, email, phone, password, pass_dt, fio, address)
VALUES (6, 'Евгений', 'Хорошев', '1986-03-15', '2017-05-01 22:13:29.992572', 'evg-khoroshev@ya.ru', '+79094336877', '123', '2017-05-01 22:13:29.992572', 'Хорошев Евгений', NULL);

INSERT INTO person (id, name, surname, bdate, regdate, email, phone, password, pass_dt, fio, address)
VALUES (98, NULL, NULL, NULL, '2017-06-27 21:46:12.995186', 'ere@er.er', NULL, '123', '2017-06-27 21:46:12.995186', 'P P', NULL);

INSERT INTO person (id, name, surname, bdate, regdate, email, phone, password, pass_dt, fio, address)
VALUES (99, NULL, NULL, NULL, '2017-06-27 22:07:42.775375', 'eree@er.er', NULL, 'diplom', '2017-06-27 22:07:42.775375', '', NULL);

INSERT INTO person (id, name, surname, bdate, regdate, email, phone, password, pass_dt, fio, address)
VALUES (100, NULL, NULL, NULL, '2017-06-27 22:08:48.932966', '12@12.12', NULL, 'diplom', '2017-06-27 22:08:48.932966', '12', NULL);

INSERT INTO person (id, name, surname, bdate, regdate, email, phone, password, pass_dt, fio, address)
VALUES (101, NULL, NULL, NULL, '2017-06-27 22:14:51.088098', 'evgeniy@er.er', NULL, '124', '2017-06-27 22:14:51.088098', 'Evgeniy', NULL);

INSERT INTO person (id, name, surname, bdate, regdate, email, phone, password, pass_dt, fio, address)
VALUES (102, NULL, NULL, NULL, '2017-06-27 22:24:09.842802', 'newevgeniy@er.er', NULL, '123', '2017-06-27 22:24:09.842802', 'evgeniy', NULL);

INSERT INTO person (id, name, surname, bdate, regdate, email, phone, password, pass_dt, fio, address)
VALUES (103, NULL, NULL, NULL, '2017-06-27 22:33:36.8851', 'evg@er.er', NULL, '1234', '2017-06-27 22:33:36.8851', 'evg', NULL);

--
-- Data for table diplom.person_log (OID = 16587) (LIMIT 0,243)
--
INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (1, 1, '2017-05-28 14:16:23.667225', 1, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (2, 13, '2017-05-28 15:32:02.241827', 1, '282387394144828', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (3, 13, '2017-05-28 16:30:24.032933', 1, '282387394282336', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (4, 13, '2017-05-28 16:30:52.67188', 1, '282387394282728', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (5, 13, '2017-05-28 16:31:08.860981', 1, '282387394283512', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (6, 13, '2017-05-28 16:32:55.317219', 1, '282387394285570', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (7, -1, '2017-05-28 17:00:52.050229', 2, NULL, '34');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (8, 13, '2017-05-28 17:01:26.939602', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (9, -1, '2017-06-25 11:24:29.121601', 2, NULL, '23232');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (10, -1, '2017-06-25 11:30:15.329299', 2, NULL, 'wewe@drer.rt');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (11, -1, '2017-06-25 11:34:03.432982', 2, NULL, 'erer');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (12, 13, '2017-06-25 11:38:42.767172', 1, '282388751593788', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (13, -1, '2017-06-25 12:26:42.353755', 2, NULL, 'er');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (14, -1, '2017-06-25 12:27:28.171052', 2, NULL, 'er');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (15, 13, '2017-06-25 12:27:38.810274', 1, '282388751718332', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (16, 13, '2017-06-25 12:29:43.485738', 1, '282388751721202', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (17, 13, '2017-06-25 12:31:54.728816', 1, '282388751724156', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (18, 13, '2017-06-25 12:32:48.221329', 1, '282388751725472', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (19, 13, '2017-06-25 12:47:59.450457', 1, '282388751746626', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (20, 13, '2017-06-25 12:50:43.500404', 1, '282388751750602', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (21, -1, '2017-06-25 12:51:28.178898', 2, NULL, '12');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (22, -1, '2017-06-25 12:51:36.743316', 2, NULL, '12');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (23, -1, '2017-06-25 12:57:05.685612', 2, NULL, '12');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (24, -1, '2017-06-25 12:57:05.810412', 2, NULL, '12');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (25, -1, '2017-06-25 12:58:49.566232', 2, NULL, '12');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (26, -1, '2017-06-25 12:58:49.644232', 2, NULL, '12');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (27, 13, '2017-06-25 12:59:07.39707', 1, '282388751762698', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (28, 13, '2017-06-25 12:59:07.50627', 1, '282388751762698', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (29, -1, '2017-06-25 13:01:40.854594', 2, NULL, '12');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (30, 13, '2017-06-25 13:02:28.200694', 1, '282388751823192', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (31, 13, '2017-06-25 13:02:28.387895', 1, '282388751823192', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (32, 13, '2017-06-25 13:05:41.251103', 1, '282388751827574', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (33, 13, '2017-06-25 13:05:41.313503', 1, '282388751827574', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (34, -1, '2017-06-25 13:47:11.857361', 2, NULL, '1@1.1');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (35, -1, '2017-06-25 13:48:09.951884', 2, NULL, '1@1.1f');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (36, 13, '2017-06-25 13:48:22.759511', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (37, 13, '2017-06-25 13:48:56.595982', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (38, 13, '2017-06-25 13:49:14.879221', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (39, -1, '2017-06-25 13:49:33.31846', 2, NULL, 'er@er.err');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (40, -1, '2017-06-25 13:49:58.372113', 2, NULL, 'etr@er.err');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (41, -1, '2017-06-25 13:50:29.82178', 2, NULL, 'etr@er.err');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (42, -1, '2017-06-25 13:54:30.452289', 2, NULL, 'etr@er.err');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (43, 13, '2017-06-25 14:15:11.622114', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (44, 13, '2017-06-25 14:15:19.593731', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (45, -1, '2017-06-25 14:15:24.648142', 2, NULL, 'er@er.err');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (46, 13, '2017-06-25 14:15:32.432558', 1, '282388751981448', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (47, 13, '2017-06-25 14:18:18.80691', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (48, 13, '2017-06-25 14:18:22.784919', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (49, 13, '2017-06-25 14:18:27.402528', 1, '282388751985578', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (50, 13, '2017-06-25 14:28:28.4094', 1, '282388751999592', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (51, 13, '2017-06-25 14:29:06.769881', 1, '282388752000684', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (52, 13, '2017-06-25 14:30:35.908469', 1, '282388752002490', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (53, 13, '2017-06-25 18:18:35.234206', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (54, 13, '2017-06-25 18:18:42.176221', 1, '282388752545788', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (55, 13, '2017-06-25 18:19:45.605955', 1, '282388752547230', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (56, 13, '2017-06-25 18:21:50.125419', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (57, 13, '2017-06-25 18:22:12.449066', 1, '282388752550968', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (58, 13, '2017-06-25 18:28:01.069785', 1, '282388752559214', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (59, 13, '2017-06-25 18:31:50.446864', 1, '282388752564100', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (60, 13, '2017-06-25 18:33:22.143858', 1, '282388752566508', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (61, 13, '2017-06-25 18:33:24.093862', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (62, 13, '2017-06-25 18:35:08.052482', 1, '282388752569112', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (63, 13, '2017-06-25 18:35:09.362885', 1, '282388752569126', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (64, 13, '2017-06-25 19:23:06.336571', 1, '282388752692284', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (65, 13, '2017-06-25 19:23:07.802974', 1, '282388752692298', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (66, 13, '2017-06-25 19:54:05.267703', 1, '282388752735670', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (67, 13, '2017-06-25 19:54:07.139707', 1, '282388752735698', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (68, 13, '2017-06-25 20:10:48.537026', 1, '282388752814672', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (69, 13, '2017-06-25 20:10:50.45583', 1, '282388752814700', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (70, 13, '2017-06-25 20:12:31.637644', 1, '282388752817234', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (71, 13, '2017-06-25 20:12:33.322447', 1, '282388752817262', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (72, 13, '2017-06-25 20:14:03.755839', 4, '282388752817262', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (73, 13, '2017-06-25 20:15:10.976381', 1, '282388752821140', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (74, 13, '2017-06-25 20:15:12.629984', 1, '282388752821168', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (75, 13, '2017-06-25 20:15:16.093192', 4, '282388752821168', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (76, 13, '2017-06-25 20:16:03.517292', 1, '282388752822442', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (77, 13, '2017-06-25 20:16:05.217696', 1, '282388752822470', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (78, 13, '2017-06-25 20:16:15.342117', 4, '282388752822470', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (79, 13, '2017-06-27 20:31:01.12131', 1, '282388780843414', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (80, 13, '2017-06-27 20:31:03.539315', 1, '282388780843442', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (81, 13, '2017-06-27 21:10:32.375568', 1, '282388780954448', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (82, 13, '2017-06-27 21:14:40.820101', 4, '282388780954448', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (83, -1, '2017-06-27 21:58:51.967991', 2, NULL, 'evgeniy@er.er');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (84, -1, '2017-06-27 22:01:49.255843', 2, NULL, 'evgeniy@er.er');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (85, -1, '2017-06-27 22:05:27.121962', 2, NULL, 'evgeniy@er.er');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (86, -1, '2017-06-27 22:06:44.954363', 2, NULL, 'evgeniy@er.er');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (87, 99, '2017-06-27 22:07:52.701064', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (88, 100, '2017-06-27 22:08:54.825375', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (89, -1, '2017-06-27 22:13:45.173524', 2, NULL, 'evgeniy@er.er');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (90, 101, '2017-06-27 22:14:52.882223', 1, '2057403976588104', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (91, 101, '2017-06-27 22:15:09.245358', 4, '2057403976588104', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (92, 102, '2017-06-27 22:24:11.383909', 1, '2077574603908333', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (93, 102, '2017-06-27 22:28:36.991341', 4, '2077574603908333', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (94, -1, '2017-06-27 22:32:29.445971', 2, NULL, 'evg@er.er');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (95, 103, '2017-06-27 22:33:36.935104', 5, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (96, 103, '2017-06-27 22:33:38.198191', 1, '2097745231227152', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (97, 103, '2017-06-27 22:33:41.578426', 4, '2097745231227152', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (98, 104, '2017-06-28 20:23:56.305593', 5, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (99, 104, '2017-06-28 20:23:57.908704', 1, '2117915961247485', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (100, 1, '2017-06-28 21:54:04.471333', 1, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (101, 1, '2017-06-28 21:56:31.766805', 1, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (102, 1, '2017-06-28 22:07:38.059635', 1, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (103, 104, '2017-06-28 23:07:03.149817', 4, '2117915961247485', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (104, -1, '2017-06-29 20:52:18.170099', 2, NULL, 'evgen@er.er');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (105, 104, '2017-06-29 20:52:24.56611', 1, '2117916066548520', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (106, 104, '2017-06-29 20:52:26.438114', 1, '2117916066548730', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (109, 6, '2017-06-29 22:47:36.720471', 6, NULL, 'тест');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (116, 6, '2017-06-29 23:03:42.019053', 6, NULL, 'тест');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (117, 6, '2017-06-29 23:11:03.109868', 6, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (118, 6, '2017-06-29 23:15:33.224366', 6, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (119, 6, '2017-06-29 23:16:29.25967', 6, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (120, 6, '2017-06-29 23:16:49.102907', 6, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (121, 6, '2017-06-29 23:30:29.555221', 6, NULL, 'test');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (122, 6, '2017-06-29 23:33:50.374392', 6, NULL, 'old_name=Евгений; old_surname=Хорошев; old_fio=Евгений; old_bdate=1986-03-15; old_email=evg-khoroshev@ya.ru; old_phone=+79094336877.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (123, 6, '2017-06-29 23:35:22.024561', 6, NULL, 'old_name=Евгений; old_surname=Хорошев; old_fio=Евгений; old_bdate=1986-03-15; old_email=evg-khoroshev@ya.ru; old_phone=+79094336877.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (124, 104, '2017-06-30 00:01:39.655474', 6, NULL, 'old_name=');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (125, 104, '2017-06-30 00:03:51.740918', 6, NULL, 'old_name=-.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (126, 104, '2017-06-30 00:05:48.117132', 6, NULL, 'old_name=-.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (127, 104, '2017-06-30 00:06:10.939975', 6, NULL, 'old_name=-; old_surname=-.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (128, 104, '2017-06-30 00:06:28.287207', 6, NULL, 'old_name=-; old_surname=-; old_fio=evgen.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (129, 104, '2017-06-30 00:10:18.262831', 6, NULL, 'old_name=-; old_surname=-; old_fio=evgen; old_bdate=2017-06-30.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (130, 104, '2017-06-30 00:11:46.215793', 6, NULL, 'old_name=-; old_surname=-; old_fio=evgen; old_bdate=1900-01-01.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (131, 104, '2017-06-30 00:12:29.505873', 6, NULL, 'old_name=-; old_surname=-; old_fio=evgen; old_bdate=1900-01-01; old_email=evgen@e.e; old_phone=-.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (132, 104, '2017-06-30 00:13:35.883996', 4, '2117916066548730', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (133, 105, '2017-06-30 00:13:56.304434', 5, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (134, 105, '2017-06-30 00:13:58.238837', 1, '2138086780143948', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (135, 105, '2017-06-30 00:14:38.596112', 6, NULL, 'old_name=-; old_surname=-; old_fio=new; old_bdate=1900-01-01; old_email=test@ts.ts; old_phone=-.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (136, 105, '2017-06-30 00:15:09.811769', 6, NULL, 'old_name=-; old_surname=-; old_fio=new; old_bdate=1900-01-01; old_email=test@ts.ts; old_phone=+7-900-000-00-00.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (137, 105, '2017-06-30 00:15:18.095385', 6, NULL, 'old_name=-; old_surname=-; old_fio=new; old_bdate=1900-01-01; old_email=test@ts.ts; old_phone=+7-900-000-00-01.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (138, 105, '2017-06-30 00:15:45.691836', 6, NULL, 'old_name=-; old_surname=-; old_fio=Евгений; old_bdate=1900-01-01; old_email=test@ts.ts; old_phone=+7-900-000-00-01.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (139, 105, '2017-06-30 00:15:54.661852', 4, '2138086780143948', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (140, 106, '2017-07-01 11:14:35.75298', 5, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (141, 106, '2017-07-01 11:14:37.546983', 1, '2158265018923759', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (142, 106, '2017-07-01 11:15:07.655039', 6, NULL, 'old_name=-; old_surname=-; old_fio=ser; old_bdate=1900-01-01; old_email=ser@ser.ser; old_phone=-.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (143, 106, '2017-07-01 12:17:43.845573', 7, '2158265018923759', 'Password was changed.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (144, 106, '2017-07-01 12:18:03.252009', 4, '2158265018923759', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (145, 106, '2017-07-01 12:18:16.434033', 1, '2158265020034312', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (146, 106, '2017-07-01 12:18:18.072036', 1, '2158265020034526', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (147, 106, '2017-07-01 12:23:21.617397', 4, '2158265020034526', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (148, 106, '2017-07-01 12:41:50.295843', 1, '2158265020284050', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (149, 106, '2017-07-01 12:41:52.074247', 1, '2158265020284264', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (150, 106, '2017-07-01 12:42:09.171878', 7, '2158265020284264', 'Password was changed.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (151, 106, '2017-07-01 12:42:46.097147', 7, '21582650202842641', 'Password was changed.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (152, 106, '2017-07-01 12:45:39.943867', 7, '2158265020284264', 'Password was changed.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (153, 106, '2017-07-01 12:45:59.896304', 7, '2158265020284264', 'Password was changed.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (154, 106, '2017-07-01 12:54:17.755623', 7, '2158265020284264', 'Password was changed.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (155, 1, '2017-07-01 14:26:51.038324', 1, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (156, 106, '2017-07-01 14:34:24.468761', 7, '2158265020284264', 'Password was changed.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (157, 104, '2017-07-01 14:47:22.613798', 6, NULL, 'old_name=-; old_surname=-; old_fio=evgen; old_bdate=1900-01-01; old_email=evgen@e.e; old_phone=-.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (158, 106, '2017-07-01 14:54:45.015015', 6, NULL, 'old_name=-; old_surname=-; old_fio=ser; old_bdate=1900-01-01; old_email=ser@ser.ser; old_phone=+7-900-000-00-00.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (159, 106, '2017-07-01 16:40:22.745115', 7, '2158265020284264', 'Password was changed.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (160, 105, '2017-07-01 17:01:49.872291', 6, NULL, 'old_name=-; old_surname=-; old_fio=Васильев Василий Василивилич; old_bdate=1900-01-01; old_email=test@ts.ts; old_phone=+7-900-000-00-10; old_address=-1.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (161, 106, '2017-07-01 17:02:04.505118', 6, NULL, 'old_name=-; old_surname=-; old_fio=er; old_bdate=1900-01-01; old_email=ser@ser.ser; old_phone=+7-900-000-00-00; old_address=5.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (162, 106, '2017-07-01 17:02:22.148751', 6, NULL, 'old_name=-; old_surname=-; old_fio=er; old_bdate=1900-01-01; old_email=ser@ser.ser; old_phone=+7-900-000-00-00; old_address=8.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (163, 106, '2017-07-01 17:02:32.023569', 6, NULL, 'old_name=-; old_surname=-; old_fio=er; old_bdate=1900-01-01; old_email=ser@ser.ser; old_phone=+7-900-000-00-00; old_address=9.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (164, 106, '2017-07-01 17:02:42.771989', 6, NULL, 'old_name=-; old_surname=-; old_fio=er; old_bdate=1900-01-01; old_email=ser@ser.ser; old_phone=+7-900-000-00-00; old_address=10.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (165, 106, '2017-07-01 17:02:42.803189', 7, '2158265020284264', 'Password was changed.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (166, 106, '2017-07-01 17:52:45.527933', 1, '2158265025751215', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (167, 106, '2017-07-01 17:52:47.119135', 1, '2158265025751429', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (168, 106, '2017-07-01 18:33:03.454396', 6, NULL, 'old_name=-; old_surname=-; old_fio=er; old_bdate=1900-01-01; old_email=ser@ser.ser; old_phone=+7-900-000-00-00; old_address=11.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (169, 106, '2017-07-01 18:34:48.39579', 7, '2158265025751429', 'Password was changed.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (170, 106, '2017-07-01 18:35:02.701017', 4, '2158265025751429', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (171, 13, '2017-07-01 18:35:16.366642', 1, '282389816569224', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (172, 13, '2017-07-01 18:35:17.801844', 1, '282389816569238', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (173, 13, '2017-07-01 18:40:25.684013', 6, NULL, 'old_name=Semen; old_surname=Semenov; old_fio=-; old_bdate=1986-03-15; old_email=er@er.er; old_phone=+7; old_address=-1.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (174, 13, '2017-07-01 18:40:25.699613', 7, '282389816569238', 'Password was changed.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (175, 1, '2017-07-02 20:37:37.586178', 1, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (176, 106, '2017-07-09 16:05:01.683942', 1, '2158265880173607', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (177, 106, '2017-07-09 16:05:03.399946', 1, '2158265880173821', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (178, 107, '2017-08-02 01:02:52.199701', 5, NULL, NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (179, 107, '2017-08-02 01:02:53.993705', 1, '2178446617107324', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (180, 107, '2017-08-02 01:03:31.901785', 6, NULL, 'old_name=-; old_surname=-; old_fio=vasya; old_bdate=1900-01-01; old_email=era@era.era; old_phone=-; old_address=-1.');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (181, 106, '2017-08-04 23:25:42.420002', 1, '2158276052881994', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (182, 106, '2017-08-04 23:25:44.370006', 1, '2158276052882208', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (183, 106, '2017-08-04 23:26:16.818075', 4, '2158276052882208', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (184, 104, '2017-08-04 23:30:47.041846', 1, '2117934444469935', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (185, 104, '2017-08-04 23:30:48.61745', 1, '2117934444470040', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (186, 104, '2017-08-04 23:30:53.64066', 4, '2117934444470040', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (187, 106, '2017-08-04 23:31:07.43109', 1, '2158276052942449', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (188, 106, '2017-08-04 23:31:09.287493', 1, '2158276052942663', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (189, 106, '2017-08-04 23:49:43.020649', 4, '2158276052942663', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (190, 106, '2017-08-04 23:49:48.24666', 1, '2158276053139436', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (191, 106, '2017-08-04 23:49:49.884664', 1, '2158276053139543', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (192, 106, '2017-08-04 23:50:21.505931', 4, '2158276053139543', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (193, 106, '2017-08-04 23:50:25.76474', 1, '2158276053147675', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (194, 106, '2017-08-04 23:50:27.293543', 1, '2158276053147889', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (195, 106, '2017-08-04 23:56:57.372368', 4, '2158276053147889', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (196, 106, '2017-08-04 23:57:02.067978', 1, '2158276053220114', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (197, 106, '2017-08-04 23:57:03.690382', 1, '2158276053220221', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (198, 106, '2017-08-04 23:57:09.914795', 4, '2158276053220221', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (199, 104, '2017-08-04 23:57:15.000406', 1, '2117934444750075', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (200, 104, '2017-08-04 23:57:17.21561', 1, '2117934444750285', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (201, 104, '2017-08-04 23:57:28.276034', 4, '2117934444750285', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (202, 13, '2017-08-04 23:57:37.745254', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (203, 13, '2017-08-04 23:57:42.331663', 1, '282391259300388', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (204, 13, '2017-08-04 23:57:44.188067', 1, '282391259300416', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (205, 13, '2017-08-05 00:13:25.431658', 4, '282391259300416', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (206, 106, '2017-08-05 00:13:30.018068', 1, '2158276135142310', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (207, 106, '2017-08-05 00:13:31.671672', 1, '2158276135142417', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (208, 106, '2017-08-05 00:17:49.587017', 4, '2158276135142417', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (209, 104, '2017-08-05 00:17:55.203029', 1, '2117934525184275', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (210, 104, '2017-08-05 00:17:56.903433', 1, '2117934525184380', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (211, 104, '2017-08-05 00:18:12.831066', 4, '2117934525184380', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (212, 106, '2017-08-05 00:26:14.310485', 1, '2158276135279698', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (213, 106, '2017-08-05 00:26:15.870488', 1, '2158276135279805', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (214, 106, '2017-08-05 00:38:43.53327', 4, '2158276135279805', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (215, 0, '2017-08-05 00:40:13.046259', 4, '', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (216, 0, '2017-08-05 00:40:48.458334', 4, '', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (217, 104, '2017-08-05 00:41:56.989279', 1, '2117934525436380', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (218, 104, '2017-08-05 00:41:58.705283', 1, '2117934525436590', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (219, 104, '2017-08-05 00:42:05.491297', 4, '2117934525436590', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (220, 106, '2017-08-05 00:42:11.41931', 1, '2158276135450577', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (221, 106, '2017-08-05 00:42:13.260113', 1, '2158276135450791', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (222, 106, '2017-08-06 15:41:21.767426', 1, '2158276258490947', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (223, 106, '2017-08-06 15:41:23.53023', 1, '2158276258491161', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (224, 106, '2017-08-08 19:59:37.997639', 1, '2158276476965259', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (225, 106, '2017-08-08 19:59:39.60175', 1, '2158276476965473', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (226, 106, '2017-08-16 22:23:40.079182', 1, '2158277335790380', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (227, 106, '2017-08-16 22:23:41.873185', 1, '2158277335790487', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (228, 106, '2017-08-17 20:56:21.056871', 1, '2158277441001447', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (229, 106, '2017-08-17 20:56:22.882074', 1, '2158277441001554', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (230, 106, '2017-08-17 21:05:58.72577', 4, '2158277441001554', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (231, 104, '2017-08-17 21:06:03.733378', 1, '2117935807113315', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (232, 104, '2017-08-17 21:06:05.355781', 1, '2117935807113525', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (233, 104, '2017-08-17 21:31:41.193773', 4, '2117935807113525', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (234, 106, '2017-08-17 21:31:46.528981', 1, '2158277441806622', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (235, 106, '2017-08-17 21:31:48.369784', 1, '2158277441806836', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (236, 106, '2017-08-20 20:12:47.627759', 1, '2158277761533429', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (237, 106, '2017-08-20 20:12:50.186163', 1, '2158277761533750', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (238, 106, '2017-08-21 20:39:38.484755', 1, '2158277868821366', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (239, 106, '2017-08-21 20:39:40.77796', 1, '2158277868821580', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (240, 106, '2017-08-22 21:12:48.874347', 1, '2158277976603536', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (241, 106, '2017-08-22 21:12:50.778479', 1, '2158277976603750', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (242, 106, '2017-08-22 21:51:47.48303', 1, '2158277977020729', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (243, 106, '2017-08-22 21:51:49.308235', 1, '2158277977020943', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (244, 106, '2017-08-22 23:11:53.714184', 4, '2158277977020943', '');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (245, 106, '2017-08-22 23:12:04.52501', 1, '2158277978738828', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (246, 106, '2017-08-22 23:12:06.755815', 1, '2158277978739042', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (247, 13, '2017-09-12 21:21:33.07029', 3, NULL, 'incorrect password');

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (248, 106, '2017-09-12 21:21:52.510651', 1, '2158287606700264', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (249, 106, '2017-09-12 21:21:55.938891', 1, '2158287606700585', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (250, 106, '2017-09-14 19:01:35.333004', 1, '2158287818344445', NULL);

INSERT INTO person_log (n, up, dt, action, mc, dsc)
VALUES (251, 106, '2017-09-14 19:01:38.494221', 1, '2158287818344766', NULL);

--
-- Data for table diplom.address (OID = 16618) (LIMIT 0,10)
--
INSERT INTO address (n, country, city, street, house, appartment, dsc)
VALUES (5, 1, 4, 1, 1, 431, NULL);

INSERT INTO address (n, country, city, street, house, appartment, dsc)
VALUES (6, 1, 4, 1, 2, 431, NULL);

INSERT INTO address (n, country, city, street, house, appartment, dsc)
VALUES (7, 1, 4, 1, 2, 431, NULL);

INSERT INTO address (n, country, city, street, house, appartment, dsc)
VALUES (8, 1, 4, 1, 2, 431, NULL);

INSERT INTO address (n, country, city, street, house, appartment, dsc)
VALUES (9, 1, 4, 1, 2, 431, NULL);

INSERT INTO address (n, country, city, street, house, appartment, dsc)
VALUES (10, 1, 4, 1, 2, 414, NULL);

INSERT INTO address (n, country, city, street, house, appartment, dsc)
VALUES (11, 1, 4, 1, 2, 431, NULL);

INSERT INTO address (n, country, city, street, house, appartment, dsc)
VALUES (12, 1, 4, 1, 3, 431, NULL);

INSERT INTO address (n, country, city, street, house, appartment, dsc)
VALUES (13, 1, 5, 2, 4, 4, NULL);

INSERT INTO address (n, country, city, street, house, appartment, dsc)
VALUES (14, 1, 1, 3, 5, 12, NULL);

--
-- Data for table diplom.dic_data (OID = 16635) (LIMIT 0,37)
--
INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (2, 'Россия', 1, 1, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (3, 'США', 1, 2, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (4, 'Москва', 2, 1, 1, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (6, 'Санкт-Петербург', 2, 3, 1, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (7, 'Ростов-на-Дону', 2, 2, 1, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (9, 'Таганрог', 2, 4, 1, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (10, 'пер. Некрасовский', 3, 1, 4, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (11, '17', 4, 1, 1, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (12, '18', 4, 2, 1, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (13, '181', 4, 3, 1, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (14, 'Тамбов', 2, 5, 1, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (15, 'Красных партизан', 3, 2, 5, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (16, '23', 4, 4, 2, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (17, 'Красный', 5, 1, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (18, 'Оранжевый', 5, 2, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (20, 'Желтый', 5, 3, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (21, 'Зеленый', 5, 4, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (22, 'Голубой', 5, 5, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (23, 'Синий', 5, 6, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (24, 'Фиолетовый', 5, 7, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (25, 'Белый', 5, 8, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (29, 'Новинка', 7, 1, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (30, 'Популярный', 7, 2, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (31, 'Распродажа', 7, 3, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (27, 'Название по убыванию', 6, 2, NULL, 'Сортировка');

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (26, 'Название по возрастанию', 6, 1, NULL, 'Сортировка');

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (28, 'Производитель по возрастанию', 6, 3, NULL, 'Сортировка');

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (32, 'Производитель по убыванию', 6, 4, NULL, 'Сортировка');

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (33, 'Цена по возрастанию', 6, 5, NULL, 'Сортировка');

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (34, 'Цена по убыванию', 6, 6, NULL, 'Сортировка');

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (35, 'Черный', 5, 9, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (36, 'Серебряный', 5, 10, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (37, 'Park', 3, 3, 1, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (38, '17', 4, 5, 3, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (39, 'Бирюзовый', 5, 11, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (40, 'Черно-синий', 5, 12, NULL, NULL);

INSERT INTO dic_data (n, term, up, code, r$code, dsc)
VALUES (41, 'Сине-голубой', 5, 13, NULL, NULL);

--
-- Data for table diplom.dic (OID = 16647) (LIMIT 0,7)
--
INSERT INTO dic (n, name, up$dic$n, dsc)
VALUES (1, 'Countries', NULL, 'List of countries.');

INSERT INTO dic (n, name, up$dic$n, dsc)
VALUES (2, 'City', 1, 'List of cities for countries.');

INSERT INTO dic (n, name, up$dic$n, dsc)
VALUES (3, 'Streets', 2, 'List of streets for cities.');

INSERT INTO dic (n, name, up$dic$n, dsc)
VALUES (4, 'Building', 3, 'List of buildings for streets.');

INSERT INTO dic (n, name, up$dic$n, dsc)
VALUES (5, 'Цвета', NULL, 'List of colors.');

INSERT INTO dic (n, name, up$dic$n, dsc)
VALUES (6, 'Сортировка товаров', NULL, 'List of sorting.');

INSERT INTO dic (n, name, up$dic$n, dsc)
VALUES (7, 'Ярлыки', NULL, 'List of labels.');

--
-- Data for table diplom.category (OID = 16668) (LIMIT 0,4)
--
INSERT INTO category (n, up, level, name, type, status, dsc)
VALUES (1, 1, 0, 'Main category', 0, 1, 'Базовая категория!');

INSERT INTO category (n, up, level, name, type, status, dsc)
VALUES (2, 1, 1, 'Спортивные товары', 0, 1, 'Базовая категория для СуперМага');

INSERT INTO category (n, up, level, name, type, status, dsc)
VALUES (3, 2, 2, 'Самокаты', 1, 1, NULL);

INSERT INTO category (n, up, level, name, type, status, dsc)
VALUES (4, 2, 2, 'Сноуборды', 1, 1, NULL);

--
-- Data for table diplom.vendor (OID = 16699) (LIMIT 0,4)
--
INSERT INTO vendor (n, name, dsc)
VALUES (1, 'Explore', 'Канадская фирма по производсву самокатов');

INSERT INTO vendor (n, name, dsc)
VALUES (2, 'Oxelo', 'Бренд, знакомый практически каждому, кто в самокатной теме уже не первый год.');

INSERT INTO vendor (n, name, dsc)
VALUES (3, 'Burton', 'Американская компания Burton относится к тем немногим фирмам, которые по праву можно назвать легендарными. Она была основана Джейком Карпентером Бертоном в 1977 году в штате Вермонт в США. Сегодня его имя известно каждому профессиональному сноубордисту. А для начинающих стоит отметить, что Джейк Карпентер Бертон является «прародителем» современного сноуборда. 

Тогда, в 1977 году, Джейк Бертон начинал создавать свои первые сноуборды в небольшом сарае. Сейчас же его Burton Snowboards – первая в мире компания серийного производства досок для сноубординга. Первые годы развития давались довольно сложно из-за непопулярности данного вида спорта. После открытия в 1982 году в Вермонте первого сноуборд-курорта, куда съезжались отдыхающие со всей Америки, темпы развития компании пошли в гору. 

Наш интернет-магазин не случайно продает сноуборды производства Burton. Они являются частью истории. А приобретая сноуборд, Вы также становитесь частичкой большой легенды. Наслаждайтесь победами на сноубордах Burton!');

INSERT INTO vendor (n, name, dsc)
VALUES (4, 'HelloWood', NULL);

--
-- Data for table diplom.product (OID = 16713) (LIMIT 0,21)
--
INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (7, 3, 2, 'Самокат Oxelo TOWN7 XL ВЗР', '2017-08-08', '5 in exel', 'Для передвижения по городу на средние и длинные дистанции. Размер: от 145 до 195 см. Максим. вес: 100 кг. 2 подвески обеспечивают амортизацию. Идеальный самокат для перемещения на средние и длинные дистанции. В 3 раза быстрее и в 3 раза дальше, чем на своих двоих!', 1, 6999, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (8, 3, 2, 'Самокат для фристайла и дерта Oxelo MF DIRT', '2017-08-08', '6 in excel', 'Для катания в стиле дёрт. Катайтесь по любому покрытию с дертовым самокатом от Oxelo!', 1, 7999, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (9, 3, 1, 'Самокат для взрослых Explore Big Foot Black/Grey', '2017-08-08', '7 in list', 'Колёса: переднее - 230 мм, заднее - 180 мм.
Подшипники АВЕС 7.
Оснащён усиленным тормозом и резиновыми ручками.
Выдерживает вес до 130 кг.', 1, 6790, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (1, 3, 1, 'Самокат для взрослых EXPLORE Robo 200 Black', '2017-07-02', '17 in excel', 'Уникальная разработка этого сезона, новейшая технология сборки (одним нажатием кнопки) дает большую фору другим самокатам, выдерживает 
нагрузку до 120 кг, хороший выбор для тех кто ищет самокат с большими колесами! Explore robo 200 подходит как самокат для взрослых и в тоже время как детский самокат от 8+.', 0, 3250, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (10, 4, 3, 'Сноуборд Burton GENIE (13-14)', '2017-08-13', '1 in list', 'Genie - модель в линейке досок для девушек, которые только начинают осваивать сноубординг. Её можно описать фразой, что нет ничего плохого в том, чтобы быть проще! В этой доске собрано всё необходимое для того чтобы быстро и безопасно освоить снежную доску! 

Система закладных 3D. 
Форма - Easy Rider. 
Сердечник - Women''s Specific True Flex Fly. 
Стекловолокно - Biax. 
Жёсткость - Twin.', 1, 12456, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (11, 4, 3, 'Сноуборд Burton BARRACUDA FW15', '2017-08-13', '2 in list', 'Барракуда - это рыба обитающая в тропических водах мирового океана. Среда обитания, где Барракуды обычно охотятся - заросли, камни и скалы. Именно в таких условиях, конечно, не в мировом океане, обитают настоящие любители фрирайда. Будь-то лес, скалистая альпика или просто свежий паудер рядом с трассой - Barracuda справится со всем! Отличный фрирайд снаряд, позволяющий получить максимальное удовольствие от катания.
Назначение: groomers + backcountry
Жесткость: средняя 
Прогиб: S-Rocker
Система закладных ICS. 
Форма 15 мм Taper. 
Сердечник - Super Fly ll с Dualzone EGD, 
Вставки из карбона Carbon I-Beam. 
Frostbite Edges - канты в зоне креплений на пол-миллиметра шире, для невероятного контроля, даже на ледяной поверхности. При этом общая жесткость доски остается неизменной, 
Pro-tip - заостренный хвост для лучшей маневренности в глубоком снегу и более низкого веса 
Infinite Ride - эксклюзивная технология от Burton, которая позволяет повысить щелчок и прочность доски

', 1, 29740, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (2, 3, 1, 'Самокат Explore Leader blue', '2017-07-02', '15 in excel - 3999', '100% Алюминиевая рама Подножка Регулируемая высота руля до 95 см Легкая система складывания Колёса: PU 205*36 мм, жесткость 82А Подшипники: ABEC - 5 Грузоподъемность: до 100 кг.', 1, 4650, 2999);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (3, 3, 1, 'Самокат Explore DECKLINE', '2017-07-08', '1 in excel', 'Стальная рама
Не регулируемая высота руля
Прорезиненные ручки
Деревянная платформа 55*15 см
Колёса: PU 200*36 мм, жесткость 82А
Подшипники: ABEC -7 
Грузоподъемность: до 100 кг', 1, 2500, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (4, 3, 2, 'Самокат Oxelo TOWN 7 ХРОМ', '2017-07-08', '2 in excel', 'Для передвижения по городу на средние и длинные дистанции. Размер: от 1м 45 до 1м 95 ПЕРЕДВИГАЙТЕСЬ ПО ГОРОДУ ПРОЩЕ!Передвигайтесь в 3 раза быстрее на новом самокате Town 7 200Easyfold.', 1, 8999, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (5, 3, 2, 'Самокат для фристайла Oxelo FREESTYLE MF ONE ', '2017-07-08', '3 in excel', 'Для желающих обучиться катанию на самокате в стиле "фристайл". Самокат для фристайла, доступный для всех!', 1, 4299, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (6, 3, 2, 'Самокат для фристайла Oxelo MF 1.8 2013', '2017-08-08', '4 in excel', 'Для начинающих кататься на самокате в стиле Freestyle. Новый самокат MF 1.8 2013 для первых трюков на самокате!', 1, 5999, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (12, 4, 3, 'Сноуборд Burton BLUNT FW14', '2017-08-13', '3 in list', 'Burton Blunt - это отличная парковая доска, ориентированная, преимущественно на джиббинг. Но на ней можно спокойно начинать свой путь в сноубординге новичкам. Ведь доска сама по себе мягкая и податливая, что позитивно сказывается на прогрессе в катании.  Графика - Jeff Fried.

Назначение: groomers + park
Жесткость: средняя 
Прогиб: Rocker 
Ширина: традиционная и wide
Система закладных ICS. 
Форма Twin. 
Сердечник - Fly Core. 
Scoop - специальная форма хвоста и носа делает каждый поворот еще четким. Эта технология позволяет прощать ошибки, как на рейлах, так и в паудере. 
Стрингеры Jumper Cables, распределяющие энергию из центральной части к хвосту и тейлу 
Канты Frostbite
Pro-tip - заостренный хвост для лучшей маневренности в глубоком снегу и более низкого веса', 1, 14370, 13999);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (13, 3, 4, 'Самокат для взрослых HW Hellowood - RACER BLACK', '2017-08-13', '8 in list', 'Самокат для взрослых HW Hellowod-RACER BLACK

Бренды: HelloWood 
Материал: 100% алюминий, стальная вилка, усиленная рулевая стойка. 
Дека: 46.5*13.5см 
Колеса: PU 200мм 
Подшипники: ABEC 7 
Вес: 5, 5 кг 
Максимальная нагрузка: 100 кг 
Технологии: самокат с двумя амортизаторами', 1, 5890, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (14, 3, 4, 'Самокат для взрослых HW Hellowood - RACER RED', '2017-08-13', '9 in list', 'Самокат для взрослых HW Hellowood-RACER RED

Бренды: HelloWood 
Материал: 100% алюминий, стальная вилка, усиленная рулевая стойка. 
Дека: 46.5*13.5см 
Колеса: PU 200мм 
Подшипники: ABEC 7 
Вес: 5, 5 кг 
Максимальная нагрузка: 100 кг 
Технологии: самокат с двумя амортизаторами', 1, 5890, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (15, 3, 1, 'Самокат для взрослых Explore Spitfire', '2017-08-13', '10 in list', 'Самокат для взрослых Explore Spitfire

100% Алюминиевая рама
Подножка
Регулируемая высота руля до 95см, 
Легкая система складывания
Пластиковые крылья-брызговики
Плечевой ремень
Колёса: PU 205/30 мм, жесткость 82А
Подшипники: ABEC -7
Грузоподъемность: до 110 кг
Вес: 5 кг', 1, 6290, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (16, 3, 4, 'Самокат для взрослых HW Hellowood - RACER PINK', '2017-08-13', '11 in list', 'Самокат для взрослых HW Hellowood Racer pink

Бренды: HelloWood 
Материал: 100% алюминий, стальная вилка, усиленная рулевая стойка. 
Дека: 46.5*13.5см 
Колеса: PU 200мм 
Подшипники: ABEC 7 
Вес: 5, 5 кг 
Максимальная нагрузка: 100 кг 
Технологии: самокат с двумя амортизаторами', 1, 5890, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (17, 3, 1, 'Самокат Explore Leader blk', '2017-08-13', '13 in list', '100% Алюминиевая рама Подножка Регулируемая высота руля до 95 см Легкая система складывания Колёса: PU 205*36 мм, жесткость 82А Подшипники: ABEC - 5 Грузоподъемность: до 100 кг', 1, 4650, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (18, 3, 1, 'Самокат для взрослых Explore BRIXTON', '2017-08-13', '16 in list', '100% Алюминиевая рама
Подножка
Регулируемая высота руля ______, 
Пластиковые крылья-брызговики (+ запасной)
Плечевой ремень
Легкая система складывания
Колёса: PU 205/30 мм, жесткость 82А
Подшипники: ABEC -7
Грузоподъемность: до 100 кг
Вес: 6 кг', 1, 5790, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (19, 3, 1, 'Двухколесный самокат Explore LEADER', '2017-08-13', '18 in list', 'Explore LEADER - самокат, который дарит волшебную возможность витать над землей, пусть даже на колесах, но ощущения легко сравнить с полетом в воздухе. Но испытать такой шанс могут не только дети, которые так любят самокаты, но и взрослые, которые в последнее время все больше приспосабливаются к этому. Покоряй дороги вместе с самокатом Explore LEADER.', 1, 4200, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (20, 3, 1, 'Самокат для взрослых Explore Voltage Green', '2017-08-13', '19 in list', 'Колёса 200 мм. </br>
Подшипники  АВЕС 5.</br>
Размеры площадки для ног - 44 * 12 см</br>
Выдерживает вес до 100 кг', 1, 2890, NULL);

INSERT INTO product (n, up, vendor, name, dt, dsc, descr, in_stock, price, price_d)
VALUES (21, 3, 1, 'Самокат для взрослых Explore Rapler green', '2017-08-13', '20 in list', '100 % алюминиевая рама </br>
Регулируемая высота руля до 95см</br>
Прорезиненные ручки</br>
Легкая система складывания</br>
Подножка</br>
Колёса: PU 200*36 мм, жесткость 82А</br>
Подшипники: ABEC -7</br>
Грузоподъемность: до 100 кг', 1, 3990, 2990);

--
-- Data for table diplom.attr (OID = 16726) (LIMIT 0,107)
--
INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (1, 1, 1, 1, '1', NULL, 1, 'Красный');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (2, 1, 1, 1, '4', NULL, 1, 'Зеленый');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (3, 1, 1, 1, '7', NULL, 1, 'Фиолетовый');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (4, 1, 1, 1, '8', NULL, 0, 'Белый');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (5, 1, 1, 2, '17-1.jpg', '1', 1, 'Главная');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (6, 1, 2, 2, '15-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (7, 1, 2, 2, '15-2.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (8, 1, 2, 2, '15-3.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (9, 1, 2, 2, '15-4.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (10, 1, 2, 3, '3', NULL, 1, 'Sale');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (11, 1, 3, 1, '1', NULL, 1, 'Красный');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (12, 1, 3, 1, '4', NULL, 1, 'Зеленый');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (13, 1, 3, 2, '1-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (14, 1, 3, 2, '1-2.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (15, 1, 3, 3, '1', NULL, 1, 'New');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (16, 1, 4, 3, '2', NULL, 1, 'Hot');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (23, 1, 4, 1, '5', NULL, 1, 'Голубой');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (24, 1, 4, 1, '6', NULL, 1, 'Синий');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (25, 1, 4, 1, '9', NULL, 1, 'Черный');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (26, 1, 4, 1, '10', NULL, 1, 'Серебро');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (17, 1, 4, 2, '2-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (18, 1, 4, 2, '2-2.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (19, 1, 4, 2, '2-3.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (20, 1, 4, 2, '2-4.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (21, 1, 4, 2, '2-5.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (22, 1, 4, 2, '2-6.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (27, 1, 5, 1, '1', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (28, 1, 5, 1, '8', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (29, 1, 5, 2, '3-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (30, 1, 5, 2, '3-2.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (31, 1, 5, 2, '3-3.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (32, 1, 5, 2, '3-4.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (33, 1, 5, 2, '3-5.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (34, 1, 5, 2, '3-6.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (35, 1, 5, 2, '3-7.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (36, 1, 5, 2, '3-8.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (37, 1, 5, 2, '3-9.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (38, 1, 5, 2, '3-10.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (39, 1, 5, 2, '3-11.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (40, 1, 6, 3, '1', NULL, 1, 'New');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (41, 1, 6, 2, '4-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (42, 1, 6, 2, '4-2.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (43, 1, 6, 2, '4-3.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (44, 1, 6, 2, '4-4.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (45, 1, 6, 2, '4-5.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (46, 1, 6, 2, '4-6.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (47, 1, 6, 2, '4-7.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (48, 1, 6, 2, '4-8.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (49, 1, 6, 2, '4-9.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (50, 1, 6, 2, '4-10.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (51, 1, 6, 1, '9', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (52, 1, 6, 1, '10', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (53, 1, 7, 1, '8', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (54, 1, 7, 1, '9', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (57, 1, 7, 2, '5-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (58, 1, 7, 2, '5-2.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (59, 1, 7, 2, '5-3.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (60, 1, 7, 2, '5-4.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (62, 1, 7, 2, '5-6.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (61, 1, 7, 2, '5-5.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (63, 1, 7, 2, '5-7.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (64, 1, 7, 2, '5-8.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (65, 1, 7, 2, '5-9.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (66, 1, 7, 3, '1', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (67, 1, 8, 2, '6-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (68, 1, 8, 2, '6-2.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (69, 1, 8, 2, '6-3.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (70, 1, 8, 2, '6-4.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (71, 1, 8, 2, '6-5.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (72, 1, 8, 2, '6-6.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (73, 1, 8, 3, '1', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (74, 1, 9, 2, '7-1.png', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (75, 1, 9, 2, '7-2.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (76, 1, 9, 2, '7-3.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (77, 1, 9, 3, '1', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (80, 1, 10, 1, '6', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (79, 1, 10, 1, '7', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (81, 1, 10, 1, '3', NULL, 1, 'Желтый');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (82, 1, 10, 1, '11', NULL, 1, 'Бирюзовый');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (84, 1, 11, 1, '13', NULL, 1, 'Сине-голубой');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (83, 1, 11, 1, '12', NULL, 1, 'Черно-синий');

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (86, 1, 10, 2, '1-2.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (85, 1, 10, 2, '1-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (87, 1, 10, 2, '1-3.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (88, 1, 10, 2, '1-4.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (89, 1, 11, 2, '2-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (90, 1, 11, 2, '2-2.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (91, 1, 12, 2, '3.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (92, 1, 10, 3, '1', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (94, 1, 12, 3, '3', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (93, 1, 11, 3, '2', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (95, 1, 13, 2, '8-1.png', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (96, 1, 14, 2, '9-1.png', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (97, 1, 15, 2, '10-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (98, 1, 15, 2, '10-2.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (99, 1, 15, 2, '10-3.jpg', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (100, 1, 16, 2, '11-1.png', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (101, 1, 17, 2, '13-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (102, 1, 18, 2, '16-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (103, 1, 14, 3, '1', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (105, 1, 18, 3, '1', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (104, 1, 16, 3, '2', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (106, 1, 19, 2, '18-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (107, 1, 20, 2, '19-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (108, 1, 21, 2, '20-1.jpg', '1', 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (109, 1, 19, 3, '2', NULL, 1, NULL);

INSERT INTO attr (n, obj, obj_n, attr, val1, val2, status, dsc)
VALUES (110, 1, 21, 3, '3', NULL, 1, NULL);

--
-- Data for table diplom.obj (OID = 16735) (LIMIT 0,11)
--
INSERT INTO obj (n, obj_name, obj_type, dsc)
VALUES (7, 'DIC_DATA', 'Table', 'Таблица с терминами словарей');

INSERT INTO obj (n, obj_name, obj_type, dsc)
VALUES (8, 'OBJ', 'Table', 'Таблица с объектами');

INSERT INTO obj (n, obj_name, obj_type, dsc)
VALUES (9, 'PERSON_LOG', 'Table', 'Таблица с логами');

INSERT INTO obj (n, obj_name, obj_type, dsc)
VALUES (10, 'VENDOR', 'Table', 'Таблица с производителями продуктов');

INSERT INTO obj (n, obj_name, obj_type, dsc)
VALUES (6, 'DIC', 'Table', 'Таблица со словарями');

INSERT INTO obj (n, obj_name, obj_type, dsc)
VALUES (5, 'ATTR', 'Table', 'Таблица с атрибутами объектов');

INSERT INTO obj (n, obj_name, obj_type, dsc)
VALUES (4, 'ADDRESS', 'Table', 'Таблица с адресами');

INSERT INTO obj (n, obj_name, obj_type, dsc)
VALUES (3, 'PERSON', 'Table', 'Таблица с пользователями');

INSERT INTO obj (n, obj_name, obj_type, dsc)
VALUES (2, 'CATEGORY', 'Table', 'Таблица с категориями');

INSERT INTO obj (n, obj_name, obj_type, dsc)
VALUES (1, 'PRODUCT', 'Table', 'Таблица с продуктами');

INSERT INTO obj (n, obj_name, obj_type, dsc)
VALUES (11, 'ATTR_DESC', 'Table', 'Таблица с описанием атрибутов');

--
-- Data for table diplom.attr_desc (OID = 16743) (LIMIT 0,3)
--
INSERT INTO attr_desc (n, name, type, dic_n, dsc)
VALUES (1, 'Цвет', 1, 5, NULL);

INSERT INTO attr_desc (n, name, type, dic_n, dsc)
VALUES (2, 'Изображение', 3, NULL, NULL);

INSERT INTO attr_desc (n, name, type, dic_n, dsc)
VALUES (3, 'Ярлык', 1, 7, NULL);

--
-- Data for table diplom.cart (OID = 16765) (LIMIT 0,14)
--
INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (104, 1, 1, 1, NULL, NULL);

INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (103, 1, 2, 2, NULL, NULL);

INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (106, 10, 0, 80, 0, NULL);

INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (106, 8, 6, 0, 0, NULL);

INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (106, 4, 4, 23, 0, NULL);

INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (106, 11, 1, 84, 0, NULL);

INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (106, 3, 1, 0, 0, NULL);

INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (103, 2, 1, NULL, NULL, NULL);

INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (106, 1, 1, 1, 0, NULL);

INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (106, 4, 0, 0, 0, NULL);

INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (107, 4, 2, 0, 0, NULL);

INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (13, 3, 1, 0, 0, NULL);

INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (104, 2, 1, 0, 0, NULL);

INSERT INTO cart (up, product_n, cnt, attr_1, attr_2, dsc)
VALUES (106, 2, 3, 0, 0, NULL);

--
-- Definition for index cart_pkey (OID = 16774) : 
--
CREATE INDEX cart_pkey ON cart USING btree (up);
--
-- Definition for index person_pkey (OID = 16451) : 
--
ALTER TABLE ONLY person
    ADD CONSTRAINT person_pkey
    PRIMARY KEY (id);
--
-- Definition for index person_log_pkey (OID = 16594) : 
--
ALTER TABLE ONLY person_log
    ADD CONSTRAINT person_log_pkey
    PRIMARY KEY (n);
--
-- Definition for index address_pkey (OID = 16625) : 
--
ALTER TABLE ONLY address
    ADD CONSTRAINT address_pkey
    PRIMARY KEY (n);
--
-- Definition for index dic_data_pkey (OID = 16642) : 
--
ALTER TABLE ONLY dic_data
    ADD CONSTRAINT dic_data_pkey
    PRIMARY KEY (n);
--
-- Definition for index dic_pkey (OID = 16654) : 
--
ALTER TABLE ONLY dic
    ADD CONSTRAINT dic_pkey
    PRIMARY KEY (n);
--
-- Definition for index dic_name_key (OID = 16656) : 
--
ALTER TABLE ONLY dic
    ADD CONSTRAINT dic_name_key
    UNIQUE (name);
--
-- Definition for index category_pkey (OID = 16675) : 
--
ALTER TABLE ONLY category
    ADD CONSTRAINT category_pkey
    PRIMARY KEY (n);
--
-- Definition for index vendor_pkey (OID = 16706) : 
--
ALTER TABLE ONLY vendor
    ADD CONSTRAINT vendor_pkey
    PRIMARY KEY (n);
--
-- Definition for index vendor_name_key (OID = 16708) : 
--
ALTER TABLE ONLY vendor
    ADD CONSTRAINT vendor_name_key
    UNIQUE (name);
--
-- Definition for index product_pkey (OID = 16720) : 
--
ALTER TABLE ONLY product
    ADD CONSTRAINT product_pkey
    PRIMARY KEY (n);
--
-- Definition for index attr_pkey (OID = 16733) : 
--
ALTER TABLE ONLY attr
    ADD CONSTRAINT attr_pkey
    PRIMARY KEY (n);
--
-- Definition for index obj_pkey (OID = 16741) : 
--
ALTER TABLE ONLY obj
    ADD CONSTRAINT obj_pkey
    PRIMARY KEY (n);
--
-- Definition for index attr_desc_pkey (OID = 16749) : 
--
ALTER TABLE ONLY attr_desc
    ADD CONSTRAINT attr_desc_pkey
    PRIMARY KEY (n);
--
-- Data for sequence diplom.sq$person (OID = 16394)
--
SELECT pg_catalog.setval('sq$person', 107, true);
--
-- Data for sequence diplom.sq$person_log (OID = 16538)
--
SELECT pg_catalog.setval('sq$person_log', 251, true);
--
-- Data for sequence diplom.sq$address (OID = 16616)
--
SELECT pg_catalog.setval('sq$address', 14, true);
--
-- Data for sequence diplom.sq$dic_data (OID = 16633)
--
SELECT pg_catalog.setval('sq$dic_data', 41, true);
--
-- Data for sequence diplom.sq$dic (OID = 16644)
--
SELECT pg_catalog.setval('sq$dic', 7, true);
--
-- Data for sequence diplom.sq$category (OID = 16666)
--
SELECT pg_catalog.setval('sq$category', 4, true);
--
-- Data for sequence diplom.sq$vendor (OID = 16697)
--
SELECT pg_catalog.setval('sq$vendor', 4, true);
--
-- Data for sequence diplom.sq$product (OID = 16711)
--
SELECT pg_catalog.setval('sq$product', 21, true);
--
-- Data for sequence diplom.sq$attr (OID = 16724)
--
SELECT pg_catalog.setval('sq$attr', 110, true);
--
-- Comments
--
COMMENT ON SCHEMA public IS 'standard public schema';
COMMENT ON FUNCTION diplom.change_password (i_id numeric, i_newpas varchar, i_sessionid varchar) IS 'Function for changing password for person.
result number:
1 - Ok!
0 - person not found!
-1 - new password is null!
-2 - new password are same with old password.';
COMMENT ON FUNCTION diplom.check_session (i_id numeric, i_sessionid varchar) IS 'Function eor checking session.
Return 1 if sessionID equal sessionID for last login.';
COMMENT ON COLUMN diplom.address.dsc IS 'comments';
COMMENT ON COLUMN diplom.dic_data.up IS 'link on the table with list of dictionaries';
COMMENT ON COLUMN diplom.dic_data.code IS 'code of termin';
COMMENT ON COLUMN diplom.dic_data.r$code IS 'link on the term in other dictionary';
COMMENT ON COLUMN diplom.dic_data.dsc IS 'comments';
COMMENT ON COLUMN diplom.dic.up$dic$n IS 'link on the parents dictionary';
COMMENT ON COLUMN diplom.dic.dsc IS 'comments';
COMMENT ON FUNCTION diplom.dic_data$find_or_insert (i_up numeric, i_term varchar, i_r$code numeric, i_dsc varchar) IS 'Function for finding or adding new termins in the dictionaries.
Returns number:
positive value - code of new termin;
-1 - for this dictionary not exist parents;
-2 - in the parents dictionary not exist termin with i_r$code;
-999 - others error.';
COMMENT ON FUNCTION diplom.change_person_info (i_id numeric, i_name varchar, i_surname varchar, i_fio varchar, i_bdate date, i_email varchar, i_phone varchar, i_address numeric) IS 'Function for changing person by PERSON.ID
return:
1 - data was changed without errors;
0 - person not found;
-1 - person with same email with new email already exists;
-999 - other errors. ';
COMMENT ON COLUMN diplom.category.up IS 'link on upper category';
COMMENT ON COLUMN diplom.category.type IS '0 - parent for other category; 1 - parent for products.';
COMMENT ON COLUMN diplom.category.status IS '1 - active; 0 - not active.';
COMMENT ON COLUMN diplom.category.dsc IS 'comments';
COMMENT ON FUNCTION diplom.category$new (i_up integer, i_name varchar, i_type integer, i_status integer, i_dsc varchar) IS 'Function for creating new category.
Return number:
positive value - number of new category;
0 - one of the parameters is null;
-1 - parent category not exists;
-2 - status or type has incorrect status (possible 0,1);
-3 - category with same name exist in the i_up category;
-999 - other errors.';
COMMENT ON FUNCTION diplom.vendor$find_or_insert (i_name varchar, i_dsc varchar) IS 'Function for adding new vendor.
Return number:
positive value - number of new vendor;
-999 - other errors.';
COMMENT ON COLUMN diplom.product.up IS 'link on the category.n';
COMMENT ON COLUMN diplom.product.vendor IS 'link on the vendor.n';
COMMENT ON COLUMN diplom.product.dt IS 'date of adding in catalogue';
COMMENT ON COLUMN diplom.product.dsc IS 'internal comments';
COMMENT ON COLUMN diplom.product.descr IS 'description for product';
COMMENT ON COLUMN diplom.product.in_stock IS '1 - in stock; 0 - out of stock';
COMMENT ON FUNCTION diplom.product$new_product (i_up integer, i_vendor integer, i_name varchar, i_dsc varchar, i_desc varchar, i_stock integer) IS 'Function for adding new product in catalogue.
Return number:
positive value - number of new product;
-1 - category i_up not exist;
-2 - vendor not exist;
-3 - incorrect stock status (i_stock). possible 0,1;
-999 - other error.';
COMMENT ON COLUMN diplom.attr.obj IS 'type of object';
COMMENT ON COLUMN diplom.attr.obj_n IS 'number of object';
COMMENT ON COLUMN diplom.attr.attr IS 'type of attribute';
COMMENT ON COLUMN diplom.attr.val1 IS 'first value of attribute';
COMMENT ON COLUMN diplom.attr.val2 IS 'second value of attribute';
COMMENT ON COLUMN diplom.attr.dsc IS 'internal comments';
COMMENT ON COLUMN diplom.attr_desc.type IS 'type of attr. 1-number, 2-date, 3-char, 4-boolean';
COMMENT ON COLUMN diplom.attr_desc.dic_n IS 'number of dictionary.';
COMMENT ON COLUMN diplom.attr_desc.dsc IS 'internal comments.';
COMMENT ON COLUMN diplom.cart.up IS 'link on a person';
COMMENT ON COLUMN diplom.cart.cnt IS 'count of product';
COMMENT ON COLUMN diplom.cart.attr_1 IS 'link on attr';
COMMENT ON COLUMN diplom.cart.attr_2 IS 'link on attr';
COMMENT ON COLUMN diplom.cart.dsc IS 'comments';
COMMENT ON FUNCTION diplom.cart$add_product (i_up integer, i_product_n integer, i_cnt integer, i_attr_n_a integer, i_attr_n_b integer, i_dsc varchar) IS 'Function for adding product in the cart.
Return total price for cart or negative error:
-1 - incorrect number of person;
-2 - incorrect number of product;
-3 - incorrect number of attribute A;
-4 - incorrect number of attribute B;
-5 - can''t deduct product for product with cnt=0;
-6 - can''t deduct product which not present in the cart;
-7 - can''t dudect product. count of product in the cart less when i_cnt; 
-10 - can''t make choice.
-999 - other errors.
';
