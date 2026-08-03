CREATE OR REPLACE FUNCTION keplersc.ser_afectacionconta_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Realiza actualización de de cuentas contables de taller y servicio KDTALLCONT
--Autor: Miriam Santana
--Fecha: 06/Feb/23
--Bitacora de cambios

	--Variables de definicion de documento
	sucursal_id text;
	anio text;
	vtasmo text;
	vtasrefacc text;
	vtastots text;
	vtasvarios text;
	costomo text;
	costorefacc text;
	costotots text;
	costovarios text;
	ptemo text;
	invrefacc text;
	ptetots text;
	ptevarios text;
	
	tipo text;
	no_partidas int = 0;
	
	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	anio := (xpath('//document/k_anio/text()',dataxml))[1];

	strValor:=coalesce((xpath('//document/k_partidas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;

	if anio is null then
		raise exception 'Falta especificar el año';
	end if;
	
	--Actualizar registros
	for cont in 0..no_partidas-1 loop
		tipo:= (xpath('//document/k_mov/r' ||cont||'/k_tipo/text()',dataxml))[1];
	
		vtasmo := (xpath('//document/k_mov/r' ||cont||'/k_vtasmo/text()',dataxml))[1];
		vtasrefacc:= (xpath('//document/k_mov/r' ||cont||'/k_vtasrefacc/text()',dataxml))[1];
		vtastots:= (xpath('//document/k_mov/r' ||cont||'/k_vtastots/text()',dataxml))[1];
		vtasvarios:= (xpath('//document/k_mov/r' ||cont||'/k_vtasvarios/text()',dataxml))[1];
		costomo:= (xpath('//document/k_mov/r' ||cont||'/k_costomo/text()',dataxml))[1];
		costorefacc:= (xpath('//document/k_mov/r' ||cont||'/k_costorefacc/text()',dataxml))[1];
		costotots:= (xpath('//document/k_mov/r' ||cont||'/k_costotots/text()',dataxml))[1];
		costovarios:= (xpath('//document/k_mov/r' ||cont||'/k_costovarios/text()',dataxml))[1];
		ptemo:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_ptemo/text()',dataxml))[1],'');
		invrefacc:= (xpath('//document/k_mov/r' ||cont||'/k_invrefacc/text()',dataxml))[1];
		ptetots:= (xpath('//document/k_mov/r' ||cont||'/k_ptetots/text()',dataxml))[1];
		ptevarios:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_ptevarios/text()',dataxml))[1],'');
			
		if tipo <> 'L' then
			if vtasmo is null then
				raise exception 'Falta especificar la cuenta Ventas M.O. del tipo "%"',tipo;
			end if;
			if vtasrefacc is null then
				raise exception 'Falta especificar la cuenta Ventas Refacciones del tipo "%"',tipo;
			end if;
			if vtastots is null then
				raise exception 'Falta especificar la cuenta Ventas TOTs del tipo "%"',tipo;
			end if; 
			if vtasvarios is null then
				raise exception 'Falta especificar la cuenta Ventas Varios del tipo "%"',tipo;
			end if;
			if costomo is null then
				raise exception 'Falta especificar la cuenta Costo M.O. del tipo "%"',tipo;
			end if; 
			if costorefacc is null then
				raise exception 'Falta especificar la cuenta Costo Refacciones del tipo "%"',tipo;
			end if;
			if costotots is null then
				raise exception 'Falta especificar la cuenta Costo TOTs del tipo "%"',tipo;
			end if; 
			if costovarios is null then
				raise exception 'Falta especificar la cuenta Costo Varios del tipo "%"',tipo;
			end if;
			if invrefacc is null then
				raise exception 'Falta especificar la cuenta Inventario Refacciones del tipo "%"',tipo;
			end if;
			if ptetots is null then
				raise exception 'Falta especificar la cuenta Puente TOTs del tipo "%"',tipo;
			end if;
		else 
			if costomo is null then
				raise exception 'Falta especificar la cuenta Costo M.O. del tipo "%"',tipo;
			else
				vtasmo := coalesce((xpath('//document/k_mov/r' ||cont||'/k_vtasmo/text()',dataxml))[1],'');
				vtasrefacc:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_vtasrefacc/text()',dataxml))[1],'');
				vtastots:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_vtastots/text()',dataxml))[1],'');
				vtasvarios:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_vtasvarios/text()',dataxml))[1],'');
				costorefacc:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_costorefacc/text()',dataxml))[1],'');
				costotots:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_costotots/text()',dataxml))[1],'');
				costovarios:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_costovarios/text()',dataxml))[1],'');
				ptemo:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_ptemo/text()',dataxml))[1],'');
				invrefacc:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_invrefacc/text()',dataxml))[1],'');
				ptetots:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_ptetots/text()',dataxml))[1],'');
				ptevarios:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_ptevarios/text()',dataxml))[1],'');
			end if; 
		end if;
	
		if tipo is not null or tipo <> '' then	
			update keplersc.kdtallcont set
				c5=vtasmo,
				c6=vtasrefacc,
				c7=vtastots,
				c8=vtasvarios,
				c10=costomo,
				c11=costorefacc,
				c12=costotots,
				c13=costovarios,
				c15=ptemo,
				c16=invrefacc,
				c17=ptetots,
				c18=ptevarios
			where c1=tipo and c2=sucursal_id and c3=anio;
		end if;
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_afectacioncontaser_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
