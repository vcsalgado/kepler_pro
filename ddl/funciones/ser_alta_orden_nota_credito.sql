CREATE OR REPLACE FUNCTION keplersc.ser_alta_orden_nota_credito(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Realiza inserciÃ³n de nota de crÃ©dito en KDORDFACT y actualiza KDORD y KDTORD 
--Autor: Miriam Santana
--Fecha: 15/12/2022

declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	fecha_operacion text; --yyyy-mm-dd
	sin_fecha text ='1800-01-01 00:00:00';
	tipo text;
	tipo_orden text;
	num_orden text;
	flujo_admon int;
	flujo_servicio int;
	consecutivo int = 1;

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

	if (xpath('//row/c11/text()', xmlKDMM))[1]::text = 'S' and genero='U' and naturaleza='A' then
		select c7,c8 into flujo_admon, flujo_servicio from keplersc.kdord
			where c1=sucursal_id and c2=tipo_orden and c3=num_orden;	
		 
		if found then
			update keplersc.kdord 
					set c7=10,
					c8=40,
					c40='',
					c41='',
					c42=0,
					c43=0,
					c44=''
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
					set c6=to_date(sin_fecha,'YYYY-MM-DD'),
					c7='',
					c8='',
					c9=0,
					c10=0,
					c11=''
				where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
			
		end if;
	end if;
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_alta_orden_nota_credito() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
