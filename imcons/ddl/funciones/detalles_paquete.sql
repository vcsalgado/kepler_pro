CREATE OR REPLACE FUNCTION keplersc.detalles_paquete(dataxml xml)
 RETURNS TABLE(paquete text, refacciones text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: selecciona los detalles de un paquete
--Autor: Luis Leal
--Fecha: 25/05/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	marca text ;
	modelo text;
	paquete text;
	sucursal_id text;
	desc_paq text;
	cargos_varios decimal = 0.00;
	importe_paq decimal = 0.00;
	subtotal_paq decimal = 0.00;
	iva_paq decimal = 0.00;
	sum_refacciones decimal = 0.00;
	mano_de_obra_paq decimal = 0.00;
	hrs_tabuladas int = 0;
	clave_refaccion text;
	desc_ref text;
	cantidad text;
	importe_ref decimal = 0.00;
	existencia int;
	prepicking int;
	disponibilidad int;
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

	vals text;
	refacciones text;
	intValor integer = 0;

begin
	marca := (xpath('//document/marca/text()', dataxml))[1];
	modelo := (xpath('//document/modelo/text()', dataxml))[1];
	paquete := (xpath('//document/paquete/text()', dataxml))[1];
	sucursal_id  := (xpath('//document/sucursal_id/text()', dataxml))[1];
	

	select c6,c3,c4,c5 into catalogo, metodo_calculo,utilidad_base,iva from keplersc.kdicatprecio where c1='PUBLI';
		
	for clave_refaccion, desc_ref,cantidad, ult_costo, ctd_entradas,ctd_salidas,monto_entradas,monto_salidas
	in select paq.c6, refc.c2, paq.c7,movs.c14, movs.c5, movs.c6, movs.c8, movs.c9
	from keplersc.kdspaqm as paq inner join keplersc.kdini as refc on refc.c1=paq.c6
	inner join keplersc.kdinl as movs on movs.c2=refc.c1 
	where paq.c1=marca  and paq.c2=modelo and paq.c4=paquete and movs.c1=sucursal_id
		loop 
					
			existencia := ctd_entradas-ctd_salidas;
			if existencia <> 0 then 
				costo_prom :=  (monto_entradas-monto_salidas)/ existencia;
			else
				costo_prom := 0;
			end if;
		
		
			select precio into importe_ref from keplersc.calcula_precio_ref(clave_refaccion,catalogo
			,metodo_calculo,utilidad_base,iva,ult_costo,costo_prom );
		
			--busca si la refaccion tiene piezas en prepicking 
			select c4::int into prepicking from keplersc.prepicking where c1=sucursal_id and c3=clave_refaccion and c5 <> 20;
			if not found then
				prepicking := 0;
			end if ;
		
			disponibilidad := existencia - prepicking;
				
			vals := xmlforest(clave_refaccion as clave_ref, desc_ref as desc_ref, cantidad AS cantidad, 
			importe_ref as importe_ref, existencia as existencia, prepicking as prepicking, disponibilidad as disponibilidad );
					
			refacciones := concat(refacciones, format('<r%1$s>%2$s</r%1$s>',intValor,vals));
		
			sum_refacciones := sum_refacciones + importe_ref;
			intValor := intValor + 1;

		end loop;
	
		--calcula datos generales paquete
		select c5,c8,c9,c10 into desc_paq,cargos_varios,hrs_tabuladas,importe_paq from keplersc.kdspaq 
		where c1=marca and c2= modelo  and c4=paquete; 

		subtotal_paq := importe_paq/(1+iva/100);
		iva_paq := importe_paq - subtotal_paq;
		mano_de_obra_paq := subtotal_paq - cargos_varios - sum_refacciones;
	
		paquete := xmlforest(desc_paq as desc_paq, ROUND(mano_de_obra_paq, 2) as mano_de_obra, 
		hrs_tabuladas as hrs_tabuladas, ROUND(sum_refacciones,2) as refacciones, 
		ROUND(cargos_varios,2) as cargos_varios, ROUND(subtotal_paq,2) as subtotal, ROUND(iva_paq,2) as iva,
		ROUND(importe_paq,2) as importe_paq );
		
	return query
	select paquete, refacciones;

exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
