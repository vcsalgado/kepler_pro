CREATE OR REPLACE FUNCTION keplersc.pld_crea_archivo(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Genera archivo PDL (prevencion lavado de dinero)
--Autor: Miriam Santana
--Fecha: 23/05/2023
--18/09/2024 Miriam Santana: No considerar KDCOMISMOV. Obtener informacion solo de KDVENTAS y enviar solamente las altas c10=0

	--Variables para xml 
	sucursal_id text;
	fecha_inicial date;
	fecha_final date;
	
	--Variables de uso general
	cve_tipo_ope text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo text = '';
	folio text = '';
	fecha_vale date;
	inventario text = '';
	tipo_movto text = '';
	tipo_operacion text = '';

	suc_vtas text = '';
	inv_vtas text = '';
	gen_vtas text = '';
	nat_vtas text = '';
	gpo_vtas text = '';
	tpo_vtas text = '';
	folio_vtas text = '';
	fecha_factura date;
	cve_cliente text = '';
	cve_vehiculo text = '';
	tipope_vtas text = '';
	marca text = '';
	nvo_us text = '';
	anio text = '';
	partida_vtas text;

	str_folio text = '';
	fecha text = '';
	sujeto_obligado text = '';
	codigo_postal text = '';
	str_tipo_ope text = '';
	desc_marca text = '';
	desc_vehiculo text = '';
	vin text = '';
	repuve text = '';
	rfc text = '';
	nombre_imp text = '';
	nombre text = '';
	ap_paterno text = '';			
	ap_materno text = '';
	colonia text = '';
	calle text = '';
	num_ext text = '';
	cod_postal text = '';
	correo text = '';
	telefono text = '';
	placas text = '';
	m_pago text = '';
	f_pago text = '';
	str_moneda text = '';

	strPld text = '';
	xmlPld text = '';
	expSql text ='';
	nombre_archivo text = '';
	strValor text ='';
	cont_linea int = 0;
	rec record;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;	
begin
	--Transaccion
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	strValor:=(xpath('//document/k_fecha_ini/text()', dataxml))[1];
	fecha_inicial:=to_date(strValor,'yyyy-mm-dd');
	strValor:=(xpath('//document/k_fecha_fin/text()', dataxml))[1];
	fecha_final:=to_date(strValor,'yyyy-mm-dd');	
--raise notice 'suc:%, fec_ini:%, fec_fin:%',sucursal_id,fecha_inicial,fecha_final;
	drop table if exists tmpResultados;
	create temp table tmpResultados (
		num_linea int,linea text);
	create index tmpResultados_num_linea_idx on tmpResultados (num_linea);

	select concat(trim(cf.c5),'PLD',trim(cf.c2),'.CSV') 
		into nombre_archivo
		from keplersc.kdcfdconfig cf
		where c1=sucursal_id;
			--raise notice 'archivo:%',nombre_archivo;
	for rec 
		in select * from keplersc.kdms where c1=sucursal_id
	loop 
			--raise notice 'Inicio loop suc';
	   	for cve_tipo_ope	
			in select c1 from keplersc.kdtop
		loop 
--raise notice 'Inicio loop de kdtop';			

		for suc_vtas,inv_vtas,partida_vtas,gen_vtas,nat_vtas,gpo_vtas,tpo_vtas,folio_vtas,fecha_factura,cve_cliente,cve_vehiculo,
			tipope_vtas,marca,nvo_us,anio
			in select c1,c2,c3,c4,c5,c6,c7,c8,c9,c11,c14,c17,c18,c19,c20
			from keplersc.kdventas where c1=sucursal_id and c17=cve_tipo_ope and c10=0 and c9>=fecha_inicial and c9<=fecha_final
			order by c1,c17,c9,c2,c3
		loop
--raise notice 'INICIA loop kdventas';			
			xmlPld := concat(format(
					'<document>
						<suc_vtas>%1$s</suc_vtas>
						<inv_vtas>%2$s</inv_vtas>
						<gen_vtas>%3$s</gen_vtas>
						<nat_vtas>%4$s</nat_vtas>
						<gpo_vtas>%5$s</gpo_vtas>
						<tpo_vtas>%6$s</tpo_vtas>
						<folio_vtas>%7$s</folio_vtas>
						<fecha_factura>%8$s</fecha_factura>
						<cve_cliente>%9$s</cve_cliente>
						<cve_vehiculo>%10$s</cve_vehiculo>
						<tipope_vtas>%11$s</tipope_vtas>
						<marca>%12$s</marca>
						<nvo_us>%13$s</nvo_us>
						<anio>%14$s</anio>
						<partida_vtas>%15$s</partida_vtas>								
					</document>',
					suc_vtas,inv_vtas,gen_vtas,nat_vtas,gpo_vtas,
					tpo_vtas,folio_vtas,fecha_factura,cve_cliente,cve_vehiculo,
					tipope_vtas,marca,nvo_us,anio,partida_vtas)); 
--raise notice 'CREA suc_vtas:% gen_vtas;% nat_vtas:% gpo_vtas:% tpo_vtas:% partida_vtas:% inv_vtas:%',
--suc_vtas,gen_vtas,nat_vtas,gpo_vtas,tpo_vtas,partida_vtas,inv_vtas;		
			select * into resultado, mensaje, adicionales from keplersc.pld_escribe_lineas(xmlPld::xml); 
			if resultado = '0' then
				raise exception '%',mensaje;
			end if; 
		end loop;
--raise notice 'Fin loop kdventas';	
		end loop;	--KDTOP
	end loop;	--KDMS
--raise notice 'Fin loop suc';
	strPld := '||FIN||';
	select coalesce(max(num_linea),0)+1 into cont_linea from tmpResultados;
	insert into tmpResultados (num_linea,linea)
				values(cont_linea,strPld);	
	
	expSql:= format('copy (select linea from tmpresultados order by num_linea) to %1$L',nombre_archivo);
	execute expSql;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;		
	
exception
	when others then
		resultado := 0;
		mensaje := 'pld_crea_archivo() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
