CREATE OR REPLACE FUNCTION keplersc.ser_alta_orden_factura(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Realiza inserción en KDORDFACT y actualiza KDORD y KDTORD
--Autor: Miriam Santana
--Fecha: 10/10/2022

declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	fecha_operacion text; --yyyy-mm-dd
	tipo text;
	tipo_orden text;
	num_orden text;
	flujo_admon int;
	imprime_vale text;
	consecutivo int = 1;
	intValor int;

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
	fecha_operacion := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
	tipo_orden := (xpath('//document/k_tipo_orden/r1/text()',dataxml))[1];
	num_orden := (xpath('//document/k_orden/text()',dataxml))[1];

	if (xpath('//row/c11/text()', xmlKDMM))[1]::text = 'S' and genero='U' and naturaleza='D' then	
	select c7 into flujo_admon from keplersc.kdord
		where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
		if found then 
			if flujo_admon < 30 then 
				select c12 into imprime_vale from keplersc.kdmargen
					where c1=tipo_orden;
				if imprime_vale='N' then 
					intValor=30;
				else 
					intValor=20; 
				end if;
				update keplersc.kdord 
					set c7=intValor,
					c8=50,
					c39=to_date(fecha_operacion,'YYYY-MM-DD'),
					c40=genero,
					c41=naturaleza,
					c42=grupo::integer,
					c43=tipo::integer,
					c44=folio_operacion
				where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
				select c4 into consecutivo from keplersc.kdordfact 
					where c1=sucursal_id and c2=tipo_orden and c3=num_orden
					order by c4 desc limit 1;
				if found then
					consecutivo := consecutivo+1;
				else 
					consecutivo := 1;
				end if;
				insert into keplersc.kdordfact (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10)
					values(
					sucursal_id,tipo_orden,num_orden,
					consecutivo,0,
					genero,naturaleza,grupo::integer,tipo::integer,folio_operacion);
				update keplersc.kdtord 
					set c6=to_date(fecha_operacion,'YYYY-MM-DD'),c7=genero,c8=naturaleza,c9=grupo::integer,c10=tipo::integer,c11=folio_operacion
				where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
			end if;
		end if;
	end if;
	

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_alta_orden_factura() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
