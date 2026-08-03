CREATE OR REPLACE FUNCTION keplersc.cat_crud_movimientos_copiar(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	gen_or text = '';	
	nat_or text = '';
	gpo_or text = '';
	tipo_or text = '';
	desc_or text = '';

	gen_new text = '';	
	nat_new text = '';
	gpo_new text = '';
	tipo_new text = '';
	desc_new text = '';

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	totReg int = 0;

	--Grabar en bitacora
	usuario_movto text;
	operacion_desc text = '';
	detalle_movto text = '';
	xmlUsr xml;	


	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	sucursal_id = (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	gen_or := coalesce((xpath('//document/k_gen_or/text()',dataxml))[1]::text,'')::text;
	nat_or := coalesce((xpath('//document/k_nat_or/text()',dataxml))[1]::text,'')::text;
	gpo_or := coalesce((xpath('//document/k_gpo_or/text()',dataxml))[1]::text,'0')::text;
	tipo_or := coalesce((xpath('//document/k_tipo_or/text()',dataxml))[1]::text,'0')::text;
	desc_or := coalesce((xpath('//document/k_desc_or/text()',dataxml))[1]::text,'')::text;

	gen_new := coalesce((xpath('//document/k_gen_new/text()',dataxml))[1]::text,'')::text;
	nat_new := coalesce((xpath('//document/k_nat_new/text()',dataxml))[1]::text,'')::text;
	gpo_new := coalesce((xpath('//document/k_gpo_new/text()',dataxml))[1]::text,'0')::text;
	tipo_new := coalesce((xpath('//document/k_tipo_new/text()',dataxml))[1]::text,'0')::text;
	desc_new := coalesce((xpath('//document/k_desc_new/text()',dataxml))[1]::text,'')::text;

	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];

	--Validar que el movimiento origen existe

	select count(*) into totReg from keplersc.kdmm where col_sucursal = sucursal_id and c1=gen_or and c2=nat_or and c3=gpo_or::numeric and c4=tipo_or::numeric;
	if totReg=0 then
		raise exception 'No se encontró el movimiento origen.';
	end if;

	select count(*) into totReg from keplersc.kdmm where col_sucursal = sucursal_id and c1=gen_new and c2=nat_new and c3=gpo_new::numeric and c4=tipo_new::numeric;
	if totReg>0 then
		raise exception 'El movimiento destino ya existe.';
	end if;

	drop table if exists tmpkdmm;
	create temp table tmpkdmm as select * from keplersc.kdmm with no data;   

	insert into tmpkdmm select * from keplersc.kdmm where col_sucursal = sucursal_id and c1=gen_or and c2=nat_or and c3=gpo_or::numeric and c4=tipo_or::numeric;
--select count(*) into totReg from tmpkdmm;
--raise exception 'totReg %', totReg;
	update tmpkdmm set c1=gen_new, c2=nat_new, c3=gpo_new::numeric, c4=tipo_new::numeric, c5=desc_new;
--	select concat(col_sucursal, '-',  c1, '-', c2, '-',  c3::text, '-',  c4::text, '-', c5) into strValor 
--		from tmpkdmm where col_sucursal = sucursal_id and c1=gen_new and c2=nat_new and c3=gpo_new::numeric and c4=tipo_new::numeric and c5=desc_new;
--	commit;
--raise exception 'sucursal_id %, gen_or %, nat_or %, gpo_or %, tipo_or %',sucursal_id, gen_new, nat_new, gpo_new, tipo_new;
--raise exception 'Valores %',strValor;
	insert into keplersc.kdmm select * from tmpkdmm where col_sucursal = sucursal_id and c1=gen_new and c2=nat_new and c3=gpo_new::numeric and c4=tipo_new::numeric;

	--Registro de movimiento en bitacora
	operacion_desc := 'COPIAR';
	detalle_movto := operacion_desc || ' MOVTO ORIGEN ' || gen_or || ' ' || nat_or || ' ' || gpo_or || ' ' || tipo_or || ' ' || desc_or;
	select xmlforest(usuario_movto as usuario, current_date as fecha, TO_CHAR(NOW(), 'HH24:MI:SS') as hora,
				sucursal_id as sucursal, gen_new as genero, nat_new as naturaleza, gpo_new as grupo, tipo_new as tipo, 'KDMM' as folio,
				operacion_desc as tipo_movto, detalle_movto as detalle_movto) :: text into strValor;					
		
	select '<document>'||strValor||'</document>' into strValor;
	xmlUsr := strValor::xml;
		
	select * into resultado, mensaje, adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);
	--raise notice '%',sucursal_id;	
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;	

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'base_function() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
