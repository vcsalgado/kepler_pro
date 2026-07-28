CREATE OR REPLACE FUNCTION keplersc.cxcp_kduxg_baja(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Realiza baja de Cuentas por Cobara y/o Pagar en kduxg
--Autor: Miriam Santana
--Fecha: 22/08/2022
--Bitacora de cambios
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_clave text;
	no_partidas int;
	referencia text;
	clave_cteprov text;
	fecha_operacion text; --yyyy-mm-dd
	plazo_vencimiento text;	
	monto_iva text;
	monto_total text;

	--variables kduxg
	identificador text;
	factura_xg text;
	docpar_xg int;
	cargos_xg decimal = 0;
	abonos_xg decimal = 0;
	iva_cargos_xg decimal = 0;
	iva_abonos_xg decimal = 0;
	saldado_xg int = 0;
	fecha_exp_xg text;
	fecha_venc_xg text;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	strValor text;
	intValor int;
	totalReg int;

begin
	--Valores de XML
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];


	clave_cteprov := (xpath('//document/k_clave/text()', dataxml))[1];
	referencia := (xpath('//document/k_refer/text()',dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	plazo_vencimiento := coalesce((xpath('//document/k_vence/text()', dataxml))[1]::text,'1800-01-01')::text;
	monto_iva := (xpath('//document/k_iva/text()',dataxml))[1];		
	monto_total := (xpath('//document/k_monto/text()',dataxml))[1];
	--factura_xg :=  lpad(referencia,10,'0');

	if (/*grupo = '7' and*/ upper((xpath('//document/ambiente/uen/text()', dataxml))[1]::text) = 'VEN') then
		factura_xg := lpad(referencia,10,'0');
	else
		factura_xg := referencia;
	end if;

	docpar_xg := 1;
	cargos_xg := 0;
	abonos_xg := 0;
	iva_cargos_xg := 0;
	iva_abonos_xg := 0;
	saldado_xg := 0;  
	fecha_exp_xg := fecha_operacion;
	fecha_venc_xg := plazo_vencimiento;

	select xe.c11,xe.c12,xe.c13,xe.c14,xg.c6,xg.c7,xg.c8,xg.c9 
		into fecha_exp_xg, fecha_venc_xg, monto_total, monto_iva, cargos_xg, abonos_xg, iva_cargos_xg, iva_abonos_xg 
		from keplersc.kduxe xe  
		inner join keplersc.kduxg xg on xe.c1=xg.c1 and xe.c5= xg.c2 and xe.c2=xg.c3 and xe.c3=xg.c4  
		where xe.c1=sucursal_id and xe.c5=genero and xe.c6=naturaleza and xe.c7=grupo::integer and xe.c8=tipo_clave::integer and xe.c9=folio_operacion::text;
	
	
	if naturaleza = 'D' then
		cargos_xg = cargos_xg-monto_total::decimal;
		iva_cargos_xg = iva_cargos_xg-monto_iva::decimal;
		identificador :=  folio_operacion; 
	else
		abonos_xg = abonos_xg-monto_total::decimal;
		iva_abonos_xg = iva_abonos_xg-monto_iva::decimal;
		identificador :=  factura_xg;
	end if;
	if genero ='U' and cargos_xg<=abonos_xg then
		saldado_xg := 10;
	end if;
	if genero = 'X' and abonos_xg<=cargos_xg then 
		saldado_xg := 10;
	end if;
	select count(*) into totalReg from  keplersc.kduxg
		where c1=sucursal_id and c2=genero and c3=clave_cteprov and c4=identificador and c5=1;
	if totalReg = 0 then	
		cargos_xg = 0;
		iva_cargos_xg = 0;
		saldado_xg := 0;
	 	insert into keplersc.kduxg (c1,c2,c3,c4,c5,
			c6,c7,c8,c9,c10,
			c11,c12)
		values(sucursal_id,genero,clave_cteprov,identificador,docpar_xg,
			cargos_xg,abonos_xg,iva_cargos_xg,iva_abonos_xg,saldado_xg,
			to_date(fecha_exp_xg,'YYYY-MM-DD'),to_date(fecha_venc_xg,'YYYY-MM-DD'));
		
	else  
		update keplersc.kduxg set
			c6=cargos_xg,
			c7=abonos_xg,
			c8=iva_cargos_xg,
			c9=iva_abonos_xg,
			c10=saldado_xg
		where c1=sucursal_id and c2=genero and c3=clave_cteprov and c4=identificador and c5=docpar_xg;
		--MSS CANCELA FACT  le cambie a c4=identificador		
	end if; 
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cxcp_kduxg_baja() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
