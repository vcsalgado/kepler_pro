CREATE OR REPLACE FUNCTION keplersc.ven_cambio_sucursal_inventario(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	--Realiza los movimientos necesarios para cambiar un inventario de sucursal
	--Autor: Miriam Santana
	--Fecha: 8 Abril 2025
	
	--Variables para xml
	sucursal_origen text;
	sucursal_destino text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;
	inventario text;
	
	--Variables de uso general
	sucursal_id text;
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
	folio_operacion text;
	folio_operacion_entrada text;
	folio_operacion_salida text;
	strRemplazable text = '';

	paso text;
	referencia text;
	xmlResultado xml;
	folio_id text;
	uen text= '';
	cmmnt text;
	totReg int;
	costo_origen decimal;
	costo_destino decimal;
	iva_origen decimal;

	--Movimiento bitacora
	usuario_movto text;
	fecha_movto text;
	hora_movto text;
	detalle_movto text;
	operacion_desc text;

	arrNaturaleza text[];
	
	xmlKDMM xml;			--xml documento
	xmlKDM1 xml;			--xml Movimiento
	k_sucn xml;				--xml nodo
	xmlUsr xml;				--xml Bitacora usuario
	xmlFolio xml;			--xml obtener folio
	xmlEstadisticas xml;	--xml genereacion de estadisticas

	--Variables de retorno desde funciones externas
	get_resultado text; --retorno
	get_mensaje text; --retorno
	get_adicionales text; --retorno
	

begin
	-- Inicializacion de variables
	folio_operacion := 0;
	get_resultado := '';
	get_adicionales := '';

	--Documento
	sucursal_origen := (xpath('//document/k_sucn_origen/r1/text()', dataxml))[1];
	sucursal_destino := (xpath('//document/k_sucn_destino/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	--Movimiento bitacora
	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
	fecha_movto := (xpath('//document/movimiento/fecha/text()',dataxml))[1];
	hora_movto := (xpath('//document/movimiento/hora/text()',dataxml))[1];
	detalle_movto:= coalesce((xpath('//document/detalle_movto/text()', dataxml))[1]::text,'');
	operacion_desc := (xpath('//document/operacion/text()', dataxml))[1];
	
	uen := coalesce((xpath('//document/ambiente/uen/text()',dataxml))[1],'');
	inventario := (xpath('//document/k_claveinv/text()', dataxml))[1];
	arrNaturaleza := array['D','A'];
	
	if sucursal_origen = sucursal_destino then
		raise exception 'Verifique. La sucursal origen y destino no puede ser la misma';
	end if;
	if inventario is null then
		raise exception 'Verifique. Falta el No. de Inventario';
	end if;

	for i in array_lower(arrNaturaleza,1) .. array_upper(arrNaturaleza,1)
	loop
		if arrNaturaleza[i] = 'A' then
			sucursal_id := sucursal_destino; 
		else
			sucursal_id := sucursal_origen;
		end if;
		naturaleza := arrNaturaleza[i];

		--Obtener registro de Kdmm
		expSql = 'select * from keplersc.kdmm where col_sucursal='|| E'\'' || sucursal_id || E'\'' || ' and c1='  || E'\'' || genero || E'\'' ||
			' and c2=' || E'\'' || naturaleza || E'\'' || ' and c3=' || grupo || ' and c4=' || tipo;		
		select query_to_xml(expSql, true, false, '') into xmlKDMM;

		strValor := (xpath('//row/c90/text()', xmlKDMM))[1];
		if strValor is not null then
			if strValor = 'S' then
				mensajeError := 'Documento no valido';
				raise exception '%',mensajeError;			
			end if;
		end if;
	
		---------------------------------------------------------------
		--Obtencion de consecutivo
		---------------------------------------------------------------
		--TO DO: Verificar con que variable se identifican documentos que registran movimiento	
		folio_id := (xpath('//row/c17/text()', xmlKDMM))[1] || '.' || sucursal_id; --Identificador del consecutivo del documento
		strValor := (xpath('//row/c93/text()', xmlKDMM))[1];
		if strValor is null or strValor <> 'S' then

		strValor := dataxml::text;
		strvalor := replace(strValor,'naturaleza_reemplazable',arrNaturaleza[i]);
		
		xmlFolio := strValor::xml;
		dataxml := xmlFolio;

			select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(folio_id,0,0, xmlFolio);			
			if get_resultado = '0' then	
				raise exception '%',get_mensaje;
				end if;
				
				if arrNaturaleza[i] = 'A' then
					folio_operacion_entrada := get_mensaje;
				else
					folio_operacion_salida := get_mensaje;
				end if;
				folio_operacion := get_mensaje;
		end if;		

		---------------------------------------------------------------
		--INVENTARIOS. Registro de movimiento en kdm1
		---------------------------------------------------------------   
		strValor := dataxml::text;
		strValor := replace(strValor,'<document>','');
		strValor := replace(strValor,'</document>','');
		-- Extraer el nodo <k_sucn>
		    SELECT unnest(xpath('/document/k_sucn', dataxml)) INTO k_sucn;
		
		--Armar el nuevo nodo
		select xmlelement(name k_sucn, xmlforest(sucursal_id as r1)):: text into paso;    
		
		strValor := replace(strValor,'k_sucn>','k_sucn_sinvalor>');
		
		strValor := concat('<document>',paso,strValor,'</document>');
		xmlKDM1 := strValor::xml;

		select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_prim_alta(xmlKDM1, folio_operacion);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;
		---------------------------------------------------------------
		--Registro en KDINF
		---------------------------------------------------------------
		select count(*) into totReg from keplersc.kdinf where c1=sucursal_destino and c2=inventario;
		if totReg=0 then
			INSERT INTO keplersc.kdinf
				(c1, c2, c3, c4, c5, 
				c6, c7, c8, c9, c10, 
				c11, c12, c13, c14, c15, 
				c16, c17, c18, c19, c20, 
				c21, c22, c23, c24, c25, 
				c26, c27, c28, c29, c30, 
				c31, c32, c33, c34, c35, 
				c36, c37, c38, c39, c40, 
				c41, c42, c43, c44, c45, 
				c46, c47, c48, c49, c50, 
				c51, c52, c53, c54, c55, 
				c56, c57, c58, c59, c60, 
				c61, c62, c63, c64, c65, 
				c66, c67, c68, c69, c70, 
				c71, c72, c73, c74, c75, 
				c76, c77, c78, c79, c80, 
				c81, c82, c83, c84, c85, 
				c86, c87, c88, c89, c90, 
				c91, c92, c93, c94)
				select sucursal_destino,c2, c3, c4, c5, 
				c6, c7, c8, c9, c10, 
				c11, c12, c13, c14, c15, 
				c16, c17, c18, c19, c20, 
				c21, c22, c23, c24, c25, 
				c26, c27, c28, c29, c30, 
				c31, c32, c33, c34, c35, 
				c36, c37, c38, c39, c40, 
				c41, c42, c43, c44, c45, 
				c46, c47, c48, c49, c50, 
				c51, c52, c53, c54, c55, 
				c56, c57, c58, c59, c60, 
				c61, c62, c63, c64, c65, 
				c66, c67, c68, c69, c70, 
				c71, c72, c73, c74, c75, 
				c76, c77, c78, c79, c80, 
				c81, c82, c83, c84, c85, 
				c86, c87, c88, c89, c90, 
				c91, c92, c93, c94
				from keplersc.kdinf where c1=sucursal_origen and c2=inventario;
		
				update keplersc.kdinf set c31=20		--Factura e compra registrada
					where c1=sucursal_destino and c2=inventario;
		else 
				update keplersc.kdinf set c31=20		--Factura e compra registrada
					where c1=sucursal_destino and c2=inventario;
		
		end if;
		--Actualiza estatus de inventario
		update keplersc.kdinf set c31=0			--Cancelado
			where c1=sucursal_origen and c2=inventario;

		---------------------------------------------------------------
		--ACTUALIZACION DE ESTADISTICAS: KDEINV, KDGINV, KDLINV
		---------------------------------------------------------------	
		--CALL invlib_inv_alta 
		select xmlelement(name document,
				xmlelement(name k_sucn,xmlforest(sucursal_id as r1)),
			    xmlelement(name k_tipon, xmlforest(genero as r1, arrNaturaleza[i] as r2, grupo as r3, tipo as r4)),
			    xmlelement(name k_inventario,inventario)):: text into strValor;
		
		xmlEstadisticas := strValor::xml;	
		select * into resultado, mensaje, adicionales from keplersc.invlib_inv_alta(xmlEstadisticas,xmlKDMM,folio_operacion); --dentro de la libreria se encuentra inv_alta_k

		---------------------------------------------------------------
		--GRABA EN BTACORA EL MOVIMIENTO
		---------------------------------------------------------------
		select xmlforest(usuario_movto as usuario, fecha_movto as fecha, hora_movto as hora, 
				sucursal_id as sucursal, genero, naturaleza, grupo, tipo, folio_operacion as folio,
				operacion_desc as tipo_movto, detalle_movto as detalle_movto) :: text into strValor;
			
		select '<document>'||strValor||'</document>' into strValor;
		xmlUsr := strValor::xml;
	
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);

		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;			

		strValor := dataxml::text;	
		strRemplazable := concat('<r2>',arrNaturaleza[i],'</r2>');	
		strvalor := replace(strValor,strRemplazable,concat('<r2>','naturaleza_reemplazable','</r2>'));			
		dataxml := strValor::xml;

		--Valida costos
		if arrNaturaleza[i] = 'A' then
			select c11 into costo_destino 
				from keplersc.kdeinv where c1=sucursal_destino and c2=inventario and c5=genero and c6=arrNaturaleza[i] and c7=grupo::integer and c8=tipo::integer and c9=folio_operacion_entrada;
		else 
		select c11,c12 into costo_origen, iva_origen
			from keplersc.kdeinv where c1=sucursal_origen and c2=inventario and c5=genero and c6=arrNaturaleza[i] and c7=grupo::integer and c8=tipo::integer and c9=folio_operacion_salida;
		
		end if;
	end loop;

	--Ajusta costo
	if costo_origen<>costo_destino then
		update keplersc.kdeinv set c11 = costo_origen, c12 = iva_origen
			where c1=sucursal_destino and c2=inventario and c5=genero and c7=grupo::integer and c8=tipo::integer and c9=folio_operacion_entrada;
		update keplersc.kdginv set c11 = costo_origen, c13 = iva_origen
			where c1=sucursal_destino and c2=inventario;
		update keplersc.kdlinv set c5=costo_origen,c8=costo_origen, c9 = iva_origen, c10 = iva_origen
			where c1=sucursal_destino and c2=inventario;

	end if;
	
	get_resultado:=1;
	get_mensaje:=folio_operacion_entrada;
	get_adicionales:=folio_operacion_salida;
	return query select get_resultado, get_mensaje, get_adicionales;
END;
$function$
