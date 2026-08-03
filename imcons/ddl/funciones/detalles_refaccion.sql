CREATE OR REPLACE FUNCTION keplersc.detalles_refaccion(dataxml xml)
 RETURNS TABLE(refaccion xml)
 LANGUAGE plpgsql
AS $function$
--Descripcion: selecciona los detalles de una refaccion
--Autor: Luis Leal
--Fecha: 26/05/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text;
	clave_refaccion text;
	desc_ref text;

	importe_ref decimal = 0.00;
	existencia int;
	catalogo int;
	metodo_calculo int;
	utilidad_base decimal = 0.00;
	ult_costo decimal = 0.00;
	ctd_entradas int = 0;
	ctd_salidas int = 0;
	monto_entradas decimal = 0.00;
	monto_salidas decimal = 0.00;
	iva decimal = 0.00;
	costo_prom  decimal = 0.00;

	--Variable de retorno
	refaccion xml;

begin
	
	clave_refaccion := (xpath('//document/clave_ref/text()', dataxml))[1];
	sucursal_id  := (xpath('//document/sucursal_id/text()', dataxml))[1];
	
	select c6,c3,c4,c5 into catalogo, metodo_calculo,utilidad_base,iva from keplersc.kdicatprecio where c1='PUBLI';

	select refc.c2, movs.c14, movs.c5, movs.c6, movs.c8, movs.c9 
	into desc_ref ,ult_costo, ctd_entradas,ctd_salidas,monto_entradas,monto_salidas
	from keplersc.kdinl as movs inner join keplersc.kdini as refc on movs.c2=refc.c1
	where movs.c1=sucursal_id and movs.c2=clave_refaccion;
				
	existencia := ctd_entradas-ctd_salidas;
	costo_prom :=  (monto_entradas-monto_salidas)/ existencia;
		
	select precio into importe_ref from keplersc.calcula_precio_ref(clave_refaccion,catalogo
	,metodo_calculo,utilidad_base,iva,ult_costo,costo_prom );
				
	refaccion := xmlforest(clave_refaccion as clave_ref, desc_ref as desc_ref, 
	importe_ref as importe_ref, existencia as existencia );
					
	return query
	select refaccion;

exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
