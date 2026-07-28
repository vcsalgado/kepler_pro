CREATE OR REPLACE FUNCTION keplersc.verify_invbaja(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Baja Pedido Autos
--Autor: Saltiel Rc
--Fecha: 15/09/2022

declare
v_sucursal_id text = ''; 
v_folio text = ''; 
v_consecutivo text = '';	
v_contador numeric = 0;
genero text;
naturaleza text;
grupo text;
tipo_clave text;
v_rol_usuario text='';
v_fecha text = '';
v_kdmm_m8 text='';
paso text='';
strValor text = '';
get_adicionales text = '';
v_kdmm_m65 numeric = 0;
v_kdinf_h32 numeric = 0;
v_inventario text ='';
v_estado_venta numeric = 0;
expSql text;
xmlKDMM xml;
resultado text= '';
mensaje text = '0';
adicionales text = '';
totreg int = 0;
v_nocatalogo text =''; 
get_resultado text ='';
get_mensaje text ='';
intValor int =0;
usuario text = '';

BEGIN
				v_sucursal_id := upper((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text); --
				v_folio := upper((xpath('//document/k_folio/text()', dataxml))[1]::text);
				genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
				naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
				grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
				tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
				v_rol_usuario := (xpath('//document/k_rol_usuario/text()', dataxml))[1];
				get_resultado := (xpath('//document/k_b11001/text()', dataxml))[1]; --siempre se inicializa en 1 para realizar validaciones --véase lib MOVLIB
				strValor:=(xpath('//document/k_fecha/text()', dataxml))[1];
				v_fecha := (xpath('//document/k_fecha/text()', dataxml))[1];
   				v_inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text);
				usuario := (xpath('//document/usuario/text()', dataxml))[1]::text;
	  			--raise notice  '1 %' , v_sucursal_id;	  		
				expSql = 'select * from keplersc.kdmm where c1='  || E'\'' || genero || E'\'' ||
				' and c2=' || E'\'' || naturaleza || E'\'' || ' and c3=' || grupo || ' and c4=' || tipo_clave;	
--raise notice 'expSql: %', expSql;			
				select query_to_xml(expSql, true, false, '') into xmlKDMM;
--				strValor := (xpath('//row/c8/text()', xmlKDMM))[1];
--				if strValor is not null then
--					if strValor = 'S' then
--						mensaje := 'Documento no válido';
--						raise exception '%',mensaje;			
--					end if;
--				end if;


				strValor:=substring(v_fecha,9,2) || '/' || substring(v_fecha,6,2) || '/' || substring(v_fecha,1,4) ; --2023-01-01
--raise notice 'strValor: %', strValor;				
				paso:= 'docdis.mov_sec_alta';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_year(strValor);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
			
				paso:= 'docdis.verify_cxcp_baja';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_cxcp_baja(dataxml);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				
				strValor:=coalesce((xpath('//row/c65/text()', xmlKDMM))[1],'0');
				intValor:=strValor::int;
	  			IF get_resultado::int > 0 and 
	  				(xpath('//row/c8/text()', xmlKDMM))[1]::text='S' and 
	  				intValor > 0 and intValor < 80 THEN     --VALIDA TODO EL PROCESO DE VENTA MIENTRAS NO SEA TRASPASO	  			
	  				if (select count(*) from keplersc.KDINF where  c1 = v_sucursal_id and C2 = v_inventario) > 0 then 
						select c32 into v_estado_venta from keplersc.KDINF where  c1 = v_sucursal_id and C2 = v_inventario;
	  					if intValor = 20 and 
	  						v_estado_venta < 10 then 
	  						get_mensaje := 'El pedido para este inventario, ya esta cancelado.';
	  						raise exception '%',get_mensaje;
						end if;
				
	  					if intValor = 70  then --VALE DE SALIDA
	  						if v_estado_venta < 60 then 
								get_mensaje := 'El vale de salida para este inventario, ya esta cancelado.';
	  							raise exception '%',get_mensaje;
							else 
								select c7 + '7 days' into v_fecha from keplersc.KDCOMISMOV where c1 = v_sucursal_id and c8 = v_inventario;
								--VCSS 01 sep 2025, el usuario que tenga habilitado el acceso a la opcion de baja de vale puede realizar
								--		la operación sin restricción alguna. 
								--if usuario <> 'ADMIN80' then 
								--	get_mensaje := 'No est� autorizado para dar de baja el vale de salida';
	  							--	raise exception '%',get_mensaje;
								--end if;
	  						end if;
	  					end if;

	  					if intValor = 20  and 
	  						v_estado_venta >= 20 then 
	  						get_mensaje := 'No se puede dar de baja el pedido hasta dar de baja la factura.';
	  							raise exception '%',get_mensaje;
	  					end if;
	  				end if;--encontrado...	  			
	  			end if;					
			resultado ='1';
			mensaje ='Finalizado';
			adicionales ='';
--		end if; 

return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;	
		mensaje := 'verify_invbaja() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
END;
$function$
