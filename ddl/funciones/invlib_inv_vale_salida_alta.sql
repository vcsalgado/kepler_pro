CREATE OR REPLACE FUNCTION keplersc.invlib_inv_vale_salida_alta(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 

	--Debe ser llamada con los parametros dataXml y xmlKDMM)	
	--Autor: Saltiel Cruz
	--Fecha: 03 NOV 2022
	--Actualizacion, el Folio_operacion estaba reemplazandose con cero. 23/Dic/2022	
	--Variables para xml
	v_sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;
	v_inventario text ='';
	v_fecha_movto text='';
	
	--xml Movimiento
	xmlKDM1 xml;
	xmlKDM1_c3 text = '';	
	v_vendedor text = '';
	v_coach text = '';
	v_status numeric = 0;
	v_accesorios numeric =0;
	v_garantia_extendida numeric =0;
	v_extras1 numeric =0;
	v_extras2 numeric =0;
	v_extras3 numeric =0;
	v_suma_accesorios numeric = 0;
	v_suma_pedidos numeric = 0;
	v_clave_de_operacion text = '';
	v_clave_vehiculo text = '';
	v_fecha_factura text = '';
	v_tipoauto text = '';
	v_descuento numeric = 0;
	v_gastos_administrativos numeric = 0;
	v_seguro_del_automovil numeric = 0;
	v_ISAN numeric = 0;
	v_IVA numeric = 0;
	v_Importe numeric = 0;
	v_costo numeric = 0;
	v_fecha_compra text='';
	v_anio_modelo text ='';
	v_asesor_comprador text ='';
	v_valuador text ='';
	v_asesor_cc text ='';
--Variables de uso general	
	mensajeError text;		
	--folio_operacion text;
	xmlResultado xml;
	totReg int = 0;
	v_folio text = ''; 
			
	--Variables de retorno desde funciones externas
	get_resultado text; --retorno
	get_mensaje text; --retorno
	get_adicionales text; --retorno
	

begin
	-- Inicializacion de variables
	--folio_operacion := 0;
	get_resultado := '';
	get_adicionales := '';

	--Documento
	v_sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r5/text()', dataxml))[1];	
	v_inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text);
	v_vendedor := coalesce((xpath('//document/k_vendedor/text()', dataxml))[1]::text,'')::text;
	v_coach := upper((xpath('//document/k_coach/r2/text()', dataxml))[1]::text);
    v_tipoauto:= upper((xpath('//document/k_tipoauto/text()', dataxml))[1]::text);
    v_asesor_cc:= upper((xpath('//document/k_asesor_cc/text()', dataxml))[1]::text);
   	v_fecha_movto:= upper((xpath('//document/k_fecha/text()', dataxml))[1]::text);
   

   --Validar que no se tenga un vale activo
   
   	--LGLG 13/06/24 codigo obsoleto
	/*select count(folio) into totReg from 
	(select folio, sum(alta) as alta, sum(baja) as baja from
	(select c6 as folio, 1 alta, 0 as baja  from keplersc.kdcomismov where c8=v_inventario and c10='0'
	union 
	select c6 as folio, 0 alta, 1 as baja  from keplersc.kdcomismov where c8=v_inventario and c10='1') as movtos
	group by folio) as resumen
	where alta=1 and baja = 0;*/

   	--LGLG 13/06/24 correccion query
	select count(inv) into totReg from 
	(select inv, sum(alta) as alta, sum(baja) as baja from
	(select c6 as folio, c8 as inv, 1 alta, 0 as baja  from keplersc.kdcomismov where c8=v_inventario and c10='0'
	union 
	select c6 as folio, c8 as inv, 0 alta, 1 as baja  from keplersc.kdcomismov where c8=v_inventario and c10='1') as movtos
	group by inv) as resumen
	where alta > baja;

	if totReg>0 then	
	
		--LGLG 13/06/24 codigo obsoleto
		/*select folio into v_folio from 
		(select folio, sum(alta) as alta, sum(baja) as baja from
		(select c6 as folio, 1 alta, 0 as baja  from keplersc.kdcomismov where c8=v_inventario and c10='0'
		union 
		select c6 as folio, 0 alta, 1 as baja  from keplersc.kdcomismov where c8=v_inventario and c10='1') as movtos
		group by folio) as resumen
		where alta=1 and baja = 0 limit 1;
		raise exception 'Ya se tiene un vale de salida para el inventario:%; el folio es:%',v_inventario,v_folio;*/
	
		--LGLG 13/06/24 encuentra ultimo vale 
		select c6 into v_folio from keplersc.kdcomismov where c1=v_sucursal_id 
		and c8=v_inventario and c10='0' order by c6 desc limit 1;
		raise exception 'Ya se tiene un vale de salida para el inventario:%; el folio es:%',v_inventario,v_folio;
	
	end if;

	--raise notice 'terminado';
	if (select count(*) from keplersc.kdpedido where c1 = v_sucursal_id and c2 = v_inventario) > 0 and 
		(select count(*) from keplersc.KDINF where c1 = v_sucursal_id and c2 = v_inventario) > 0 and 
		(select count(*) from keplersc.KDVENTAS where c1 = v_sucursal_id and c2 = v_inventario) > 0  then
				v_suma_accesorios = 0;
		select c19,c43,c44,c45,c11,c30,c17,c20,c12,c13,c14 into v_garantia_extendida, v_extras1,v_extras2,v_extras3,v_clave_de_operacion,v_descuento,v_gastos_administrativos,v_seguro_del_automovil,v_ISAN,v_IVA,v_Importe from keplersc.kdpedido where c1 = v_sucursal_id and c2 = v_inventario;
		v_suma_pedidos = v_garantia_extendida + v_extras1 + v_extras2 + v_extras3;
		select c3 into v_clave_vehiculo from keplersc.KDINF where c1 = v_sucursal_id and c2 = v_inventario;
		select c9,c29,c30,c20 into v_fecha_factura,v_costo,v_fecha_compra,v_anio_modelo from keplersc.KDVENTAS where c1 = v_sucursal_id and c2 = v_inventario;
		for v_status,v_accesorios in select c10,c25 from keplersc.KDIPVA where c1 = v_sucursal_id and c2 = v_inventario
			loop
				if v_status = 0 then
					v_suma_accesorios = v_suma_accesorios  + v_accesorios;
				else
					v_suma_accesorios = v_suma_accesorios  - v_accesorios;
				end if;					
		end loop; --end loop 1
			 
		update keplersc.KDVENTAS 
		set c16 = v_vendedor,
			c13 = v_coach
		where c1 = v_sucursal_id and c2 = v_inventario;	
	
		insert into keplersc.KDCOMISMOV (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26)
		values (v_sucursal_id,genero,naturaleza,grupo::numeric,tipo::numeric,
					folio_operacion,v_fecha_movto::timestamp,v_inventario,v_vendedor,0,
					v_clave_de_operacion,v_clave_vehiculo,v_fecha_factura::timestamp,v_tipoauto,v_descuento,
					v_gastos_administrativos,v_seguro_del_automovil,v_suma_accesorios,v_suma_pedidos,v_ISAN,
					v_IVA, v_Importe,v_costo,v_fecha_compra::timestamp,v_anio_modelo,
					v_coach);
		select c41 , c42 into v_asesor_comprador,v_valuador from keplersc.KDICOM where  c1 = v_sucursal_id and c2 = v_inventario and c3 = (select count(*) from keplersc.KDICOM  where  c1 = v_sucursal_id and c2 = v_inventario);
		
		--LGLG 21/12/24, agregar coalesce
		insert into keplersc.KDCOMISMOV2 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c15,c16)
		values (v_sucursal_id,genero,naturaleza,grupo::numeric,tipo::numeric,
				folio_operacion,v_fecha_movto::timestamp,v_inventario,v_asesor_cc,0,
				v_clave_de_operacion, coalesce(v_asesor_comprador, '')::text ,coalesce(v_valuador, '')::text ,v_vendedor,'');
			
	end if;
	
	--paso:= 'docdis.invlib_INV_VALE_SALIDA_ADIS_ALTA';
	select * into resultado, mensaje, adicionales from keplersc.invlib_inv_vale_salida_adis_alta(dataxml,xmlkdmm,folio_operacion);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;	
  	--raise notice 'fin en invlib_inv_vale_salida_adis_alta';

	select * into resultado, mensaje, adicionales from keplersc.invlib_inv_status(dataxml,xmlkdmm);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;	
	--raise notice 'fin en invlib_inv_status';
	get_resultado:=1;
	get_mensaje:=folio_operacion;
	return query select get_resultado, get_mensaje, get_adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'invlib_inv_vale_salida_alta() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		raise notice 'err sqlState %',mensaje ;
		return query select resultado, mensaje, adicionales;	
end;
$function$
