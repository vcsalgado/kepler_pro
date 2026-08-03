CREATE OR REPLACE FUNCTION keplersc.caja_alta(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Realiza alta de caja. Resuelve ALTA_CAJA y ALTA_K_CAJA 
--Autor: Miriam Santana
--Fecha: 30/09/2022

	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	clave_cteprov text;
	forma_pago text;
	cuenta text;
	fecha_operacion text;
	anticipo text;
	movto_caja text;
	importe text;

	--Variables de uso general
	expSql text;
	totalReg int;
	mesValor int;
	anioValor int;
	strCol text;
	strValor text;
	strPlus text = '+';
	columna_caja text;
	ingreso_caja decimal = 0;
	egreso_caja decimal = 0;
	importe_caja decimal;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	--Valores de XML
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	clave_cteprov := (xpath('//document/k_clave/text()', dataxml))[1];
	forma_pago := (xpath('//document/k_f_pago/r1/text()', dataxml))[1];
	cuenta := (xpath('//document/k_cuenta/text()', dataxml))[1];
	fecha_operacion := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
	anticipo := coalesce((xpath('//document/k_montoanticipo/text()', dataxml))[1]::text,'0');
	movto_caja := (xpath('//row/c51/text()', xmlKDMM))[1]::text;
	importe := (xpath('//document/k_monto/text()', dataxml))[1];
	raise notice '%', 'importe: '||importe;
	importe_caja := importe::decimal - anticipo::decimal;
	raise notice '%', 'importe caja: '||importe_caja;
	
	if (xpath('//row/c14/text()', xmlKDMM))[1]::text = 'S' then		--Afecta fecha último cobro
		--ALTA_CAJA
		insert into keplersc.kdecaja (
			c1,c2,c3,c4,c5,
			c6,c7,c8,c9,c10)
		values(sucursal_id,movto_caja,genero,naturaleza,grupo::integer, 
		tipo::integer, folio_operacion,1,to_date(fecha_operacion,'YYYY-MM-DD'),importe_caja);

		--ALTA_K_CAJA
		anioValor = extract(year from to_date(fecha_operacion,'YYYY-MM-DD'));
	
		raise notice '%','anio valor:'||anioValor;
		select count(*) into totalReg  from keplersc.kdkcaja
			where c1= sucursal_id and c2=anioValor::text;
		if totalReg=0 then
			insert into keplersc.kdkcaja(c1,c2) values (sucursal_id,anioValor::text);
		end if;
		raise notice '%','totreg kdkcaja:'||totalReg;		
		mesValor = extract(month from to_date(fecha_operacion,'YYYY-MM-DD'));
		select count(*) into totalReg from keplersc.kdcajdep
			where c1= to_date(fecha_operacion,'YYYY-MM-DD');
		raise notice '%','totreg kdcajdep:'||totalReg;	
		if totalReg=0 then
			insert into keplersc.kdcajdep(c1) values (to_date(fecha_operacion,'YYYY-MM-DD'));
		end if;
		
		select coalesce(c10,0) into ingreso_caja from keplersc.kdecaja 
			where c1= sucursal_id and c2='I' and c3= genero and c4=naturaleza and c5=grupo::integer and c6= tipo::integer and c7=folio_operacion;
		raise notice '%','ingreso:'||ingreso_caja;
		select coalesce(c10,0) into egreso_caja from keplersc.kdecaja 
			where c1= sucursal_id and c2='E' and c3= genero and c4=naturaleza and c5=grupo::integer and c6= tipo::integer and c7=folio_operacion;
		ingreso_caja=coalesce(ingreso_caja,0);
		egreso_caja=coalesce(egreso_caja,0);
		raise notice '%','egreso:'||egreso_caja;
	
		strCol = 9+mesValor;
		columna_caja := 'c' || strCol;
		raise notice '%','columna9+mes:'||strCol;
		raise notice '%','columna9+mes:'||columna_caja;
		if ingreso_caja > 0 then
			expSql= format('update keplersc.kdkcaja set %1$s=%1$s%5$s%2$s 
					where c1=%3$L and c2=%4$L',
					columna_caja,ingreso_caja,sucursal_id,anioValor,strPlus);	
			raise notice '%', expSql;			
			execute expSql;
			update keplersc.kdcajdep set c2=c2+ingreso_caja where c1=to_date(fecha_operacion,'YYYY-MM-DD');
		end if;
		strCol = 24+mesValor;
		columna_caja := 'c' || strCol;
		raise notice '%','columna24+mes:'||strCol;
		raise notice '%','columna24+mes:'||columna_caja;
		if egreso_caja > 0 then
			expSql= format('update keplersc.kdkcaja set %1$s=%1$s%5$s%2$s 
					where c1=%3$L and c2=%4$L',
					columna_caja,egreso_caja,sucursal_id,anioValor,strPlus);
			raise notice '%', expSql;	
			execute expSql;
			update keplersc.kdcajdep set c3=c3+egreso_caja where c1=to_date(fecha_operacion,'YYYY-MM-DD');	
		end if;
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'caja_alta() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
