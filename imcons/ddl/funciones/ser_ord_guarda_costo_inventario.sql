CREATE OR REPLACE FUNCTION keplersc.ser_ord_guarda_costo_inventario(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: CARGA EL COSTO DE ACCESORIOS O DE ADECUACIONES A SEMINUEVOS A INVENTARIOS. Resuelve ORD_GUARDA_COSTO_INVENTARIO  
--Autor: Miriam Santana
--Fecha: 20/10/2022
	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	suc_inventario text;
	inventario text;
	tipo_costo text;
	costo text;
	partida text;
	monto_iva text;
	monto_total text;
	totReg int;
begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	--Tipo de documento
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	monto_iva := coalesce((xpath('//document/k_iva/text()',dataxml))[1]::text,'0')::text;
	monto_total := coalesce((xpath('//document/k_monto/text()',dataxml))[1]::text,'0')::text;
	suc_inventario := coalesce((xpath('//document/k_pedimento/text()',dataxml))[1]::text,'')::text;
	inventario := coalesce((xpath('//document/k_claveinv/text()',dataxml))[1]::text,'')::text;
	tipo_costo := (xpath('//row/c67/text()', xmlKDMM))[1]::text;	

	if tipo_costo = 'U' or tipo_costo='A' then		--kdmm.c67='U' or kdmm.c67='A'
		if inventario = '' or inventario is null then 
			raise exception 'Es necesario capturar la clave de inventario';
		end if;
		select count(*) into totReg from keplersc.kdsunicosto
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion;
		if totReg=0 then 
			insert into keplersc.kdsunicosto(
				c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11)
			values(
				sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
				folio_operacion,suc_inventario,inventario,tipo_costo,monto_total::decimal-monto_iva::decimal,
				1);
		end if;
	end if;
		
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_ord_guarda_costo_inventario() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
