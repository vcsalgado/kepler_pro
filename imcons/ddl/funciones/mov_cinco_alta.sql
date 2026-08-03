CREATE OR REPLACE FUNCTION keplersc.mov_cinco_alta(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserción de documentos a Saldar por documento en KDM5
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
	naturaleza_movto text;
	grupo_movto text;
	tipo_movto text;
	folio_movto text;	--Partida o folio documento
	monto_cargo text;	--Monto
	monto_abono text;	--IVA
	referencia text;	--factura
	vencimiento text;	--fecha vencimiento
	sin_descrip_c16 text = '';
	sin_descrip_c17 text = '';

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
	--Procesar detalle de partidas a KDM5 (ALTA_DOC_SEC)
	--TO DO: Revisar si sólo debe insertar si trae monto en la partida como en MOV_SEC_ALTA
	for cont in 0..no_partidas - 1 loop
		numero_partida := cont + 1;
	
		naturaleza_movto := coalesce((xpath('//document/kmov/r' ||cont||'/k_natmovto/text()',dataxml))[1]::text,'')::text;
		grupo_movto := coalesce((xpath('//document/kmov/r' ||cont||'/k_gpomovto/text()',dataxml))[1]::text,'0')::text;
		tipo_movto := coalesce((xpath('//document/kmov/r' ||cont||'/k_tipomovto/text()',dataxml))[1]::text,'0')::text;
		folio_movto := coalesce((xpath('//document/kmov/r' ||cont||'/k_foliomovto/text()',dataxml))[1]::text,'1')::text;
		monto_cargo := coalesce((xpath('//document/kmov/r' ||cont||'/k_monto/text()',dataxml))[1]::text,'0')::text;
		monto_abono := coalesce((xpath('//document/kmov/r' ||cont||'/k_ivamovto/text()',dataxml))[1]::text,'0')::text;
		referencia := coalesce((xpath('//document/kmov/r' ||cont||'/k_refermovto/text()',dataxml))[1]::text,'')::text;
		vencimiento := coalesce((xpath('//document/r' ||cont||'/k_fechavto/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
		sin_descrip_c16 := coalesce((xpath('//document/kmov/r' ||cont||'/k_sindesc16/text()',dataxml))[1]::text,'0')::text;
		sin_descrip_c17 := coalesce((xpath('//document/kmov/r' ||cont||'/k_sindesc17/text()',dataxml))[1]::text,'0')::text;
	
		insert into keplersc.kdm5 (
			c1,c2,c3,c4,c5,
			c6,c7,c8,c9,c10,
			c11,c12,c13,c14,c15,
			c16,c17)
		values(sucursal_id,genero,naturaleza,grupo::integer,tipo_clave::integer,
			folio_operacion,numero_partida,naturaleza_movto,grupo_movto::integer,tipo_movto::integer,
			partida_doc,monto_cargo::decimal,monto_abono::decimal,referencia,to_date(vencimiento,'YYYY-MM-DD'),
			sin_descrip_c16::integer,sin_descrip_c17::decimal);
	end loop ;	
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'mov_cinco_alta() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	

end;
$function$
