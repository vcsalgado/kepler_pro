CREATE OR REPLACE FUNCTION keplersc.invr_obtener_costo_promedio(dataxml xml)
 RETURNS TABLE(sucursal_id text, clave_producto text, anio text, cant_ent_total numeric, cant_sal_total numeric, monto_ent_total numeric, monto_sal_total numeric, ultimo_costo numeric, penultimo_costo numeric, costo_prom_total numeric, minimo_reorden numeric)
 LANGUAGE plpgsql
AS $function$
	--Descripcion: Obtiene la informacion relacionada a las estadisticas de un producto,
    --             incluyendo el calc del costo promedio
	--Autor: Victor Salgado
	--Fecha: 07/12/202
	--Bitacora de cambios
declare 
	--Variables de definicion de documento
	sucursal_id text = '';
	clave_producto text = '';
	anio text = '';
	mes text = '';

	--Variables de proceso
	transaccion_id text='';
	error text = '';
	clave_original text = '';
	clave_actual text = ''; 
	cadena_reemplazo text = '';
	strValor text = '';
	xmlRequest xml;
	totReg int = 0;

	--Variables mensuales
	cant_ent_mes decimal = 0.00;
	cant_sal_mes decimal = 0.00;
	existencias_mes decimal = 0.00;

	monto_ent_mes decimal = 0.00;
	monto_sal_mes decimal = 0.00;
	valor_mes decimal = 0.00;

	costo_prom_mes decimal = 0.00;
	ultimo_costo_mes decimal = 0.00;

	--Variables globales
	cant_ent_total decimal = 0.00;
	cant_sal_total decimal = 0.00;
	existencias_total decimal = 0.00;

	monto_ent_total decimal = 0.00;
	monto_sal_total decimal = 0.00;
	valor_total decimal = 0.00;

	ultimo_costo_total decimal = 0.00;
	penultimo_costo_total decimal = 0.00;
	minimo_reorden decimal = 0.00;
	penultimo_costo decimal = 0.00;
	ultimo_costo decimal = 0.00;

	costo_prom_total decimal = 0.00;

begin
	sucursal_id := (xpath('//document/sucursal/text()', dataxml))[1];
	clave_producto := (xpath('//document/clave_producto/text()', dataxml))[1];
	anio := (xpath('//document/anio/text()', dataxml))[1];
	mes := (xpath('//document/mes/text()', dataxml))[1];

	--Obtener clave original, actual y cadena de reemplazos
	select xmlforest(clave_producto as clave_producto, anio as fecha, 'N' as criterio_fecha) :: text into strValor;

	select '<document>'||strValor||'</document>' into strValor;
	xmlRequest := strValor::xml;

	select * into clave_original, clave_actual, cadena_reemplazo from keplersc.prod_cadena_reemplazo(xmlRequest);

	--Validar existencia de producto
	if clave_original is null or clave_original = '' then
		raise exception 'El producto % es inválido',clave_original;
	end if;

	select count(*) into totReg from keplersc.kdini where c1=clave_original;
	if totReg = 0 then
		raise exception 'El producto % no existe',clave_original;	
	end if;
	

	--Tabla KDINK, estadisticas por anio-mes. Buscar Sucursal, producto y Anio
	select count(*) into totReg from keplersc.kdink where c1=sucursal_id and c2=clave_original;
	if totReg > 0 then
		select count(*) into totReg from keplersc.kdinl where c1=sucursal_id and c2=clave_original;	
		if totReg > 0 then
			select c5,c6,c8,c9,c14,c15,c20 
			into cant_ent_total, cant_sal_total, monto_ent_total, monto_sal_total, ultimo_costo, penultimo_costo, minimo_reorden
			from keplersc.kdinl  where c1=sucursal_id and c2=clave_original order by c3 desc fetch first row only;			
		end if;	
	end if;

	if cant_ent_total - cant_sal_total <> 0 then
		if cant_ent_total - cant_sal_total > 0 then
			costo_prom_total = (monto_ent_total-monto_sal_total)/(cant_ent_total - cant_sal_total);
		else
			costo_prom_total = ultimo_costo;
		end if;
	else
		costo_prom_total = ultimo_costo;
	end if;
	return query 
		select sucursal_id, clave_original as clave_producto, anio, cant_ent_total, cant_sal_total, monto_ent_total, 
			monto_sal_total, ultimo_costo, penultimo_costo, costo_prom_total, minimo_reorden;
exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
