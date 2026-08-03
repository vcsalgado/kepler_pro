CREATE OR REPLACE FUNCTION keplersc.valida_placa(placa text)
 RETURNS TABLE(resultado text)
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: Realiza validacion del la placa de acuerdo al formato en KDFPLACAS
--Autor: Miriam Santana
--Fecha: 31/01/2023

	--Variables de uso general
	longplaca int;
	longpatron int;
	lvar int;
	charplaca text;
	charpatron text;
	patron text;
		
	esLetra bool;
	esNumero bool;
 	strValor text = '';
 	intValor text;
	ok int=0;
	rec record;

	--Variables de retorno
	resultado text;

begin 
	intValor := '0';
	resultado := '0';
	if placa = 'SP' then
		resultado := '1';
		intValor:=1;
	else
		for rec in select * from keplersc.kdfplacas k  
		loop
			patron:=rec.c3;
			ok:=0;
			--raise notice 'PATRON:%',patron; 
			longplaca:= length(placa);
			longpatron:= length(patron);
			--raise notice 'longplaca=% longpatron:%',longplaca,longpatron; 
			if longplaca=longpatron then
				for cont in 1..longplaca loop
					esLetra := true;
					esNumero:= true;
					charplaca:= substring(placa,cont,1); 
					charpatron:= substring(patron,cont,1);
					--raise notice 'charplaca=% charpatron:%',charplaca,charpatron; 
					if charpatron ='A' then			
						select charplaca ~ '^[a-zA-Z]+$' into esLetra;
						--raise notice 'esLetra=%  ',esLetra; 
					else
						if charpatron ='9' then
							select charplaca ~ '^[0-9\.]+$' into esNumero; 
							--raise notice 'esNumero=% ',esNumero; 
						end if;		
					end if;
					if not esLetra or not esNumero then
						resultado := '0';
						exit;
					end if;
					if esLetra or esNumero then 
						ok:= ok+1;
					end if;
					if ok=longplaca then 
						resultado:= 1;
					end if;
					--raise notice 'resultado=% ok=%',resultado, ok; 
				end loop;
			    --raise notice 'resultado:% intValor:%',resultado,intValor;
				intValor:=concat(intValor,resultado);
				--raise notice 'intValor:%',intValor;
			end if;
			if resultado='1' then
				exit;
			end if;
--raise notice 'Patron: % resultado:% intValor: %',patron,resultado,intValor;
		end loop;
		resultado := intValor;
	end if;
	return query select resultado;	
end;
$function$
