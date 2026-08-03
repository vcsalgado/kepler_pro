CREATE OR REPLACE FUNCTION keplersc.cfd_concept_partes(dataxml xml, xmlkdm1 xml, xmlkdmm xml, cons_cfdi text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Genera informacion para CFDI. Resuelve CFD_CONCEPT_PARTES
--Autor: Miriam Santana
--Fecha: 07/10/2022

	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	
	cve_original text;
	cve_actual text;
	cadena_reemplazo text;

	--Variables de uso general
	folio_operacion text;
	partida int = 1;
	cantidad decimal=0;
	unid_medida text;
	cve_prodserv text;
	descripcion text;
	precio_sin_impto decimal=0;
	precio_total_sin_impto decimal=0;
	cve_impto text = '002';
	tipo_factor text = 'TASA';	--Tasa, Cuota o Exento
	tasa_impto decimal=0;
	monto_iva decimal=0;
	cve_catprodserv text = '';
	monto_base_impto decimal=0;
	subtotal decimal=0;
	genref text;
	natref text; 
	gporef int;
	tiporef int;
	folioref text;
	partidaref int;
	fec_prod text;
	criterio_fec text = 'N';

	strValor text;
	intValor int;
	expXml text;
	
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
    fec_prod := current_date::text;
    
	for cantidad,unid_medida,descripcion,precio_sin_impto,precio_total_sin_impto,cve_catprodserv
		in select c9,c11,c10,c12,c13,c8
		from keplersc.kdm2
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion
	loop 
		raise notice '%','entro a loop de concept PARTES';
		if precio_total_sin_impto > 0 then
			expXml:= format('<document><clave_producto>%1$s</clave_producto><fecha>%2$s</fecha>
			<criterio_fecha>%3$s</criterio_fecha></document>',cve_catprodserv,fec_prod,criterio_fec);
			select * into cve_original, cve_actual, cadena_reemplazo from keplersc.prod_cadena_reemplazo(expXml::xml);
			select c33 into cve_prodserv from keplersc.kdini
				where c1=cve_original;					
			monto_iva := precio_total_sin_impto*tasa_impto;				--Monto del impuesto
			monto_base_impto := precio_total_sin_impto;					--Monto para la Base del Calculo de Impuesto
			if monto_base_impto <= 0 THEN 
		           monto_base_impto := 0.01;
		    end if;
			insert into keplersc.kdf3concept (
			   	c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19,c20)
				values(
				sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
				folio_operacion,cons_cfdi::integer,partida,cantidad,unid_medida,
				coalesce(cve_prodserv,''),coalesce(descripcion,''),precio_sin_impto,precio_total_sin_impto,cve_impto,
				tipo_factor,tasa_impto,monto_iva,coalesce(cve_catprodserv,''),monto_base_impto);
			raise notice '% desc:% cveprod:% cvecat:%','inserto en kdf3concept',descripcion,cve_prodserv,cve_catprodserv;
			partida := partida+1;
		end if;
	end loop;
			
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;		
	
exception
	when others then
		resultado := 0;
		mensaje := 'cfd_concept_partes() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
