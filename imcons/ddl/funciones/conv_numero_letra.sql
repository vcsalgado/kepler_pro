CREATE OR REPLACE FUNCTION keplersc.conv_numero_letra(num numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
-- Función que devuelve la cadena de texto que corresponde a un número.
-- Parámetros: número con 2 decimales, máximo 999.999.999,99.
 
DECLARE	
	d VARCHAR[];
	f VARCHAR[];
	g VARCHAR[];
	numt VARCHAR;
	txt VARCHAR;
	a INTEGER;
	a1 INTEGER;
	a2 INTEGER;
	n INTEGER;
	p INTEGER;
	negativo BOOLEAN;
begin
	-- Máximo 999.999.999,99
	if num > 999999999.99 then	
		return '---';
	end if;	
	txt = '';
	d = array[' UN',' DOS',' TRES',' CUATRO',' CINCO',' SEIS',' SIETE',' OCHO',' NUEVE',' DIEZ',' ONCE',' DOCE',' TRECE',' CATORCE',' QUINCE', 
		' DIECISEIS',' DIECISIETE',' DIECIOCHO',' DIECINUEVE',' VEINTE',' VEINTIUN',' VEINTIDOS', ' VEINTITRES', ' VEINTICUATRO', ' VEINTICINCO', 
		' VEINTISEIS',' VEINTISIETE',' VEINTIOCHO',' VEINTINUEVE'];
	f = array ['','',' TREINTA',' CUARENTA',' CINCUENTA',' SESENTA',' SETENTA',' OCHENTA', ' NOVENTA'];
	g= array [' CIENTO',' DOSCIENTOS',' TRESCIENTOS',' CUATROCIENTOS',' QUINIENTOS',' SEISCIENTOS',' SETECIENTOS',' OCHOCIENTOS',' NOVECIENTOS'];
	numt = LPAD((num::numeric(12,2))::text,12,'0');
	if strpos(numt,'-') > 0 then
	   negativo = TRUE;
	else
	   negativo = FALSE;
	end if;
	numt = translate(numt,'-','0');
	numt = translate(numt,'.,','');
	-- Trato 4 grupos: millones, miles, unidades y decimales
	p = 1;
	for i in 1..4 loop	
		IF i < 4 then  	
			n = substring(numt::text from p for 3);
		else		--decimales
			n = substring(numt::text from p for 2);
		end if;
		p = p + 3;		
		if i = 4 then		--SON DECIMALES
			if txt = '' then
				txt = ' CERO';
			end if;
			if n > 0 then
			-- Empieza con los decimales
				txt = txt || ' PESOS ' || n||'/100 M.N.';		
			else
				txt = txt || ' PESOS 00/100 M.N.';		
			end if;
			exit;
		end if;
		-- Centenas 
		if n > 99 then
			a = substring(n::text from 1 for 1);		
			a1 = substring(n::text from 2 for 2);		
			if a = 1 then
				if a1 = 0 then
					txt = txt || ' CIEN';
				else
					txt = txt || ' CIENTO';
				end if;
			else
				txt = txt || g[a];		
			end if;
		else			
			a1 = n;		
		end if;
		-- Decenas
		a = a1;		
		if a > 0 then
			if a < 30 then
				if a = 21 and (i = 3) then
					txt = txt || ' VEINTIUN';
				elsif n = 1 and i = 2 then
					txt = txt; 
				elsif a = 1 and (i = 3)then
					txt = txt || ' UN';
				else
					txt = txt || d[a];
				end if;
			else
				a1 = substring(a::text from 1 for 1);
				a2 = substring(a::text from 2 for 1);
				if a2 = 1 and (i = 3) then
						txt = txt || f[a1] || ' Y' || ' UN';
				else
					if a2 <> 0 then
						txt = txt || f[a1] || ' Y' || d[a2];
					else
						txt = txt || f[a1];
					end if;
				end if;
			end if;
		end if;
		if n > 0 then
			if i = 1 then
				if n = 1 then
					txt = txt || ' MILLON';
				else
					txt = txt || ' MILLONES';
				end if;
			elsif i = 2 then
				if n=1 then
					txt = txt || ' UN MIL';
				else 
					txt = txt || ' MIL';
				end if;
			end if;		
		end if;
	end loop;
	txt = LTRIM(txt);
	if negativo = TRUE then
	   txt= '-' || txt;
	end if;
    return txt;
end;
$function$
