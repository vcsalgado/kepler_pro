CREATE OR REPLACE FUNCTION keplersc.cxcp_sinmov_kduxe_alta(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Bitacora de cambios
--29/02/2024 (JMM) :
---- Se Incluyen Campos Prov_Pago al final 
---- para las Operaciones de los Documentos que aplique, dentro del Nvo Esquema de CxP 
--19/09/2024 Miriam Santana: Generar la cxc con la factura original para anulacion de nota de descuento
--15/01/2025 Miriam Santana: Generar la cxc con la factura original para anulacion de nota de servicio
--21/03/2025 Miriam Santana: Generar la cxc con la factura original para anulacion de aplicacion de anticipo

declare
	--Variables de definicion de documento
	sucursal_desc text;
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_compuesto text;
	tipo_clave text;
	no_partidas int;
	referencia text;
	clave_cteprov text;
	subtotal decimal;
	monto_iva text;
	retencion_iva text;
	monto_total text;
	fecha_operacion text;
	plazo_vencimiento text;
	nat_docto_anx text;
	gpo_docto_anx text;
	tipo_docto_anx text;
	folio_docto_anx text;
	factura_ini text;		--MSS 19092024 Factura original
	flag_factura_sust text ='';			--MSS 25022025 Factura por sustitucion
	
	anticipos decimal = 0;
	conf_iva decimal;
	ivaValor decimal =0;	--MSS 210824 Decimales cxc iva

	--variables kduxe
	factura_xe text;

	--Added 20240229 by JMM , Proveedor de Pago
	clave_provpago text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	strValor text;
	intValor int;
	totalReg int;
	expSql text;
	xmlKDUXE xml;


begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];

	--Tipo de documento
	tipo_desc := (xpath('//document/k_tipon/r0/text()', dataxml))[1]; 
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	clave_cteprov := (xpath('//document/k_clave/text()', dataxml))[1];
	referencia := (xpath('//document/k_refer/text()',dataxml))[1]; --Factura para 'X'
	monto_iva := (xpath('//document/k_iva/text()',dataxml))[1];		
	monto_total := (xpath('//document/k_monto/text()',dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	plazo_vencimiento := coalesce((xpath('//document/k_vence/text()', dataxml))[1]::text,'')::text;
	anticipos := (xpath('//document/k_montoanticipo/text()',dataxml))[1];	
	nat_docto_anx := (xpath('//document/k_natdocto/text()',dataxml))[1];
	gpo_docto_anx := (xpath('//document/k_gpodocto/text()',dataxml))[1];
	tipo_docto_anx := (xpath('//document/k_tipodocto/text()',dataxml))[1];
	folio_docto_anx := (xpath('//document/k_foliodocto/text()',dataxml))[1];
	factura_ini := (xpath('//document/k_facturaini/text()',dataxml))[1];	
	flag_factura_sust:=coalesce((xpath('//document/ambiente/flag_factura_sust/text()',dataxml))[1]::text,'')::text;		--MSS 25022025 Factura por sustitucion
	
	--  * * * * *  Added 20240229 by JMM, Proveedor de Pago  
	clave_provpago := '';

	if xpath_exists('//document/k_clave_pago/text()', dataxml) = true /*false*/ then 
		clave_provpago := coalesce((xpath('//document/k_clave_pago/text()',dataxml))[1]::text,'')::text;
	end if;

	-- Si no existe dato del Proveedor de Pago, se igualara al Proveedor de la Operacion 
	if length(clave_provpago) = 0 then 
		clave_provpago := clave_cteprov; 
	end if;
	--  * * * * *  End : Proveedor de Pago


	--VARIABLES K75:
		--W1=sucursal_id
		--W10=clave_cteprov
		--W11=factura_xe
		--W2=genero
		--W3=naturaleza
		--W4=grupo
		--W5=tipo_clave
		--w6=folio_operacion
		--w16=monto_total
		--w18= to_date(plazo_vencimiento,'YYYY-MM-DD')
		--w49 =anticipos


	if genero = 'U' and naturaleza = 'D' then 
	
		select count(*) into totalReg from keplersc.kduxe	
			where c1=sucursal_id and c2=clave_cteprov and c3= folio_operacion::text
			and c4=1 and c5=genero and c6=naturaleza and c7=grupo::integer 
			and c8=tipo_clave::integer and c9=folio_operacion;	
		
		if totalReg = 0 then--and naturaleza <> 'N' then	
			--TO DO: Validar de donde vienen anticipos, se deben enviar en el tag <k_montoanticipo>
			subtotal :=	 monto_total::decimal - coalesce(anticipos,'0')::decimal;
			strValor:= (xpath('//row/c16/text()', xmlKDMM))[1]::text;
		
			conf_iva := strValor::int;							--Porcentaje IVA
			ivaValor := (subtotal * conf_iva)/(100+conf_iva);	--monto_iva
			
			select count(*) into totalReg from keplersc.kdm1	
				where c1=sucursal_id and c2=genero and c3=nat_docto_anx and c4=gpo_docto_anx::int and c5=tipo_docto_anx::integer and c6=folio_docto_anx;
			if totalReg > 0 then
				--MSS 19092024: Para anulacion nota descto UD63 generar la cxc con la factura original
				--MSS 15012024: Para anulacion nota servicio UD19 generar la cxc con la factura original
				--MSS 21032025: Para anulacion aplicacion anticipo UD81 generar la cxc con la factura original
				if concat(genero,naturaleza,grupo) = 'UD63' or concat(genero,naturaleza,grupo) = 'UD19' or concat(genero,naturaleza,grupo) = 'UD81' then					
					folio_docto_anx := factura_ini;
				end if;
				if flag_factura_sust = 'FACTURA_X_SUST' then			--MSS 25022025 Factura por sustitucion
					folio_docto_anx := folio_operacion;
				end if;
				insert into keplersc.kduxe (c1,c2,c3,c4,c5,c6,
					c7,c8,c9,c10,c11,
					c12,c13,c14,c15,c16)
				values(sucursal_id,clave_cteprov,folio_docto_anx,1,genero,naturaleza,
					grupo::integer,tipo_clave::integer,folio_operacion,1,to_date(fecha_operacion,'YYYY-MM-DD'),
					to_date(plazo_vencimiento,'YYYY-MM-DD'),subtotal,ivaValor,0.00,0.00);
				
				--Obtener xml de KDUXE de registro generado 		
				expSql=format('select * from keplersc.kduxe where c1=%1$L and c2=%2$L and c3=%3$L and c4=%4$s and c5=%5$L and c6=%6$L and c7=%7$s and c8=%8$s and c9=%9$L',
						sucursal_id,clave_cteprov,folio_docto_anx,1,genero,naturaleza,grupo,tipo_clave,folio_operacion);
				select query_to_xml(expSql, true, false, '') into xmlKDUXE;
							
			else
			
				insert into keplersc.kduxe (c1,c2,c3,c4,c5,c6,
					c7,c8,c9,c10,c11,
					c12,c13,c14,c15,c16)
				values(sucursal_id,clave_cteprov,folio_operacion,1,genero,naturaleza,
					grupo::integer,tipo_clave::integer,folio_operacion,1,to_date(fecha_operacion,'YYYY-MM-DD'),
					to_date(plazo_vencimiento,'YYYY-MM-DD'),subtotal,ivaValor,0.00,0.00);
				
				--Obtener xml de KDUXE de registro generado 		
				expSql=format('select * from keplersc.kduxe where c1=%1$L and c2=%2$L and c3=%3$L and c4=%4$s and c5=%5$L and c6=%6$L and c7=%7$s and c8=%8$s and c9=%9$L',
						sucursal_id,clave_cteprov,folio_operacion,1,genero,naturaleza,grupo,tipo_clave,folio_operacion);
				select query_to_xml(expSql, true, false, '') into xmlKDUXE;
				
			end if;
		end if;
		
	end if;

	if genero = 'U' and naturaleza = 'A' then
		select count(*) into totalReg from keplersc.kduxe	
			where c1=sucursal_id and c2=clave_cteprov and c3= folio_docto_anx
			and c4=1 and c5=genero and c6=naturaleza and c7=grupo::integer 
			and c8=tipo_clave::integer and c9=folio_operacion;	
		if totalReg = 0 then
			insert into keplersc.kduxe (c1,c2,c3,c4,c5,c6,
				c7,c8,c9,c10,c11,
				c12,c13,c14,c15,c16)
			values(sucursal_id,clave_cteprov,folio_docto_anx,1,genero,naturaleza,
				grupo::integer,tipo_clave::integer,folio_operacion,1,to_date(fecha_operacion,'YYYY-MM-DD'),
				to_date(plazo_vencimiento,'YYYY-MM-DD'),monto_total::decimal,monto_iva::decimal,0.00,0.00);	
				
				--Obtener xml de KDUXE de registro generado 		
				expSql=format('select * from keplersc.kduxe where c1=%1$L and c2=%2$L and c3=%3$L and c4=%4$s and c5=%5$L and c6=%6$L and c7=%7$s and c8=%8$s and c9=%9$L',
						sucursal_id,clave_cteprov,folio_docto_anx,1,genero,naturaleza,grupo,tipo_clave,folio_operacion);
				select query_to_xml(expSql, true, false, '') into xmlKDUXE;		
		end if;
	end if;

	if genero = 'X' then 	
	
		--factura_xe :=  lpad(referencia,10,'0'); --TO DO: Valida si se utilizan los 10 primeros o los 10
											-- ultimos caracteres cuando se exceda el numero de caracteres
	
		-- Comentado por JMM, 20240226 ... Se dejo como la intruccion del else que aplicaria ahora 
		-- para todos los casos ( estaba homologada al k75 )
		/*
			-- Condition Added by JMM 4 UEN = AUT & Gpo = 7 , 20221120
			if (/*grupo = '7' and*/ upper((xpath('//document/ambiente/uen/text()', dataxml))[1]::text) = 'VEN') then
				factura_xe := lpad(referencia,10,'0');
			else
				-- sentencia original (comment added by JMM 20221120)
		*/
				factura_xe := referencia;  -- Dejada como buena el 20240226 por JMM
		/*
			end if;
		*/
	
	
		--TO DO: Validar que esta consulta sea necesaria, pueden mas de una operacion 
		--       insertar el mismo registro 				
		select count(*) into totalReg from keplersc.kduxe	
		where c1=sucursal_id and c2=clave_cteprov and c3= factura_xe::text
			and c4=1 and c5=genero and c6=naturaleza and c7=grupo::integer 
			and c8=tipo_clave::integer and c9=folio_operacion;		
		--TO DO:Validar que pasa si esta condicion no se da		
		if totalReg = 0 then	
		
			--TODO, ver si aplica
			/*
			  Opcion 1
			 if naturaleza= 'A' and grupo = '12' then
				retencion_iva := (xpath('//document/k_retencion_iva/text()',dataxml))[1];
				monto_iva := monto_iva::decimal - retencion_iva::decimal;
				monto_total := monto_total::decimal - monto_iva::decimal;
			end if;
			 Opcion 2
			if naturaleza= 'A' and grupo = '12' then
				monto_iva := 0;
			end if;*/
		
			insert into keplersc.kduxe (c1,c2,c3,c4,c5,c6,
				c7,c8,c9,c10,c11,
				c12,c13,c14,c15,c16 ,cve_prov_pago/*Added 240229*/ )
			values(sucursal_id,clave_cteprov,factura_xe,1,genero,naturaleza,
				grupo::integer,tipo_clave::integer,folio_operacion,1,to_date(fecha_operacion,'YYYY-MM-DD'),
				to_date(plazo_vencimiento,'YYYY-MM-DD'),monto_total::decimal,monto_iva::decimal,0.00,0.00 ,clave_provpago/*Added 240229*/ );
			
			expSql=format('select * from keplersc.kduxe where c1=%1$L and c2=%2$L and c3=%3$L and c4=%4$s and c5=%5$L and c6=%6$L and c7=%7$s and c8=%8$s and c9=%9$L',
						sucursal_id,clave_cteprov,factura_xe,1,genero,naturaleza,grupo,tipo_clave,folio_operacion);
				select query_to_xml(expSql, true, false, '') into xmlKDUXE;

		end if;			
	end if;
		
	resultado := 1;
	mensaje := '';
	adicionales := xmlKDUXE::text;
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cxcp_sinmmov_kduxe_alta() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
