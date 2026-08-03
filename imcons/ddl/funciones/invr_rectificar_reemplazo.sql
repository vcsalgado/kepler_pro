CREATE OR REPLACE FUNCTION keplersc.invr_rectificar_reemplazo(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion:  Corrige los registros de una refaccion que es reeemplazo pero que se ha manejado como original
--				ref_original es el nivel mas alto, ref_a_reemp es la refaccion inmediata a reemplazar en la cadena de reemplazos
--				ref_reemp es la refaccion que reemplaza
--llamado base:
--select * from keplersc.invr_rectificar_reemplazo(
--'<document><ref_original></ref_original><ref_a_reemp></ref_a_reemp><ref_reemp></ref_reemp></document>');
--Autor: Victor Salgado
--Fecha: 12/05/2025
--Bitacora de cambios

declare

	recKDIN record;
	ref_original text=0;
	ref_a_reemp text=0;
	ref_reemp text=0;
	totReg int;

	strValor text;
	resultado text = '';
	mensaje text = '';
    adicionales text = '';
   
begin 
	ref_original := (xpath('//document/ref_original/text()', dataxml))[1]; 
	ref_a_reemp := coalesce((xpath('//document/ref_a_reemp/text()', dataxml))[1]::text,'')::text;
 	ref_reemp := coalesce((xpath('//document/ref_reemp/text()', dataxml))[1]::text,'')::text; 
raise notice 'ref_original:%; ,ref_a_reemp:%; ,ref_reemp:%; ',ref_original,ref_a_reemp,ref_reemp;


	--Validar que la refaccion a reemplazar este en catalogo de reemplazos siempre y cuando exista una cadena
	if ref_original <> ref_a_reemp then 
		select count(*) into totReg from keplersc.kdinr where c1= ref_a_reemp;
		if totReg = 0 then
			raise exception 'La refaccion a reemplazar no esta configurada.';
		end if;
	end if;

	--Eliminar registro reemplazo de catalogo kdini
	delete from keplersc.kdini where c1=ref_reemp;

	--Corregir estadistica mensual kdink
	for recKDIN in select * from keplersc.kdink where c2=ref_reemp order by c1,c3 
	loop
		select count(*) into totReg from keplersc.kdink where c1=recKDIN.c1 and c2=ref_original and c3=recKDIN.c3;
		if totReg = 0 then
			insert into keplersc.kdink (c1,c2,c3) values (recKDIN.c1, ref_original, recKDIN.c3);
		end if;

		update 	keplersc.kdink set c10=c10+recKDIN.c10, c11=c11+recKDIN.c11, c12=c12+recKDIN.c12, c13=c13+recKDIN.c13, 
			c14=c14+recKDIN.c14, c15=c15+recKDIN.c15, c16=c16+recKDIN.c16, c17=c17+recKDIN.c17, c18=c18+recKDIN.c18,
			c19=c19+recKDIN.c19, c20=c20+recKDIN.c20, c21=c21+recKDIN.c21, c22=c22+recKDIN.c22, c23=c23+recKDIN.c23,
			c24=c24+recKDIN.c24, c25=c25+recKDIN.c25, c26=c26+recKDIN.c26, c27=c27+recKDIN.c27, c28=c28+recKDIN.c28,
			c29=c29+recKDIN.c29, c30=c30+recKDIN.c30, c31=c31+recKDIN.c31, c32=c32+recKDIN.c32, c33=c33+recKDIN.c33,
			c40=c40+recKDIN.c40, c41=c41+recKDIN.c41, c42=c42+recKDIN.c42, c43=c43+recKDIN.c43, 
			c44=c44+recKDIN.c44, c45=c45+recKDIN.c45, c46=c46+recKDIN.c46, c47=c47+recKDIN.c47, c48=c48+recKDIN.c48,
			c49=c49+recKDIN.c49, c50=c50+recKDIN.c50, c51=c51+recKDIN.c51, c52=c52+recKDIN.c52, c53=c53+recKDIN.c53,
			c54=c54+recKDIN.c54, c55=c55+recKDIN.c55, c56=c56+recKDIN.c56, c57=c57+recKDIN.c57, c58=c58+recKDIN.c58,
			c59=c59+recKDIN.c59, c60=c60+recKDIN.c60, c61=c61+recKDIN.c61, c62=c62+recKDIN.c62, c63=c63+recKDIN.c63
		where c1=recKDIN.c1 and c2=ref_original and c3=recKDIN.c3;

		delete from keplersc.kdink where c1=recKDIN.c1 and c2=ref_reemp and c3=recKDIN.c3;
 	end loop;


	--Corregir estadistica anual kdinl
	for recKDIN in select * from keplersc.kdinl where c2=ref_reemp order by c1,c3 
	loop
		--Obtener valores de ultimos movimiento
		select count(*) into totReg from keplersc.kdinl where c1=recKDIN.c1 and c2=ref_original;
		if totReg = 0 then
			insert into keplersc.kdinl (c1,c2) values (recKDIN.c1, ref_original);
		end if;

		update 	keplersc.kdinl set c5=c5+recKDIN.c5, c6=c6+recKDIN.c6, c8=c8+recKDIN.c8, c9=c9+recKDIN.c9
		where c1=recKDIN.c1 and c2=ref_original;

		if totReg=0 then --No habia registro de original, actualizar valores de ultimos movtos con los del reemplazo
			update 	keplersc.kdinl set c11=recKDIN.c11, c12=recKDIN.c12, 
				c14=recKDIN.c14, c15=recKDIN.c15,
				c17=recKDIN.c17, c18=recKDIN.c18 
			where c1=recKDIN.c1 and c2=ref_original;
		end if;

		delete from keplersc.kdinl where c1=recKDIN.c1 and c2=ref_reemp;
 	end loop;

	--Corregir movimientos kdinm
	update keplersc.kdinm set c2=ref_original where c2=ref_reemp;

	--Agregar como reemplazo
	insert into keplersc.kdinr (c1,c2,c3) values(ref_reemp,ref_a_reemp,now());

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;
exception
	when others then
		resultado := 0;
		mensaje := 'invr_rectificar_reemplazo() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
