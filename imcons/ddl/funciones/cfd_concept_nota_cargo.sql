CREATE OR REPLACE FUNCTION keplersc.cfd_concept_nota_cargo(dataxml xml, xmlkdm1 xml, xmlkdmm xml, cons_cfdi text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Genera informacion para CFDI. Resuelve CFD_CONCEPT_NOTA_CARGO
--Autor: Miriam Santana
--Fecha: 05/10/2022

	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;

	--Variables de uso general
	folio_operacion text;
	partida int = 1;
	cantidad int = 1;
	unid_medida text;
	cve_prodserv text;
	descripcion text;
	precio_sin_impto decimal=0;
	cve_impto text = '002';
	tipo_factor text = 'TASA';		--Tasa, Cuota o Exento
	tasa_impto decimal=0;
	monto_iva decimal=0;
	cve_catprodserv text = '';
	monto_base_impto decimal=0;

	strValor text;
	intValor int;

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
	strValor := coalesce((xpath('//row/c16/text()', xmlKDMM))[1]::text,'0');
    tasa_impto := strValor::decimal/100;      						--Porcentaje             
		
	for unid_medida,cve_prodserv,descripcion,precio_sin_impto,cve_catprodserv		
		in select dm2.c11,cat.c2,cat.c3,dm2.c13,cat.c1
		from keplersc.kdm2 dm2
		inner join keplersc.kdncargocat cat on cat.c1=dm2.c8  
		where dm2.c1=sucursal_id and dm2.c2=genero and dm2.c3=naturaleza and dm2.c4=grupo::integer and dm2.c5=tipo::integer and dm2.c6=folio_operacion
	loop 
		if precio_sin_impto > 0 then	
			monto_iva := precio_sin_impto*tasa_impto;
			monto_base_impto := precio_sin_impto;
			insert into keplersc.kdf3concept (
	      		c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19,c20)
				values(
				sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
				folio_operacion,cons_cfdi::integer,partida,cantidad,unid_medida,
				coalesce(cve_prodserv,''),coalesce(descripcion,''),precio_sin_impto,precio_sin_impto,cve_impto,
				tipo_factor,tasa_impto,monto_iva,coalesce(cve_catprodserv,''),monto_base_impto);
			partida := partida+1;
			
			resultado := 1;
			mensaje := '';
			adicionales := '';
			return query select resultado, mensaje, adicionales;
		end if;	
	end loop;
exception
	when others then
		resultado := 0;
		mensaje := 'cfd_concept_nota_cargo() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
