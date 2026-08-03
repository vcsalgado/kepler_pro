CREATE OR REPLACE FUNCTION keplersc.cfd_regenera_masivo(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Regenera de forma masiva xml de CFDI con la funcion CFD_CREA_ARCHIVO
--Autor: Miriam Santana
--Fecha: 27/12/2022
--Bitacora de cambios
--30/09/2025 Miriam Santana: Enviar datos necesarios para la aplicacion de anticipos y anulacion de cobros a la funcion de creacion de cfdi cfd_crea_archivo

	--Variables para xml 
	sucursal_id text;
	genero text='';
	naturaleza text='';
	grupo text='';
	tipo text='';
	folio_operacion text='';
	usuario text;
	uen text='';
	selreg text ='';
	cve_cteprov text='';
	validacfdi text='';
	datcfdi text='';
	
	expSql text;
	strValor text;
	no_partidas int=0;
	numero_partida int=0;
	xmlPartidas text;
	xmlKDMM xml;
	xmlKDM1 xml;
	folioxml xml;
	cfdiren int = 0;

	--MSS 30092025 Aplicacion de anticipos
	flag_cobros text = '';
	naturaleza_docto text = '';
	grupo_docto text = '0';
	tipo_docto text = '0';
	folio_docto text = '';
	importe decimal = 0.0;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	strerrores_gen text = '';

begin
	usuario := (xpath('//document/movimiento/usuario/text()', dataxml))[1];
	--Partidas
	strValor := (xpath('//document/tabla/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	
	--Procesar detalle
	
	for cont in 0..no_partidas - 1 loop
		uen:='';
		--Tipo de documento
		selreg := (xpath('//document/tabla/r' ||cont||'/seleccionar/text()',dataxml))[1];
		sucursal_id := (xpath('//document/tabla/r' ||cont||'/sucursal/text()',dataxml))[1];
		genero := (xpath('//document/tabla/r' ||cont||'/gen/text()',dataxml))[1];
		naturaleza := (xpath('//document/tabla/r' ||cont||'/nat/text()',dataxml))[1];
		grupo := (xpath('//document/tabla/r' ||cont||'/gpo/text()',dataxml))[1];
		tipo := (xpath('//document/tabla/r' ||cont||'/tipo/text()',dataxml))[1];
		folio_operacion := (xpath('//document/tabla/r' ||cont||'/folio/text()',dataxml))[1];
		cve_cteprov := (xpath('//document/tabla/r' ||cont||'/cliente/text()',dataxml))[1];
		validacfdi := (xpath('//document/tabla/r' ||cont||'/validacfdi/text()',dataxml))[1];
		strValor := substring(folio_operacion, 1,1);
		if selreg = 'S' then
		raise notice 'sel:% suc:% g:% n:% g:% t:% folio:% uen:%',selreg,sucursal_id,genero,naturaleza,grupo,tipo,folio_operacion,uen;
			if strValor = 'X' then 
				uen := 'XXX';
				elseif strValor = 'S' then 
					uen := 'SER';
				elseif strValor = 'R' then 
					uen := 'REF';
				elseif strValor = 'V' then 
					uen := 'VEN';
			end if;
			raise notice 'sel:% suc:% g:% n:% g:% t:% folio:% uen:%',selreg,sucursal_id,genero,naturaleza,grupo,tipo,folio_operacion,uen;
			--Obtener xml de KDM1 de registro generado 		
			expSql = 'select * from keplersc.kdm1 where' || 
				' c1=' || E'\'' || sucursal_id || E'\'' ||  
				' and c2=' || E'\'' || genero || E'\'' ||
				' and c3=' || E'\'' || naturaleza || E'\'' || 
				' and c4=' || grupo || 
				' and c5=' || tipo ||
			  	' and c6=' || E'\'' || folio_operacion || E'\'';
			select query_to_xml(expSql, true, false, '') into xmlKDM1;
		
			--Obtener xml de KDMM de documento 		
			expSql = 'select * from keplersc.kdmm where col_sucursal=' || E'\'' || sucursal_id || E'\'' || ' and c1='  || E'\'' || genero || E'\'' ||														
				' and c2=' || E'\'' || naturaleza || E'\'' || ' and c3=' || grupo || ' and c4=' || tipo;	
			select query_to_xml(expSql, true, false, '') into xmlKDMM;
			if validacfdi = 'Validado' then
				datcfdi := 'S';
			end if;	

			if genero = 'U' and naturaleza = 'A' and grupo = '81' then				--MSS 29092025 Enviar identificador y datos necesarios para aplicacion anticipos 
				--Obtener datos del folio por anexar
				select c16, c36, c37, c38, c39 into importe, naturaleza_docto, grupo_docto, tipo_docto, folio_docto
					from keplersc.kdm1 dm1 
					where dm1.c1=sucursal_id and dm1.c2=genero and dm1.c3=naturaleza and dm1.c4=grupo::integer and dm1.c5=tipo::integer and dm1.c6=folio_operacion;
				
				flag_cobros := 'APLICA_ANTICIPO';					
			end if;
		
			if genero = 'U' and naturaleza = 'D' and grupo = '32' then				--MSS 29092025 Enviar identificador de anulacion de cobros
				flag_cobros := 'ANULACION_COB';	
			end if;	
		
			xmlPartidas := format('<document>
										<k_sucn><r1>%1$s</r1></k_sucn>
										<k_tipon><r1>%2$s</r1></k_tipon>
										<k_tipon><r2>%3$s</r2></k_tipon>
										<k_tipon><r3>%4$s</r3></k_tipon>
										<k_tipon><r4>%5$s</r4></k_tipon>
										<k_clave>%8$s</k_clave>
										<datcfdi>%9$s</datcfdi>
										<k_monto>%11$s</k_monto>
										<k_natdocto>%12$s</k_natdocto>
										<k_gpodocto>%13$s</k_gpodocto>
										<k_tipodocto>%14$s</k_tipodocto>
										<k_foliodocto>%15$s</k_foliodocto>
										<movimiento><usuario>%6$s</usuario></movimiento>
										<ambiente><uen>%7$s</uen><flag_cobros>%10$s</flag_cobros></ambiente>
									</document>',
						         	sucursal_id,genero,naturaleza,grupo,tipo,usuario,uen,cve_cteprov,datcfdi,flag_cobros,importe,naturaleza_docto,grupo_docto,tipo_docto,folio_docto);
								         
			folioxml := xmlPartidas::xml; 
		raise notice '%',folioxml;

			--Por cada registro se llama la funcion para generar xml del cfdi
			select * into resultado, mensaje, adicionales from keplersc.cfd_crea_archivo(folioxml,xmlKDM1,xmlKDMM,folio_operacion);
			if resultado = '0' then
				--raise exception '%',mensaje;
				strerrores_gen := strerrores_gen || folio_operacion ||'-'|| mensaje || '~';
				continue;
			end if;	
			cfdiren := cfdiren + 1;
		end if;
	end loop;
		resultado := 1;
		mensaje := cfdiren;
		adicionales := strerrores_gen;
		return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cfd_regenera_masivo() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
