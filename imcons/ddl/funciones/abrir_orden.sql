CREATE OR REPLACE FUNCTION keplersc.abrir_orden(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion:  abrir orden 
--Autor: Luis Leal
--Fecha: 19/07/2022
--Bitacora de cambios
--18/09/2025 Miriam Santana: Registrar el movimiento en bitacora

declare
		sucursal_id text;
		folio_orden text;
		tipo_orden text;
		vin text;
	
		flujo_admon numeric;
		flujo_servicio numeric;
		encuesta_estatus numeric;
		
		--MSS 18092025 Registrar el movimiento en bitacora
		orden_ceros int = 0;
		varXml xml;
		usuario text;
		--
		flag_abrir_orden text ='';			--MSS 31122025 Validar orden en 0s
		get_resultado text;
		get_mensaje text; 
		get_adicionales text;
		rec_movs record;
	
		strValor text;
		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
   
begin 
	
		sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1]; 
		folio_orden := coalesce((xpath('//document/folio_orden/text()', dataxml))[1]::text,'')::text;
	 	tipo_orden := coalesce((xpath('//document/tipo_orden/text()', dataxml))[1]::text,'')::text; 
	 	vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text;
	 	usuario := (xpath('//document/usuario/text()', dataxml))[1];
	 	flag_abrir_orden := coalesce((xpath('//document/flag_abrir_orden/text()', dataxml))[1]::text,'normal')::text;		--MSS 31122025 Validar orden en 0s
	 
	 	select ord.c7::numeric,ord.c8::numeric,spv.c6::numeric into flujo_admon, flujo_servicio, encuesta_estatus from keplersc.kdord as ord 
	 	left outer join keplersc.kdencprog as spv on spv.c1=ord.c1 and spv.c2=ord.c2 and spv.c3=ord.c3
		where ord.c1=sucursal_id and ord.c2=tipo_orden and ord.c3=folio_orden;

		--MSS 18092025 Validar si la orden esta cerrada en 0s
		select count(*) into orden_ceros from keplersc.kdordceros
		where c1=sucursal_id and c2=tipo_orden and c3=folio_orden;
--raise exception 'orden_ceros:% flag_abrir_orden:%',	orden_ceros,flag_abrir_orden;
		if orden_ceros > 0 and flag_abrir_orden <> 'abrir_ceros' then
		 	raise exception 'La orden se encuentra cerrada en 0s utilice la opcion Abrir Orden en 0s';
		end if;
	
		/*if encuesta_estatus = 20 then
			raise exception '%' , 'La orden ya tiene la encuesta del seguimiento posventa registrada.';
		end if;*/
		if flujo_servicio = 50 then --
			raise exception 'La orden ya está cerrada y facturada';
		end if;		
		if flujo_servicio < 40 then
			raise exception '%' , 'La orden no se encuentra cerrada.';
		end if;
		--cfdi no calculos
		--actualizar los datos de subt,iva y total =0	
		update keplersc.kdord set c7=0,c8=30,c30=0,c31=0,c32=0,c33=0,c61=0,c62=0,c63=0 where c1=sucursal_id and c2=tipo_orden and c3=folio_orden ; 
		
		delete from keplersc.kdordceros where c1=sucursal_id and c2=tipo_orden and c3=folio_orden;
		
		update keplersc.kdtord set c6='1800-01-01'::date ,c12='1800-01-01'::date where c1=sucursal_id and c2=tipo_orden and c3=folio_orden ; 
	
		delete from keplersc.kdencprog where c1=sucursal_id and c2=tipo_orden and c3=folio_orden;
		
		--VCSS 21 Jul 2025 Restaurar importes antes de descuentos
		--Refacciones, kdref
		for rec_movs in select * from keplersc.kdlealtadmovs where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c7='R' --and importe_descuento <> 0
		loop
			update keplersc.kdref 
			set c15=rec_movs.precio_original_sin_iva/c13, 
				c16=rec_movs.precio_original_sin_iva, 
				c21=rec_movs.precio_original_sin_iva * 0.16, 
				c22=rec_movs.precio_original_sin_iva * 1.16 
			where c1=rec_movs.c1 and c2=rec_movs.c2 and c3=rec_movs.c3 and c4=rec_movs.c4 
				and c5=rec_movs.gen and c6=rec_movs.nat and c7=rec_movs.gpo and c8=rec_movs.tipo and c9=rec_movs.folio
				and c10=rec_movs.c8;
		end loop;

		--Mano de obra, kdhoras
		for rec_movs in select * from keplersc.kdlealtadmovs where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c7='H' --and importe_descuento <> 0
		loop
			update keplersc.kdhoras 
			set c14=rec_movs.precio_original_sin_iva/c8, 
				c17=rec_movs.precio_original_sin_iva,
				c18=rec_movs.precio_original_sin_iva * 0.16, 
				c19=rec_movs.precio_original_sin_iva * 1.16 
			where c1=rec_movs.c1 and c2=rec_movs.c2 and c3=rec_movs.c3 and c4=rec_movs.c4 and c5=rec_movs.c8;
		end loop;

		--Tots, kdtots
		for rec_movs in select * from keplersc.kdlealtadmovs where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c7='T' --and importe_descuento <> 0
		loop
			update keplersc.kdtot
			set c16=rec_movs.precio_original_sin_iva,
				c18=rec_movs.precio_original_sin_iva * 0.16, 
				c19=rec_movs.precio_original_sin_iva * 1.16 
			where c1=rec_movs.c1 and c2=rec_movs.c2 and c3=rec_movs.c3 and c4=rec_movs.c4 and c15=rec_movs.c8;
		end loop;

		--Cargos varios, kdcar
		for rec_movs in select * from keplersc.kdlealtadmovs where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c7='C' --and importe_descuento <> 0
		loop
			update keplersc.kdcar
			set c10=rec_movs.precio_original_sin_iva,
				c11=rec_movs.precio_original_sin_iva * 0.16, 
				c12=rec_movs.precio_original_sin_iva * 1.16 
			where c1=rec_movs.c1 and c2=rec_movs.c2 and c3=rec_movs.c3 and c4=rec_movs.c4 and c5=rec_movs.c8;
		end loop;
	
		--MSS 18092025 Registrar el movimiento en bitacora, excepto abrir una orden cerrada en 0s (utiliza esta misma funcion para abrir) 
		--y esta se graba en bitacora en Abrir orden cerrada en 0s
		if orden_ceros = 0 then	
			select xmlforest(usuario, current_date as fecha, TO_CHAR(NOW(), 'HH24:MI:SS') as hora, 
					sucursal_id as sucursal, ' ' as genero, ' ' as naturaleza, 0 as grupo, 0 as tipo, tipo_orden || '-' ||folio_orden as folio,
					'ABRIR ORDEN' as tipo_movto, ' ' as detalle_movto) :: text into strValor;
				
			select '<document>'||strValor||'</document>' into strValor;
			varXml := strValor::xml;
							
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(varXml);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;			
		end if;
		resultado := 1;
		mensaje := 'Orden Abierta';
		adicionales := folio_orden;
		return query select resultado, mensaje, adicionales;
	
exception
		when others then
			resultado := 0;
			mensaje := 'abrir_orden() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
