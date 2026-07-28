CREATE OR REPLACE FUNCTION keplersc.cat_valepedido_baja_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Baja Vale de Salida
--Autor: Saltiel Rc
--Fecha: 19/10/2022

declare
sucursal_id text = ''; 
folio_operacion text = ''; 
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
xmlKDM1 xml;
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
				sucursal_id := upper((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text); --
				folio_operacion := upper((xpath('//document/k_folio/text()', dataxml))[1]::text);
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
			expSql = 'select * from keplersc.kdm1 where' || 
				' c1=' || E'\'' || sucursal_id || E'\'' ||  
				' and c2=' || E'\'' || genero || E'\'' ||
				' and c3=' || E'\'' || naturaleza || E'\'' || 
				' and c4=' || grupo || 
				' and c5=' || tipo_clave ||
			  	' and c6=' || E'\'' || folio_operacion || E'\'';
	
				select query_to_xml(expSql, true, false, '') into xmlKDM1;
				strValor:=substring(v_fecha,9,2) || '/' || substring(v_fecha,6,2) || '/' || substring(v_fecha,1,4) ; 

/*
				paso:= 'docdis.caja_baja';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.caja_baja(dataxml,xmlKDMM,folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				
			
				paso:= 'docdis.cxcp_baja_conmov';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_baja_conmov(dataxml,xmlKDMM,folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
			
				paso:= 'cont_general_baja';
	  			select * into get_resultado, get_mensaje, get_adicionales from keplersc.cont_general_baja(dataxml, xmlKDM1, xmlkdmm, folio_operacion );
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
*/				
				paso:= 'invlib_baja_invent';
	  			select * into get_resultado, get_mensaje, get_adicionales from keplersc.invlib_baja_invent(dataxml,xmlkdmm, folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
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
