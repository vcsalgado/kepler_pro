CREATE OR REPLACE FUNCTION keplersc.ser_tmkt_asignarevento(tip_ope text, sucursal_id text, folio text, asesor text)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
--Descripcion: Esta funcion obtiene el siguiente evento de tmkt para el agente de tmkt
--   valida si no tiene algun evento pendiente, de ser asi lo asigna, de otra forma 
--   obtiene el siguiente evento, actualiza el asesor, lo marca como que esta en pantalla
--   y regresa el registro.
--Autor: Victor Salgado
--Fecha: 24/03/2022
--Bitacora de cambios
--16/08/23: Miriam Santana - Ajuste por cambio de funcionalidad de pantalla sertmkt
declare 
	--Variables de proceso
	xmlResultado xml;
	error text = '';
	totReg int = 0;
	sigFolio text ='';
	sqlExp text = '';
	serie text = '';
	inventario text = '';
--c4 esta en pantalla 0 SI, 10 No
--c5 fecha programacion
--c6 Tipo contacto, 0=Recontacto


begin
	--Verificar folio asignado al asesor que este en pantalla
	if tip_ope = 'P' then --Evento programado de forma automatica
		if sigFolio is null or sigFolio = '' then --no hay asignados en pantalla para el asesor, buscar siguiente evento a atender
			loop --Este loop es para garantizar que se asigna el evento de forma unica por posible concurrencia al proceso
				select count(*) into totReg from keplersc.kdtmktser2 tmkt 
					where tmkt.c1=sucursal_id and tmkt.c4=10 
					and (tmkt.c3='' or tmkt.c3 is null or tmkt.c3='SA') and tmkt.c8=0;
				if totReg=0 then
					raise exception 'No se tienen mas contactos programados.';
				end if;
				select c2 into sigFolio from keplersc.kdtmktser2 tmkt 
					where tmkt.c1=sucursal_id and tmkt.c4=10 
					and (tmkt.c3='' or tmkt.c3 is null or tmkt.c3='SA') and tmkt.c8=0 limit 1;
				update keplersc.kdtmktser2 set c4=0, c3=asesor where c1=sucursal_id and c2=sigFolio;			
				if sigFolio is not null then
					exit;
				end if;
			end loop;
		end if;
	else 
		if tip_ope = 'S' then --Seguimiento"
			sigFolio = folio;
		else --tip_opr = 'R' Reactivo, se esta ayendiendo una llamada
			sigFolio = folio; 
		end if;
	end if;
	--Determinar si el registro contiene serie 
	select coalesce(tmkt.c14,'') into serie from keplersc.kdtmktser2 tmkt where tmkt.c1=sucursal_id and tmkt.c2=sigFolio;
	select coalesce(c15,'') into inventario from keplersc.kdctasbienvser where c1=sucursal_id and c6=serie;
	if serie <> '' then	
		if inventario = '' or inventario is null then		--Normal anterior
			sqlExp = format('select tmkt.c1 as sucursal_id, ms.c2 as sucursal, tmkt.c2 as folio, tmkt.c3 as asesor, tmkt.c5  as fecha,
				tmkt.c11 as observacion,coalesce(tmkt.c19,''P'') as tipo_trabajo,
				ser.c1 as serie, ser.c4 as vin, ser.c2 as marca, ser.c3 as modelo, ser.c11 as anio, ser.c12 as kms, 
				motivo.descripcion as tipo_contacto,
				tmkt.c11||'' ''||tmkt.c12||'' ''||tmkt.c13 as observaciones,
				tmkt.c29 as inp_coment_resultado,
				motivo.descripcion as motivo_contacto, 
				motivo.motivo_id as motivo_id, 
				to_char(tmkt.c26, ''DD/MM/YYYY'') as fecha_dofu, ser.c38 as protec_extend, to_char(ser.c39, ''DD/MM/YYYY'') as fecha_exp_garantia
				from keplersc.kdtmktser2 tmkt 
				inner join keplersc.kdms ms on ms.c1=tmkt.c1 
				left outer join keplersc.kdserie ser on ser.c1 = tmkt.c14 
				inner join keplersc.kdtmktmotivo motivo on motivo.motivo_id = tmkt.c7 
				where ms.c1=%L and tmkt.c2=%L and tmkt.c3=%L',sucursal_id,sigFolio,asesor);
		else 											
			sqlExp = format('select tmkt.c1 as sucursal_id, ms.c2 as sucursal, tmkt.c2 as folio, tmkt.c3 as asesor, tmkt.c5 as fecha,
				tmkt.c11 as observacion,coalesce(tmkt.c19,''P'') as tipo_trabajo, 
				motivo.descripcion as tipo_contacto,
				tmkt.c11||'' ''||tmkt.c12||'' ''||tmkt.c13 as observaciones,
				tmkt.c29 as inp_coment_resultado,
				motivo.descripcion as motivo_contacto,
				motivo.motivo_id as motivo_id,
				to_char(tmkt.c26, ''DD/MM/YYYY'') as fecha_dofu
	 			from keplersc.kdtmktser2 tmkt  
				inner join keplersc.kdms ms on ms.c1=tmkt.c1 
				inner join keplersc.kdud cte on cte.c2=tmkt.c20 
				inner join keplersc.kdtmktmotivo motivo on motivo.motivo_id = tmkt.c7 
				where tmkt.c1=%L and tmkt.c2=%L and tmkt.c3=%L',sucursal_id,sigFolio,asesor);	
		end if;
	else
		sqlExp = format('select tmkt.c1 as sucursal_id, ms.c2 as sucursal, tmkt.c2 as folio, tmkt.c3 as asesor, tmkt.c5 as fecha,
			tmkt.c11 as observacion,coalesce(tmkt.c19,''P'') as tipo_trabajo, 
			motivo.descripcion as tipo_contacto,
			tmkt.c11||'' ''||tmkt.c12||'' ''||tmkt.c13 as observaciones,
			tmkt.c29 as inp_coment_resultado,
			motivo.descripcion as motivo_contacto,
			motivo.motivo_id as motivo_id,
			to_char(tmkt.c26, ''DD/MM/YYYY'') as fecha_dofu
 			from keplersc.kdtmktser2 tmkt  
			inner join keplersc.kdms ms on ms.c1=tmkt.c1 
			inner join keplersc.kdud cte on cte.c2=tmkt.c20 
			inner join keplersc.kdtmktmotivo motivo on motivo.motivo_id = tmkt.c7 
			where tmkt.c1=%L and tmkt.c2=%L and tmkt.c3=%L',sucursal_id,sigFolio,asesor);	
		
		
	end if;

	select query_to_xml(sqlExp,false,true,'') into xmlResultado;
	return xmlResultado;
exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
