CREATE OR REPLACE FUNCTION keplersc.invlib_factura_pva(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Autor: Luis Leal 24/01/2023
	
	sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo_clave text = '';
	fecha_operacion text = '';
	inventario text ='';
	clave_cli text ='';
	iva numeric;
	importe numeric;
	gastos_administrativos numeric;
	accesorios numeric;
	garantia_extendida numeric;
	partida int;
	ult_partida int;
	estatus int;

	--kdinf--
	clave_vehiculo text; 
	anio text;
	marca text;
	tipo_auto text; 

	--kdpedido--
	clave_vendedor text;
	clave_operacion text;

	--kduv--
	empresa text;

	--kdiv--
	linea text;

	resultado text;
	mensaje text;
	adicionales text;
begin
	--Resuelve INV_FACTURA_PVA
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text);	
	clave_cli := coalesce((xpath('//document/k_clave/text()', dataxml))[1]::text,'0')::text;
	iva := coalesce((xpath('//document/k_iva/text()',dataxml))[1]::text,'0')::text;
	importe := coalesce((xpath('//document/k_monto/text()',dataxml))[1]::text,'0')::text;
	gastos_administrativos := coalesce((xpath('//document/k_montoext1/text()',dataxml))[1]::text,'0')::text;
	accesorios := coalesce((xpath('//document/k_montoext2/text()',dataxml))[1]::text,'0')::text;
	garantia_extendida := coalesce((xpath('//document/k_montoext3/text()',dataxml))[1]::text,'0')::text;

	if genero = 'U' then 
	
		partida = 1;
		select c3 into ult_partida from keplersc.kdipva where c1=sucursal_id and c2=inventario order by c3 desc limit 1;
		if found then
			partida := ult_partida + 1;
		end if;
	
		if naturaleza =  'D' then 	--FACTURA PVA
			estatus := 0;
			update keplersc.kdpedido set c17=gastos_administrativos, c18=accesorios, 
			c19=garantia_extendida where c1=sucursal_id and c2=inventario;
		else 						--NOTA DE CREDITO, ANULACION PVA
			estatus := 10;
			update keplersc.kdpedido set c17=0, c18=0, c19=0 where c1=sucursal_id and c2=inventario;
		end if;
	
		select c3,c15,c17,c21 into clave_vehiculo,anio,marca,tipo_auto from keplersc.kdinf where c1=sucursal_id and c2=inventario;
		if found then
					
			select c10,c11 into clave_vendedor,clave_operacion from keplersc.kdpedido where c1=sucursal_id and c2=inventario;
			if found then
			
				select c4 into empresa from keplersc.kduv where c1=sucursal_id and c2=clave_vendedor;
				if empresa is null then
					empresa :=  '';
				end if;
				select c7 into linea from keplersc.kdiv where c1=clave_vehiculo;
				if linea is null then
					linea :=  '';
				end if;
						
				insert into keplersc.kdipva(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c14,c15,c16,c17,c18,c19,c20,c21,c24,c25,c26,c29,c30,c32) 
				values(sucursal_id, inventario,partida,genero, naturaleza,grupo::numeric, tipo_clave::numeric, folio_operacion, 
				fecha_operacion::date, estatus,clave_cli, clave_vehiculo,empresa,clave_vendedor, clave_operacion,marca,tipo_auto,
				anio,linea ,gastos_administrativos, accesorios, garantia_extendida, iva, importe,10);
			
			end if;
		
		end if;

		--call invlib_inv_status(:dataxml, :xmlkdmm) 			
		select * into resultado, mensaje, adicionales from keplersc.invlib_inv_status(dataxml,xmlkdmm);
		
	end if;
		
	

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'invlib_factura_pva() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
