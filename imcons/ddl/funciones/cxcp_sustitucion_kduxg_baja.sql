CREATE OR REPLACE FUNCTION keplersc.cxcp_sustitucion_kduxg_baja(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Realiza baja de Cuentas por Cobara y/o Pagar en kduxg de un documento a anexar o relacionado
--Autor: Miriam Santana
--Fecha: 22/12/2022
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
	foliodocto_anx text;

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
	rec record;

begin
	--Naturaleza, grupo, tipo y folio del documento a anexar w36..w39  -->k_natdocto,k_gpodocto,k_tipodocto,k_foliodocto
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_natdocto/text()', dataxml))[1];
	grupo := (xpath('//document/k_gpodocto/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipodocto/text()', dataxml))[1];
	foliodocto_anx := (xpath('//document/k_foliodocto/text()', dataxml))[1];
	

	docpar_xg := 1;
	cargos_xg := 0;
	abonos_xg := 0;
	iva_cargos_xg := 0;
	iva_abonos_xg := 0;
	saldado_xg := 0;  
	fecha_exp_xg := fecha_operacion;
	fecha_venc_xg := plazo_vencimiento;
	
	for rec
		in select *
		from keplersc.kduxe xe  
		where xe.c1=sucursal_id and xe.c5=genero and xe.c6=naturaleza and xe.c7=grupo::integer and xe.c8=tipo_clave::integer and xe.c9=foliodocto_anx
		order by c10 desc
	loop 

	--raise notice '%', rec;
	   	select xg.c6,xg.c7,xg.c8,xg.c9,xg.c4
			into cargos_xg, abonos_xg, iva_cargos_xg, iva_abonos_xg,factura_xg 
			from keplersc.kduxg xg 
			where xg.c1=rec.c1 and xg.c2=rec.c5 and xg.c3=rec.c2 and xg.c4=rec.c3; 
		 raise NOTICE '% % % % %',cargos_xg, abonos_xg, iva_cargos_xg, iva_abonos_xg,factura_xg;		
		--raise notice 'CXCP_SUSTITUCION KDUXG';
		if naturaleza = 'D' then
			cargos_xg = cargos_xg-rec.c13;			--rec.c13(monto_total)
			iva_cargos_xg = iva_cargos_xg-rec.c14;	--rec.c14(monto_iva)
			identificador :=  rec.c3; 				--rec.c3(foliodocto_anx) ya viene desde la kduxe
		else
			abonos_xg = abonos_xg-rec.c13;			--rec.c13(monto_total)
			iva_abonos_xg = iva_abonos_xg-rec.c14;	--rec.c14(monto_iva)
			identificador :=  rec.c3;				--rec.c3(factura_xg)	ya viene desde la kduxe
		end if;
		
		if genero ='U' and cargos_xg<=abonos_xg then
			saldado_xg := 10;
		end if;
		if genero = 'X' and abonos_xg<=cargos_xg then 
			saldado_xg := 10;
		end if;
		select count(*) into totalReg from  keplersc.kduxg
			where c1=rec.c1 and c2=rec.c5 and c3=rec.c2 and c4=identificador and c5=1;
	
	
		if totalReg = 0 then	
			cargos_xg = 0;
			abonos_xg = 0;
			iva_cargos_xg = 0;
			iva_abonos_xg = 0;
			saldado_xg := 0;
		 	insert into keplersc.kduxg (c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12)
			values(rec.c1,rec.c5,rec.c2,identificador,docpar_xg,
				cargos_xg,abonos_xg,iva_cargos_xg,iva_abonos_xg,saldado_xg,
				rec.c11,rec.c12);		--rec.c11(fecha_exp_xg) rec.c12(fecha_venc_xg)
			--raise notice 'INSERTA SUST KDUXG % % % % % % % % % %',rec.c1,rec.c5,rec.c2,identificador,docpar_xg,
			--	cargos_xg,abonos_xg,iva_cargos_xg,iva_abonos_xg,saldado_xg;
		else  
			update keplersc.kduxg set
				c6=cargos_xg,
				c7=abonos_xg,
				c8=iva_cargos_xg,
				c9=iva_abonos_xg,
				c10=saldado_xg
			where c1=rec.c1 and c2=rec.c5 and c3=rec.c2 and c4=identificador and c5=docpar_xg;
			--	raise notice 'ACTUALIZA SUSTITU SUST KDUXG  % % % % % % % % % %',rec.c1,rec.c5,rec.c2,identificador,docpar_xg,
			--	cargos_xg,abonos_xg,iva_cargos_xg,iva_abonos_xg,saldado_xg;
			
		end if; 
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cxcp_sustitucion_kduxg_baja() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
