CREATE OR REPLACE FUNCTION keplersc.cfd_concept_vehiculo(dataxml xml, xmlkdm1 xml, xmlkdmm xml, cons_cfdi text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Genera informacion para CFDI. Resuelve CFD_CONCEPT_VEHICULO
--Autor: Miriam Santana
--Fecha: 06/10/2022

	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	cve_inventario text;

	--Variables de uso general
	folio_operacion text;
	partida int = 1;
	cantidad int;
	unid_medida text;
	cve_prodserv text;
	descripcion text;
	precio_sin_impto decimal=0;
	precio_total_sin_impto decimal=0;
	cve_impto text = '002';
	tipo_factor text = 'TASA';	--Tasa, Cuota o Exento
	tasa_impto decimal=0;
	monto_iva decimal=0;
	cve_catprodserv text ='';
	monto_base_impto decimal=0;

	monto_total_dm1 decimal=0;
	monto_iva_dm1 decimal=0;
	sum_precio_total_sin_impto decimal = 0;
	sum_monto_iva decimal = 0;
	paquete text;
	pq2 text;
	pq3 text;
	pq4 text;
	pq5 text;
	pq6 text;
	pq7 text;
	pq8 text;
	pq9 text;
	pq10 text;
	pq11 text;
	pq12 text;
	pq13 text;
	pq14 text;
	pq15 text;
	pq16 text;
	pq17 text;
	pq18 text;
	pq19 text;
	pq20 text;

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
	monto_total_dm1 := (xpath('//row/c16/text()', xmlKDM1))[1];
	monto_iva_dm1 := (xpath('//row/c14/text()', xmlKDM1))[1];
    cve_inventario := (xpath('//row/c100/text()', xmlKDM1))[1];
    
	for cantidad,unid_medida,cve_prodserv,descripcion,precio_sin_impto,precio_total_sin_impto		
		in select c7,c6,c4,c5,c8,c9
		from keplersc.kdpedidoextras  
		where c1=sucursal_id and c2=cve_inventario
	loop 
		monto_iva := precio_total_sin_impto*(monto_iva_dm1/(monto_total_dm1-monto_iva_dm1));	--Monto del impuesto
		if monto_iva <= 0 then										
			monto_iva := 0;
		end if;
		if tasa_impto > 0 then
	    	monto_base_impto := monto_iva/tasa_impto;					--Monto para la Base del Calculo de Impuesto
	    else
	    	monto_base_impto :=0;
	    end if;
		
		if monto_base_impto <= 0 THEN 
            monto_base_impto := 0.01;
        end if;
		insert into keplersc.kdf3concept (
	    	c1,c2,c3,c4,c5,
			c6,c7,c8,c9,c10,
			c11,c12,c13,c14,c15,
			c16,c17,c18,C19,c20)
			values(
			sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
			folio_operacion,cons_cfdi::integer,partida,cantidad,unid_medida,
			coalesce(cve_prodserv,''),coalesce(descripcion,''),precio_sin_impto,precio_total_sin_impto,cve_impto,
			tipo_factor,tasa_impto,monto_iva,coalesce(cve_catprodserv,''),monto_base_impto);
		
		--suma importes total sin impuestos
		sum_precio_total_sin_impto := sum_precio_total_sin_impto+precio_total_sin_impto;
		--suma monto IVA
		sum_monto_iva := sum_monto_iva+monto_iva;
		partida := partida+1;	
	end loop;
	
	select upper(inf.c4),iv.c30,iv.c31,inf.c40,inf.c41,inf.c42,inf.c43,inf.c44,inf.c45,inf.c46,inf.c47,inf.c48,
		inf.c49,inf.c50,inf.c51,inf.c52,inf.c53,inf.c54,inf.c55,inf.c56,inf.c57,inf.c58,inf.c59,inf.c60
		into descripcion,cve_prodserv,unid_medida,paquete,pq2,pq3,pq4,pq5,pq6,pq7,pq8,pq9,pq10,pq11,pq12,pq13,pq14,
		pq15,pq16,pq17,pq18,pq19,pq20
		from keplersc.kdinf inf
		inner join keplersc.kdiv iv on iv.c1=inf.c3
		where inf.c1=sucursal_id and inf.c2=cve_inventario;
	if found then
		--unid_medida := 'C62';		Se cambia por solicitud en ticket 19968, para que lo tome del nuevo dato kdiv.c31
		if paquete <> '' then
			insert into keplersc.kdf3longconcept (
				c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19,c20,
				c21,c22,c23,c24,c25,
				c26,c27,c28)
			values (
				sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
				folio_operacion,cons_cfdi::integer,partida,paquete,coalesce(pq2,''),
				coalesce(pq3,''),coalesce(pq4,''),coalesce(pq5,''),coalesce(pq6,''),coalesce(pq7,''),
				coalesce(pq8,''),coalesce(pq9,''),coalesce(pq10,''),coalesce(pq11,''),coalesce(pq12,''),
				coalesce(pq13,''),coalesce(pq14,''),coalesce(pq15,''),coalesce(pq16,''),coalesce(pq17,''),
				coalesce(pq18,''),coalesce(pq19,''),coalesce(pq20,''));
		end if;
	end if;
	cantidad := 1;
	precio_sin_impto := monto_total_dm1-monto_iva_dm1-sum_precio_total_sin_impto;
	precio_total_sin_impto := monto_total_dm1-monto_iva_dm1-sum_precio_total_sin_impto;
	cve_impto :='002';
	tipo_factor := 'TASA';
	monto_iva := monto_iva_dm1-sum_monto_iva;
	if monto_iva <= 0 then										
		monto_iva := 0;
	end if;
	
	if tasa_impto > 0 then
	   	monto_base_impto := monto_iva/tasa_impto;					--Monto para la Base del Calculo de Impuesto
	else
	   	monto_base_impto :=0;
	end if;	
		
	if monto_base_impto <= 0 THEN 
    	monto_base_impto := 0.01;
    end if;

	insert into keplersc.kdf3concept (
	   	c1,c2,c3,c4,c5,
		c6,c7,c8,c9,c10,
		c11,c12,c13,c14,c15,
		c16,c17,c18,C19,c20)
		values(
		sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
		folio_operacion,cons_cfdi::integer,partida,cantidad,coalesce(unid_medida,''),
		coalesce(cve_prodserv,''),coalesce(descripcion,''),precio_sin_impto,precio_total_sin_impto,cve_impto,
		tipo_factor,tasa_impto,monto_iva,coalesce(cve_catprodserv,''),monto_base_impto);
			
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;		
	
exception
	when others then
		resultado := 0;
		mensaje := 'cfd_concept_vehiculo() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
