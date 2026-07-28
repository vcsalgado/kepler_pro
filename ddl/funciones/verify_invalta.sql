CREATE OR REPLACE FUNCTION keplersc.verify_invalta(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Funcion en MOVLIB AUTOS  
--Autor: Saltiel Rc
--Fecha: 20/10/2022

declare
v_sucursal_id text = '';  
v_consecutivo text = '';	
v_contador numeric = 0;
genero text;
naturaleza text;
grupo text;
tipo_clave text;
v_rol_usuario text='';
expSql text = '';
strValor text = '';
strValor2 text = '';
v_operacion text = '';
v_estatus text = '';
v_estado_compra numeric = 0;
v_estado_venta numeric = 0;
v_fecha text ='';
v_fecha_cur timestamp;
xmlKDMM xml;
v_inventario text ='';

v_fecha_dia int = 0;
resultado text= '';
mensaje text = '0';
adicionales text = '';
totreg int = 0;
v_nocatalogo text =''; 
get_resultado text ='';
get_mensaje text ='';

begin
	
				v_sucursal_id := upper((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text); --				
				genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
				naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
				grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
				tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];				
  			    v_inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text);
				v_estatus := (xpath('//document/k_status_validacion/text()', dataxml))[1]; --siempre se inicializa en 1 para realizar validaciones --v�ase lib MOVLIB
				v_fecha:= (xpath('//document/k_fecha/text()', dataxml))[1];

				expSql = 'select * from keplersc.kdmm where col_sucursal='  || E'\'' || v_sucursal_id || E'\'' || ' and c1='  || E'\'' || genero || E'\'' ||
				' and c2=' || E'\'' || naturaleza || E'\'' || ' and c3=' || grupo || ' and c4=' || tipo_clave;	
				
				select query_to_xml(expSql, true, false, '') into xmlKDMM;
				strValor := (xpath('//row/c90/text()', xmlKDMM))[1];
				if strValor is not null then
					if strValor = 'S' then
						mensaje := 'Documento no v�lido';
						raise exception '%',mensajeError;			
					end if;
				end if;
				v_operacion := (xpath('//row/c94/text()', xmlKDMM))[1];			
				
				-- Code Included by Jose Mendoza, actualiza el valor de la varible : v_inventario 
				-- Lo hara si y solo si encuentra el TAG enviado en los XML de los Procesos de Jose Mendoza 
				-- Por default asigna lo que trae originalmente el TAG k_inventario ... Esto No Afecta 
				-- La Operacion de la Funcion, solo tomara el valor del Inventario de los XMLs Enviados por 
				-- Jose Mendoza del TAG correspondiente cuando asi aplique ... 20221122 2200 
				if xpath_exists('//document/k_claveinv/text()', dataxml) = true /*false*/ then 
					v_inventario := (xpath('//document/k_claveinv/text()', dataxml))[1];
				end if;
			
			
	  			--raise notice  '1 %' , v_sucursal_id;	  		
				strValor := (xpath('//row/c8/text()', xmlKDMM))[1];
				strValor2 := (xpath('//row/c65/text()', xmlKDMM))[1];
				
		if strValor = 'S' and strValor2::numeric > 0 then 
			if(select count(*) from keplersc.KDINF WHERE c1 = v_sucursal_id and C2 = v_inventario) > 0 then
				select c31,c32 into v_estado_compra, v_estado_venta from keplersc.KDINF WHERE c1 = v_sucursal_id and C2 = v_inventario;
				strValor := (xpath('//row/c65/text()', xmlKDMM))[1];
 --raise exception 'v_operacion:%',v_operacion;
				if v_operacion = 'G' then --FACTURA					
					if strValor::int < 80 then --'VALIDA TODO EL PROCESO DE VENTA MIENTRAS NO SEA TRASPASO						
						IF strValor::int = 10 and v_estado_compra >= 20 then --B11001=0:
						adicionales := 'La compra para este inventario, ya esta registrada'; raise exception '%',adicionales; 
						end if;
						
						if strValor::int>=20 and v_estado_compra < 20 then 
						adicionales := 'No se puede realizar esta operación, porque la compra todavia no esta dada de alta'; raise exception '%',adicionales;
						end if;
						
						if strValor::int = 20 and v_estado_venta >= 10 then 
						adicionales := 'El pedido para este inventario, ya esta registrado'; raise exception '%',adicionales;
						end if;
	
						if strValor::int > 20 and v_estado_venta < 10 then 
						adicionales := 'No se puede realizar esta operación, porque el pedido todavia no esta dado de alta'; raise exception '%',adicionales;
						end if;
					
						if strValor::int = 30 and v_estado_venta >= 20 then 
						adicionales := 'La factura para este inventario, ya esta registrada'; raise exception '%',adicionales;
						end if;
					
						if strValor::int = 30 and ((select EXTRACT(year  FROM v_fecha::timestamp))::numeric > (select EXTRACT(year FROM (select now()-interval '1 day')))::numeric and
										 			(select EXTRACT(month  FROM v_fecha::timestamp))::numeric > (select EXTRACT(month FROM (select now()-interval '1 day')))::numeric and 
										 			(select EXTRACT(day  FROM v_fecha::timestamp))::numeric > (select EXTRACT(day FROM (select now()-interval '1 day')))::numeric)  then 
						adicionales := 'La fecha de la Factura no puede ser posterior a hoy'; raise exception '%',adicionales;
						end if;
					
						if strValor::int > 30 and v_estado_venta < 20 then 
						adicionales := 'No se puede realizar esta operación, porque la factura todavia no esta dada de alta'; raise exception '%',adicionales;
						end if;
						
						if strValor::int = 70 and v_estado_venta >= 60 then 
						adicionales := 'El vale de salida para este inventario, ya esta registrado'; raise exception '%',adicionales;
						end if;
						
						if strValor::int = 70  then							
							v_fecha_dia := (select extract (day from (select now())))::int;
							v_fecha_cur:= now();
							if v_fecha::timestamp > v_fecha_cur then 						
								adicionales := 'La fecha del Vale de Salida no puede ser despues del dia de hoy ';
								raise exception '%',adicionales;
							end if;
/*						 	
							if v_fecha_dia = 1 then
						 			if (select EXTRACT(year  FROM v_fecha::timestamp))::numeric < (select EXTRACT(year FROM (select now()-interval '1 day')))::numeric and
							 			(select EXTRACT(month  FROM v_fecha::timestamp))::numeric < (select EXTRACT(month FROM (select now()-interval '1 day')))::numeric and 
							 			(select EXTRACT(day  FROM v_fecha::timestamp))::numeric < (select EXTRACT(day FROM (select now()-interval '1 day')))::numeric then			
							 			adicionales := 'La fecha del Vale de Salida tiene que ser la del ultimo dia del mes pasado ';raise exception '%',adicionales;
						 			end if;
						 			if (select EXTRACT(year  FROM v_fecha::timestamp))::numeric > (select EXTRACT(year FROM (select now()-interval '1 day')))::numeric and
							 			(select EXTRACT(month  FROM v_fecha::timestamp))::numeric > (select EXTRACT(month FROM (select now()-interval '1 day')))::numeric and 
							 			(select EXTRACT(day  FROM v_fecha::timestamp))::numeric > (select EXTRACT(day FROM (select now()-interval '1 day')))::numeric then
							 			adicionales := 'La fecha del Vale de Salida no puede ser despues del dia de hoy ';raise exception '%',adicionales;
						 			end if;
						 	else --v_fecha_dia  > 1							 	
						 		if (select EXTRACT(year  FROM v_fecha::timestamp))::numeric <> (select EXTRACT(year FROM (select now())))::numeric and
						 			(select EXTRACT(month  FROM v_fecha::timestamp))::numeric <> (select EXTRACT(month FROM (select now())))::numeric and 
						 			(select EXTRACT(day  FROM v_fecha::timestamp))::numeric <> (select EXTRACT(day FROM (select now())))::numeric then
						 			adicionales := 'La fecha del Vale de Salida tiene que ser la del dia de hoy';raise exception '%',adicionales;
						 		end if;
						 	end if;
*/						 							 
						end if;
					--MSS 010523 Codigo faltante en la funcion
					 else --A PARTIR DE AQUI OPERAN TRASPASOS Y MOVIMIENTOS FUERA DE OPERACION
	                    if  strValor::int = 80 then  --TRASPASOS
	                        if  v_estado_compra < 20 then  
	                            adicionales := 'No se puede efectuar el traspaso, debido a que no esta realizada la compra'; raise exception '%',adicionales;
	                        end if;
	                        if v_estado_venta > 0 then  
	                            adicionales := 'No se puede efectuar el traspaso, debido a que la unidad no esta en inventario'; raise exception '%',adicionales;
	                        end if;
	                    else  --factura de PVA o Nota de Descuento
	                        if  v_estado_venta < 20 then  
	                            adicionales := 'No se pueden hacer Notas de Descuento o Facturas de PVA hasta que se realice la factura de la Unidad'; raise exception '%',adicionales;
	                        end if;
	                        if  v_estado_venta = 60 then  
	                            adicionales := 'No se pueden hacer Notas de Descuento o Facturas de PVA si ya esta realizado el Vale de Salida'; raise exception '%',adicionales;
	                        end if;
	                        if  v_estado_venta = 70 then
	                        adicionales := 'No se pueden hacer Notas de Descuento o Facturas de PVA si la unidad fue traspasada a otra agencia'; raise exception '%',adicionales;
	                        end if;
	                    end if;	                
					--MSS Codigo faltante hasta aqu�
					end if;
				
				else --'NOTA DE CREDITO
					if strValor::int < 80 then --VALIDA TODO EL PROCESO DE BAJA DE VENTA MIENTRAS NO SEA TRASPASO						
						if strValor::int = 10 and v_estado_compra = 10 then 
						adicionales := 'La compra para este inventario, ya esta cancelada'; raise exception '%',adicionales;
						end if;
					
						if strValor::int = 30 and v_estado_venta < 20 then 
						adicionales := 'La factura para este inventario, ya esta cancelada'; raise exception '%',adicionales;
						end if;
					
						if strValor::int <= 10 and v_estado_venta >= 10 then 
						adicionales := 'Para realizar este movimiento primero hay que dar de baja el Pedido'; raise exception '%',adicionales;
						end if;
						
						if strValor::int <= 20 and v_estado_venta >= 30 then 
						adicionales := 'Para realizar este movimiento primero hay que hacer la Nota de Credito de la Factura'; raise exception '%',adicionales;
						end if;
						
						if strValor::int <= 30 and v_estado_venta >= 60 then 
						adicionales := 'Para realizar este movimiento primero hay que dar de baja el Vale de Salida'; raise exception '%',adicionales;
						end if;
						
						-- Esta Duplicado, commented by JMM 221122 0010
						/*
						if strValor::int <= 30 and v_estado_venta >= 60 then 
						adicionales := 'Para realizar este movimiento primero hay que dar de baja el Vale de Salida'; raise exception '%',adicionales;
						end if;
						*/
					
						if v_estado_venta = 70 then
						adicionales := 'Para realizar este movimiento primero hay que elaborar la Nota de Credito de la Factura de Traspaso'; raise exception '%',adicionales;
						end if;
					else --NOTA DE CREDITO DE TRASPASOS Y MOVIMIENTOS FUERA DE OPERACION
						if strValor::int = 80 then
							if v_estado_venta <> 70 then
							adicionales := 'No se puede efectuar la baja el traspaso, por 2 razones: 1-Ya esta dada de baja previamente. 2- Se encuentra en el proceso de Ventas.'; raise exception '%',adicionales;	
							end if;
						else --Nota de Credito de PVA o Cancelacion de Nota de Descuento
							if v_estado_venta = 60 then
							adicionales := 'No puede hacer la Nota de Credito de PVA o la Cancelacion de la Nota de Descuento"," porque no se ha dado de baja el vale de salida'; raise exception '%',adicionales;	
							end if;
							if v_estado_venta = 70 then
							adicionales := 'No puede hacer la Nota de Credito de PVA o la Cancelacion de la Nota de Descuento"," porque no ha hecho la Nota de Credito del Traspaso de la Unidad'; raise exception '%',adicionales;	
							end if;
						end if;
					end if;
				end if;--end NOTA DE CR�DITO			
			else
				adicionales := 'No se encuentra el Numero de Inventario, Imposible Continuar';raise exception '%',adicionales;
			end if; --end KDINF	
		end if;
			resultado ='1';
			mensaje ='Finalizado';
--			adicionales ='';						

return query select resultado, mensaje, adicionales;

EXCEPTION
	WHEN others then		
		resultado := '0';
		mensaje := SQLERRM;
		--adicionales := 'funcion verify_invalta';
		return query select resultado, mensaje, adicionales;
END;
$function$
