CREATE OR REPLACE FUNCTION keplersc.ven_consanulacion_aplicacion_anticipos(dataxml xml, folio_operacion text)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$

--Descripcion: Obtiene xml con informacion de anticipos aplicados o anulados registrados en KDUSRACESS
--Autor: Miriam Santana
--Fecha: 25/03/2025
 declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
 	arrAnticipos text[];
 
 	gen_anticipo text;
 	nat_anticipo text;
	gpo_anticipo text;
	tipo_anticipo text;
	folio_anticipo text;

	expSql text = '';

	--Variables de retorno
	xmlResultado xml;

begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	
	drop table if exists tmpAnticipos;
	create temp table tmpAnticipos (
		gen_anticipo text,
		nat_anticipo text,
		gpo_anticipo text,
		tpo_anticipo text,
		k_factura text,
		k_vencimiento_factura text,
		k_monto_factura  numeric(15,2),
		k_iva_factura  numeric(15,2),
		referencia text,
		estatus text,
		cmnts_anticipo text);
 
 	select string_to_array(c11,'|') into arrAnticipos from keplersc.kdusraccess where c4=sucursal_id and c5=genero and c6=naturaleza and c7=grupo::integer and c8=tipo::integer and c9=folio_operacion; 
raise notice '%',arrAnticipos;
	 --UD7901VAF0004828 | UD7901VAF0004827 |
	for i in array_lower(arrAnticipos,1) .. array_upper(arrAnticipos,1) loop
		gen_anticipo := substring(trim(arrAnticipos[i]),1,1);
		nat_anticipo := substring(trim(arrAnticipos[i]),2,1);
		gpo_anticipo := substring(trim(arrAnticipos[i]),3,2);
		tipo_anticipo := substring(trim(arrAnticipos[i]),5,2);
		folio_anticipo := substring(trim(arrAnticipos[i]),7,10);
raise notice 'g:%,n:%,g:%,t:%,f:%',gen_anticipo,nat_anticipo,gpo_anticipo,tipo_anticipo,folio_anticipo;	
		if length(folio_anticipo) > 0 then
			expSql := format('insert into tmpAnticipos(gen_anticipo, nat_anticipo, gpo_anticipo, tpo_anticipo, k_factura, k_vencimiento_factura, k_monto_factura, k_iva_factura, referencia, estatus, cmnts_anticipo)
							select dm1.c2,dm1.c3,dm1.c4,dm1.c5,dm1.c6,dm1.c9,dm1.c16,dm1.c14,dm1.c11,''APLICACION ANULADA'',concat(dm1.c24,'' '',dm1.c25,'' '',dm1.c26)
							from keplersc.kdm1 dm1
							where dm1.c1=%1$L  and dm1.c2=%2$L and dm1.c3=%3$L  and dm1.c4=%4$s  and dm1.c5=%5$s and dm1.c6=%6$L' 
							,sucursal_id, gen_anticipo, nat_anticipo, gpo_anticipo, tipo_anticipo, folio_anticipo);
			raise notice '%',expSql;				
			execute expSql;
		end if;
	end loop;
		
	expSql='select * from tmpAnticipos'; 
		
	select query_to_xml(expSql,false,true,'') into xmlResultado;
raise notice '%', xmlResultado;
	
	return xmlResultado;

exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
