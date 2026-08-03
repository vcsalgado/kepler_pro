CREATE OR REPLACE FUNCTION keplersc.mov_seis_alta(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserción de Cuentas contables por documento en KDM6
--Autor: Miriam Santana
--Fecha: 25/07/2022
	declare	
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_clave text;

	--Varables de partidas 
	no_partidas int;
	numero_partida int;
	cuenta_cont text;	--cuenta contable
	descripcion text;	--descripcion cuenta
	tipo_ca text;		--C:Cargo A:Abono
	monto text;			
	cve_concepto text;	
	cve_proyecto text;	
	sub_cuenta text;	--Subcuenta contable
	referencia text;	--factura
	departamento text;
	monto_iva text;		--Monto de IVA
	monto_civa text;	--Monto incluyendo IVA

	--Variables de uso general 
	strValor text;
 
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin	
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	--Tipo de documento
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	
	--Procesar detalle de partidas a KDM6 (ALTA_CONT_SEC)
	--TO DO: Revisar si sólo debe insertar si trae monto en la partida como en MOV_SEC_ALTA
	for cont in 0..no_partidas - 1 loop
		numero_partida := cont + 1;
	
		cuenta_cont := coalesce((xpath('//document/kmov/r' ||cont||'/k_cuentacont/text()',dataxml))[1]::text,'')::text;
		descripcion := coalesce((xpath('//document/kmov/r' ||cont||'/k_descripcta/text()',dataxml))[1]::text,'')::text;
		tipo_ca := coalesce((xpath('//document/kmov/r' ||cont||'/k_tipoca/text()',dataxml))[1]::text,'')::text;
		
		monto := coalesce((xpath('//document/kmov/r' ||cont||'/k_monto/text()',dataxml))[1]::text,'0')::text;		
		cve_concepto := coalesce((xpath('//document/kmov/r' ||cont||'/k_concepto/text()',dataxml))[1]::text,'')::text;
		cve_proyecto := coalesce((xpath('//document/kmov/r' ||cont||'/k_proyectomovto/text()',dataxml))[1]::text,'')::text;
		sub_cuenta := coalesce((xpath('//document/kmov/r' ||cont||'/k_subcuenta/text()',dataxml))[1]::text,'')::text;
		referencia := coalesce((xpath('//document/kmov/r' ||cont||'/k_refermovto/text()',dataxml))[1]::text,'')::text;
		
		departamento := coalesce((xpath('//document/kmov/r' ||cont||'/k_deptomovto/text()',dataxml))[1]::text,'')::text;
		monto_iva := coalesce((xpath('//document/kmov/r' ||cont||'/k_ivamovto/text()',dataxml))[1]::text,'0.00')::text;
		monto_civa := coalesce((xpath('//document/kmov/r' ||cont||'/k_montociva/text()',dataxml))[1]::text,'0.00')::text;
		
		insert into keplersc.kdm5 (
			c1,c2,c3,c4,c5,
			c6,c7,c8,c9,c10,
			c11,c12,c13,c14,c15,
			c16,c17,c18)
		values(sucursal_id,genero,naturaleza,grupo::integer,tipo_clave::integer,
			folio_operacion,numero_partida,cuenta_cont,descripcion,tipo_ca,
			monto::decimal,cve_concepto,cve_proyecto,sub_cuenta,referencia,
			departamento,iva::decimal,monto_civa::decimal);
	end loop ;	
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'mov_seis_alta() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	

end;
$function$
