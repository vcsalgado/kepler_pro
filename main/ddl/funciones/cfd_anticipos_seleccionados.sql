CREATE OR REPLACE FUNCTION keplersc.cfd_anticipos_seleccionados(dataxml xml, xmlkdm1 xml, xmlkdmm xml, cons_cfdi text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Graba los anticipos seleccionados para una factura de auto
--Autor: Miriam Santana
--Fecha: 05/02/2026
--Bitacora de Cambios


	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	
	--Variables de uso general
	folio_operacion text;
	rec_seleccion record;
	partida int;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;	
begin
	--Transaccion
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	folio_operacion := (xpath('//row/c6/text()', xmlKDM1))[1];
	   
	if genero='U' and naturaleza='D' and (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' then
		partida=1;
		for rec_seleccion
			in select dm1.c16 monto, nca.* from keplersc.kdf3ncant nca
			inner join keplersc.kdm1 dm1 on dm1.c1=nca.c1 and dm1.c2=nca.c2 and dm1.c3=nca.c3 and dm1.c4=nca.c4 and dm1.c5=nca.c5 and dm1.c6=nca.c6
			where nca.c1=sucursal_id and nca.genero_doctorel=genero and nca.naturaleza_doctorel=naturaleza and nca.grupo_doctorel=grupo::integer and nca.tipo_doctorel=tipo::integer and nca.folio_relacionado=folio_operacion
		loop	
			insert into keplersc.kdf3anticipos (
			   	c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19)
				values(
				sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
				folio_operacion,cons_cfdi::integer,partida,rec_seleccion.tipo_relacion,rec_seleccion.c1,
				rec_seleccion.c2,rec_seleccion.c3,rec_seleccion.c4,rec_seleccion.c5,rec_seleccion.c6,
				0,rec_seleccion.monto,0,0);
				
				partida=partida+1;
		end loop; 
	
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;		
	
exception
	when others then
		resultado := 0;
		mensaje := 'cfd_anticipos_seleccionados() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
