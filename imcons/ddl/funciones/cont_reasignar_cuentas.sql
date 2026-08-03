CREATE OR REPLACE FUNCTION keplersc.cont_reasignar_cuentas(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Modifica las polizas que contienen una cuenta origen para pasarlas a una destino
--llamado base:
--select * from keplersc.cont_reasignar_cuentas(
--'<document><k_sucn></k_sucn><k_anio></k_anio><k_mes></k_mes><cuenta_origen></cuenta_origen><cuenta_destino></cuenta_destino>
--<movimiento><usuario></usuario></movimiento></document>');
--Autor: Victor Salgado
--Fecha: 13/05/2025
--Bitacora de cambios

declare
	k_sucn text = '';
	k_anio text = '';
	k_mes text = '';
	cuenta_origen text = '';
	cuenta_destino text= '';
	usuario_movto text = '';
	fecha_movto text = '';
	hora_movto text = '';
	tabla_cuentas text = '';
	tabla_polizas text = '';
	expsql text ='';
	totReg int = 0;
	xmlUsr xml ='';

	strValor text;
	intValor int = 0;
	comilla text = '''';
	resultado text = '';
	mensaje text = '';
    adicionales text = '';
   	get_resultado text = '';
	get_mensaje text = '';
    get_adicionales text = '';

begin 
	k_sucn := coalesce((xpath('//document/k_sucn/text()', dataxml))[1]::text,'')::text; 
	k_anio := coalesce((xpath('//document/k_anio/text()', dataxml))[1]::text,'')::text;
 	k_mes := coalesce((xpath('//document/k_mes/text()', dataxml))[1]::text,'')::text; 
	cuenta_origen := coalesce((xpath('//document/cuenta_origen/text()', dataxml))[1]::text,'')::text; 
	cuenta_destino := coalesce((xpath('//document/cuenta_destino/text()', dataxml))[1]::text,'')::text; 
	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
---raise notice 'ref_original:%; ,ref_a_reemp:%; ,ref_reemp:%; ',ref_original,ref_a_reemp,ref_reemp;

	--Validar que se tengan los datos necesarios
	if k_sucn='' then
		raise exception 'No se ha proporcionado la sucursal.';
	end if;
	if k_anio='' then
		raise exception 'No se ha proporcionado el anio.';
	end if;
	if k_mes='' then
		raise exception 'No se ha proporcionado el mes.';
	end if;
	if cuenta_origen='' then
		raise exception 'No se ha proporcionado la cuenta origen.';
	end if;
	if cuenta_destino='' then
		raise exception 'No se ha proporcionado la cuenta destino.';
	end if;

	--Validar que el mes y anio este abierto
	intValor:=k_mes::int;
	intValor:=intValor + 9;
	expsql:=concat('select c',intValor::text,' from keplersc.kdym where c1=',comilla,k_anio,comilla);
	execute expSql into strValor;

	if strValor = 'C' then
		raise exception 'El mes está cerrado.';
	end if;

	tabla_cuentas := 'keplersc.kdc1' || right(k_anio,2);

	--Validar que la cuenta de origen existe y es de menor nivel
	expSql := format('select count(*) from %1$s where c1=%2$L',tabla_cuentas,cuenta_origen);	
	execute expSql into intValor;
	if intValor = 0 then
		raise exception 'La cuenta origen % no existe.',cuenta_origen;
	end if;

	expSql = format('select count(*) from %1$s where position( %2$L in c1) > 0 and substring(c1,1,length(%2$L)) = %2$L 	and c1<>%2$L',tabla_cuentas,cuenta_origen);
	execute expSql into intValor;
	if intValor > 0 then --
		raise exception '%', concat('La cuenta origen ', cuenta_origen, ', no es de ultimo nivel.');
	end if ;


	--Validar que la cuenta destino existe y es de menor nivel.	
	expSql := format('select count(*) from %1$s where c1=%2$L',tabla_cuentas,cuenta_destino);	
	execute expSql into intValor;
	if intValor = 0 then
		raise exception 'La cuenta destino % no existe.',cuenta_destino;
	end if;

	expSql = format('select count(*) from %1$s where position( %2$L in c1) > 0 and substring(c1,1,length(%2$L)) = %2$L 	and c1<>%2$L',tabla_cuentas,cuenta_destino);
	execute expSql into intValor;
	if intValor > 0 then --
		raise exception '%', concat('La cuenta destino ', cuenta_destino, ', no es de ultimo nivel.');
	end if ;

	--Mover las cuentas del origen al destino
	tabla_polizas = concat('keplersc.kdc2',right(k_anio,2),k_mes);
	expSql:=concat('update ',tabla_polizas, ' set c3=' ,comilla,cuenta_destino,comilla,' where c3=',comilla,cuenta_origen,comilla);
	execute expSql;
	get diagnostics intValor = row_count;

	--Regitrar en bitacora	
	fecha_movto:=now();
	fecha_movto=substring(fecha_movto,1,19);
	hora_movto:=right(fecha_movto,8);
--raise exception 'fecha_movto %, hora_movto %',fecha_movto,hora_movto;
	select xmlforest(usuario_movto as usuario, fecha_movto as fecha, hora_movto as hora, 
	k_sucn as sucursal, ' ' as genero, ' ' as naturaleza, 0 as grupo, 0 as tipo, 'CONT' as folio,
	'REASIGCTA' as tipo_movto,expSql || ' (' || intValor::text || ')' as detalle_movto) :: text into strValor;
	select '<document>'||strValor||'</document>' into strValor;
	
	xmlUsr := strValor::xml;

	select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);
	--raise notice '%',sucursal_id;	
	if get_resultado = '0' then
		raise exception '%',get_mensaje;
	end if;	


	resultado := 1;
	mensaje := intValor::text  || ' cuentas reasignadas';
	adicionales := '';
	return query select resultado, mensaje, adicionales;
exception
	when others then
		resultado := 0;
		mensaje := 'cont_reasignar_cuentas() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
