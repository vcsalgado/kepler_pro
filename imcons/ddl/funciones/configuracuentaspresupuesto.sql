CREATE OR REPLACE FUNCTION keplersc.configuracuentaspresupuesto(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza registro de las cuentas de presupuesto
--Autor: Miriam Santana
--Fecha: 22/07/2025
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';	--col_sucursal
	stranio text='';
	selreg text ='';
	cuenta text ='';

	--Variables Loop
	no_partidas int;
	numero_partida int;
	
	--Variables de uso general
	strValor text;	
	nombre_tabla text;
	sqlExp text;
	
    --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
   		
begin 
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	stranio := (xpath('//document/k_anio/r0/text()', dataxml))[1];
	
	--Partidas
	strValor := (xpath('//document/results/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	
		
	--Procesar detalle
	for cont in 0..no_partidas - 1 loop
		--Tipo de documento
		selreg := (xpath('//document/results/r' ||cont||'/sel/text()',dataxml))[1];
		cuenta := (xpath('//document/results/r' ||cont||'/cuenta/text()',dataxml))[1];
		
		if selreg = 'S' then
			nombre_tabla = concat('keplersc.kdc1',stranio); 
			sqlExp=format('update %1$s set c99=%2$L where c1=%3$L',nombre_tabla,selreg,cuenta);
			execute sqlExp;			
		end if;
	end loop ;	
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'configuracuentaspresupuesto() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
