CREATE OR REPLACE FUNCTION keplersc.alta_bonif(dataxml xml, xmlkdmm xml, xmlkdm1 xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserción de la bonificación en KDBONIF. Resueve ALTA_BONIF
--Autor: Miriam Santana
--Fecha: 01/05/2023

declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text; 
	tipo text;

	--Variables Loop
	no_partidas int;
	numero_partida int;
	inventario text ='';
	monto text='';
	iva text='';
	
	--Variables de uso general 
	strValor text;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;


begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];

	--Tipo de documento
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	
	strValor := (xpath('//row/c66/text()', xmlKDMM))[1]::text;		--Obtiene valor del c66 de la KDMM
	numero_partida := 0;
	if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S' then --Pantalla movimientos CXP
		for cont in 0..no_partidas - 1 loop
			inventario := (xpath('//document/k_mov/r' ||cont||'/k_factura/text()',dataxml))[1];
			if inventario <> '' or inventario is not null then
				numero_partida := numero_partida + 1;
				monto := (xpath('//document/k_mov/r' ||cont||'/k_monto_factura/text()',dataxml))[1];
				iva := (xpath('//document/k_mov/r' ||cont||'/k_iva_factura/text()',dataxml))[1];
				
				insert into keplersc.kdbonif 
					(c1,c2,c3,c4,c5,
					c6,c7,c8,c9,c10)
					values(sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
					folio_operacion,numero_partida,inventario,strValor, monto::decimal-iva::decimal);
			end if;	
		end loop;
	else
		if (xpath('//row/c49/text()', xmlKDM1))[1]::text <> '0' then
			inventario := (xpath('//row/c100/text()', xmlKDM1))[1]::text;
			monto := (xpath('//row/c49/text()', xmlKDM1))[1]::text;
			insert into keplersc.kdbonif 
				(c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10)
				values(sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
				folio_operacion,1,inventario,strValor,monto::decimal);
		end if;
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_bonif() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
