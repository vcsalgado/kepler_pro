CREATE OR REPLACE FUNCTION keplersc.cfd_datos_timbrado(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Obtiene datos del timbrado de los cfdi 
--Autor: Miriam Santana
--Fecha: 19/05/2025
--Bitacora de cambios
declare 
	
	--Variables para xml 
	sucursal_id text;
	genero text='';
	naturaleza text='';
	grupo text='';
	tipo text='';
	folio_operacion text='';
	dato_consulta text = '';

	reckdm1 record;
	totreg int;	
	fecha_implementacion date;
	fecha_factura date;
	
	id_certificado text;
	folio text = '';
	consRes text ='';
	expSql text= '';

	--Variables de retorno
	resultado text ='0';
	mensaje text ='';
	adicionales text ='';

begin
	sucursal_id := (xpath('//document/sucursal/text()',dataxml))[1];
	genero := (xpath('//document/genero/text()',dataxml))[1];
	naturaleza := (xpath('//document/naturaleza/text()',dataxml))[1];
	grupo := (xpath('//document/grupo/text()',dataxml))[1];
	tipo := (xpath('//document/tipo/text()',dataxml))[1];
	folio_operacion := (xpath('//document/folio/text()',dataxml))[1];
	dato_consulta := (xpath('//document/dato_consulta/text()',dataxml))[1];

	select c6 into fecha_implementacion from keplersc.kdcfdconfig
		where c1=sucursal_id;
	
	select c9 into fecha_factura from keplersc.kdm1
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4 =grupo::integer and c5=tipo::integer and c6=folio_operacion;
raise notice 'folio:% fec_fact:% fec_impl:%', folio_operacion,fecha_factura,fecha_implementacion;	
	id_certificado := concat(sucursal_id,'-',genero,naturaleza,lpad(grupo::text,2,'0'),lpad(tipo::text,3,'0'),'-');
	if fecha_factura < fecha_implementacion then
		folio := concat(substring(folio_operacion,2,2),right(folio_operacion,5));
		id_certificado := concat(id_certificado,folio);
	else
		id_certificado := concat(id_certificado,folio_operacion);
	end if;

	expSql= format('select "%1$s" from keplersc.cert_timbres
					where "idCertificado"=%2$L',
					dato_consulta,id_certificado);	
raise notice '%', expSql;
execute expSql into consRes;
	
	resultado:= 1;
	mensaje:=consRes;
	adicionales:= '';
raise notice '%', mensaje;
	--Retorno tipo tabla
	return query select resultado, mensaje, adicionales;

EXCEPTION
	WHEN others then
		--Retorno tipo tabla
		resultado := '0';
		mensaje := sqlerrm;
		adicionales:= sqlerrm;
		return query select resultado, mensaje, adicionales;
end;
$function$
