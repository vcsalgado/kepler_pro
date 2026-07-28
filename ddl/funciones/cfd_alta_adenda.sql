CREATE OR REPLACE FUNCTION keplersc.cfd_alta_adenda(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Realiza inserción de una Adenda
--Autor: Miriam Santana
--Fecha: 13/10/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	adenda_id text;
	segmento text;
	variable text;
	valor text;
	strPartidas text;
	no_partidas int;

	--Variables de uso general
	totReg int;
	strValor text;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	begin
		--Partidas
		strPartidas := (xpath('//document/tabla_adenda/no_partidas/text()',dataxml))[1];
		no_partidas := strPartidas::integer;
	
		--Validar datos de adenda
		for cont in 0..no_partidas - 1 loop
			adenda_id := (xpath('//document/tabla_adenda/r'||cont||'/k_adenda/text()',dataxml))[1];
			segmento := (xpath('//document/tabla_adenda/r'||cont||'/k_segmento/text()',dataxml))[1];
			variable := (xpath('//document/tabla_adenda/r'||cont||'/k_variable/text()',dataxml))[1];
			valor := (xpath('//document/tabla_adenda/r'||cont||'/k_valor/text()',dataxml))[1];
			if ((adenda_id <>'') and (segmento <>'') and (variable <>'')) then
				if (valor ='') then 							
					raise exception 'El valor de la variable % del segmento % no puede quedar en blanco.',variable,segmento;
				end if;

			end if;			
		end loop;

		--Procesar alta detalle de la adenda
		for cont in 0..no_partidas - 1 loop
			adenda_id := (xpath('//document/tabla_adenda/r'||cont||'/k_adenda/text()',dataxml))[1];
			segmento := (xpath('//document/tabla_adenda/r'||cont||'/k_segmento/text()',dataxml))[1];
			variable := (xpath('//document/tabla_adenda/r'||cont||'/k_variable/text()',dataxml))[1];
			valor := (xpath('//document/tabla_adenda/r'||cont||'/k_valor/text()',dataxml))[1];
			--Sólo realiza la inserción si tiene costo la partida
			select count(*) into totReg from keplersc.kdadvariable k 
				where c1=adenda_id and c2=segmento and c3=variable;
			if totReg>0 then
				delete from keplersc.kdadvariable k 
					where c1=adenda_id and c2=segmento and c3=variable;
			end if;
			insert into keplersc.kdadvariable 
				(c1,c2,c3,c4)
				values(adenda_id,segmento,variable,valor);
		end loop ;	

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cfd_alta_adenda() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
		
	end;
$function$
