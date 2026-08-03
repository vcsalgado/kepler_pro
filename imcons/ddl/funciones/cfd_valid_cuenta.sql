CREATE OR REPLACE FUNCTION keplersc.cfd_valid_cuenta(dataxml xml)
 RETURNS TABLE(resultado_valid_cuenta text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: cfd_valid_cuenta
--Autor: Luis Leal
--Fecha: 13/12/2021
--Bitacora de cambios
declare

	numero_cuenta text;
   	longitud_cuenta numeric;
   	forma_de_pago text;
   	isnumber bool;
	resultado_valid_cuenta text;

begin
	
	resultado_valid_cuenta = '0';
	numero_cuenta := coalesce((xpath('//document/k_cuenta/text()',dataxml))[1]::text,'')::text;
	forma_de_pago := coalesce((xpath('//document/k_f_pago/r1/text()',dataxml))[1]::text,'')::text;
	longitud_cuenta := length(numero_cuenta);
		
	if forma_de_pago = '02' or forma_de_pago = '03' or forma_de_pago = '04' or forma_de_pago = '06' or forma_de_pago = '28' or forma_de_pago ='29' then
		select numero_cuenta ~ '^[0-9]+$' into isnumber; 
		if not isnumber then
			raise exception 'La cuenta solo puede tener campos Numericos' ;
		end if; 
	end if; 

	if forma_de_pago = '02' then		
		if longitud_cuenta <> 11 and longitud_cuenta <> 18 then 
			raise exception 'El Numero de Cheque tiene que tener 11 o 18 digitos' ;	
		end if;	
	end if;
		
	if forma_de_pago = '03' then
		if longitud_cuenta <> 10 and longitud_cuenta <> 16 and longitud_cuenta <> 18 then 
			raise exception 'El Numero de Transferencia Electronica tiene que tener 10,16 o 18 digitos' ;	
		end if;	
	end if;
		
	if forma_de_pago = '04' then
		if longitud_cuenta <> 16 then 
			raise exception 'El Numero de Tarjeta de Credito tiene que tener 16 digitos' ;
		end if;		
	end if;
		
	if forma_de_pago = '06' then
		if longitud_cuenta <> 10 then 	
			raise exception 'El Numero de Dinero Electronico tiene que tener 10 digitos' ;	
		end if;	
	end if;
		
	if forma_de_pago = '28' then
		if longitud_cuenta <> 16 then 	
			raise exception 'El Numero de Tarjeta de Debito tiene que tener 16 digitos' ;	
		end if;	
	end if;
		
	if forma_de_pago = '29' then
		if longitud_cuenta <> 15 and longitud_cuenta <> 16 then 
			raise exception 'El Numero de Tarjeta de Servicios tiene que tener 15 o 16 digitos' ;
		end if;	
	end if;
	

	resultado_valid_cuenta = '1';
	return query select resultado_valid_cuenta;	


end;

$function$
