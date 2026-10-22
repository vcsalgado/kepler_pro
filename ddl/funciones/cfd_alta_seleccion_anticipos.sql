CREATE OR REPLACE FUNCTION keplersc.cfd_alta_seleccion_anticipos(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Realiza alta de la seleccion de anticipos relacionados con una factura en KDF3NCANT
--Autor: Miriam Santana
--Fecha: 05/03/2025
--Bitacora de cambios
--22/04/2026 Miriam Santana: Seleccion de anticipos de una factura de autos, servicio o refacciones para relacionarlos en el CFDI

declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	cve_seleccion text;

	folio_docto text = '';
	totalAnticipos decimal = 0.00;
	montoFactura decimal = 0.00;

	--Variables de retorno
	resultado text='';
	mensaje text='';
	adicionales text='';


begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	cve_seleccion := (xpath('//document/k_seleccion/text()',dataxml))[1];
	folio_docto := coalesce((xpath('//document/k_foliodocto/text()',dataxml))[1]::text,'')::text;
	
	if naturaleza = 'D' then --ALTA
		--raise exception 'suc:%, cve_seleccion:%, g:%, n:%, gp:%, tp:%, folio:%',sucursal_id, cve_seleccion, genero, naturaleza, grupo, tipo, folio_operacion;	
		
		update keplersc.kdf3ncant ant 
		set
			tipo_relacion ='07',
			genero_doctorel = genero,
			naturaleza_doctorel = naturaleza,
			grupo_doctorel = grupo::integer,
			tipo_doctorel = tipo::integer,
			folio_relacionado = folio_operacion
			where ant.c1=sucursal_id 
				and ant.c2='U' 
				and ant.c3='D' 
				and ant.c4=79 
				and ant.folio_relacionado = cve_seleccion
				and exists (
			        select 1
			        from keplersc.kdm1 m1a
			        join keplersc.kdm1 m1b
			          on m1a.c10 = m1b.c10
			        where m1a.c1 = ant.c1
			          and m1a.c2 = ant.c2
			          and m1a.c3 = ant.c3
			          and m1a.c4 = ant.c4
			          and m1a.c5 = ant.c5
			          and m1a.c6 = ant.c6
			          and m1b.c1 = sucursal_id
			          and m1b.c2 = genero
			          and m1b.c3 = naturaleza
			          and m1b.c4 = grupo::integer
			          and m1b.c5 = tipo::integer
			          and m1b.c6 = folio_operacion);

	else					--BAJA
		update keplersc.kdf3ncant set
			tipo_relacion ='',
			genero_doctorel = '',
			naturaleza_doctorel = '',
			grupo_doctorel = 0,
			tipo_doctorel = 0,
			folio_relacionado = ''				
			where c1=sucursal_id and c2='U' and c3='D' and c4=79 and folio_relacionado = folio_docto;
	
	end if;
	--Valida la suma de los anticipos vs. el monto de la fatura
	select coalesce(sum(dm1.c16),0) into totalAnticipos from keplersc.kdf3ncant nca
		inner join keplersc.kdm1 dm1 on nca.c1=dm1.c1 and nca.c2=dm1.c2 and nca.c3=dm1.c3 and nca.c4=dm1.c4 and nca.c5=dm1.c5 and nca.c6=dm1.c6  
		where nca.c1 = sucursal_id and nca.c8=0 
			and nca.tipo_relacion ='07' and nca.genero_doctorel = genero
			and nca.naturaleza_doctorel = naturaleza and nca.grupo_doctorel = grupo::integer
			and nca.tipo_doctorel = tipo::integer and nca.folio_relacionado = folio_operacion;
	
	select c16 into montoFactura from keplersc.kdm1
		where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::integer and c5 = tipo::integer and c6 = folio_operacion;
	
	if totalAnticipos > montoFactura then
		raise exception 'La suma de los anticipos seleccionados: % es mayor al total de la factura: %',totalAnticipos,montoFactura;
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cfd_alta_seleccion_anticipos() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
		
end;
$function$
