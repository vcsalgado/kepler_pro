CREATE OR REPLACE FUNCTION keplersc.mov_sec_alta(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserción de partidas de documentos en KDM2
--Autor: Victor Salgado
--Fecha: 21/06/2021
--Bitacora de cambios
--25/07/22 Miriam Santana:
--Completar la inserción de las 40 columnas, se estrandarizan 
--los nombres de los campos para la interfaz gráfica K80 
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

	--Varables de partidas 
	no_partidas int;
	numero_partida int;
	clave_producto text;
	cantidad_unidades text;
	descripcion_producto text;
	unidad text;
	precio_unitario text;
	importe_partida text;
	codigo_requisicion text;
	
	porc_desc1 text = '0';
	porc_desc2 text = '0';
	
	porc_desc3 text = '0';
	porc_iva text;
	porc_ieps text = '0';
	naturaleza_docant text;
	grupo_docant text = 0;
	
	tipo_docant text = '0';
	folio_docant text = '';
	partida_docant text = '0';
	saldo_unid_part text = '0';
	cve_cliente text = '';
	
	costo_venta_partida text = '0';
	clave_original text = '';
	cve_almacen text = '';
	num_cargos text = '0';
	
	cant_rest_docant text = '0';
	fecha_part text;
	monto_costo text = '0';
	exist_prev_unid text = '0';
	exist_prev_pesos text ='0';

	moneda text = '';
	costo_moneda text = '0';
	venta_moneda text = '0';
	orden_trabajo text = '';
	concepto text = '';

	deccantidad_partida decimal;

	--Variables de uso general 
	strValor text;
	totReg int = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;


begin
	sucursal_desc := (xpath('//document/k_sucn/r0/text()', dataxml))[1];
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];

	--Tipo de documento
	tipo_desc := (xpath('//document/k_tipon/r0/text()', dataxml))[1]; 
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	--fact taller
	orden_trabajo := coalesce((xpath('//document/k_orden/text()',dataxml))[1]::text,'')::text;
	
	porc_iva := coalesce((xpath('//document/k_tipon/r6/text()', dataxml))[1]::text,'0')::text;
	porc_ieps := coalesce((xpath('//document/k_tipon/r11/k_porcieps/text()', dataxml))[1]::text,'0')::text;
	moneda := coalesce((xpath('//document/k_moneda/r0/text()', dataxml))[1]::text,'')::text;
	
	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	
	--Procesar detalle de partidas a kdm2 (ALTA_MOV_SEC)

	-- added by JMM 220804 
	numero_partida := 0;

	for cont in 0..no_partidas - 1 loop
		
		--updated by JMM 220804 
		--numero_partida := cont + 1;
		deccantidad_partida := 0;
		--cantidad_unidades := (xpath('//document/k_mov/r'||cont||'/k_q/text()',dataxml))[1];
		cantidad_unidades := coalesce((xpath('//document/k_mov/r'||cont||'/k_q/text()',dataxml))[1],
								  (xpath('//document/k_mov/r'||cont||'/k_Q/text()',dataxml))[1]);
		deccantidad_partida := cantidad_unidades::decimal;
		importe_partida := (xpath('//document/k_mov/r' ||cont||'/k_monto/text()',dataxml))[1];
		
		if deccantidad_partida > 0 or importe_partida::decimal > 0 then
		
			numero_partida := numero_partida + 1;
			
			--Guardar reemplazo, si el producto es original, en el campo reeemplazo viene el reemplazo  Victor Salgado 13 Oct 2023
			clave_producto := coalesce((xpath('//document/k_mov/r' ||cont||'/k_partesel/text()',dataxml))[1],
							(xpath('//document/k_mov/r' ||cont||'/k_parte/text()',dataxml))[1]);					--producto capturado
			clave_original := coalesce((xpath('//document/k_mov/r' ||cont||'/k_parte/text()',dataxml))[1],'');		--producto original

			if clave_producto='' then
				--Si no se trae reemplazo, mandar error
				clave_producto := (xpath('//document/k_mov/r' ||cont||'/k_parte/text()',dataxml))[1];
				raise exception 'No se especifico reemplazo para el producto %',clave_producto;
			end if;
			
			--cantidad_unidades := coalesce((xpath('//document/k_mov/r'||cont||'/k_q/text()',dataxml))[1],
			--							  (xpath('//document/k_mov/r'||cont||'/k_Q/text()',dataxml))[1]);
			
			descripcion_producto := (xpath('//document/k_mov/r' ||cont||'/k_descr/text()',dataxml))[1];
			unidad := (xpath('//document/k_mov/r' ||cont||'/k_unidad/text()',dataxml))[1];
			precio_unitario := (xpath('//document/k_mov/r' ||cont||'/k_precio/text()',dataxml))[1];
		
			importe_partida := (xpath('//document/k_mov/r' ||cont||'/k_monto/text()',dataxml))[1];
			codigo_requisicion := coalesce((xpath('//document/k_mov/r' ||cont||'/k_control/text()',dataxml))[1]::text,'');
			--Datos agregados
			porc_desc1 := coalesce((xpath('//document/kmov/r' ||cont||'/k_partpdesc1/text()',dataxml))[1]::text,'0')::text;
			porc_desc2 := coalesce((xpath('//document/kmov/r' ||cont||'/k_partpdesc2/text()',dataxml))[1]::text,'0')::text;		
			porc_desc3 := coalesce((xpath('//document/kmov/r' ||cont||'/k_partpdesc3/text()',dataxml))[1]::text,'0')::text;
			
			naturaleza_docant := coalesce((xpath('//document/r' ||cont||'/k_natdocant/text()', dataxml))[1]::text,'')::text;
			grupo_docant := coalesce((xpath('//document/r' ||cont||'/k_gpodocant/text()', dataxml))[1]::text,'0')::text;
		
			tipo_docant := coalesce((xpath('//document/r' ||cont||'/k_tipodocant/text()', dataxml))[1]::text,'0')::text;
			folio_docant := coalesce((xpath('//document/r' ||cont||'/k_foliodocant/text()', dataxml))[1]::text,'')::text;
			partida_docant := coalesce((xpath('//document/r' ||cont||'/k_partidadocant/text()', dataxml))[1]::text,'0')::text;
			saldo_unid_part :=coalesce((xpath('//document/r' ||cont||'/k_saldounid/text()', dataxml))[1]::text,'0')::text;
			cve_cliente := coalesce((xpath('//document/r' ||cont||'/k_cvecliente/text()', dataxml))[1]::text,'')::text;
			
			costo_venta_partida := coalesce((xpath('//document/r' ||cont||'/k_costovta/text()', dataxml))[1]::text,'0')::text;
			cve_almacen := coalesce((xpath('//document/r' ||cont||'/k_cvealmacen/text()', dataxml))[1]::text,'0')::text;
			num_cargos := coalesce((xpath('//document/r' ||cont||'/k_numcargos/text()', dataxml))[1]::text,'0')::text;
		
			cant_rest_docant := coalesce((xpath('//document/r' ||cont||'/k_cantrestdocant/text()', dataxml))[1]::text,'0')::text;
			fecha_part := coalesce((xpath('//document/r' ||cont||'/k_fechapart/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
			monto_costo := coalesce((xpath('//document/r' ||cont||'/k_montocosto/text()', dataxml))[1]::text,'0')::text;
			exist_prev_unid := coalesce((xpath('//document/r' ||cont||'/k_existprevunid/text()', dataxml))[1]::text,'0')::text;
			exist_prev_pesos := coalesce((xpath('//document/r' ||cont||'/k_existprevpesos/text()', dataxml))[1]::text,'0')::text;
		
			costo_moneda := coalesce((xpath('//document/r' ||cont||'/k_costomoneda/text()', dataxml))[1]::text,'0')::text;
			venta_moneda := coalesce((xpath('//document/r' ||cont||'/k_venta/text()', dataxml))[1]::text,'0')::text;
			concepto := coalesce((xpath('//document/r' ||cont||'/k_concepto/text()', dataxml))[1]::text,'')::text;	
	
			insert into keplersc.kdm2 (
				c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19,c20,
				c21,c22,c23,c24,c25,
				c26,c27,c28,c29,c30,			
				c31,c32,c33,c34,c35,
				c36,c37,c38,c39,c40)
			values(sucursal_id,genero,naturaleza,grupo::integer,tipo_clave::integer,
				folio_operacion,numero_partida,clave_producto,cantidad_unidades::decimal,descripcion_producto,
				unidad,precio_unitario::decimal,importe_partida::decimal,porc_desc1::decimal,porc_desc2::decimal,
				porc_desc3::decimal,porc_iva,porc_ieps::decimal,naturaleza_docant,grupo_docant::integer,
				tipo_docant::integer,folio_docant,partida_docant::integer,saldo_unid_part::decimal,cve_cliente,
				costo_venta_partida::decimal,codigo_requisicion,clave_original,cve_almacen::integer,num_cargos::integer,			
				cant_rest_docant::decimal,to_date(fecha_part,'YYYY-MM-DD'),monto_costo::decimal,exist_prev_unid::decimal,exist_prev_pesos::decimal,
				moneda,costo_moneda::decimal,venta_moneda::decimal,orden_trabajo,concepto);
			
		end if; --if deccantidad_partida > 0 
		
	end loop ;	
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'mov_sec_alta() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
