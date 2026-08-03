CREATE OR REPLACE FUNCTION keplersc.cat_autobajapedido_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: BAJA_INVENT 
--Autor: Saltiel Rc
--Fecha: 15/09/2022
--Bitacora de cambios
--Miriam Santana: 07/10/24 No permitir baja de pedido si ya esta vendido
--Miriam Santana:25/05/2026 Deseleccionar anticipos

declare
v_sucursal_id text = ''; 
v_folio text = ''; 
v_consecutivo text = '';	
v_contador numeric = 0;
genero text;
naturaleza text;
grupo text;
tipo text;
v_rol_usuario text='';
v_inventario text = '';
v_aniocontable text='';
v_diacontable text='';
v_mescontable text='';
v_fechacontable text = '';
estado_venta int;		--MSS 

--MSS Deseleccionar anticipos
gen_ant	text;
nat_ant text;
gpo_ant int;
tipo_ant int;
folio_ant text;

resultado text= '';
mensaje text = '0';
adicionales text = '';
totreg int = 0;
v_nocatalogo text =''; 
get_resultado text ='';
get_mensaje text ='';

strValor text;
strValor2 text;
varcont xml;
expSql text;
--xml documento
xmlKDMM xml;
mensajeError text;
BEGIN
				v_sucursal_id := upper((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text); --
				v_folio := upper((xpath('//document/k_folio/text()', dataxml))[1]::text);
				genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
				naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
				grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
				tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
				v_rol_usuario := (xpath('//document/k_rol_usuario/text()', dataxml))[1];
				v_inventario:= (xpath('//document/k_inventario/text()', dataxml))[1];
			--if ((select count(*) from keplersc.kdm1 where c1 = v_sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::numeric and c5 = tipo::numeric  and c6 = v_folio) > 0) then
	  			--raise notice  '1 %' , v_sucursal_id;
				
		  		v_aniocontable = (select extract(year from (select now())))::text ;
			  	v_mescontable = (select extract(month from (select now())))::text ;
	    		v_diacontable = (select extract(day from (select now())))::text ;
				v_fechacontable = v_diacontable||'/'||v_mescontable||'/'||v_aniocontable;
				--raise notice  'fecha %' , v_fechacontable;	
				expSql = 'select * from keplersc.kdmm where col_sucursal='|| E'\'' || v_sucursal_id || E'\'' || ' and c1=' || E'\'' || genero || E'\'' ||
					' and c2=' || E'\'' || naturaleza || E'\'' || ' and c3=' || grupo || ' and c4=' || tipo;	
				select query_to_xml(expSql, true, false, '') into xmlKDMM;

				strValor := (xpath('//row/c90/text()', xmlKDMM))[1];
				if strValor is not null then
					if strValor = 'S' then
						mensajeError := 'Documento no valido';
						raise exception '%',mensajeError;			
					end if;
				end if;

				--MSS 07102024 No permitir baja de pedido si ya esta vendido
				select c32 into estado_venta from keplersc.kdinf where c1 = v_sucursal_id and c2 = v_inventario;	
				if estado_venta > 10 then
					raise exception 'El inventario ya esta vendido, verifique...';
				end if;
				
				---BAJA_INVENT - INV_PEDIDO_BAJA ()damos de baja
				 
				strValor := (xpath('//row/c8/text()', xmlKDMM))[1];
				strValor2 := (xpath('//row/c65/text()', xmlKDMM))[1];
				if strValor = 'S' then						
					if strValor2::numeric = 20 then 
						if (select count(*) from keplersc.KDPEDIDO where c1=v_sucursal_id and c2 = v_inventario) > 0 then
							delete from keplersc.KDPEDIDO where c1 = v_sucursal_id and  c2 = v_inventario;
						end if;
						if (select count(*) from keplersc.kdinf  where c1=v_sucursal_id and c2 = v_inventario) > 0 then
							update keplersc.kdinf  
							set c32 = 0 
							where c1 = v_sucursal_id and  c2 = v_inventario;
						end if;
						
						delete from keplersc.KDBONIF 
						where c1 = v_sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::numeric and c5 = tipo::numeric and c6 = v_folio;
					end if;
				end if;
				
			
				---end  INV_PEDIDO_BAJA
				
						update keplersc.kdm1 
							set c43 = 'C',
								c16=0,
								c15=0,
								c14=0,
								c42=0
						where c1 = v_sucursal_id and 
							  c2 = genero and 
							  c3 = naturaleza and 
							  c4 = grupo::numeric and 
							  c5 = tipo::numeric  and 
							  c6 = v_folio;
				 		
						--MSS 25052026: Deseleccionar anticipos
						select c2,c3,c4,c5,c6 into gen_ant,nat_ant,gpo_ant,tipo_ant,folio_ant from keplersc.kdf3ncant
							where c1=v_sucursal_id and tipo_relacion ='' and folio_relacionado = v_inventario;
					
						update keplersc.kdf3ncant set
							folio_relacionado = ''				
							where c1=v_sucursal_id and c2=gen_ant and c3=nat_ant and c4=gpo_ant and c5=tipo_ant and c6=folio_ant;
						
						insert into keplersc.KDUSRACCESS (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10)
						values(v_rol_usuario,
								(select now()),
								'00:00:00',
								v_sucursal_id,
								genero,
								naturaleza,
								grupo::numeric,
								tipo::numeric,
								v_folio,
								'BAJA');
						
			resultado ='1';
			mensaje ='Finalizado';
			adicionales ='';
--		end if; 

return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;	
		mensaje := 'cat_AltaPedido_seminuevos_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
END;
$function$
