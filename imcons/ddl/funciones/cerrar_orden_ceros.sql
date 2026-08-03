CREATE OR REPLACE FUNCTION keplersc.cerrar_orden_ceros(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Cierra ordenes en 0´s
--Autor: Miriam Santana
--Fecha: 01/10/2023
--Bitacora de cambios
--18/09/2025 Miriam Santana: Registrar el movimiento en bitacora

declare
	sucursal_id text = '';
	usuario text = '';
	fecha text = '';
	motivo text = '';
	selReg text = '';
	tipo_orden text = '';
	num_orden text = '';
	
	msgPuntos text ='';
	valPuntos integer;
	msgMotivo text ='';
	valMotivo integer;
	msgFact text ='';
	valFact integer;
	valRes integer = 1;
	no_partidas integer = 0;
	
	marca text = '';
	modelo text = '';
	anio text = '';

	--Calculos
	importe_total_refs decimal = 0;
	importe_total_tots decimal = 0;
	importe_total_car decimal = 0;
	importe_total_horas decimal = 0;
	costo_por_hora decimal = 0;
	hrs_a_pagar decimal = 0;
	costo_mo_default decimal = 0;

	--resultados
	resultado text = '';
	mensaje text = '';
    adicionales text = '';

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	xmlResultado xml;
	expSql text = '';
	recOrden record;
	recPuntos record;
	rec record;

	--MSS 18092025 Registrar movimiento en bitacora
	varXml xml;
	get_resultado text;
	get_mensaje text;
	get_adicionales text;

begin

raise notice 'Inicio';

	sucursal_id := (xpath('//document/k_sucn/r1/text()',dataxml))[1];
	usuario := (xpath('//document/k_usuario/text()', dataxml))[1];
	fecha := (xpath('//document/k_fecha/text()',dataxml))[1];

	--Partidas
	strValor := (xpath('//document/tabla/no_partidas/text()',dataxml))[1];

	no_partidas := strValor::integer;	
	--Procesar detalle
	for cont in 0..no_partidas - 1 loop
		selreg := (xpath('//document/tabla/r' ||cont||'/seleccionar/text()',dataxml))[1];		
		tipo_orden := (xpath('//document/tabla/r' ||cont||'/k_tipo_orden/text()',dataxml))[1];
		num_orden := (xpath('//document/tabla/r' ||cont||'/k_orden/text()',dataxml))[1];
		motivo := (xpath('//document/tabla/r' ||cont||'/k_motivo/text()',dataxml))[1];
		raise notice 'partida:% valres:%',cont,valRes;
	raise notice 'For Partidas Suc:% Tipo:% Orden:% Seleccionar:%',sucursal_id,tipo_orden,num_orden,selreg;
		if selreg = 'S' then
			--Orden
			for recOrden in select * from keplersc.kdord
				where c1=sucursal_id and c2=tipo_orden and c3=num_orden
			loop	
				importe_total_refs := 0;
				importe_total_horas := 0;
				importe_total_tots := 0;
				importe_total_car := 0;
			--//raise exception 'ver error';
			raise notice 'For orden Suc:% Tipo:% Orden:%',recOrden.c1,recOrden.c2,recOrden.c3;
				--MSS 18092025 Valida si esta cerrada en 0s		
				select count(*) into intValor from keplersc.kdordceros
				where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
				if intValor > 0 then
					raise exception 'Orden % . Ya esta cerrada en 0s',num_orden;
				end if;
		
				--Valida puntos terminados
				for recPuntos in select * from keplersc.kdpun
					where c1=recOrden.c1 and c2=recOrden.c2 and c3=recOrden.c3
				loop	
					if recPuntos.c7 <> 'T' then
						raise notice 'La orden % aún tiene puntos no terminados, imposible cerrar en 0''s',num_orden;
						msgPuntos := format('La orden %1$s aún tiene puntos no terminados, imposible cerrar en 0s',num_orden);
						--armar xml de regreso para saber resultados
						valPuntos := 0;
						--valRes := 0;
					end if;
				end loop;
				if motivo ='' then
					raise exception 'Orden % . El campo de motivo no puede estar en blanco',num_orden;					
					msgMotivo := format('Orden %1$s. El campo de motivo no puede estar en blanco',num_orden);
					--armar xml de regreso para saber resultados
					valMotivo := 0;
					valRes := 0;
				end if;
				if recOrden.c7 = 20 then		--Facturada
					raise exception 'La orden % ya esta facturada. Genere el Vale de Salida',num_orden;					
					msgFact := format('La orden % ya esta facturada. Genere el Vale de Salida',num_orden);
					--armar xml de regreso para saber resultados
					valFact := 0;		
					valRes := 0;
				end if;
				if recOrden.c7 = 30 then		--Vale de salda
					raise exception 'La orden % ya tiene el Vale de Salida, no se puede cerrar en 0s',num_orden;					
					msgFact := format('La orden %1$s ya tiene el Vale de Salida, no se puede cerrar en 0s',num_orden);
					--armar xml de regreso para saber resultados
					valFact := 0;
					valRes := 0;
				end if;
				--MSS 23122025 Valida si esta cerrada en proceso normal
				if recOrden.c8 = 40 then		--Cerrada proceso normal
					raise exception 'La orden % se encuentra cerrada, no se puede cerrar en 0s',num_orden;					
					msgFact := format('La orden %1$s se encuentra cerrada, no se puede cerrar en 0s',num_orden);
					--armar xml de regreso para saber resultados
					valFact := 0;
					valRes := 0;
				end if;
				if valRes = 1 then
					update keplersc.kdord 		--Actualiza en 0 MO, ref, TOTs, cargos
						set c30=0,
							c31=0,
							c32=0,
							c33=0,
							c61=0,
							c62=0,
							c63=0
						where c1=recOrden.c1 and c2=recOrden.c2 and c3=recOrden.c3;
					raise notice 'Actualiza en 0 kdord,31..33';
											
					--Puntos
					for recPuntos in select * from keplersc.kdpun
						where c1=recOrden.c1 and c2=recOrden.c2 and c3=recOrden.c3
					loop	
 						if recPuntos.c6 <> 'P' and recPuntos.c6 <> 'N' and recPuntos.c6 <> 'L' then	--P-Por predupuestar, N-No autorizados, L-Sin cargo al ciente
 							--Ref
							for rec in select * from keplersc.kdref
								where c1=recPuntos.c1 and c2=recPuntos.c2 and c3=recPuntos.c3 and c4=recPuntos.c4
							loop
								importe_total_refs := importe_total_refs + rec.c16;
							end loop;
							raise notice 'Refacc';
							--TOTs
							for rec in select * from keplersc.kdtot
								where c1=recPuntos.c1 and c2=recPuntos.c2 and c3=recPuntos.c3 and c4=recPuntos.c4
							loop
								importe_total_tots := importe_total_tots + rec.c16;
							end loop;
							raise notice 'TOTs';
							--Cargos
							for rec in select * from keplersc.kdcar
								where c1=recPuntos.c1 and c2=recPuntos.c2 and c3=recPuntos.c3 and c4=recPuntos.c4
							loop
								importe_total_car := importe_total_car + rec.c10;
							end loop;
							raise notice 'Cargos';
							--Horas
							for rec in select * from keplersc.kdhoras
								where c1=recPuntos.c1 and c2=recPuntos.c2 and c3=recPuntos.c3 and c4=recPuntos.c4
							loop
								costo_por_hora :=0;
								if recPuntos.c6 <> 'S' then
									if recPuntos.c6 <> 'L' then
										select c4 into costo_por_hora 
											from keplersc.kdmargen
											where c1=recOrden.c2;
									else
										costo_por_hora :=0;
									end if;	
								else
									select c2,c3,c11 into marca,modelo,anio from keplersc.kdserie
										where c1=recOrden.c6;
									if found then
										select c6,c9 into costo_mo_default, hrs_a_pagar
											from keplersc.kdspaq
											where c1=marca and c2=modelo and c4=recPuntos.c5;
										if found then
											if hrs_a_pagar>0 then
												costo_por_hora := costo_mo_default/hrs_a_pagar;
											end if;
										else
											costo_por_hora :=0;
										end if;
									end if;
								end if;
								importe_total_horas := importe_total_horas + (rec.c8*costo_por_hora);
							end loop;	--Horas
							raise notice 'Horas';
						end if;
					end loop;	--Puntos	
					raise notice 'Orden %,importe_total_refs:% ,importe_total_horas:% ,importe_total_tots:% ,importe_total_car:%',num_orden,importe_total_refs,importe_total_horas,importe_total_tots,importe_total_car;
					--Orden en ceros la cierra
				--raise exception '% % % %',importe_total_refs,importe_total_horas,importe_total_tots,importe_total_car;
					if (importe_total_refs+importe_total_horas+importe_total_tots+importe_total_car)=0 then
						update keplersc.kdord 		--Actualiza en 0 MO, ref, TOTs, cargos
							set c7 =30,		--Vale de Salida impreso
								c8 =50,		--Fuera de taller
								c9 ='C', -- Orden Cerrada en 0s validacion para disparos BP
								c30=0,
								c31=0,
								c32=0,
								c33=0,
								c35=current_date,
								c37=left(current_time::text, 2)::integer,
								c61=0,
								c62=0,
								c63=0
							where c1=recOrden.c1 and c2=recOrden.c2 and c3=recOrden.c3;
						raise notice 'Actualiza kdord en 0 y estatus 30 y 50';
						update keplersc.kdtord 
							set c6 =current_date,
								c12=current_date 
							where c1=recOrden.c1 and c2=recOrden.c2 and c3=recOrden.c3;
						raise notice 'Actializa kdtord';	
						--Cierre Automatico
						update keplersc.kdpun 
							set c6 ='N',			--No autorizado
								c7 ='T',			--Terminado
								c20='C',			--Cerrado refacciones
								c22='C',			--Cerrado tabulacion
								c23='C',			--Cerrado tots
								c24='C'				--Cerrado cargos
							where c1=recOrden.c1 and c2=recOrden.c2 and c3=recOrden.c3;
						raise notice 'Actualiza kdpun con puntos cerrados';
						delete from keplersc.kdhorpag 
							where c1=recOrden.c1 and c2=recOrden.c2 and c3=recOrden.c3;
						raise notice 'Elimina kdhorpag';
						insert into keplersc.kdordceros 
							(c1,c2,c3,c4,c5,c6) 
							values 
							(recOrden.c1,recOrden.c2,recOrden.c3,usuario,current_date,motivo);
						raise notice 'Inserta en kdordceros';
						
						--Actualiza bitacora
						select xmlforest(usuario, current_date as fecha, TO_CHAR(NOW(), 'HH24:MI:SS') as hora, 
							sucursal_id as sucursal, ' ' as genero, ' ' as naturaleza, 0 as grupo, 0 as tipo, tipo_orden || '-' ||num_orden as folio,
							'ORDEN CERRADA EN 0s' as tipo_movto, 'MOTIVO: '|| motivo as detalle_movto) :: text into strValor;
				
						select '<document>'||strValor||'</document>' into strValor;
						varXml := strValor::xml;
						
						select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(varXml);
						if get_resultado = '0' then
							raise exception '%',get_mensaje;
						end if;	
					else
						raise exception 'Orden % no esta en 0. Solo se pueden cerrar ordenes en 0 en este modulo',num_orden;	
						continue;
					end if;
				
				end if;
		
			end loop;		--Orden		
		end if;
		valRes := 1;
		resultado :='1';
		 
	end loop;		--Partidas

		resultado := '1';
		mensaje := 'Orden Cerrada en 0s';
		adicionales := '';
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := '0';
			mensaje := 'cerrar_orden_ceros() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
