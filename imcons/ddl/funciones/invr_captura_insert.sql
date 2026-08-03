CREATE OR REPLACE FUNCTION keplersc.invr_captura_insert(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: invr_captura_insert
--Autor: Luis Leal
--Fecha: 17/01/2022
--Bitacora de cambios
--Fecha: 2023-11-09 , By JMM ... Include {Data Folio Marbete} 
--Fecha: 2023-11-17 , By JMM ... Fixed Values / Calc (gotten of KPL)
declare 
	
	sucursal_id text = '';
	fecha text = '';
	refer text = '';
	parte text = '';
	parte_desc text = '';
	unidad text = '';
	existencia_real numeric;
	costo_promedio_real numeric;
	diferencia_existencia numeric;
	diferencia_valor_inventario numeric;

	--Added by JMM ...
	exist numeric;
	valor numeric;
	valor_real numeric;
	dif_exist numeric;
	dif_valor numeric;

	result_query text = '';

	resultado text = '';
	mensaje text = '0';
    adicionales text = '';

begin
	
	sucursal_id :=  coalesce((xpath('//document/cmb_sucursal/r1/text()', dataxml))[1]::text,'')::text;
	fecha := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'')::text;
	--refer := coalesce((xpath('//document/k_refer/text()', dataxml))[1]::text,'')::text;
	parte := coalesce((xpath('//document/k_parte/text()', dataxml))[1]::text,'')::text;
	parte_desc := coalesce((xpath('//document/k_parte_desc/text()', dataxml))[1]::text,'')::text;
	--unidad := coalesce((xpath('//document/k_unidad/r1/text()', dataxml))[1]::text,'')::text;
	unidad := coalesce((xpath('//document/k_unidad/text()', dataxml))[1]::text,'')::text;

	existencia_real := coalesce((xpath('//document/k_exist_real/text()', dataxml))[1]::text,'0')::numeric;
	costo_promedio_real := coalesce((xpath('//document/k_costo_prom_real/text()', dataxml))[1]::text,'0')::numeric;
	diferencia_existencia := coalesce((xpath('//document/k_dif_exist/text()', dataxml))[1]::text,'0')::numeric;
	diferencia_valor_inventario := coalesce((xpath('//document/k_dif_valor_invr/text()', dataxml))[1]::text,'0')::numeric;

	-- Added by JMM 20231118 
	-- Para esta opcion el k_refer que viene del KPL de CapturaInventario se refiere al Marbete 
	refer := coalesce((xpath('//document/k_refer/text()', dataxml))[1]::text,'0')::text;
	exist := coalesce((xpath('//document/k_exist/text()', dataxml))[1]::text,'0')::numeric;
	valor := coalesce((xpath('//document/k_valor_inv/text()', dataxml))[1]::text,'0')::numeric;
	valor_real := coalesce((xpath('//document/k_valor_inv_real/text()', dataxml))[1]::text,'0')::numeric;



	select c1 into result_query from keplersc.kdini where c1=parte;
	if not found or result_query = '' then 
		raise exception '%', 'La clave capturada no se encuentra [Kdini], verifique por favor.';
	end if;

	-- Addeb by JMM 20231118
	dif_exist := existencia_real - exist ;
	dif_valor := valor_real - valor;


	select c2 into result_query from keplersc.kdifis where c1=sucursal_id and c2=parte;
	if found then 
		update keplersc.kdifis set c3=parte_desc,c4=to_date(fecha,'YYYY-MM-DD'),folio_marbe=refer::int,
		c6=existencia_real,c7=costo_promedio_real,c8=unidad,c9=dif_exist,
		c10=dif_valor,cantidad_sis=exist,costo_invent_sis=valor,costo_invent_real=valor_real, estatus='REGISTRADO' 
		where c1=sucursal_id and c2=parte;
	else
		insert into keplersc.kdifis(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,
		folio_marbe,cantidad_sis, costo_invent_sis,costo_invent_real,estatus)
		values(sucursal_id,parte,parte_desc,to_date(fecha,'YYYY-MM-DD') ,'',existencia_real,
		costo_promedio_real,unidad,dif_exist,dif_valor,
		refer::int,exist,valor,valor_real,'REGISTRADO');	
	end if;


	resultado := 1;
	mensaje := 'agregado:' || parte;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'invr_captura_insert() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;	
$function$
