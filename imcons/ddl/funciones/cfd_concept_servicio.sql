CREATE OR REPLACE FUNCTION keplersc.cfd_concept_servicio(dataxml xml, xmlkdm1 xml, xmlkdmm xml, cons_cfdi text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Genera informacion para CFDI. Resuelve CFD_CONCEPT_SERVICIO
--Autor: Miriam Santana
--Fecha: 06/10/2022

	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_orden text;
	num_orden text;

	cve_original text;
	cve_actual text;
	cadena_reemplazo text;

	--Variables de uso general
	folio_operacion text;
	partida int = 1;
	cantidad decimal=0;
	unid_medida text = 'E48';
	cve_prodserv text = '78181500';
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
	tipo_orden := (xpath('//row/c121/text()', xmlKDM1))[1]::text;
	num_orden := (xpath('//row/c122/text()', xmlKDM1))[1]::text;
	strValor := coalesce((xpath('//row/c16/text()', xmlKDMM))[1]::text,'0');
    tasa_impto := strValor::decimal/100;      						--Porcentaje             
    fec_prod := current_date::text;
    
   --raise notice '%','Entro a concept servicio';
	--kdhoras  
  	precio_sin_impto:=0;
	precio_total_sin_impto:=0;
	monto_base_impto:=0; monto_iva:=0;
	for cantidad,descripcion,precio_sin_impto,precio_total_sin_impto,monto_iva				--precio_total_sin_impto=c14*c8	=c17(ya calcuada)
		in select c8,c7,c14,c17,c18			--c18=monto_iva
		from keplersc.kdhoras 
		where c1=sucursal_id and c2=tipo_orden and c3=num_orden
	loop 
   --raise notice '%','Entro a loop horas';
		if precio_sin_impto > 0 and cantidad > 0 then
			--monto_iva := (precio_sin_impto*cantidad)*tasa_impto;	--Monto del impuesto
			--VCSS 14 Julio 2027, Recalcular el IVA con base en movimiento en KDMM, sustituir los de KDORD
			monto_iva := precio_total_sin_impto * tasa_impto;

			monto_base_impto := precio_total_sin_impto; --(precio_sin_impto*cantidad);					--Monto para la Base del Calculo de Impuesto
			if monto_base_impto <= 0 THEN 
	            monto_base_impto := 0.01;
	        end if;
  --raise notice '%','Entro a horas';	
  --raise notice 'C:% D:% PU:% PT:% moniva: % mbimpto:%',cantidad,descripcion,precio_sin_impto,precio_total_sin_impto,monto_iva,monto_base_impto;
			insert into keplersc.kdf3concept (
		    	c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19,c20)
				values(
				sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
				folio_operacion,cons_cfdi::integer,partida,cantidad,unid_medida,
				cve_prodserv,descripcion,precio_sin_impto,precio_total_sin_impto,cve_impto,
				tipo_factor,tasa_impto,monto_iva,cve_catprodserv,monto_base_impto);
			
			partida := partida+1;
   --raise notice 'PARTIDA_HORAS%',partida;			
		end if;
	end loop;

	--kdtot
	precio_sin_impto:=0;
	precio_total_sin_impto:=0;
	monto_base_impto:=0; monto_iva:=0;
	for descripcion,precio_sin_impto,subtotal,monto_iva	
		in select c10,c16,c11,c18
		from keplersc.kdtot
		where c1=sucursal_id and c2=tipo_orden and c3=num_orden
	loop 
	   --raise notice '%','Entro a loop tot';
		if precio_sin_impto > 0 then
			cantidad :=1;
			--monto_iva := precio_sin_impto*tasa_impto;	--Monto del impuesto

			--VCSS 14 Julio 2027, Recalcular el IVA con base en movimiento en KDMM, sustituir los de KDORD
			monto_iva := precio_sin_impto * tasa_impto;

			monto_base_impto := precio_sin_impto;					--Monto para la Base del Calculo de Impuesto
			if monto_base_impto <= 0 THEN 
	            monto_base_impto := 0.01;
	        end if;
   raise notice '%','Entro a tot';
  raise notice 'C:% D:% PU:% PT:% mbimpto:%',cantidad,descripcion,precio_sin_impto,precio_sin_impto,monto_base_impto;
			insert into keplersc.kdf3concept (
		    	c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19,c20)
				values(
				sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
				folio_operacion,cons_cfdi::integer,partida,cantidad,unid_medida,
				cve_prodserv,descripcion,precio_sin_impto,precio_sin_impto,cve_impto,
				tipo_factor,tasa_impto,monto_iva,cve_catprodserv,monto_base_impto);
			
			partida := partida+1;	
		end if;
	end loop;
	--kdcar
	precio_sin_impto:=0;
	precio_total_sin_impto:=0;
	monto_base_impto:=0; monto_iva:=0;
	for descripcion,precio_sin_impto,monto_iva		
		in select c7,c10,c11
		from keplersc.kdcar
		where c1=sucursal_id and c2=tipo_orden and c3=num_orden
	loop 
	   --raise notice '%','Entro a loop cargos';
		if precio_sin_impto > 0 then
			cantidad :=1;
			--monto_iva := precio_sin_impto*tasa_impto;	--Monto del impuesto

			--VCSS 14 Julio 2027, Recalcular el IVA con base en movimiento en KDMM, sustituir los de KDORD
			monto_iva := precio_sin_impto * tasa_impto;

			monto_base_impto := precio_sin_impto;					--Monto para la Base del Calculo de Impuesto
			if monto_base_impto <= 0 THEN 
	            monto_base_impto := 0.01;
	        end if;
raise notice '%','Entro a cargos';
raise notice 'C:% D:% PU:% PT:% mbimpt:%',cantidad,descripcion,precio_sin_impto,precio_sin_impto,monto_base_impto;
			insert into keplersc.kdf3concept (
		    	c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19,c20)
				values(
				sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
				folio_operacion,cons_cfdi::integer,partida,cantidad,unid_medida,
				cve_prodserv,descripcion,precio_sin_impto,precio_sin_impto,cve_impto,
				tipo_factor,tasa_impto,monto_iva,cve_catprodserv,monto_base_impto);
			
			partida := partida+1;	
		end if;
	end loop;
	--kdref y kdm2
	precio_sin_impto:=0;
	precio_total_sin_impto:=0;
	monto_base_impto:=0; monto_iva:=0;
	for cantidad,unid_medida,descripcion,precio_sin_impto,precio_total_sin_impto,
		genref,natref,gporef,tiporef,folioref,partidaref,monto_iva
		in select c13,c14,c12,c15,c16,c5,c6,c7,c8,c9,c10,c21
		from keplersc.kdref
		where c1=sucursal_id and c2=tipo_orden and c3=num_orden
	loop 
	--raise notice '%','Entro a loop kdm2';
		if precio_total_sin_impto > 0 then

			select c8 into cve_catprodserv from keplersc.kdm2
				where c1=sucursal_id and c2=genref and c3=natref 
				and c4=gporef and c5=tiporef and c6=folioref and c7=partidaref;

			if found then
				expXml:= format('<document><clave_producto>%1$s</clave_producto><fecha>%2$s</fecha>
				<criterio_fecha>%3$s</criterio_fecha></document>',cve_catprodserv,fec_prod,criterio_fec);

				select * into cve_original, cve_actual, cadena_reemplazo from keplersc.prod_cadena_reemplazo(expXml::xml);
				--cve_catprodserv := cve_original;				--Tomar no. parte que capturan sea reemplazo u original
	
				select c33 into cve_prodserv from keplersc.kdini
					where c1=cve_original;
				
				--monto_iva := precio_total_sin_impto*tasa_impto;				--Monto del impuesto	--Se toma el IVA de KDREF.C21
				
				--VCSS 14 Julio 2027, Recalcular el IVA con base en movimiento en KDMM, sustituir los de KDORD
				monto_iva := precio_total_sin_impto * tasa_impto;
				
				monto_base_impto := precio_total_sin_impto;					--Monto para la Base del Calculo de Impuesto

				if monto_base_impto <= 0 then

		            monto_base_impto := 0.01;
		        end if;
--raise notice '%','Entra s kdref';
--raise notice 'C:% D:% PU:% PT:%,mbimpto:%',cantidad,descripcion,precio_sin_impto,precio_total_sin_impto,monto_base_impto;
				insert into keplersc.kdf3concept (
			    	c1,c2,c3,c4,c5,
					c6,c7,c8,c9,c10,
					c11,c12,c13,c14,c15,
					c16,c17,c18,c19,c20)
					values(
					sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
					folio_operacion,cons_cfdi::integer,partida,cantidad,unid_medida,
					cve_prodserv,descripcion,precio_sin_impto,precio_total_sin_impto,cve_impto,
					tipo_factor,tasa_impto,monto_iva,cve_catprodserv,monto_base_impto);

				partida := partida+1;
			end if;
		end if;
	end loop;
			
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;		
	
exception
	when others then
		resultado := 0;
		mensaje := 'cfd_concept_servicio() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
