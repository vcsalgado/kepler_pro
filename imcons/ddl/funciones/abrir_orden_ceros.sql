CREATE OR REPLACE FUNCTION keplersc.abrir_orden_ceros(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion:  abrir orden 
--Autor: Miriam Santana
--Fecha: 15/09/2025
--Bitacora de cambios
declare
		sucursal_id text;
		folio_orden text;
		tipo_orden text;
		vin text;
	
		--puntos
		tipo_punto text;
		tipo_operario text;
		clave_paquete text;
		trabajo_a_realizar text;
		horas text;
		no_puntos int;
		numero_punto int;	
		ctd_pnts_iguales int;
		ope_permitido text;
		ctd_puntos int;
		pnt_ya_asignado text;
		clave_campana text;
		campana_igual text;
		clave_operario text;
		status_punto text;
	
		detalle_movto text;
		usuario_cierre text;
		usuario_movto text;
		fecha_cierre text;
		motivo text;
		flag_abrir_orden text ='';			--MSS 31122025 Validar orden en 0s
	
		get_resultado text;
		get_mensaje text; 
		get_adicionales text;
	
		totReg int = 0;
		strValor text;
		varXml xml;
		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
   
begin 
	
		sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1]; 
		folio_orden := coalesce((xpath('//document/k_orden/text()', dataxml))[1]::text,'')::text;
	 	tipo_orden := coalesce((xpath('//document/k_tipo_orden/r1/text()', dataxml))[1]::text,'')::text;
	 	usuario_movto := coalesce((xpath('//document/usuario/text()', dataxml))[1]::text,'')::text;
	 
	 	usuario_cierre := coalesce((xpath('//document/k_usuario/text()', dataxml))[1]::text,'')::text;
	 	fecha_cierre := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'')::text;
	 	motivo := coalesce((xpath('//document/k_motivo/text()', dataxml))[1]::text,'')::text;
	 	flag_abrir_orden := coalesce((xpath('//document/flag_abrir_orden/text()', dataxml))[1]::text,'')::text;		--MSS 31122025 Validar orden en 0s
	 		 	
		strValor := (xpath('//document/ctd_puntos/text()',dataxml))[1];
		no_puntos := strValor::integer;	
		ctd_puntos = no_puntos;
		--raise notice 'suc:% tipo:% folio:% usMovto:% usCierre:% fecCierre:% Motivo:%', sucursal_id,tipo_orden,folio_orden,usuario_movto,usuario_cierre,fecha_cierre,motivo;
		select count(*) into totReg from keplersc.kdordceros 
		where c1 = sucursal_id and c2 = tipo_orden and c3 = folio_orden;
		if totReg = 0 then
		 	raise exception '%' , 'La orden no se encuentra cerrada en 0s utilice la opcion normal de Abrir Orden';
		else
			update keplersc.kdord set c8=40 
			where c1 = sucursal_id and c2 = tipo_orden and c3 = folio_orden;
		
			--Abrir orden opcion normal
			strValor='';
			select xmlforest(sucursal_id, folio_orden, tipo_orden, flag_abrir_orden)::text into strValor;				  		  
			select '<document>'||strValor||'</document>' into strValor;
			varXml := strValor::xml;
			
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.abrir_orden(varXml); 
			if get_resultado = '0' then
				raise exception '%',mensaje;
			end if; 
			
			--Actualizar puntos
			for cont in 0..no_puntos - 1 loop
				numero_punto := cont + 1;
			
				tipo_punto := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/tipo_punto/text()',dataxml))[1]::text,'');
				tipo_operario := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/tipo_operario/text()',dataxml))[1]::text,'');
				clave_paquete := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/clave_paquete/text()',dataxml))[1]::text,'');
				trabajo_a_realizar := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/trabajo_a_realizar/text()',dataxml))[1]::text,'');
				clave_campana := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/clave_campana/text()',dataxml))[1]::text,'');
				horas := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/horas/text()',dataxml))[1]::text,'0');
				clave_operario := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/clave_operario/text()',dataxml))[1]::text,'');
	
				if tipo_punto = 'N' then
					raise exception '%', format('Error en punto numero %1$L. No puede abrir una orden con puntos No Autorizados', numero_punto);
				end if;

				if tipo_punto = '' or tipo_operario = '' or trabajo_a_realizar = '' or clave_operario = '' then
					if tipo_punto = '' then
						raise exception '%', format('Error en punto numero %1$L. Falta el dato Tipo de Punto', numero_punto);
					end if;
					if tipo_operario = '' then
						raise exception '%', format('Error en punto numero %1$L. Falta el dato Tipo de Operario', numero_punto);
					end if;
					if trabajo_a_realizar = '' then
						raise exception '%', format('Error en punto numero %1$L. Falta especificar el trabajo a realizar', numero_punto);
					end if;
					if clave_operario = '' then
						raise exception '%', format('Error en punto numero %1$L. Falta del dato de Operario', numero_punto);
					end if;
					
				end if;
										
				if tipo_punto = 'S' then 
					if clave_paquete = '' then
						raise exception '%', format('Error en punto numero %1$L. Los puntos S deben tener un paquete.', numero_punto);
					end if;
				else
					if clave_paquete <> '' then
						raise exception '%', format('Error en punto numero %1$L. Solo los puntos S pueden tener paquetes.', numero_punto);
					end if;
				end if;
			
			
				if tipo_orden = 'C' then
				
					if no_puntos > 1 then
						raise exception '%' , 'Las Ordenes C solo pueden tener un punto G';
					end if;
				
					if tipo_punto <> 'G' then
						raise exception '%', format('Error en punto numero %1$L. Una Orden C debe tener solo un punto G', numero_punto);
					end if;
	
				end if;
							
				select c2 into ope_permitido from keplersc.kdpuntop where c1=tipo_punto and c2=tipo_operario;
				if not found then 
					raise exception '%', format('El punto numero %1$L no coincide con el tipo de Operario que le corresponde al Tipo de Punto.', numero_punto);
				end if;
		
				update keplersc.kdpun set c6=tipo_punto, c7='P', c8=trabajo_a_realizar,
					c37=tipo_operario, c9=clave_operario, c22='A'
				where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto;
					
			end loop ;	
			--Actualiza bitacora
			detalle_movto := 'DATOS DE ORDEN CERRADA EN 0s: USUARIO: ' || usuario_cierre || ' FECHA: ' || to_char(fecha_cierre::date,'DD-MM-YYYY') || ' MOTIVO: ' || motivo;
			select xmlforest(usuario_movto as usuario, current_date as fecha, TO_CHAR(NOW(), 'HH24:MI:SS') as hora, 
				sucursal_id as sucursal, ' ' as genero, ' ' as naturaleza, 0 as grupo, 0 as tipo, tipo_orden || '-' ||folio_orden as folio,
				'ABRIR ORDEN CERRADA EN 0s' as tipo_movto, detalle_movto as detalle_movto) :: text into strValor;
	
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
			mensaje := 'abrir_orden_ceros() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
