CREATE OR REPLACE FUNCTION keplersc.venedomovtobonif(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza cancelación de encabezados de documentos en KDM1 para una bonificacion
--Autor: Miriam Santana
--Fecha: 04/01/2023
--Bitacora de cambios
				  
declare
	--Variables de definicion de documento
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_compuesto text;
	tipo_clave text;
	estado_movto text;
	monto_iva decimal;
	monto_total decimal;
	saldo_docto decimal;

	--variables de uso general
	strValor text;
	intValor int;
	totalReg int;

	--Variables Loop
	no_partidas int;
	numero_partida int;
	folio_bonif text;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	
begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];

	--Tipo de documento
	tipo_desc := (xpath('//document/k_tipon/r0/text()', dataxml))[1]; 
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := 'D';
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	

	for cont in 0..no_partidas - 1 loop
		folio_bonif := (xpath('//document/k_mov/r' ||cont||'/k_folio_bon/text()',dataxml))[1];

		if folio_bonif <> '' or folio_bonif is not null then
			select count(*) into totalReg from keplersc.kdm1	
				where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer 
				and c5=tipo_clave::integer and c6=folio_bonif::text;
			if totalReg > 0 then	
				estado_movto := 'C';
								
				update keplersc.kdm1 
					set c43=estado_movto, c197=current_date
					where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer 
					and c5=tipo_clave::integer and c6=folio_bonif::text;
				resultado := 1;		
			else
				mensaje := 'No se encuentra el movimiento';
				resultado := 0;
			end if;
		end if;	
	end loop ;	

	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'venedomovtobonif() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
