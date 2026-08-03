CREATE OR REPLACE FUNCTION keplersc.verify_altainvr(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Función verify_invalta  
--Autor: Luis Leal
--Fecha: 10/01/2023

declare

		sucursal_id text = '';  
		genero text;
		naturaleza text;
		grupo text;
		tipo_clave text;

		no_partidas int;
		numero_partida int ;
		tipo_precio text;
	
		--refacciones---
		refaccion text;
		cantidad_ref numeric;
		unidad_ref text;
		precio_ref numeric;
		monto_ref numeric;
		unidad_default text;
		entradas numeric;
		salidas numeric;
		existencias numeric;
		deccantidad_partida decimal = 0.00;

		resultado text= '';
		mensaje text = '0';
		adicionales text = '';
		strValor text ;


begin
	
		sucursal_id := upper((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text); --				
		genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
		naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
		grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
		tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];				
		tipo_precio := upper((xpath('//document/k_tipoprecio/r1/text()', dataxml))[1]::text);
		--Partidas
		strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
		no_partidas := strValor::integer;	
	
		numero_partida := 0;

		if (tipo_precio = '' or tipo_precio is null) and naturaleza ='D' then 
			raise exception 'Imposible continuar, Debe especificar Tipo de Precio';
		end if;
		for cont in 0..no_partidas - 1 loop
		
			refaccion := (xpath('//document/k_mov/r' ||cont||'/k_parte/text()',dataxml))[1];
			cantidad_ref := (xpath('//document/k_mov/r' ||cont||'/k_q/text()',dataxml))[1];
			unidad_ref := (xpath('//document/k_mov/r' ||cont||'/k_unidad/text()',dataxml))[1];
			precio_ref := (xpath('//document/k_mov/r' ||cont||'/k_precio/text()',dataxml))[1];
			monto_ref := (xpath('//document/k_mov/r' ||cont||'/k_monto/text()',dataxml))[1];
	
			deccantidad_partida := 0;
			cantidad_ref := (xpath('//document/k_mov/r' ||cont||'/k_q/text()',dataxml))[1];
			deccantidad_partida := cantidad_ref::decimal;

			if deccantidad_partida > 0 then

				if cantidad_ref <= 0 then
					raise exception '%' , 'Imposible continuar cantidades invalidas';
				end if;
			
				select c19 into unidad_default from keplersc.kdini where c1=refaccion;
				if found then
							
					if unidad_ref = '0' or unidad_ref <> unidad_default then 
						raise exception '%' , 'Imposible continuar, Unidades invalidas';
					end if;
				
					if naturaleza = 'D' then
						select c5,c6 into entradas,salidas from keplersc.kdinl where c1=sucursal_id and c2=refaccion;
						if found then
						
							existencias := entradas - salidas;
											
							if existencias <= 0 then
								raise exception 'Imposible continuar, % , Salida en Rojo' , refaccion;
							end if;
						
							if cantidad_ref > existencias then
								raise exception 'Imposible continuar, % , Salida en Rojo' , refaccion;
							end if;
						else
							raise exception 'Imposible continuar, % , Salida en Rojo' , refaccion;
						end if;
					end if;
				else
					raise exception '%' , 'Imposible continuar, el numero de producto no existe';
				end if;
			end if;
		end loop ;		

		resultado ='1';
		mensaje ='Finalizado';
		adicionales ='';						

		return query select resultado, mensaje, adicionales;

EXCEPTION
	WHEN others then		
		resultado := '0';
		mensaje := SQLERRM;
		--adicionales := 'funcion verify_altainvr';
		return query select resultado, mensaje, adicionales;
END;
$function$
