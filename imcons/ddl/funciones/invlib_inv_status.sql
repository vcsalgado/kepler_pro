CREATE OR REPLACE FUNCTION keplersc.invlib_inv_status(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 

--Debe ser llamada con los parametros dataXml y xmlKDMM)	
--Autor: Saltiel Cruz
--Fecha: 17 Oct 2022
--actualizado:07/Dic/2022
--Bitacora de cambios
--27/05/2025 Miriam Santana: Se incluye validaciones para anulacion por sustitución (flag_anulacion)

--Variables para xml
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;
	v_inventario text ='';
	--xml Movimiento
	xmlKDM1 xml;
	xmlKDM1_c8 text = '';
	xmlKDM1_c65 text = '';
	xmlKDM1_c76 text = '';
	--Variables de uso general
	mensajeError text;
		
	folio_operacion text;
	v_Factura_intereses numeric =0;
	v_plazo numeric =0;
	v_estado_venta numeric = 0;

	xmlResultado xml;
	flag_anulacion text = '';	--MSS 27052025 Anulacion por sustitucion
			
	--Variables de retorno desde funciones externas
	resultado text; --retorno
	mensaje text; --retorno
	adicionales text; --retorno
	

begin
	-- Inicializacion de variables
	folio_operacion := 0;
	resultado := '0';
	adicionales := '';

	--Documento
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r5/text()', dataxml))[1];	
	v_inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text);

	xmlKDM1_c8 := (xpath('//row/c8/text()', xmlkdmm))[1];
 	xmlKDM1_c65 := (xpath('//row/c65/text()', xmlkdmm))[1];
    xmlKDM1_c76 := (xpath('//row/c76/text()', xmlkdmm))[1];
   
   	flag_anulacion :=coalesce((xpath('//document/ambiente/flag_anulacion/text()',dataxml))[1]::text,'')::text;	--MSS 27052025 Anulacion por sustitucion
	if xmlKDM1_c8 = 'S' then 
		
		if(select count(*) from keplersc.KDINF where c1 = sucursal_id and c2 = v_inventario) > 0 then --VERIFICANDO COMPRA Y PEDIDO
			
			if xmlKDM1_c65::numeric = 10 and naturaleza = 'A' then --******** COMPRA REGISTRADA
				if(select count(*) from keplersc.KDINF where c1 = sucursal_id and c2 = v_inventario) > 0 then 
					update keplersc.kdinf 
					set c31 = 20
					where c1 = sucursal_id and c2 = v_inventario;
				end if;
				if (select count(*) from keplersc.kdasig where c1 = sucursal_id and c2 = v_inventario) > 0 then 
					update keplersc.kdasig 
					--Fixed by JMM 20230108
					--set c31 = 20
					set c11 = 20 
					where c1 = sucursal_id and c2 = v_inventario;
				end if;
			end if;
			
			if xmlKDM1_c65::numeric = 10 and naturaleza = 'D' then --******** BAJA DE COMPRA REGISTRADA
				if(select count(*) from keplersc.kdinf where c1 = sucursal_id and c2 = v_inventario) > 0 then 
					update keplersc.kdinf 
					set c31 = 10
					WHERE c1 = sucursal_id and c2 = v_inventario;
				end if;
				if (select count(*) from keplersc.kdasig where c1 = sucursal_id and c2 = v_inventario) > 0 then 
					update keplersc.kdasig
					--Fixed by JMM 20230108
					--set c31 = 10
					set c11 = 10 
					WHERE c1 = sucursal_id and c2 = v_inventario;
				end if;
			end if;
				
			if xmlKDM1_c65::numeric = 20 then --********PEDIDO REGISTRADO
				update keplersc.kdinf 
				--Fixed by JMM 20230108
				--set c31 = 10
				set c32 = 10
				where c1 = sucursal_id and c2 = v_inventario;
			end if;
			
			if genero = 'N' and xmlKDM1_c76 = 'S' then 
				if xmlKDM1_c65::numeric = 100 then
					if naturaleza = 'D' then 
						update keplersc.kdinf
						--Fixed by JMM 20230108
						--set c31 = 80
						set c32 = 80
						where c1 = sucursal_id and c2 = v_inventario;
					else
						update keplersc.kdinf 
						--Fixed by JMM 20230108
						--set c31 = 0
						set c32 = 0
						where c1 = sucursal_id and c2 = v_inventario;
					end if;
				end if;
				if xmlKDM1_c65::numeric = 110 then
					if naturaleza = 'A' then 
						update keplersc.kdinf 
						--Fixed by JMM 20230108
						--set c31 = 0
						set c32 = 0
						where c1 = sucursal_id and c2 = v_inventario;
					else
						update keplersc.kdinf 
						--Fixed by JMM 20230108
						--set c31 = 80
						set c32 = 80
						where c1 = sucursal_id and c2 = v_inventario;
					end if;
				end if;			
			end if;			
		end if;
		
			--		H,KDINF,I,KDPEDIDO
		if(select count(*) from keplersc.kdinf where c1 = sucursal_id and C2 = v_inventario) > 0 and  --H
		  (select count(*) from keplersc.kdpedido where c1 = sucursal_id and C2 = v_inventario) > 0 --I
		then 
		
			select c32 into v_estado_venta from keplersc.kdinf where c1 = sucursal_id and C2 = v_inventario;
			select (c27 + c28) as c27, c24 into v_Factura_intereses, v_plazo from keplersc.kdpedido where c1 = sucursal_id and C2 = v_inventario;
		
			--FACTURA DE INTERESES --PLAZO			
			if xmlKDM1_c65::numeric = 30 and naturaleza = 'D' then --FACTURA
			
				if v_Factura_intereses > 0 then 
					update keplersc.kdinf 
					set c32 = 20 --'LISTO PARA REALIZAR FACTURA PVA Y LISTA PARA HACER PVA
					where c1 = sucursal_id and c2 = v_inventario;						
				else 
					if v_plazo > 0 then
						update keplersc.kdinf 
						set c32 = 30--'LISTO PARA ELABORAR DOCUMENTOS
						where c1 = sucursal_id and c2 = v_inventario;	
						--raise notice 'actualizado 30';
					else
						update keplersc.kdinf 
						set c32 = 50 --'LISTO PARA ELABORAR VALE DE SALIDA
						where c1 = sucursal_id and c2 = v_inventario;	
						--raise notice 'actualizado 50';
					end if;
				end if;
			
			end if;	--end xmlKDM1_c65=30
			
			if xmlKDM1_c65::numeric = 30 and naturaleza = 'A' then  --NOTA CREDITO DE FACTURA
				if upper(flag_anulacion) <> 'CANCELA_X_SUST' then	--MSS 27052025 Anulacion por sustitucion
					update keplersc.kdinf 
					set c32 = 10 --'LISTO PARA HACER FACTURA OTRA VEZ O DAR DE BAJA PEDIDO
					where c1 = sucursal_id and c2 = v_inventario;	
				end if;
			end if;
		
			if xmlKDM1_c65::numeric = 40 and naturaleza = 'D' then --FACTURA DE INTERESES Y COBRANZA
			
				update keplersc.kdpedido 
				set c41 = 'S'
				where c1 = sucursal_id and c2 = v_inventario;
				
				if v_plazo > 0 then 
					update keplersc.kdinf 
					set c32 = 30 --LISTO PARA ELABORAR DOCUMENTOS
					where c1 = sucursal_id and c2 = v_inventario;
				else
					update keplersc.kdinf 
					set c32 = 50 --LISTO PARA ELABORAR VALE DE SALIDA
					where c1 = sucursal_id and c2 = v_inventario;
				end if;
			
			end if;
			
			if xmlKDM1_c65::numeric = 40 and naturaleza = 'A' then --NOTA CREDITO DE FACTURA   DE PVA
			
				update keplersc.kdpedido 
				set c41 = 'N'
				where c1 = sucursal_id and c2 = v_inventario;
			
				update keplersc.kdinf 
				set c32 = 20 --LISTO PARA REALIZAR FACTURA PVA O DAR DE BAJA LA FACTURA DEL VEHICULO
				where c1 = sucursal_id and c2 = v_inventario;
			
			end if;
		
			if xmlKDM1_c65::numeric = 50 and naturaleza = 'D' then ---DOCUMENTOS
				update keplersc.kdinf 
				set c32 = 50 ---LISTO PARA ELABORAR VALE DE SALIDA
				where c1 = sucursal_id and c2 = v_inventario;
			end if;
		
			if xmlKDM1_c65::numeric = 70 and v_estado_venta < 60 then  --ALTA DE VALE DE SALIDA
			
					update keplersc.kdinf 
					set c32 = 60 --'VALE DE SALIDA REGISTRADO
					where c1 = sucursal_id and c2 = v_inventario;
			
			else 
			-- Updated by JMM para alinearlo con funcion K75
			/*end if;--end xmlKDM1_c65 =70 and v_estado_venta < 60*/

				if xmlKDM1_c65::numeric = 70 and v_estado_venta = 60 then  --BAJA DE VALE DE SALIDA
						update keplersc.kdinf 
						set c32 = 50 --'DIRECTO A LA FACTURA DE LA UNIDAD
						where c1 = sucursal_id and c2 = v_inventario;
				end if;--end xmlKDM1_c65 =70 and v_estado_venta=60
				
			end if;
			
		end if;--end 
			
		if xmlKDM1_c65::numeric = 80 and  
		(select count(*) from keplersc.kdinf where c1 = sucursal_id and C2 = v_inventario) > 0 then 
			if naturaleza = 'D'  then 
				update keplersc.kdinf 
				set c32 = 70 --'FACTURA DEL TRASPASO
				where c1 = sucursal_id and c2 = v_inventario;
			else 
				update keplersc.kdinf 
				set c32 = 0 --'NOTA DE CREDITO DEL TRASPASO
				where c1 = sucursal_id and c2 = v_inventario;
			end if;
		end if;--end 80 
	
	end if;
	resultado := '1';
	mensaje := '';
	return query select resultado, mensaje, adicionales;
/*
exception
	when others then
		resultado := 0;
		mensaje := 'invlib_inv_status() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
*/	
end;
$function$
