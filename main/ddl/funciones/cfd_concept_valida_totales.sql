CREATE OR REPLACE FUNCTION keplersc.cfd_concept_valida_totales(dataxml xml, xmlkdm1 xml, xmlkdmm xml, cons_cfdi text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: ASEGURA QUE EL TOTAL DE LA FACTURA SEA EQUIVALENTE A LA SUMA DE LOS TOTALES EN LOS CONCEPTOS.
--			   Resuelve CFD_CONCEPT_VALIDA_TOTALES
--Autor: Miriam Santana
--Fecha: 11/10/2022

	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	
	--Variables de uso general
	folio_operacion text;
	cantidad int;
	cve_inventario text;
	sum_precio_total_sin_impto decimal = 0;
	sum_monto_iva decimal = 0;
	dif_precio_total_sin_impto decimal = 0;
	dif_monto_iva decimal = 0;
	precio_total_sin_impto_head decimal = 0;
	monto_iva_head	decimal = 0;
	rec_concept record;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;	
begin
	--Transaccion
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	folio_operacion := (xpath('//row/c6/text()', xmlKDM1))[1];

   	select c38 into cve_inventario from keplersc.kdf3header
   		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer;	

   	if found and substring(cve_inventario,8,1)<>'U' then 		
		for rec_concept in select * from keplersc.kdf3concept
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer
		loop 
			update keplersc.kdf3concept set	
				c14=c13*c9,					--precio_total_sin_impto					
				c20=c14,					--monto_base_impto
				c18=c20*c17,				--monto_iva
				c9=c14/c13					--cantidad
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer and c8=rec_concept.c8;
			sum_precio_total_sin_impto:=sum_precio_total_sin_impto+rec_concept.c14;
			sum_monto_iva:=sum_monto_iva+rec_concept.c18 ;
		end loop;
		update keplersc.kdf3header set 
			c18=sum_precio_total_sin_impto+sum_monto_iva,	--importe
			c56=sum_monto_iva,								--monto_iva
			c58=sum_precio_total_sin_impto					--monto_base_impto
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer;
		select c17,c56 into precio_total_sin_impto_head,monto_iva_head from keplersc.kdf3header
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer;
		dif_precio_total_sin_impto:= precio_total_sin_impto_head-sum_precio_total_sin_impto;
		dif_monto_iva:= monto_iva_head-sum_monto_iva;
		update keplersc.kdf3concept set	
				c14=c14+dif_precio_total_sin_impto,					--precio_total_sin_impto					
				c20=c14,					--monto_base_impto
				c18=c14*c17,				--monto_iva
				c9=c14/c13,					--cantidad
				c13=c14/c9					--precio_sin_impuesto
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer and c8=1;
		select sum(c14),sum(c18) into sum_precio_total_sin_impto,sum_monto_iva
			from keplersc.kdf3concept
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer;
		dif_precio_total_sin_impto:= precio_total_sin_impto_head-sum_precio_total_sin_impto;
		dif_monto_iva:= monto_iva_head-sum_monto_iva;
		if dif_monto_iva<>0 then
			update keplersc.kdf3header set 
				c56=c56-dif_monto_iva,	--monto_iva dif_sum_monto_iva
				c18=c56+c17					--importe
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion; 
		end if;
	end if;			
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;		
	
exception
	when others then
		resultado := 0;
		mensaje := 'cfd_concept_valida_totales() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
