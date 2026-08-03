CREATE OR REPLACE FUNCTION keplersc.caracteristicas_cuenta(dataxml xml)
 RETURNS TABLE(nivel text, desc_nivel text, tipo text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: obtiene características de una cuenta contable
--Autor: Luis Leal
--Fecha: 12/10/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cuenta text = '';
	anio text;
	nivel_cuenta text = '';
	descripcion_nivel text = '';
	cuenta_len_1 int;
	cuenta_len_2 int;
	cuenta_len_3 int;
	tipo_cuenta text = '';
	is_number bool;
	caracter_distintivo text;
	posicion_cuenta text;

	--variables de uso general
	tabla_cuentas text = '';
	intValor int = 0;
	expSql text = '';

	cuenta_nivel_1 bool;
	cuenta_nivel_2 bool;
	cuenta_nivel_3 bool;
	cuenta_nivel_4 bool;


begin
	
	cuenta := coalesce((xpath('//document/cuenta/text()', dataxml))[1]::text,'')::text; 
	anio := coalesce((xpath('//document/anio/text()', dataxml))[1]::text,'')::text; 

	tabla_cuentas = 'keplersc.kdc1' || anio;

	cuenta_len_1 := length(cuenta);
	cuenta_nivel_1 := true;

	for i in 1..cuenta_len_1 loop	
		
		posicion_cuenta := substring(cuenta,1, cuenta_len_1 - i);
	
		if length(posicion_cuenta) = '0' then
			exit;
		end if;
				
		raise notice 'loop 1 %, %' , cuenta, posicion_cuenta; 
	
		expSql = format('SELECT count(*) from %1$s where c1=%2$L',tabla_cuentas,posicion_cuenta);
		
		execute expSql into intValor;
	
		if intValor > 0 then 

			raise notice 'cuenta mayor encontrada: %', posicion_cuenta;
		
			cuenta_len_2 := length(posicion_cuenta);
			cuenta_nivel_2 := true;

			for x in 1..cuenta_len_2 loop
				
				posicion_cuenta := substring(posicion_cuenta,1, cuenta_len_2 - x);
			
				if length(posicion_cuenta) = '0' then
					exit;
				end if;
				
				raise notice 'loop 2 %, %, %' , cuenta, posicion_cuenta, x; 
	
				expSql = format('SELECT count(*) from %1$s where c1=%2$L',tabla_cuentas,posicion_cuenta);
			
				execute expSql into intValor;
			
				if intValor > 0 then 
			
					raise notice 'cuenta mayor encontrada: %', posicion_cuenta;

					cuenta_len_3 := length(posicion_cuenta);
					cuenta_nivel_3 := true;

					for y in 1..cuenta_len_3 loop	

						posicion_cuenta := substring(posicion_cuenta,1, cuenta_len_3 - y);
					
						if length(posicion_cuenta) = '0' then
							exit;
						end if;
			
						raise notice 'loop 3 %, %' , cuenta, posicion_cuenta; 
					
						expSql = format('SELECT count(*) from %1$s where c1=%2$L',tabla_cuentas,posicion_cuenta);
						
						execute expSql into intValor;
					
						if intValor > 0 then 
						
							raise notice 'cuenta mayor encontrada: %', posicion_cuenta;
							cuenta_nivel_4 := true;
						
						end if;
					
					end loop;
					
				end if;
			
				if cuenta_nivel_3 is true then
					exit;
				end if;
			
			end loop;
		
		end if;	
	
		if cuenta_nivel_2 is true then
			exit;
		end if;
	
	end loop;

	if cuenta_nivel_4 is true then
		nivel_cuenta := '4';
	else
		if cuenta_nivel_3 is true then
			nivel_cuenta := '3';
		else 
			if cuenta_nivel_2 is true then
				nivel_cuenta := '2';
			else
				if cuenta_nivel_1 is true then
					nivel_cuenta := '1';
					descripcion_nivel := 'Mayor';
				end if;
			end if;
		end if;
	end if;


	if descripcion_nivel <> 'Mayor' then
	
		expSql = format('SELECT count(*) from %1$s where c1 like %2$L',tabla_cuentas,concat(cuenta, '%'));
			
		execute expSql into intValor;
	
		if intValor > 1 then 
			descripcion_nivel := 'Intermedia';
		else 
			descripcion_nivel := 'Menor';
		end if;
	
	end if;	

					
	caracter_distintivo := substring(cuenta,9, 1);

	if caracter_distintivo = 'N' or caracter_distintivo = 'U'  then
		tipo_cuenta := 'Otros Conceptos';
	else
		caracter_distintivo := substring(cuenta,5, 1);
		
		if caracter_distintivo = 'C' then
			tipo_cuenta := 'Cliente';
		else 
			if  caracter_distintivo = 'D' then
				tipo_cuenta := 'Proveedor';	
			end if;
		end if ;
			
	end if;
	

	return query
	select nivel_cuenta, descripcion_nivel , tipo_cuenta;
	
exception
	when others then
		raise exception '%', 'Sin Resultados';
end;
$function$
